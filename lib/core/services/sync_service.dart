import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:trtravel/core/services/local_storage.dart';
import 'package:trtravel/core/services/auth_service.dart';
import 'package:trtravel/core/services/logger.dart';

enum SyncStatus { idle, syncing, success, error }

class SyncService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService;
  bool _isSyncing = false;
  bool _isEnabled = false;
  DateTime? _lastSync;
  SyncStatus _status = SyncStatus.idle;
  String? _lastError;
  final StreamController<SyncStatus> _statusController = StreamController<SyncStatus>.broadcast();
  StreamSubscription? _connectivitySubscription;
  static const int _maxRetries = 3;

  bool get isSyncing => _isSyncing;
  bool get isEnabled => _isEnabled;
  DateTime? get lastSync => _lastSync;
  SyncStatus get status => _status;
  String? get lastError => _lastError;
  Stream<SyncStatus> get statusStream => _statusController.stream;

  SyncService(this._authService) {
    _isEnabled = LocalStorage.getBool('cloud_sync') ?? false;
    _authService.addListener(_onAuthChanged);
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection && _isEnabled && _authService.isAuthenticated) {
        syncAll();
      }
    });
  }

  void _onAuthChanged() {
    if (_authService.isAuthenticated) {
      _isEnabled = true;
      LocalStorage.setBool('cloud_sync', true);
      syncAll();
    } else {
      _isEnabled = false;
    }
  }

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    LocalStorage.setBool('cloud_sync', enabled);
    if (enabled && _authService.isAuthenticated) {
      syncAll();
    }
    notifyListeners();
  }

  Future<void> syncAll() async {
    if (!_isEnabled || !_authService.isAuthenticated) return;
    if (_isSyncing) return;

    _isSyncing = true;
    _status = SyncStatus.syncing;
    _statusController.add(_status);
    notifyListeners();

    await _syncWithRetry();

    _isSyncing = false;
    notifyListeners();
  }

  Future<void> _syncWithRetry() async {
    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        await Future.wait([
          _syncData('journal_entries', 'journal'),
          _syncData('budget_expenses', 'budget'),
          _syncData('itinerary_trips', 'itinerary'),
          _syncSettings(),
        ]);
        _lastSync = DateTime.now();
        _lastError = null;
        _status = SyncStatus.success;
        LocalStorage.setString('last_sync', _lastSync!.toIso8601String());
        _statusController.add(_status);
        return;
      } catch (e) {
        _lastError = e.toString();
        LogService.error('Sync', 'Échec de la synchronisation (tentative ${attempt + 1}/$_maxRetries)', e);
        if (attempt < _maxRetries) {
          await Future.delayed(Duration(seconds: (attempt + 1) * 2));
        }
      }
    }
    _status = SyncStatus.error;
    _statusController.add(_status);
  }

  Future<void> _syncData(String localKey, String firestoreCollection) async {
    final userId = _authService.userId;
    if (userId == null) return;

    final localData = LocalStorage.getJsonList(localKey);
    final localTimestamp = LocalStorage.getString('${localKey}_timestamp');

    final cloudDocRef = _firestore
        .collection('users')
        .doc(userId)
        .collection(firestoreCollection)
        .doc('user_data');

    final cloudSnapshot = await cloudDocRef.get();
    final cloudData = cloudSnapshot.exists
        ? (cloudSnapshot.data()?['data'] as List?)
        : null;
    final cloudTimestamp = cloudSnapshot.exists
        ? (cloudSnapshot.data()?['updatedAt'] as Timestamp?)?.toDate().toIso8601String()
        : null;

    if (localData != null && cloudData != null) {
      if (localTimestamp != null && cloudTimestamp != null) {
        if (localTimestamp.compareTo(cloudTimestamp) >= 0) {
          await cloudDocRef.set({
            'data': localData,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          LocalStorage.setJsonList(localKey, cloudData.cast<Map<String, dynamic>>());
        }
      } else {
        await cloudDocRef.set({
          'data': localData,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } else if (localData != null) {
      await cloudDocRef.set({
        'data': localData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else if (cloudData != null) {
      LocalStorage.setJsonList(localKey, cloudData.cast<Map<String, dynamic>>());
    }
  }

  Future<void> pullFromCloud() async {
    if (!_authService.isAuthenticated) return;

    _isSyncing = true;
    _status = SyncStatus.syncing;
    _statusController.add(_status);
    notifyListeners();

    try {
      await Future.wait([
        _pullData('journal_entries', 'journal'),
        _pullData('budget_expenses', 'budget'),
        _pullData('itinerary_trips', 'itinerary'),
        _pullSettings(),
      ]);
      _lastSync = DateTime.now();
      _lastError = null;
      _status = SyncStatus.success;
      _statusController.add(_status);
    } catch (e) {
      _lastError = e.toString();
      _status = SyncStatus.error;
      LogService.error('Sync', 'Échec de la récupération', e);
      _statusController.add(_status);
    }

    _isSyncing = false;
    notifyListeners();
  }

  Future<void> _syncSettings() async {
    final userId = _authService.userId;
    if (userId == null) return;

    final keys = ['offline_mode', 'dark_mode', 'notifications', 'language', 'currency_from', 'currency_to'];
    final settings = <String, dynamic>{};
    for (final key in keys) {
      final val = LocalStorage.getString(key) ?? LocalStorage.getBool(key)?.toString();
      if (val != null) settings[key] = val;
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('preferences')
        .set({'data': settings, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> _pullSettings() async {
    final userId = _authService.userId;
    if (userId == null) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('preferences')
        .get();

    if (snapshot.exists) {
      final data = snapshot.data()?['data'] as Map<String, dynamic>?;
      if (data != null) {
        for (final entry in data.entries) {
          LocalStorage.setString(entry.key, entry.value.toString());
        }
      }
    }
  }

  Future<void> _pullData(String localKey, String firestoreCollection) async {
    final userId = _authService.userId;
    if (userId == null) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection(firestoreCollection)
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final listData = data['data'] as List?;
      if (listData != null) {
        LocalStorage.setJsonList(localKey, listData.cast<Map<String, dynamic>>());
      }
    }
  }

  Future<String?> exportAllData() async {
    try {
      final data = {
        'journal_entries': LocalStorage.getJsonList('journal_entries') ?? [],
        'budget_expenses': LocalStorage.getJsonList('budget_expenses') ?? [],
        'itinerary_trips': LocalStorage.getJsonList('itinerary_trips') ?? [],
        'settings': {
          'offline_mode': LocalStorage.getBool('offline_mode'),
          'dark_mode': LocalStorage.getBool('dark_mode'),
          'notifications': LocalStorage.getBool('notifications'),
          'language': LocalStorage.getString('language'),
        },
        'exported_at': DateTime.now().toIso8601String(),
        'version': '3.1.0',
      };
      return jsonEncode(data);
    } catch (e) {
      LogService.error('Sync', 'Échec de l\'exportation', e);
      return null;
    }
  }

  Future<bool> importData(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      if (data['version'] == null) return false;

      if (data['journal_entries'] is List) {
        LocalStorage.setJsonList('journal_entries', (data['journal_entries'] as List).cast<Map<String, dynamic>>());
      }
      if (data['budget_expenses'] is List) {
        LocalStorage.setJsonList('budget_expenses', (data['budget_expenses'] as List).cast<Map<String, dynamic>>());
      }
      if (data['itinerary_trips'] is List) {
        LocalStorage.setJsonList('itinerary_trips', (data['itinerary_trips'] as List).cast<Map<String, dynamic>>());
      }
      if (data['settings'] is Map) {
        final settings = data['settings'] as Map<String, dynamic>;
        for (final entry in settings.entries) {
          if (entry.value != null) {
            LocalStorage.setString(entry.key, entry.value.toString());
          }
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      LogService.error('Sync', 'Échec de l\'importation', e);
      return false;
    }
  }

  Future<bool> backupToCloud() async {
    if (!_authService.isAuthenticated) return false;
    try {
      final json = await exportAllData();
      if (json == null) return false;

      final userId = _authService.userId;
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('backups')
          .doc('backup_${DateTime.now().millisecondsSinceEpoch}')
          .set({
        'data': json,
        'createdAt': FieldValue.serverTimestamp(),
        'version': '3.1.0',
      });
      return true;
    } catch (e) {
      LogService.error('Sync', 'Échec de la sauvegarde cloud', e);
      return false;
    }
  }

  Future<bool> restoreFromCloud(String backupId) async {
    if (!_authService.isAuthenticated) return false;
    try {
      final userId = _authService.userId;
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('backups')
          .doc(backupId)
          .get();

      if (!snapshot.exists) return false;
      final jsonStr = snapshot.data()?['data'] as String?;
      if (jsonStr == null) return false;

      return importData(jsonStr);
    } catch (e) {
      LogService.error('Sync', 'Échec de la restauration cloud', e);
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getBackups() async {
    if (!_authService.isAuthenticated) return [];
    try {
      final userId = _authService.userId;
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('backups')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => {
        'id': doc.id,
        'createdAt': (doc.data()['createdAt'] as Timestamp?)?.toDate().toIso8601String() ?? '',
        'version': doc.data()['version'] as String? ?? '',
      }).toList();
    } catch (e) {
      LogService.error('Sync', 'Échec du listage des sauvegardes', e);
      return [];
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _statusController.close();
    super.dispose();
  }
}
