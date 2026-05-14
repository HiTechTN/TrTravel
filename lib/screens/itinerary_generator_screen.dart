import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../services/itinerary_generator_service.dart';
import '../models/place.dart';
import '../models/generated_itinerary.dart';

class ItineraryGeneratorScreen extends StatefulWidget {
  const ItineraryGeneratorScreen({super.key});

  @override
  State<ItineraryGeneratorScreen> createState() => _ItineraryGeneratorScreenState();
}

class _ItineraryGeneratorScreenState extends State<ItineraryGeneratorScreen> {
  final Set<String> _selectedPreferences = {};
  int _selectedDays = 3;
  String _selectedCity = 'Istanbul';
  bool _isGenerating = false;
  GeneratedItinerary? _currentItinerary;
  List<GeneratedItinerary> _savedItineraries = [];

  @override
  void initState() {
    super.initState();
    _loadSavedItineraries();
  }

  Future<void> _loadSavedItineraries() async {
    final service = context.read<ItineraryGeneratorService>();
    final itineraries = await service.getSavedItineraries();
    if (mounted) {
      setState(() {
        _savedItineraries = itineraries;
        if (itineraries.isNotEmpty) {
          _currentItinerary = itineraries.last;
        }
      });
    }
  }

  Future<void> _generateItinerary() async {
    if (_isGenerating) return;
    
    HapticFeedback.mediumImpact();
    setState(() => _isGenerating = true);
    
    try {
      final service = context.read<ItineraryGeneratorService>();
      final itinerary = await service.generateItinerary(
        preferences: _selectedPreferences.toList(),
        days: _selectedDays,
        city: _selectedCity,
      );
      
      if (mounted) {
        setState(() {
          _currentItinerary = itinerary;
          _savedItineraries.add(itinerary);
          _isGenerating = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Itinéraire "${itinerary.title}" généré avec succès!'),
            backgroundColor: const Color(0xFF43A047),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la génération: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteItinerary(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cet itinéraire?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final service = context.read<ItineraryGeneratorService>();
      await service.deleteItinerary(id);
      setState(() {
        _savedItineraries.removeWhere((i) => i.id == id);
        if (_currentItinerary?.id == id) {
          _currentItinerary = _savedItineraries.isNotEmpty ? _savedItineraries.last : null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ItineraryGeneratorService>();
    final preferences = service.availablePreferences;
    final cities = service.availableCities;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFFE30A17),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFE30A17), Color(0xFFCC0815)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                            SizedBox(width: 12),
                            Text(
                              'Générateur d\'itinéraire',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Créez un planning personnalisé pour votre voyage',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSection(
                    title: 'Ville destination',
                    icon: Icons.location_city,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: cities.map((city) => ChoiceChip(
                        label: Text(city),
                        selected: _selectedCity == city,
                        selectedColor: const Color(0xFFE30A17).withValues(alpha: 0.15),
                        labelStyle: TextStyle(
                          color: _selectedCity == city ? const Color(0xFFE30A17) : Colors.grey[700],
                          fontWeight: _selectedCity == city ? FontWeight.w700 : FontWeight.w500,
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedCity = city);
                        },
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Durée du voyage',
                    icon: Icons.calendar_today,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$_selectedDays',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFE30A17),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedDays == 1 ? 'jour' : 'jours',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _selectedDays.toDouble(),
                          min: 1,
                          max: 7,
                          divisions: 6,
                          activeColor: const Color(0xFFE30A17),
                          onChanged: (value) => setState(() => _selectedDays = value.toInt()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Centres d\'intérêt',
                    icon: Icons.interests,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: preferences.map((pref) => FilterChip(
                        label: Text(_getPreferenceLabel(pref)),
                        selected: _selectedPreferences.contains(pref),
                        selectedColor: const Color(0xFFE30A17).withValues(alpha: 0.15),
                        checkmarkColor: const Color(0xFFE30A17),
                        labelStyle: TextStyle(
                          color: _selectedPreferences.contains(pref) ? const Color(0xFFE30A17) : Colors.grey[700],
                          fontWeight: _selectedPreferences.contains(pref) ? FontWeight.w700 : FontWeight.w500,
                        ),
                        onSelected: (selected) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            if (selected) {
                              _selectedPreferences.add(pref);
                            } else {
                              _selectedPreferences.remove(pref);
                            }
                          });
                        },
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      icon: _isGenerating
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Icon(Icons.auto_awesome, size: 24),
                      label: Text(
                        _isGenerating ? 'Génération en cours...' : 'Générer mon itinéraire',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE30A17),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _isGenerating ? null : _generateItinerary,
                    ),
                  ),
                  if (_currentItinerary != null) ...[
                    const SizedBox(height: 24),
                    _buildItineraryPreview(_currentItinerary!),
                  ],
                  if (_savedItineraries.length > 1) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Itinéraires sauvegardés',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    ..._savedItineraries.reversed.skip(1).map((it) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE30A17).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.route, color: Color(0xFFE30A17), size: 20),
                        ),
                        title: Text(it.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${it.duration} jours • ${it.days.fold(0, (sum, d) => sum + d.places.length)} lieux'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () => _deleteItinerary(it.id),
                        ),
                        onTap: () => setState(() => _currentItinerary = it),
                      ),
                    )),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFFE30A17)),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildItineraryPreview(GeneratedItinerary itinerary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE30A17).withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE30A17).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.route, color: Color(0xFFE30A17), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itinerary.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      '${itinerary.duration} jours • ${itinerary.days.fold(0, (sum, d) => sum + d.places.length)} lieux',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 14),
                    SizedBox(width: 4),
                    Text('Généré', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...itinerary.days.asMap().entries.map((entry) {
            final idx = entry.key;
            final day = entry.value;
            final dayColor = [
              const Color(0xFFE30A17),
              const Color(0xFF003B66),
              const Color(0xFF43A047),
              const Color(0xFFFF6D00),
              const Color(0xFF8E24AA),
              const Color(0xFF1E88E5),
              const Color(0xFFD81B60),
            ][idx % 7];
            
            return ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 8),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: dayColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${idx + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              title: Text('Jour ${idx + 1}', style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(
                '${day.places.length} lieux • ~${day.totalDuration.toStringAsFixed(1)}h',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              children: day.places.map((place) {
                return Container(
                  margin: const EdgeInsets.only(left: 36, bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(_getCategoryIcon(place.category), size: 16, color: dayColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(place.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            Text(place.description, style: TextStyle(fontSize: 11, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      Text('${place.rating} ★', style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 8),
          _buildMapPreview(itinerary),
        ],
      ),
    );
  }

  Widget _buildMapPreview(GeneratedItinerary itinerary) {
    final allPlaces = <LatLng>[];
    for (final day in itinerary.days) {
      for (final place in day.places) {
        if (place.latitude != 0 && place.longitude != 0) {
          allPlaces.add(LatLng(place.latitude, place.longitude));
        }
      }
    }

    if (allPlaces.length < 2) return const SizedBox.shrink();

    return Container(
      height: 180,
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(
                allPlaces.map((p) => p.latitude).reduce((a, b) => a + b) / allPlaces.length,
                allPlaces.map((p) => p.longitude).reduce((a, b) => a + b) / allPlaces.length,
              ),
              initialZoom: 11,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.trtravel.app',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: allPlaces,
                    strokeWidth: 3,
                    color: const Color(0xFFE30A17).withValues(alpha: 0.6),
                  ),
                ],
              ),
              MarkerLayer(
                markers: allPlaces.asMap().entries.map((e) {
                  return Marker(
                    point: e.value,
                    width: 30,
                    height: 30,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE30A17),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          '${e.key + 1}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.route, size: 12, color: Color(0xFFE30A17)),
                  const SizedBox(width: 4),
                  Text(
                    '${allPlaces.length} étapes',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPreferenceLabel(String pref) {
    final labels = {
      'historical': 'Histoire',
      'religious': 'Religion',
      'nature': 'Nature',
      'beach': 'Plage',
      'museum': 'Musée',
      'shopping': 'Shopping',
      'food': 'Gastronomie',
      'adventure': 'Aventure',
    };
    return labels[pref] ?? pref;
  }

  IconData _getCategoryIcon(String category) {
    final icons = {
      'historical': Icons.account_balance,
      'religious': Icons.church,
      'nature': Icons.park,
      'beach': Icons.beach_access,
      'museum': Icons.museum,
      'shopping': Icons.shopping_bag,
      'food': Icons.restaurant,
      'adventure': Icons.hiking,
      'landmark': Icons.location_on,
      'village': Icons.home,
      'palace': Icons.castle,
      'old_town': Icons.streetview,
      'port': Icons.directions_boat,
    };
    return icons[category] ?? Icons.place;
  }
}