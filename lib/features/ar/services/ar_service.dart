import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:trtravel/core/services/local_storage.dart';
import 'package:trtravel/core/services/logger.dart';
import 'package:trtravel/features/ar/models/ar_models.dart';

class ARService extends ChangeNotifier {
  List<ARLandmark> _landmarks = [];
  List<String> _visitedLandmarks = [];
  ARTrackingSession? _currentSession;
  final bool _isLoading = false;
  double _currentLatitude = 41.0082;
  double _currentLongitude = 28.9784;

  List<ARLandmark> get landmarks => List.unmodifiable(_landmarks);
  List<String> get visitedLandmarks => List.unmodifiable(_visitedLandmarks);
  ARTrackingSession? get currentSession => _currentSession;
  bool get isLoading => _isLoading;

  ARService() {
    _load();
  }

  void _load() {
    final jsonList = LocalStorage.getJsonList('ar_visited_landmarks');
    if (jsonList != null) {
      _visitedLandmarks = jsonList.map((j) => j['id'] as String).toList();
    }
    _loadLandmarksFromBundle();
  }

  Future<void> _loadLandmarksFromBundle() async {
    try {
      final jsonString = await rootBundle.loadString('assets/itinerary.json');
      final data = jsonDecode(jsonString) as List;
      final generated = <ARLandmark>[];
      final seen = <String>{};
      int index = 0;

      for (final day in data) {
        final location = (day['location'] as String?) ?? '';
        final activities = (day['activities'] as List?) ?? [];
        for (final act in activities) {
          final desc = (act['description'] as String?) ?? '';
          final key = desc.toLowerCase();
          if (!seen.contains(key) && desc.length > 5) {
            seen.add(key);
            generated.add(ARLandmark(
              id: 'landmark_${index++}',
              name: _extractName(desc),
              description: desc,
              latitude: _getLatitudeForLocation(location),
              longitude: _getLongitudeForLocation(location),
              category: _categorize(desc),
              distance: 0,
            ));
          }
        }
      }

      if (generated.isEmpty) {
        _landmarks = _defaultLandmarks();
      } else {
        _landmarks = generated;
      }
      notifyListeners();
    } catch (e) {
      LogService.warning('ARService', 'Failed to load landmarks from bundle: $e');
      _landmarks = _defaultLandmarks();
      notifyListeners();
    }
  }

  String _extractName(String desc) {
    final clean = desc.replaceAll(RegExp(r'[:\-].*$'), '').trim();
    final words = clean.split(' ');
    if (words.length > 5) {
      return words.take(5).join(' ');
    }
    return clean;
  }

  String _categorize(String desc) {
    final lower = desc.toLowerCase();
    if (lower.contains('mosquée') || lower.contains('mosque')) return 'mosquée';
    if (lower.contains('musée') || lower.contains('museum')) return 'musée';
    if (lower.contains('plage') || lower.contains('beach')) return 'plage';
    if (lower.contains('marché') || lower.contains('bazar') || lower.contains('shopping') || lower.contains('mall')) return 'shopping';
    if (lower.contains('restaurant') || lower.contains('café') || lower.contains('diner') || lower.contains('déjeuner') || lower.contains('manger')) return 'restaurant';
    if (lower.contains('parc') || lower.contains('jardin')) return 'parc';
    if (lower.contains('port') || lower.contains('marina')) return 'port';
    if (lower.contains('tour') || lower.contains('chute') || lower.contains('cascade')) return 'nature';
    return 'monument';
  }

  double _getLatitudeForLocation(String location) {
    final lower = location.toLowerCase();
    if (lower.contains('istanbul')) return 41.0082;
    if (lower.contains('antalya')) return 36.8969;
    if (lower.contains('kaleiçi') || lower.contains('kaleici')) return 36.8872;
    if (lower.contains('konyaaltı') || lower.contains('konyaalti')) return 36.8667;
    if (lower.contains('lara')) return 36.8550;
    if (lower.contains('çıralı') || lower.contains('cirali') || lower.contains('çirali')) return 36.4036;
    if (lower.contains('düden') || lower.contains('duden')) return 36.9150;
    if (lower.contains('köprülü') || lower.contains('koprulu') || lower.contains('kanon')) return 37.2000;
    if (lower.contains('taksim')) return 41.0370;
    if (lower.contains('galata')) return 41.0256;
    if (lower.contains('üsküdar') || lower.contains('uskudar')) return 41.0267;
    if (lower.contains('ortaköy') || lower.contains('ortakoy')) return 41.0472;
    if (lower.contains('karaköy') || lower.contains('karakoy')) return 41.0235;
    return 39.9208;
  }

  double _getLongitudeForLocation(String location) {
    final lower = location.toLowerCase();
    if (lower.contains('istanbul')) return 28.9784;
    if (lower.contains('antalya')) return 30.7133;
    if (lower.contains('kaleiçi') || lower.contains('kaleici')) return 30.7067;
    if (lower.contains('konyaaltı') || lower.contains('konyaalti')) return 30.6361;
    if (lower.contains('lara')) return 30.8150;
    if (lower.contains('çıralı') || lower.contains('cirali') || lower.contains('çirali')) return 30.4744;
    if (lower.contains('düden') || lower.contains('duden')) return 30.7986;
    if (lower.contains('köprülü') || lower.contains('koprulu') || lower.contains('kanon')) return 31.2000;
    if (lower.contains('taksim')) return 28.9850;
    if (lower.contains('galata')) return 28.9740;
    if (lower.contains('üsküdar') || lower.contains('uskudar')) return 29.0167;
    if (lower.contains('ortaköy') || lower.contains('ortakoy')) return 29.0247;
    if (lower.contains('karaköy') || lower.contains('karakoy')) return 28.9778;
    return 32.8541;
  }

