import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MapRegion {
  final String id;
  final String name;
  final String emoji;
  final LatLngBounds bounds;
  final List<String> cities;
  double downloadProgress;
  bool isDownloaded;
  int tileCount;
  int totalTiles;
  bool isDownloading;

  MapRegion({
    required this.id,
    required this.name,
    required this.emoji,
    required this.bounds,
    required this.cities,
    this.downloadProgress = 0,
    this.isDownloaded = false,
    this.tileCount = 0,
    this.totalTiles = 0,
    this.isDownloading = false,
  });

  String get sizeFormatted {
    if (tileCount == 0) return '--';
    final mb = tileCount * 0.015;
    if (mb < 1) return '${(mb * 1024).toStringAsFixed(0)} KB';
    return '${mb.toStringAsFixed(1)} MB';
  }

  String get progressLabel {
    if (isDownloaded) return 'T\u00E9l\u00E9charg\u00E9';
    if (isDownloading) return '${(downloadProgress * 100).toStringAsFixed(0)}%';
    return 'Pr\u00EAt \u00E0 t\u00E9l\u00E9charger';
  }
}

class OfflineMapManager extends ChangeNotifier {
  static const String _storeName = 'trtravel_maps';
  static const String _prefsKey = 'downloaded_regions';

  final List<MapRegion> regions = [
    MapRegion(
      id: 'istanbul',
      name: 'Istanbul',
      emoji: '\u{1F3DB}\uFE0F',
      bounds: LatLngBounds(const LatLng(40.85, 28.65), const LatLng(41.25, 29.35)),
      cities: ['Istanbul'],
    ),
    MapRegion(
      id: 'antalya',
      name: 'Antalya',
      emoji: '\u{1F3D6}\uFE0F',
      bounds: LatLngBounds(const LatLng(36.50, 30.10), const LatLng(37.20, 31.20)),
      cities: ['Antalya', 'Alanya', 'Side'],
    ),
    MapRegion(
      id: 'cappadoce',
      name: 'Cappadoce',
      emoji: '\u{1F3A8}',
      bounds: LatLngBounds(const LatLng(38.20, 34.40), const LatLng(38.80, 35.10)),
      cities: ['Nev\u015Fehir', 'G\u00F6reme', '\u00DCrg\u00FCp', 'Avanos'],
    ),
    MapRegion(
      id: 'ankara',
      name: 'Ankara',
      emoji: '\u{1F3DB}\uFE0F',
      bounds: LatLngBounds(const LatLng(39.70, 32.50), const LatLng(40.20, 33.20)),
      cities: ['Ankara'],
    ),
    MapRegion(
      id: 'izmir',
      name: 'Izmir & Ephesus',
      emoji: '\u{1F3DB}\uFE0F',
      bounds: LatLngBounds(const LatLng(37.60, 26.60), const LatLng(38.80, 27.60)),
      cities: ['Izmir', 'Sel\u00E7uk', 'Efes'],
    ),
    MapRegion(
      id: 'trabzon',
      name: 'Trabzon',
      emoji: '\u26F0\uFE0F',
      bounds: LatLngBounds(const LatLng(40.60, 39.30), const LatLng(41.10, 40.00)),
      cities: ['Trabzon', 'Ma\u00E7ka'],
    ),
    MapRegion(
      id: 'pamukkale',
      name: 'Pamukkale',
      emoji: '\u{1F3DB}\uFE0F',
      bounds: LatLngBounds(const LatLng(37.80, 28.90), const LatLng(38.00, 29.30)),
      cities: ['Denizli', 'Pamukkale'],
    ),
    MapRegion(
      id: 'turkey_all',
      name: 'Turquie compl\u00E8te',
      emoji: '\u{1F1F9}\u{1F1F7}',
      bounds: LatLngBounds(const LatLng(35.50, 25.50), const LatLng(42.50, 45.00)),
      cities: ['Toute la Turquie'],
    ),
  ];

  FMTCStore? get store {
    try {
      return FMTCStore(_storeName);
    } catch (_) {
      return null;
    }
  }

  Future<void> initialize() async {
    try {
      await FMTCObjectBoxBackend().initialise();
      final s = store;
      if (s != null && !await s.manage.ready) {
        await s.manage.create();
      }
      await _loadDownloadedState();
      notifyListeners();
    } catch (_) {
      notifyListeners();
    }
  }

  Future<void> _loadDownloadedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final downloaded = prefs.getStringList(_prefsKey) ?? [];
      for (final id in downloaded) {
        final r = regions.where((r) => r.id == id);
        for (final region in r) {
          region.isDownloaded = true;
          region.tileCount = 1;
        }
      }
    } catch (e) {
      debugPrint('OfflineMapManager: error checking download status: $e');
    }
  }

  Future<void> downloadRegion(MapRegion region) async {
    if (region.isDownloading || region.isDownloaded) return;

    region.isDownloading = true;
    region.downloadProgress = 0;
    notifyListeners();

    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity.contains(ConnectivityResult.none)) {
        region.isDownloading = false;
        notifyListeners();
        return;
      }

      final s = store;
      if (s == null) {
        region.isDownloading = false;
        notifyListeners();
        return;
      }

      final downloadable = RectangleRegion(region.bounds).toDownloadable(
        minZoom: 5,
        maxZoom: 14,
        options: TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
      );

      final downloadHandle = s.download.startForeground(
        region: downloadable,
        parallelThreads: 4,
        maxBufferLength: 200,
        skipSeaTiles: true,
      );

      await for (final progress in downloadHandle.downloadProgress) {
        region.downloadProgress = progress.percentageProgress / 100;
        notifyListeners();
      }

      region.isDownloaded = true;
      region.isDownloading = false;
      region.downloadProgress = 1.0;

      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_prefsKey) ?? [];
      if (!list.contains(region.id)) {
        list.add(region.id);
        await prefs.setStringList(_prefsKey, list);
      }
      notifyListeners();
    } catch (_) {
      region.isDownloading = false;
      region.isDownloaded = false;
      notifyListeners();
    }
  }

  Future<void> deleteRegion(MapRegion region) async {
    region.isDownloaded = false;
    region.isDownloading = false;
    region.downloadProgress = 0;
    region.tileCount = 0;
    region.totalTiles = 0;

    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefsKey) ?? [];
    list.remove(region.id);
    await prefs.setStringList(_prefsKey, list);

    final s = store;
    if (s != null) {
      try {
        await s.manage.reset();
      } catch (e) {
        debugPrint('OfflineMapManager: error resetting store: $e');
      }
    }
    notifyListeners();
  }

  Future<double> getStorageUsed() async {
    final s = store;
    if (s == null) return 0;
    try {
      final size = await FMTCRoot.stats.realSize;
      return size / (1024 * 1024);
    } catch (_) {
      return 0;
    }
  }

  FMTCTileProvider? getTileProvider() {
    try {
      final s = store;
      if (s == null) return null;
      return FMTCTileProvider(stores: {s.storeName: BrowseStoreStrategy.readUpdateCreate});
    } catch (_) {
      return null;
    }
  }

  bool isInDownloadedRegion(LatLng point) {
    for (final region in regions) {
      if (region.isDownloaded && region.bounds.contains(point)) return true;
    }
    return false;
  }
}
