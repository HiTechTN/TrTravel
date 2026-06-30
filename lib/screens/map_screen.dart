import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/itinerary_service.dart';
import '../services/routing_service.dart';
import '../services/voice_guidance_service.dart';
import '../services/favorites_service.dart';
import '../services/offline_map_manager.dart';
import '../models/itinerary.dart';
import '../models/map_place.dart';
import '../models/place.dart';
import '../models/route_info.dart';
import '../data/map_places_data.dart';
import 'map_download_screen.dart';

class MapScreen extends StatefulWidget {
  final ItineraryItem? focusedDay;

  const MapScreen({super.key, this.focusedDay});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with TickerProviderStateMixin {
  FMTCTileProvider? _tileProvider;
  bool _isInitialized = false;
  String _transportMode = 'walking';
  MapPlace? _selectedPlace;
  MapController? _mapController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _showRoute = false;
  String _selectedCategory = 'all';
  bool _showTripPlanner = false;
  int _selectedDayIndex = 0;
  bool _showFavoritesOnly = false;

  final RoutingService _routingService = RoutingService();
  final VoiceGuidanceService _voiceGuidance = VoiceGuidanceService();
  RouteInfo? _routeInfo;
  bool _isRouteLoading = false;
  LatLng? _routeOrigin;
  LatLng? _mapCenter;

  static const String _storeName = 'trtravel_maps';

  static List<MapPlace> get allPlaces => MapPlacesData.allPlaces;

  final List<String> _categories = [
    'all', 'historical', 'religious', 'nature', 'beach', 'museum',
    'shopping', 'palace', 'landmark', 'village', 'port', 'old_town',
  ];

  final List<Map<String, String>> _transportModes = [
    {'id': 'walking', 'icon': '\u{1F6B6}', 'label': 'Pi\u00E9ton'},
    {'id': 'taxi', 'icon': '\u{1F695}', 'label': 'Taxi'},
    {'id': 'transit', 'icon': '\u{1F68C}', 'label': 'Bus/M\u00E9tro'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeTileLayer();
    _mapController = MapController();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _slideController.forward();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      await context.read<FavoritesService>().load();
    } catch (e) {
      debugPrint('MapScreen: error loading favorites: $e');
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _voiceGuidance.dispose();
    super.dispose();
  }

  Future<void> _initializeTileLayer() async {
    try {
      await FMTCObjectBoxBackend().initialise();
      const store = FMTCStore(_storeName);
      if (!await store.manage.ready) {
        await store.manage.create();
      }
      _tileProvider = store.getTileProvider();
      if (mounted) setState(() => _isInitialized = true);
    } catch (e) {
      if (mounted) setState(() => _isInitialized = true);
    }
  }

  List<MapPlace> get _filteredPlaces {
    if (_showFavoritesOnly) {
      final favs = context.read<FavoritesService>();
      return allPlaces.where((p) => favs.isFavorite(p.name)).toList();
    }
    if (_selectedCategory == 'all') return allPlaces;
    return allPlaces.where((p) => p.category == _selectedCategory).toList();
  }

  IconData _getCategoryIcon(String category) {
    final icons = {
      'historical': Icons.account_balance, 'religious': Icons.church,
      'nature': Icons.park, 'beach': Icons.beach_access,
      'museum': Icons.museum, 'shopping': Icons.shopping_bag,
      'palace': Icons.castle, 'landmark': Icons.location_on,
      'village': Icons.home, 'port': Icons.directions_boat,
      'old_town': Icons.streetview,
    };
    return icons[category] ?? Icons.place;
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'historical': const Color(0xFF8D6E63), 'religious': const Color(0xFF9C27B0),
      'nature': const Color(0xFF43A047), 'beach': const Color(0xFF1E88E5),
      'museum': const Color(0xFFFF6D00), 'shopping': const Color(0xFFE91E63),
      'palace': const Color(0xFFFFB300), 'landmark': const Color(0xFF5C6BC0),
      'village': const Color(0xFF78909C), 'port': const Color(0xFF26A69A),
      'old_town': const Color(0xFF6D4C41),
    };
    return colors[category] ?? Colors.grey;
  }

  String _getCategoryLabel(String category) {
    final labels = {
      'all': 'Tous', 'historical': 'Histoire', 'religious': 'Religion',
      'nature': 'Nature', 'beach': 'Plage', 'museum': 'Mus\u00E9e',
      'shopping': 'Shopping', 'palace': 'Palais', 'landmark': 'Monument',
      'village': 'Village', 'port': 'Port', 'old_town': 'Vieille ville',
    };
    return labels[category] ?? category;
  }

  List<LatLng> _getPolylinePoints(List<Place> places) {
    if (places.length < 2) return [];
    final coords = places.map((p) => LatLng(p.latitude, p.longitude)).toList();
    final route = <LatLng>[];
    for (int i = 0; i < coords.length - 1; i++) {
      route.addAll(_generateIntermediatePoints(coords[i], coords[i + 1]));
    }
    return route;
  }

  List<LatLng> _generateIntermediatePoints(LatLng start, LatLng end) {
    final points = <LatLng>[start];
    const steps = 10;
    for (int i = 1; i <= steps; i++) {
      final t = i / steps;
      points.add(LatLng(
        start.latitude + (end.latitude - start.latitude) * t,
        start.longitude + (end.longitude - start.longitude) * t,
      ));
    }
    return points;
  }

  Future<void> _calculateRoute(MapPlace destination) async {
    setState(() {
      _isRouteLoading = true;
      _showRoute = true;
      _routeOrigin ??= _mapCenter ?? const LatLng(41.0086, 28.9802);
    });

    final route = await _routingService.getRouteWithFallback(
      origin: _routeOrigin!,
      destination: destination.location,
      mode: _transportMode,
    );

    if (mounted) {
      setState(() {
        _routeInfo = route;
        _isRouteLoading = false;
      });
      if (route != null) {
        _voiceGuidance.startGuidance(route.steps);
        if (route.points.isNotEmpty) _fitRouteOnMap(route.points);
      }
    }
  }

  void _fitRouteOnMap(List<LatLng> points) {
    if (points.isEmpty) return;
    double minLat = double.infinity, maxLat = double.negativeInfinity;
    double minLon = double.infinity, maxLon = double.negativeInfinity;
    for (final p in points) {
      minLat = min(minLat, p.latitude);
      maxLat = max(maxLat, p.latitude);
      minLon = min(minLon, p.longitude);
      maxLon = max(maxLon, p.longitude);
    }
    final bounds = LatLngBounds(LatLng(minLat, minLon), LatLng(maxLat, maxLon));
    _mapController?.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
    );
  }

