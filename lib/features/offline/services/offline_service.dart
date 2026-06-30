import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:trtravel/core/services/local_storage.dart';
import 'package:trtravel/features/offline/models/offline_models.dart';

class OfflineService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  final List<OfflineQueueItem> _queue = [];
  final List<CacheEntry> _cache = [];
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  static const String _queueKey = 'offline_sync_queue';
  static const String _cacheKey = 'offline_cache';
  static const int _maxRetries = 3;
  static const Duration _cacheTtl = Duration(hours: 24);

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  int get pendingCount => _queue.where((q) => q.status == QueueStatus.pending).length;
  int get failedCount => _queue.where((q) => q.status == QueueStatus.failed).length;
  int get syncingCount => _queue.where((q) => q.status == QueueStatus.syncing).length;
  int get totalQueueCount => _queue.length;

  List<OfflineQueueItem> get queue => List.unmodifiable(_queue);

  final StreamController<QueueStatus> _syncStatusController = StreamController<QueueStatus>.broadcast();
  Stream<QueueStatus> get syncStatusStream => _syncStatusController.stream;

  OfflineService() {
    _load();
    _initConnectivity();
  }

  void _load() {
    final queueJson = LocalStorage.getJsonList(_queueKey);
    if (queueJson != null) {
      _queue.addAll(queueJson.map((j) => OfflineQueueItem.fromJson(j)));
    }
    final cacheJson = LocalStorage.getJsonList(_cacheKey);
    if (cacheJson != null) {
      _cache.addAll(cacheJson.map((j) => CacheEntry.fromJson(j)));
      _cache.removeWhere((e) => e.isExpired);
    }
  }

  void _saveQueue() {
    final list = _queue.map((q) => q.toJson()).toList();
    LocalStorage.setJsonList(_queueKey, list);
  }

  void _saveCache() {
    final list = _cache.map((c) => c.toJson()).toList();
    LocalStorage.setJsonList(_cacheKey, list);
  }

  void _initConnectivity() {
    _connectivity.checkConnectivity().then((results) {
      _updateConnectivityStatus(results);
    });

    _connectivitySub = _connectivity.onConnectivityChanged.listen((results) {
      _updateConnectivityStatus(results);
    });
  }

  void _updateConnectivityStatus(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _isOnline = results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet);

    if (_isOnline != wasOnline) {
      notifyListeners();
    }

    if (_isOnline && !wasOnline) {
      processQueue();
    }
  }

  Future<bool> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _isOnline = results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet);
    notifyListeners();
    return _isOnline;
  }

  void addToQueue(OfflineQueueItem item) {
    _queue.add(item);
    _saveQueue();
    notifyListeners();

    if (_isOnline) {
      processQueue();
    }
  }

  Future<void> processQueue() async {
    if (_isSyncing || _queue.isEmpty) return;

    _isSyncing = true;
    notifyListeners();
    _syncStatusController.add(QueueStatus.syncing);

    final pendingItems = _queue.where((q) => q.status == QueueStatus.pending).toList();

    for (final item in pendingItems) {
      final index = _queue.indexWhere((q) => q.id == item.id);
      if (index == -1) continue;

      _queue[index] = item.copyWith(status: QueueStatus.syncing);
      _saveQueue();
      notifyListeners();

      try {
        await _syncItem(item);
        _queue[index] = item.copyWith(status: QueueStatus.pending);
        _queue.removeAt(index);
        _saveQueue();
        notifyListeners();
      } catch (e) {
        final newRetry = item.retryCount + 1;
        if (newRetry >= _maxRetries) {
          _queue[index] = item.copyWith(status: QueueStatus.failed, retryCount: newRetry);
        } else {
          _queue[index] = item.copyWith(status: QueueStatus.pending, retryCount: newRetry);
        }
        _saveQueue();
        notifyListeners();
      }
    }

    _isSyncing = false;
    notifyListeners();

    final hasFailed = _queue.any((q) => q.status == QueueStatus.failed);
    _syncStatusController.add(hasFailed ? QueueStatus.failed : QueueStatus.pending);
  }

  Future<void> _syncItem(OfflineQueueItem item) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void retryFailed() {
    for (int i = 0; i < _queue.length; i++) {
      if (_queue[i].status == QueueStatus.failed) {
        _queue[i] = _queue[i].copyWith(status: QueueStatus.pending, retryCount: 0);
      }
    }
    _saveQueue();
    notifyListeners();
    processQueue();
  }

  void clearQueue() {
    _queue.clear();
    _saveQueue();
    notifyListeners();
  }

  void cacheResponse(String key, Map<String, dynamic> data, {Duration? ttl}) {
    _cache.removeWhere((e) => e.key == key);
    _cache.add(CacheEntry(
      key: key,
      data: data,
      expiry: DateTime.now().add(ttl ?? _cacheTtl),
    ));
    _saveCache();
  }

  Map<String, dynamic>? getCachedResponse(String key) {
    try {
      final entry = _cache.firstWhere((e) => e.key == key);
      if (entry.isExpired) {
        _cache.remove(entry);
        _saveCache();
        return null;
      }
      return entry.data;
    } catch (_) {
      return null;
    }
  }

  void clearCache() {
    _cache.clear();
    _saveCache();
    notifyListeners();
  }

  int get cacheSize {
    int total = 0;
    for (final entry in _cache) {
      final json = entry.toJson();
      total += json.toString().length;
    }
    return total;
  }

  String getCacheSizeFormatted() {
    final bytes = cacheSize;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _syncStatusController.close();
    super.dispose();
  }
}
