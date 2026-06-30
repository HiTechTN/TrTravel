import 'package:flutter/foundation.dart';
import 'package:trtravel/core/services/local_storage.dart';

class MapRegion {
  final String name;
  final String id;
  final double latMin;
  final double latMax;
  final double lngMin;
  final double lngMax;
  final String size;

  const MapRegion({
    required this.name,
    required this.id,
    required this.latMin,
    required this.latMax,
    required this.lngMin,
    required this.lngMax,
    this.size = '~25 MB',
  });
}

class OfflineMapService extends ChangeNotifier {
  final List<MapRegion> _regions = const [
    MapRegion(name: 'Istanbul Centre', id: 'istanbul', latMin: 40.98, latMax: 41.28, lngMin: 28.95, lngMax: 29.05),
    MapRegion(name: 'Antalya Centre', id: 'antalya', latMin: 36.83, latMax: 36.92, lngMin: 30.60, lngMax: 30.85),
    MapRegion(name: 'Cappadoce', id: 'cappadoce', latMin: 38.55, latMax: 38.75, lngMin: 34.70, lngMax: 35.00),
    MapRegion(name: 'Izmir', id: 'izmir', latMin: 38.35, latMax: 38.50, lngMin: 27.05, lngMax: 27.25),
    MapRegion(name: 'Ankara', id: 'ankara', latMin: 39.82, latMax: 40.00, lngMin: 32.78, lngMax: 32.95),
    MapRegion(name: 'Pamukkale', id: 'pamukkale', latMin: 37.90, latMax: 37.95, lngMin: 29.08, lngMax: 29.15),
    MapRegion(name: 'Côte Turquoise', id: 'cote_turquoise', latMin: 36.30, latMax: 36.60, lngMin: 29.80, lngMax: 30.60, size: '~35 MB'),
    MapRegion(name: 'Bursa', id: 'bursa', latMin: 40.15, latMax: 40.22, lngMin: 28.95, lngMax: 29.15),
  ];

  Future<void> init() async {}

  int get regionCount => _regions.length;
  String getRegionName(int index) => _regions[index].name;
  String getRegionSize(int index) => _regions[index].size;

  bool isRegionDownloaded(int index) =>
      index < _regions.length && (LocalStorage.getBool('map_${_regions[index].id}') ?? false);

  Future<void> downloadRegion(int index) async {
    if (index >= _regions.length) return;
    LocalStorage.setBool('map_${_regions[index].id}', true);
    notifyListeners();
  }

  Future<void> deleteRegion(int index) async {
    if (index >= _regions.length) return;
    LocalStorage.setBool('map_${_regions[index].id}', false);
    notifyListeners();
  }

  double getStorageUsed() => isRegionDownloaded(0) ? 25.0 : 0;

  Future<void> clearAll() async {
    for (int i = 0; i < _regions.length; i++) {
      await deleteRegion(i);
    }
  }
}