  List<ARLandmark> _defaultLandmarks() {
    return [
      ARLandmark(id: 'lm_ist_1', name: 'Sainte-Sophie', description: 'Mosquée et ancienne basilique emblématique d\'Istanbul', latitude: 41.0086, longitude: 28.9802, category: 'mosquée'),
      ARLandmark(id: 'lm_ist_2', name: 'Mosquée Bleue', description: 'Mosquée historique aux six minarets', latitude: 41.0054, longitude: 28.9768, category: 'mosquée'),
      ARLandmark(id: 'lm_ist_3', name: 'Tour de Galata', description: 'Tour médiévale offrant une vue panoramique', latitude: 41.0256, longitude: 28.9741, category: 'monument'),
      ARLandmark(id: 'lm_ist_4', name: 'Grand Bazar', description: 'Marché couvert historique', latitude: 41.0107, longitude: 28.9680, category: 'shopping'),
      ARLandmark(id: 'lm_ant_1', name: 'Porte d\'Hadrien', description: 'Arc de triomphe romain du IIe siècle', latitude: 36.8872, longitude: 30.7067, category: 'monument'),
      ARLandmark(id: 'lm_ant_2', name: 'Tour d\'Hidirlik', description: 'Tour romaine de la vieille ville', latitude: 36.8853, longitude: 30.7050, category: 'monument'),
      ARLandmark(id: 'lm_ant_3', name: 'Plage de Konyaaltı', description: 'Plage de galets avec vue sur les montagnes', latitude: 36.8667, longitude: 30.6361, category: 'plage'),
      ARLandmark(id: 'lm_ant_4', name: 'Chutes de Düden', description: 'Cascades spectaculaires se jetant dans la mer', latitude: 36.9150, longitude: 30.7986, category: 'nature'),
      ARLandmark(id: 'lm_ant_5', name: 'The Land of Legends', description: 'Parc d\'attractions et aquarium', latitude: 36.8200, longitude: 30.8820, category: 'parc'),
      ARLandmark(id: 'lm_ant_6', name: 'Köprülü Canyon', description: 'Parc national avec rafting et canyoning', latitude: 37.2000, longitude: 31.2000, category: 'nature'),
      ARLandmark(id: 'lm_ant_7', name: 'Çıralı Beach', description: 'Plage sauvage et site des flammes de Chimaera', latitude: 36.4036, longitude: 30.4744, category: 'plage'),
    ];
  }

  void updateLocation(double lat, double lng) {
    _currentLatitude = lat;
    _currentLongitude = lng;
    notifyListeners();
  }

  List<ARLandmark> getNearbyLandmarks({double radiusKm = 50, int maxResults = 20}) {
    final nearby = <ARLandmark>[];
    for (final lm in _landmarks) {
      final distance = _calculateDistance(_currentLatitude, _currentLongitude, lm.latitude, lm.longitude);
      if (distance <= radiusKm) {
        nearby.add(ARLandmark(
          id: lm.id,
          name: lm.name,
          description: lm.description,
          latitude: lm.latitude,
          longitude: lm.longitude,
          imageUrl: lm.imageUrl,
          category: lm.category,
          distance: distance,
        ));
      }
    }
    nearby.sort((a, b) => a.distance.compareTo(b.distance));
    return nearby.take(maxResults).toList();
  }

  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    final a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat1)) * _cos(_toRadians(lat2)) * _sin(dLng / 2) * _sin(dLng / 2);
    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double deg) => deg * (3.141592653589793 / 180);
  double _sin(double x) => x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  double _cos(double x) => 1 - (x * x) / 2 + (x * x * x * x) / 24;
  double _atan2(double y, double x) => y == 0 ? (x >= 0 ? 0 : 3.141592653589793) : (x >= 0 ? _sqrt(1 - x * x) / x : 0);
  double _sqrt(double x) => x <= 0 ? 0 : x / (1 + (x - 1) / 2);

  ARLandmark? getLandmarkById(String id) {
    try {
      return _landmarks.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  void markVisited(String landmarkId) {
    if (!_visitedLandmarks.contains(landmarkId)) {
      _visitedLandmarks.add(landmarkId);
      _saveVisited();
      notifyListeners();
    }
  }

  bool isVisited(String landmarkId) => _visitedLandmarks.contains(landmarkId);

  void startSession() {
    _currentSession = ARTrackingSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    notifyListeners();
  }

  void endSession() {
    if (_currentSession != null) {
      _currentSession = ARTrackingSession(
        id: _currentSession!.id,
        startTime: _currentSession!.startTime,
        recognizedLandmarks: _currentSession!.recognizedLandmarks,
        totalScans: _currentSession!.totalScans,
        isActive: false,
      );
      notifyListeners();
    }
  }

  void recordScan(String landmarkId) {
    if (_currentSession == null) return;
    final recognized = List<String>.from(_currentSession!.recognizedLandmarks);
    if (!recognized.contains(landmarkId)) {
      recognized.add(landmarkId);
    }
    _currentSession = ARTrackingSession(
      id: _currentSession!.id,
      startTime: _currentSession!.startTime,
      recognizedLandmarks: recognized,
      totalScans: _currentSession!.totalScans + 1,
      isActive: _currentSession!.isActive,
    );
    markVisited(landmarkId);
    notifyListeners();
  }

  void _saveVisited() {
    LocalStorage.setJsonList('ar_visited_landmarks',
      _visitedLandmarks.map((id) => {'id': id}).toList());
  }
}
