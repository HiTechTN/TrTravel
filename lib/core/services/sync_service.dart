import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trtravel/core/services/local_storage.dart';
import 'package:trtravel/core/services/auth_service.dart';
import 'package:trtravel/core/services/logger.dart';

class SyncService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService;
  bool _isSyncing = false;
  bool _isEnabled = false;
  DateTime? _lastSync;

  bool get isSyncing => _isSyncing;
  bool get isEnabled => _isEnabled;
  DateTime? get lastSync => _lastSync;

  SyncService(this._authService) {
    _isEnabled = LocalStorage.getBool('cloud_sync') ?? false;
    _authService.addListener(_onAuthChanged);
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
    notifyListeners();

    try {
      await Future.wait([
        _syncData('journal_entries', 'journal'),
        _syncData('budget_expenses', 'budget'),
        _syncData('itinerary_trips', 'itinerary'),
        _syncSettings(),
      ]);
      _lastSync = DateTime.now();
      LocalStorage.setString('last_sync', _lastSync!.toIso8601String());
    } catch (e) {
      LogService.error('Sync', 'Failed to sync data', e);
    }

    _isSyncing = false;
    notifyListeners();
  }

  Future<void> _syncData(String localKey, String firestoreCollection) async {
    final userId = _authService.userId;
    if (userId == null) return;

    final localData = LocalStorage.getJsonList(localKey);
    if (localData != null) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(firestoreCollection)
          .doc('user_data')
          .set({'data': localData, 'updatedAt': FieldValue.serverTimestamp()});
    }

    final cloudDoc = await _firestore
        .collection('users')
        .doc(userId)
        .collection(firestoreCollection)
        .get();

    if (cloudDoc.docs.isNotEmpty) {
      final cloudData = cloudDoc.docs.first.data()['data'] as List?;
      if (cloudData != null && localData == null) {
        LocalStorage.setJsonList(localKey, cloudData.cast<Map<String, dynamic>>());
      }
    }
  }

  Future<void> pullFromCloud() async {
    if (!_authService.isAuthenticated) return;
    _isSyncing = true;
    notifyListeners();

    try {
      await Future.wait([
        _pullData('journal_entries', 'journal'),
        _pullData('budget_expenses', 'budget'),
        _pullData('itinerary_trips', 'itinerary'),
        _pullSettings(),
      ]);
      _lastSync = DateTime.now();
    } catch (e) {
      LogService.error('Sync', 'Failed to pull data', e);
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
}