  void _clearRoute() {
    setState(() {
      _showRoute = false;
      _routeInfo = null;
      _selectedPlace = null;
    });
    _voiceGuidance.stop();
  }

  @override
  Widget build(BuildContext context) {
    final itineraryService = context.watch<ItineraryService>();
    final itineraryItems = itineraryService.getCachedItinerary();
    final favoritesService = context.watch<FavoritesService>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(itineraryItems, favoritesService),
          Expanded(child: _buildMapArea(favoritesService)),
          _buildBottomPanel(favoritesService),
        ],
      ),
    );
  }

  Widget _buildHeader(List<ItineraryItem> itineraryItems, FavoritesService favService) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16, right: 16, bottom: 8,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE30A17), Color(0xFFCC0815)],
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ..._categories.map((cat) {
                  final isSelected = _selectedCategory == cat && !_showFavoritesOnly;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        _getCategoryLabel(cat),
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) => setState(() {
                        _selectedCategory = cat;
                        _showFavoritesOnly = false;
                      }),
                      backgroundColor: Colors.white,
                      selectedColor: _getCategoryColor(cat),
                      checkmarkColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  );
                }),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _showFavoritesOnly = !_showFavoritesOnly;
                      if (_showFavoritesOnly) _selectedCategory = 'all';
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _showFavoritesOnly ? Colors.white : Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: _showFavoritesOnly ? Border.all(color: Colors.red, width: 2) : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite, color: _showFavoritesOnly ? Colors.red : Colors.white, size: 16),
                          if (favService.count > 0) ...[
                            const SizedBox(width: 4),
                            Text('${favService.count}', style: TextStyle(
                              color: _showFavoritesOnly ? Colors.red : Colors.white,
                              fontWeight: FontWeight.w700, fontSize: 12,
                            )),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _transportModes.map((mode) {
                final isSelected = _transportMode == mode['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _transportMode = mode['id']!;
                      if (_showRoute && _routeInfo != null && _selectedPlace != null) {
                        _calculateRoute(_selectedPlace!);
                      }
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(mode['icon']!, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            mode['label']!,
                            style: TextStyle(
                              color: isSelected ? const Color(0xFFE30A17) : Colors.white,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                _showFavoritesOnly ? '${favService.count} favoris' : '${_filteredPlaces.length} lieux',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '\u{1F5FA} ${_getCategoryLabel(_selectedCategory)}',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapArea(FavoritesService favService) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(39.0, 35.0),
            initialZoom: 6,
            minZoom: 5,
            maxZoom: 18,
            onTap: (_, __) => setState(() => _selectedPlace = null),
            onPositionChanged: (pos, _) => _mapCenter = pos.center,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.trtravel.app',
              tileProvider: _tileProvider,
            ),
            if (_showRoute && _routeInfo != null)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routeInfo!.points,
                    strokeWidth: 6,
                    color: _transportMode == 'walking'
                        ? const Color(0xFF43A047)
                        : _transportMode == 'taxi'
                            ? const Color(0xFFFFA000)
                            : const Color(0xFF1E88E5),
                  ),
                ],
              ),
            if (_showRoute && _routeInfo != null && _routeInfo!.points.length >= 2)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _routeInfo!.points.first,
                    width: 36, height: 36,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF43A047),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4)],
                      ),
                      child: const Icon(Icons.trip_origin, color: Colors.white, size: 20),
                    ),
                  ),
                  Marker(
                    point: _routeInfo!.points.last,
                    width: 36, height: 36,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE30A17),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4)],
                      ),
                      child: const Icon(Icons.flag, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            MarkerLayer(
              markers: _filteredPlaces.map((place) {
                final isSelected = place == _selectedPlace;
                final isFav = favService.isFavorite(place.name);
                return Marker(
                  point: place.location,
                  width: isSelected ? 56 : 44,
                  height: isSelected ? 56 : 44,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPlace = place),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isFav && !isSelected ? Colors.amber : _getCategoryColor(place.category),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : (isFav ? Colors.brown.shade300 : Colors.transparent),
                              width: isSelected ? 3 : (isFav ? 2 : 0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_getCategoryColor(place.category)).withValues(alpha: isSelected ? 0.5 : 0.3),
                                blurRadius: isSelected ? 12 : 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            _getCategoryIcon(place.category),
                            color: Colors.white,
                            size: isSelected ? 28 : 20,
                          ),
                        ),
                        if (isFav && !isSelected)
                          Positioned(
                            top: 0, right: 0,
                            child: Container(
                              width: 14, height: 14,
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: const Icon(Icons.favorite, color: Colors.white, size: 8),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        if (_routeInfo != null && _showRoute)
          Positioned(
            left: 12, right: 12, bottom: 12,
            child: _buildRouteInfoPanel(),
          ),
        if (_isRouteLoading)
          const Positioned(
            left: 0, right: 0, top: 0, bottom: 0,
            child: Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Color(0xFFE30A17)),
                      SizedBox(height: 12),
                      Text('Calcul de l\'itin\u00E9raire...', style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        Positioned(top: 12, right: 12, child: _buildOverlayButtons()),
        if (_selectedPlace != null && !_showRoute)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildPlaceInfo(favService),
            ),
          ),
        if (_showTripPlanner)
          Positioned(
            left: 12, top: 12, right: 80,
            child: Builder(
              builder: (context) {
                final items = context.watch<ItineraryService>().getCachedItinerary();
                if (items.isEmpty) return const SizedBox.shrink();
                return _buildTripPlannerPanel(items);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildOverlayButtons() {
    return Column(
      children: [
        _buildMapButton(Icons.layers, 'Type de carte', () => _showMapTypeMenu()),
        const SizedBox(height: 8),
        _buildMapButton(
          _showRoute ? Icons.route : Icons.route_outlined,
          _showRoute ? 'Itin\u00E9raire actif' : 'Itin\u00E9raire',
          _clearRoute,
        ),
        const SizedBox(height: 8),
        _buildMapButton(
          _showTripPlanner ? Icons.list_alt : Icons.list_alt_outlined,
          'Planificateur de voyage',
          () => setState(() => _showTripPlanner = !_showTripPlanner),
        ),
        const SizedBox(height: 8),
        _buildMapButton(
          _voiceGuidance.isEnabled ? Icons.record_voice_over : Icons.voice_over_off,
          _voiceGuidance.isEnabled ? 'Guide vocal ON' : 'Guide vocal OFF',
          () {
            _voiceGuidance.toggle();
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_voiceGuidance.isEnabled
                    ? 'Guide vocal activ\u00E9'
                    : 'Guide vocal d\u00E9sactiv\u00E9'),
                duration: const Duration(seconds: 1),
                backgroundColor: const Color(0xFFE30A17),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        _buildMapButton(Icons.download, 'T\u00E9l\u00E9charger cartes', () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MapDownloadScreen()));
        }),
      ],
    );
  }

  Widget _buildMapButton(IconData icon, String tooltip, VoidCallback onPressed) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: IconButton(
          icon: Icon(icon, size: 22),
          onPressed: onPressed,
          color: const Color(0xFFE30A17),
        ),
      ),
    );
  }

  Widget _buildRouteInfoPanel() {
    if (_routeInfo == null) return const SizedBox.shrink();
    final route = _routeInfo!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _transportMode == 'walking'
                      ? const Color(0xFF43A047).withValues(alpha: 0.1)
                      : _transportMode == 'taxi'
                          ? const Color(0xFFFFA000).withValues(alpha: 0.1)
                          : const Color(0xFF1E88E5).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(route.modeEmoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${route.modeLabel} \u2022 ${route.distanceFormatted}',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1A1A2E)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${route.durationFormatted} \u2022 ${route.steps.length} \u00E9tapes',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.expand_less, size: 22),
                onPressed: () => _showRouteSteps(route),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 22),
                onPressed: _clearRoute,
              ),
            ],
          ),
          if (route.steps.length > 1)
            Container(
              margin: const EdgeInsets.only(top: 8),
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(2),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: max(1, route.steps.length * 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _transportMode == 'walking'
                            ? const Color(0xFF43A047)
                            : _transportMode == 'taxi'
                                ? const Color(0xFFFFA000)
                                : const Color(0xFF1E88E5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Expanded(flex: 1, child: SizedBox()),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showRouteSteps(RouteInfo route) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(route.modeEmoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Itin\u00E9raire d\u00E9taill\u00E9',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                  ),
                  Text('${route.distanceFormatted} \u2022 ${route.durationFormatted}',
                    style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: route.steps.length,
                itemBuilder: (ctx, index) {
                  final step = route.steps[index];
                  final isFirst = index == 0;
                  final isLast = index == route.steps.length - 1;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(
                                color: isFirst ? const Color(0xFF43A047) : isLast
                                    ? const Color(0xFFE30A17) : const Color(0xFFE30A17).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(child: Icon(
                                isFirst ? Icons.trip_origin : isLast ? Icons.flag : Icons.arrow_forward,
                                color: isFirst || isLast ? Colors.white : const Color(0xFFE30A17), size: 16,
                              )),
                            ),
                            if (index < route.steps.length - 1)
                              Container(width: 2, height: 30, color: Colors.grey[300]),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(step.simplifiedInstruction,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              const SizedBox(height: 2),
                              Text('${step.distance.toStringAsFixed(0)} m \u2022 ${step.duration.toStringAsFixed(0)} s',
                                style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMapTypeMenu() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Type de carte', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('OpenStreetMap'),
              subtitle: const Text('Cartes libres et gratuites'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.satellite),
              title: const Text('Satellite'),
              subtitle: const Text('Vue satellite'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.terrain),
              title: const Text('Terrain'),
              subtitle: const Text('Relief et topographie'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceInfo(FavoritesService favService) {
    final place = _selectedPlace!;
    final isFav = favService.isFavorite(place.name);

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getCategoryColor(place.category).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_getCategoryIcon(place.category), color: _getCategoryColor(place.category), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(place.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        ...List.generate(5, (i) => Icon(
                          i < place.rating.floor() ? Icons.star : Icons.star_border,
                          color: Colors.amber, size: 16)),
                        const SizedBox(width: 4),
                        Text('${place.rating}', style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(place.category).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(_getCategoryLabel(place.category),
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                              color: _getCategoryColor(place.category))),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.red, size: 22),
                onPressed: () => favService.toggle(place.name),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 22),
                onPressed: () => setState(() => _selectedPlace = null),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(place.description, style: TextStyle(color: Colors.grey[700], height: 1.4),
            maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (place.openingHours != null) _buildInfoChip(Icons.access_time, place.openingHours!),
            if (place.estimatedDuration != null)
              _buildInfoChip(Icons.schedule, '~${place.estimatedDuration!.toStringAsFixed(1)}h'),
            if (place.entranceFee != null)
              _buildInfoChip(Icons.monetization_on,
                place.entranceFee! > 0 ? '${place.entranceFee!.toStringAsFixed(0)} TL' : 'Gratuit'),
          ]),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: _isRouteLoading
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.directions, size: 18),
                  label: Text(_isRouteLoading ? 'Calcul...' : 'Itin\u00E9raire'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE30A17),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _isRouteLoading ? null : () => _calculateRoute(place),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('D\u00E9tails'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  onPressed: () => _showPlaceDetails(place),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _buildBottomPanel(FavoritesService favService) {
    if (_routeInfo != null && _showRoute) return const SizedBox.shrink();

    return Container(
      height: 120,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: _filteredPlaces.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, color: Colors.grey[400], size: 32),
                  const SizedBox(height: 8),
                  Text('Aucun favori', style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w600)),
                  TextButton(
                    onPressed: () => setState(() => _showFavoritesOnly = false),
                    child: const Text('Voir tous les lieux'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filteredPlaces.length,
              itemBuilder: (context, index) {
                final place = _filteredPlaces[index];
                final isSelected = place == _selectedPlace;
                final isFav = favService.isFavorite(place.name);
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedPlace = place);
                    _mapController?.move(place.location, 14);
                  },
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? _getCategoryColor(place.category).withValues(alpha: 0.08) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? _getCategoryColor(place.category) : Colors.grey[200]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(place.category).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(_getCategoryIcon(place.category), size: 14,
                                color: _getCategoryColor(place.category)),
                            ),
                            const Spacer(),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              if (isFav)
                                const Icon(Icons.favorite, size: 12, color: Colors.red),
                              if (isFav) const SizedBox(width: 2),
                              const Icon(Icons.star, size: 12, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text('${place.rating}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                            ]),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(place.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                        const Spacer(),
                        Row(children: [
                          Icon(Icons.access_time, size: 11, color: Colors.grey[400]),
                          const SizedBox(width: 3),
                          Text(place.openingHours ?? '24h',
                            style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                        ]),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildTripPlannerPanel(List<ItineraryItem> itineraryItems) {
    if (itineraryItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Text('G\u00E9n\u00E9rez un itin\u00E9raire pour voir le parcours',
                style: TextStyle(color: Colors.grey[600])),
            ),
          ],
        ),
      );
    }

    final dayItem = _selectedDayIndex < itineraryItems.length
        ? itineraryItems[_selectedDayIndex] : itineraryItems.first;
    final activities = dayItem.activities;

    return Container(
      constraints: const BoxConstraints(maxHeight: 280),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFE30A17),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.map, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Jour ${_selectedDayIndex + 1}: ${dayItem.dayName}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                  child: Text('${activities.length} lieux', style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                final lat = _findPlaceLat(activity.description);
                final lon = _findPlaceLon(activity.description);
                final isValid = lat != 0 && lon != 0;

                return InkWell(
                  onTap: isValid ? () => _mapController?.move(LatLng(lat, lon), 15) : null,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: index == 0 ? const Color(0xFFE30A17).withValues(alpha: 0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: index == 0 ? const Color(0xFFE30A17) : Colors.grey[200]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: index == 0 ? const Color(0xFFE30A17) : Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                          child: Center(child: Text('${index + 1}',
                            style: TextStyle(color: index == 0 ? Colors.white : Colors.grey[700],
                              fontWeight: FontWeight.w700, fontSize: 12))),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(activity.description,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                              if (activity.time != null)
                                Text(activity.time!, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                            ],
                          ),
                        ),
                        if (isValid)
                          Icon(Icons.navigation, size: 16, color: Colors.grey[400])
                        else
                          Icon(Icons.help_outline, size: 16, color: Colors.orange[300]),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (itineraryItems.length > 1)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey[200]!))),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 20),
                    onPressed: _selectedDayIndex > 0 ? () => setState(() => _selectedDayIndex--) : null,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(itineraryItems.length, (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: i == _selectedDayIndex ? const Color(0xFFE30A17) : Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text('J${i + 1}',
                            style: TextStyle(color: i == _selectedDayIndex ? Colors.white : Colors.grey[700],
                              fontWeight: FontWeight.w600, fontSize: 12)),
                        )),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20),
                    onPressed: _selectedDayIndex < itineraryItems.length - 1
                        ? () => setState(() => _selectedDayIndex++) : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  double _findPlaceLat(String desc) {
    final lower = desc.toLowerCase();
    for (final p in allPlaces) {
      if (lower.contains(p.name.toLowerCase())) return p.location.latitude;
    }
    return 0;
  }

  double _findPlaceLon(String desc) {
    final lower = desc.toLowerCase();
    for (final p in allPlaces) {
      if (lower.contains(p.name.toLowerCase())) return p.location.longitude;
    }
    return 0;
  }

  void _showPlaceDetails(MapPlace place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(place.category).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(_getCategoryIcon(place.category), color: _getCategoryColor(place.category), size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(place.name,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                          const SizedBox(height: 4),
                          Row(children: [
                            ...List.generate(5, (i) => Icon(
                              i < place.rating.floor() ? Icons.star : Icons.star_border,
                              color: Colors.amber, size: 18)),
                            const SizedBox(width: 6),
                            Text('${place.rating}/5',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(place.category).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getCategoryLabel(place.category).toUpperCase(),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                      color: _getCategoryColor(place.category), letterSpacing: 1),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Description', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(place.description, style: TextStyle(color: Colors.grey[700], height: 1.5)),
                if (place.descriptionTr.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Text('\u{1F1F9}\u{1F1F7} ', style: TextStyle(fontSize: 14)),
                          Text('T\u00FCrk\u00E7e',
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
                        ]),
                        const SizedBox(height: 6),
                        Text(place.descriptionTr, style: TextStyle(color: Colors.grey[600], height: 1.5)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                const Text('Informations pratiques', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                if (place.address != null) _buildDetailRow(Icons.location_on, 'Adresse', place.address!),
                if (place.openingHours != null) _buildDetailRow(Icons.access_time, 'Horaires', place.openingHours!),
                if (place.estimatedDuration != null)
                  _buildDetailRow(Icons.schedule, 'Dur\u00E9e estim\u00E9e',
                    '~${place.estimatedDuration!.toStringAsFixed(1)} heures'),
                if (place.entranceFee != null)
                  _buildDetailRow(Icons.monetization_on, 'Entr\u00E9e',
                    place.entranceFee! > 0 ? '${place.entranceFee!.toStringAsFixed(0)} TL' : 'Gratuit'),
                if (place.bestTime != null) _buildDetailRow(Icons.wb_sunny, 'Meilleur moment', place.bestTime!),
                if (place.city.isNotEmpty) _buildDetailRow(Icons.location_city, 'Ville', place.city),
                if (place.phone != null && place.phone!.isNotEmpty)
                  _buildDetailRow(Icons.phone, 'T\u00E9l\u00E9phone', place.phone!),
                if (place.website != null && place.website!.isNotEmpty)
                  _buildDetailRow(Icons.language, 'Site web', place.website!),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.pin_drop, 'Coordonn\u00E9es',
                  '${place.location.latitude.toStringAsFixed(4)}, ${place.location.longitude.toStringAsFixed(4)}'),
                if (place.tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Tags', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: place.tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE30A17).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('#$tag',
                      style: const TextStyle(fontSize: 13, color: Color(0xFFE30A17), fontWeight: FontWeight.w600)),
                  )).toList()),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _mapController?.move(place.location, 16);
                    },
                    icon: const Icon(Icons.navigation, size: 20),
                    label: const Text('Naviguer vers ce lieu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE30A17),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[500]),
          const SizedBox(width: 12),
          SizedBox(width: 100, child: Text('$label:',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[600]))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
