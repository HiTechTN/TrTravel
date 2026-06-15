import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheManager extends ChangeNotifier {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  final Map<String, _CacheEntry> _memoryCache = {};
  SharedPreferences? _prefs;
  static const int _maxMemoryItems = 200;
  static const Duration _defaultTTL = Duration(hours: 24);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<T?> get<T>(String key, {T Function(Map<String, dynamic>)? fromJson}) async {
    final entry = _memoryCache[key];
    if (entry != null) {
      if (entry.isExpired) {
        _memoryCache.remove(key);
      } else {
        if (entry.value is T) return entry.value as T;
        if (fromJson != null && entry.rawJson != null) {
          return fromJson(entry.rawJson!);
        }
      }
    }

    final diskKey = 'cache_$key';
    final diskValue = _prefs?.getString(diskKey);
    if (diskValue != null) {
      try {
        final data = json.decode(diskValue);
        final cachedAt = DateTime.tryParse(data['_ct'] ?? '');
        final ttlSeconds = data['_ttl'] ?? 86400;
        if (cachedAt != null && DateTime.now().difference(cachedAt).inSeconds > ttlSeconds) {
          await _prefs?.remove(diskKey);
        } else {
          if (data['v'] is T) {
            _memoryCache[key] = _CacheEntry(data['v'], DateTime.now(), ttlSeconds: ttlSeconds);
            return data['v'];
          }
          if (fromJson != null) {
            final result = fromJson(data);
            _memoryCache[key] = _CacheEntry(result, DateTime.now(), ttlSeconds: ttlSeconds, rawJson: data);
            return result;
          }
        }
        } catch (e) {
          debugPrint('CacheManager: error prefetching key $key: $e');
        }
    }
    return null;
  }

  Future<void> set<T>(String key, T value, {Duration? ttl, Map<String, dynamic>? rawJson}) async {
    final ttlSeconds = ttl?.inSeconds ?? _defaultTTL.inSeconds;
    final entry = _CacheEntry(value, DateTime.now(), ttlSeconds: ttlSeconds, rawJson: rawJson);
    _memoryCache[key] = entry;

    if (_memoryCache.length > _maxMemoryItems) {
      _evictOldest();
    }

    final diskKey = 'cache_$key';
    final data = rawJson ?? (value is Map ? value as Map<String, dynamic> : {'v': value});
    data['_ct'] = DateTime.now().toIso8601String();
    data['_ttl'] = ttlSeconds;
    await _prefs?.setString(diskKey, json.encode(data));
  }

  Future<void> invalidate(String key) async {
    _memoryCache.remove(key);
    await _prefs?.remove('cache_$key');
    notifyListeners();
  }

  Future<void> prefetch(List<String> keys) async {
    for (final key in keys) {
      final diskKey = 'cache_$key';
      if (!_memoryCache.containsKey(key) && _prefs?.containsKey(diskKey) == true) {
        try {
          final diskValue = _prefs!.getString(diskKey)!;
          final data = json.decode(diskValue);
          _memoryCache[key] = _CacheEntry(null, DateTime.now(), ttlSeconds: 86400, rawJson: data);
      } catch (e) {
        debugPrint('CacheManager: error reading disk cache for key $key: $e');
      }
      }
    }
  }

  void _evictOldest() {
    String? oldestKey;
    DateTime? oldest;
    for (final e in _memoryCache.entries) {
      if (oldest == null || e.value.cachedAt.isBefore(oldest)) {
        oldest = e.value.cachedAt;
        oldestKey = e.key;
      }
    }
    if (oldestKey != null) _memoryCache.remove(oldestKey);
  }

  Future<int> getCacheSize() async {
    int size = 0;
    for (final key in _prefs!.getKeys()) {
      if (key.startsWith('cache_')) {
        size += (_prefs!.getString(key)?.length ?? 0);
      }
    }
    return size;
  }

  Future<void> clearMemory() async {
    _memoryCache.clear();
    notifyListeners();
  }

  int get _memorySize => _memoryCache.length;
}

class _CacheEntry {
  final dynamic value;
  final DateTime cachedAt;
  final int ttlSeconds;
  final Map<String, dynamic>? rawJson;

  _CacheEntry(this.value, this.cachedAt, {required this.ttlSeconds, this.rawJson});

  bool get isExpired => DateTime.now().difference(cachedAt).inSeconds > ttlSeconds;
}

abstract class LazyLoadItem {
  Future<dynamic> load();
  bool get isLoaded;
}

class ImageCache {
  static final Map<String, dynamic> _cache = {};
  static const int _maxItems = 50;

  static void put(String key, dynamic image) {
    if (_cache.length > _maxItems) {
      final keys = _cache.keys.toList();
      for (int i = 0; i < 10; i++) {
        _cache.remove(keys[i]);
      }
    }
    _cache[key] = image;
  }

  static dynamic get(String key) => _cache[key];

  static void clear() => _cache.clear();
}

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() => _timer?.cancel();
}

class Throttler {
  final Duration delay;
  DateTime? _lastRun;

  Throttler({this.delay = const Duration(milliseconds: 500)});

  bool canRun() {
    final now = DateTime.now();
    if (_lastRun == null || now.difference(_lastRun!) > delay) {
      _lastRun = now;
      return true;
    }
    return false;
  }
}