import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/shared/widgets/widgets.dart';
import 'package:trtravel/l10n/app_localizations.dart';
import '../models/map_place.dart';
import '../data/map_places_data.dart';
import '../services/routing_service.dart';

final _distanceCalc = Distance();

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  String _selectedCity = 'all';
  String _selectedCategory = 'Tout';
  MapPlace? _selectedPlace;
  List<MapPlace> _filteredPlaces = MapPlacesData.all;
  List<MapPlace> _searchResults = [];
  bool _isSearching = false;
  final _searchCtrl = TextEditingController();
  RouteResult? _route;
  bool _isRouting = false;
  String _routeProfile = 'walking';
  List<LatLng>? _routePolyline;
  bool _showRoutePanel = false;

  LatLng? _userLocation;
  bool _locationLoading = true;

  bool _isNavigating = false;
  int _currentStepIndex = -1;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
    _initLocation();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _mapController.dispose();
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    setState(() => _locationLoading = true);
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      setState(() => _locationLoading = false);
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
      setState(() => _locationLoading = false);
      return;
    }
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 10)),
      );
      if (mounted) {
        setState(() {
          _userLocation = LatLng(pos.latitude, pos.longitude);
          _locationLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _locationLoading = false);
    }
  }

  void _startNavigation() {
    if (_route == null || _userLocation == null) return;
    setState(() => _isNavigating = true);
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        timeLimit: null,
      ),
    ).listen((pos) {
      if (!mounted) return;
      setState(() {
        _userLocation = LatLng(pos.latitude, pos.longitude);
        _updateCurrentStep();
      });
    });
  }

  void _stopNavigation() {
    _positionStream?.cancel();
    _positionStream = null;
    setState(() {
      _isNavigating = false;
      _currentStepIndex = -1;
    });
  }

  void _updateCurrentStep() {
    if (_route == null || _userLocation == null || _route!.steps.isEmpty) return;
    double minDist = double.infinity;
    int closest = 0;
    for (int i = 0; i < _route!.steps.length; i++) {
      final d = _distanceCalc.distance(
        _userLocation!,
        LatLng(_route!.steps[i].point.latitude, _route!.steps[i].point.longitude),
      );
      if (d < minDist) {
        minDist = d;
        closest = i;
      }
    }
    _currentStepIndex = closest;
  }

  void _onSearchChanged() {
    final q = _searchCtrl.text;
    if (q.length >= 2) {
      setState(() { _isSearching = true; _searchResults = MapPlacesData.filter(query: q); });
    } else {
      setState(() { _isSearching = false; _searchResults = []; });
    }
  }

  void _filterPlaces() {
    setState(() {
      _filteredPlaces = MapPlacesData.filter(city: _selectedCity, category: _selectedCategory);
    });
  }

  void _onPlaceSelected(MapPlace place) {
    setState(() {
      _selectedPlace = place;
      _showRoutePanel = false;
      _route = null;
      _routePolyline = null;
      _isNavigating = false;
      _currentStepIndex = -1;
      _positionStream?.cancel();
      _positionStream = null;
    });
    _mapController.move(place.location, 15.0);
  }

  Future<void> _calculateRoute(MapPlace dest) async {
    final origin = _userLocation ?? const LatLng(41.0086, 28.9802);
    setState(() { _isRouting = true; _showRoutePanel = true; _isNavigating = false; _currentStepIndex = -1; });
    _positionStream?.cancel();
    _positionStream = null;
    final route = await RoutingService.getRouteWithCache(origin, dest.location, profile: _routeProfile);
    if (route != null && mounted) {
      setState(() { _route = route; _routePolyline = route.points; _isRouting = false; });
      if (route.points.isNotEmpty) {
        _mapController.fitCamera(CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(route.points),
          padding: const EdgeInsets.all(50),
        ));
      }
    } else if (mounted) {
      setState(() => _isRouting = false);
      _openGoogleMaps(dest.location);
    }
  }

  void _openGoogleMaps(LatLng dest) async {
    final origin = _userLocation ?? const LatLng(41.0086, 28.9802);
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=${origin.latitude},${origin.longitude}&destination=${dest.latitude},${dest.longitude}&travelmode=$_routeProfile',
    );
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Color _catColor(String c) {
    switch (c) {
      case 'Mosquées': return AppColors.mosque;
      case 'Musées': return AppColors.museum;
      case 'Palais': return AppColors.hotel;
      case 'Monuments Historiques': return AppColors.secondary;
      case 'Parcs & Jardins': return AppColors.nature;
      case 'Points de Vue': return AppColors.gold;
      case 'Plages': return AppColors.transport;
      case 'Restaurants': return AppColors.food;
      case 'Shopping': return AppColors.shop;
      default: return AppColors.primary;
    }
  }

  String _catIcon(String c) {
    switch (c) {
      case 'Mosquées': return '\u{1F54C}';
      case 'Musées': return '\u{1F3DB}\u{FE0F}';
      case 'Palais': return '\u{1F3F0}';
      case 'Monuments Historiques': return '\u{1F3DB}\u{FE0F}';
      case 'Parcs & Jardins': return '\u{1F33F}';
      case 'Points de Vue': return '\u{1F441}\u{FE0F}';
      case 'Plages': return '\u{1F3D6}\u{FE0F}';
      case 'Restaurants': return '\u{1F37D}\u{FE0F}';
      case 'Shopping': return '\u{1F6CD}\u{FE0F}';
      default: return '\u{1F4CD}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppScaffold(
      body: Column(children: [
        AppHeader(title: l.mapTitle, subtitle: l.mapSubtitle, icon: Icons.map_rounded, height: 110),
        _buildTopBar(l),
        Expanded(child: Stack(children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userLocation ?? const LatLng(39.0, 32.0),
              initialZoom: _userLocation != null ? 12.0 : 6.0,
              onTap: (_, __) => setState(() { _selectedPlace = null; _showRoutePanel = false; }),
            ),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.trtravel'),
              if (_routePolyline != null && _routePolyline!.length > 1)
                PolylineLayer(polylines: [
                  Polyline(
                    points: _routePolyline!,
                    color: AppColors.primary,
                    strokeWidth: 5,
                    borderColor: Colors.white,
                    borderStrokeWidth: 2,
                  ),
                  if (_isNavigating && _currentStepIndex >= 0 && _currentStepIndex < (_route?.steps.length ?? 0))
                    Polyline(
                      points: _getRemainingRoute(),
                      color: AppColors.gold,
                      strokeWidth: 6,
                      borderColor: Colors.white,
                      borderStrokeWidth: 2,
                    ),
                ]),
              MarkerLayer(markers: [
                if (_userLocation != null)
                  Marker(
                    point: _userLocation!,
                    width: 32,
                    height: 32,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isNavigating ? AppColors.gold : AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: const Icon(Icons.navigation, color: Colors.white, size: 18),
                    ),
                  ),
                ..._filteredPlaces.map((p) {
                  final c = _catColor(p.category);
                  final sel = _selectedPlace?.id == p.id;
                  return Marker(point: p.location, width: 42, height: 42, child: GestureDetector(
                    onTap: () => _onPlaceSelected(p),
                    child: Container(
                      decoration: BoxDecoration(
                        color: sel ? AppColors.primary : c,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: sel ? 3 : 2),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: Center(child: Text(_catIcon(p.category), style: TextStyle(fontSize: sel ? 20 : 16))),
                    ),
                  ));
                }),
              ]),
            ],
          ),
          if (_locationLoading && _userLocation == null)
            Positioned(top: 8, left: 16, right: 16, child: _locationBanner()),
          if (_isSearching && _searchResults.isNotEmpty)
            Positioned(top: 8, left: 16, right: 16, child: _searchDropdown()),
          if (_showRoutePanel && _route != null) _routePanel()
          else if (_selectedPlace != null) _placePanel(),
        ])),
      ]),
    );
  }

  Widget _locationBanner() {
    final l = AppLocalizations.of(context);
    return AppCard(
      padding: const EdgeInsets.all(12),
        child: Row(children: [
          const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
          const SizedBox(width: 12),
          Text(l.locating, style: const TextStyle(color: Colors.white, fontSize: 14)),
          const Spacer(),
          TextButton(
            onPressed: _initLocation,
            child: Text(l.retry, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ]),
      );
  }

  Widget _buildTopBar(AppLocalizations l) {
    return Container(
      color: Colors.white, padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(children: [
        SizedBox(height: 38, child: TextField(
          controller: _searchCtrl,
          decoration: InputDecoration(
            hintText: l.searchMapHint,
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _searchCtrl.clear(); setState(() => _isSearching = false); })
                : null,
            isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
          ),
        )),
        const SizedBox(height: 6),
        SizedBox(height: 34, child: ListView(scrollDirection: Axis.horizontal, children: [
          ...[l.allItems, 'Istanbul', 'Antalya'].map((c) {
            final sel = (_selectedCity == 'all' && c == l.allItems) || _selectedCity.toLowerCase() == c.toLowerCase();
            return Padding(padding: const EdgeInsets.only(right: 6), child: ChoiceChip(
              label: Text(c, style: const TextStyle(fontSize: 12)), selected: sel,
              onSelected: (_) { setState(() { _selectedCity = c == l.allItems ? 'all' : c.toLowerCase(); _filterPlaces(); }); },
              visualDensity: VisualDensity.compact, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ));
          }),
          ...MapPlace.categories.where((c) => c != 'Tout').map((cat) {
            final sel = _selectedCategory == cat;
            return Padding(padding: const EdgeInsets.only(right: 6), child: ChoiceChip(
              label: Row(mainAxisSize: MainAxisSize.min, children: [Text('${_catIcon(cat)} ', style: const TextStyle(fontSize: 12)), Text(cat, style: const TextStyle(fontSize: 11))]),
              selected: sel, selectedColor: _catColor(cat),
              labelStyle: TextStyle(color: sel ? Colors.white : null),
              onSelected: (_) { setState(() { _selectedCategory = _selectedCategory == cat ? 'Tout' : cat; _filterPlaces(); }); },
              visualDensity: VisualDensity.compact, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ));
          }),
        ])),
      ]),
    );
  }

  Widget _searchDropdown() => Card(margin: EdgeInsets.zero, elevation: 8,
    child: SizedBox(height: 200, child: ListView.builder(
      itemCount: _searchResults.length > 5 ? 5 : _searchResults.length,
      itemBuilder: (_, i) {
        final p = _searchResults[i];
        return ListTile(dense: true, leading: Text(_catIcon(p.category), style: const TextStyle(fontSize: 20)),
          title: Text(p.name, style: const TextStyle(fontSize: 14)),
          subtitle: Text('${p.city} \u{2022} ${p.category}', style: const TextStyle(fontSize: 12)),
          onTap: () { _onPlaceSelected(p); _searchCtrl.clear(); setState(() => _isSearching = false); });
      },
    )),
  );

  Widget _placePanel() {
    final l = AppLocalizations.of(context);
    final p = _selectedPlace!;
    final c = _catColor(p.category);
    return Positioned(bottom: 0, left: 0, right: 0,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -4))]),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
        child: DraggableScrollableSheet(initialChildSize: 0.35, minChildSize: 0.15, maxChildSize: 0.6, expand: false,
          builder: (_, scrollCtrl) => ListView(controller: scrollCtrl, padding: const EdgeInsets.all(20), children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 12),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(_catIcon(p.category), style: const TextStyle(fontSize: 24))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: Text(p.category, style: TextStyle(fontSize: 12, color: c))),
                  const SizedBox(width: 8),
                  const Icon(Icons.star, size: 18, color: Color(0xFFFFB800)),
                  Text(' ${p.rating.toStringAsFixed(1)} (${p.reviewCount > 999 ? '${(p.reviewCount / 1000).toStringAsFixed(1)}k' : p.reviewCount.toString()})'),
                ]),
              ])),
              IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _selectedPlace = null)),
            ]),
            const SizedBox(height: 12),
            Text(p.description, style: const TextStyle(fontSize: 14, height: 1.5, color: const Color(0xFF6B7280))),
            const SizedBox(height: 12),
            if (p.address != null) _il(Icons.location_on, p.address!),
            if (p.openingHours != null) _il(Icons.access_time, '${p.openingHours} - ${p.closingHours}'),
            if (p.metroStation != null) _il(Icons.subway, p.metroStation!),
            if (p.entranceFee != null && p.entranceFee!.isNotEmpty) _il(Icons.monetization_on, p.entranceFee!),
            const SizedBox(height: 8),
            Wrap(spacing: 4, runSpacing: 4, children: p.tags.take(8).map((t) => Chip(
              label: Text(t, style: const TextStyle(fontSize: 10)),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, visualDensity: VisualDensity.compact, padding: EdgeInsets.zero,
            )).toList()),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: () => _openGoogleMaps(p.location), icon: const Icon(Icons.directions, size: 18), label: Text(l.itinerary, style: const TextStyle(fontSize: 13)))),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton.icon(
                onPressed: () => _calculateRoute(p),
                icon: _isRouting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.navigation, size: 18),
                label: Text(_isRouting ? l.calculating : l.goThere, style: const TextStyle(fontSize: 13)),
              )),
              if (p.website != null) const SizedBox(width: 4),
              if (p.website != null) IconButton(icon: const Icon(Icons.language, size: 22), onPressed: () => launchUrl(Uri.parse(p.website!)), tooltip: l.website),
              if (p.phone != null) IconButton(icon: const Icon(Icons.phone, size: 22), onPressed: () => launchUrl(Uri.parse('tel:${p.phone}')), tooltip: l.call),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _il(IconData icon, String text) => Padding(padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [Icon(icon, size: 16, color: Color(0xFF6B7280)), const SizedBox(width: 6), Expanded(child: Text(text, style: const TextStyle(fontSize: 13)))]) );

  Widget _routePanel() {
    final l = AppLocalizations.of(context);
    if (_route == null) return const SizedBox.shrink();
    final r = _route!;
    return Positioned(bottom: 0, left: 0, right: 0,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -4))]),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 0), child: Column(children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 12),
            Row(children: [
              Container(padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(_isNavigating ? Icons.navigation : Icons.directions, color: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${r.distanceFormatted} \u{2022} ${r.durationFormatted}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(children: [
                  _pc('walking', '\u{1F6B6}'), const SizedBox(width: 4),
                  _pc('driving', '\u{1F697}'), const SizedBox(width: 4),
                  _pc('taxi', '\u{1F695}'),
                ]),
              ])),
              Column(children: [
                if (!_isNavigating && _userLocation != null)
                  IconButton(
                    icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.success),
                    onPressed: _startNavigation,
                    tooltip: l.startNavigation,
                  ),
                if (_isNavigating)
                  IconButton(
                    icon: const Icon(Icons.stop_circle_rounded, color: AppColors.error),
                    onPressed: _stopNavigation,
                    tooltip: l.stopNavigation,
                  ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _showRoutePanel = false)),
              ]),
            ]),
            if (_isNavigating && _currentStepIndex >= 0 && _currentStepIndex < r.steps.length)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.turn_slight_right_rounded, color: AppColors.gold, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    r.steps[_currentStepIndex].instruction,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  )),
                ]),
              ),
            const Divider(height: 16),
          ])),
          if (r.steps.isNotEmpty)
            Expanded(child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              itemCount: r.steps.length,
              itemBuilder: (_, i) {
                final s = r.steps[i];
                final isActive = _isNavigating && i == _currentStepIndex;
                final isPast = _isNavigating && i < _currentStepIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.gold : (isPast ? AppColors.success : AppColors.primary),
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: isPast
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(
                      s.instruction,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: isPast ? AppColors.textHint : AppColors.textPrimary,
                        decoration: isPast ? TextDecoration.lineThrough : null,
                      ),
                    )),
                    Text(
                      '${s.distance.toStringAsFixed(0)}m',
                      style: TextStyle(fontSize: 12, color: isActive ? AppColors.gold : (isPast ? AppColors.textHint : AppColors.textSecondary)),
                    ),
                  ]),
                );
              },
            )),
        ]),
      ),
    );
  }

  List<LatLng> _getRemainingRoute() {
    if (_route == null || _currentStepIndex < 0) return [];
    final stepPoint = _route!.steps[_currentStepIndex].point;
    int closestIdx = 0;
    double minDist = double.infinity;
    for (int i = 0; i < _routePolyline!.length; i++) {
      final d = _distanceCalc.distance(stepPoint, _routePolyline![i]);
      if (d < minDist) {
        minDist = d;
        closestIdx = i;
      }
    }
    return _routePolyline!.sublist(closestIdx);
  }

  Widget _pc(String profile, String emoji) {
    final sel = _routeProfile == profile;
    return GestureDetector(
      onTap: () {
        setState(() => _routeProfile = profile);
        if (_selectedPlace != null) _calculateRoute(_selectedPlace!);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: sel ? AppColors.primary.withValues(alpha: 0.1) : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: sel ? AppColors.primary : const Color(0xFFE5E7EB)),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
