import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/itinerary_service.dart';
import '../models/itinerary.dart';
import 'itinerary_screen.dart';
import 'itinerary_edit_screen.dart';
import 'weather_screen.dart';
import 'prayer_times_screen.dart';
import 'emergency_screen.dart';
import 'packing_checklist_screen.dart';
import 'budget_tracker_screen.dart';
import '../widgets/floating_travel_assistant.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  Future<List<ItineraryItem>>? _itineraryFuture;
  late AnimationController _fabAnimController;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _itineraryFuture = Provider.of<ItineraryService>(context, listen: false).loadItinerary();
    _fabAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimController, curve: Curves.elasticOut),
    );
    _fabAnimController.forward();
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    super.dispose();
  }

  Future<void> _addNewDay() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => const ItineraryEditScreen(),
      ),
    );
    if (result != null && mounted) {
      final service = context.read<ItineraryService>();
      await service.addItineraryDay(result);
      setState(() => _itineraryFuture = service.loadItinerary());
    }
  }

  Future<void> _deleteDay(ItineraryItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce jour?'),
        content: Text('Voulez-vous supprimer "${item.location}" de l\'itinéraire?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final service = context.read<ItineraryService>();
      await service.deleteItineraryDay(item);
      setState(() => _itineraryFuture = service.loadItinerary());
    }
  }

  Future<void> _editDay(ItineraryItem item) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => ItineraryEditScreen(existingItem: item),
      ),
    );
    if (result != null && mounted) {
      final service = context.read<ItineraryService>();
      await service.updateItineraryDay(item, result);
      setState(() => _itineraryFuture = service.loadItinerary());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              bottom: 24,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE30A17), Color(0xFFCC0815)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Voyage en Turquie',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '4 - 14 Juillet 2026',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.flight, color: Colors.white, size: 28),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildStatChip(Icons.calendar_today, '11 Jours', Colors.white),
                    const SizedBox(width: 12),
                    _buildStatChip(Icons.place, '5 Étapes', Colors.white),
                    const SizedBox(width: 12),
                    _buildStatChip(Icons.wb_sunny, '10 Activités', Colors.white),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                _buildDashboardCards(),
                Expanded(
                  child: FutureBuilder<List<ItineraryItem>>(
                    future: _itineraryFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Color(0xFFE30A17)),
                        );
                      } else if (snapshot.hasError) {
                        return _buildEmptyState('Erreur: ${snapshot.error}', Icons.error_outline);
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildEmptyState(
                          'Aucun itinéraire disponible\nAppuyez sur + pour ajouter un jour',
                          Icons.calendar_today,
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final itinerary = snapshot.data![index];
                          final isFirst = index == 0;
                          final isLast = index == snapshot.data!.length - 1;
                          return _buildDayCard(itinerary, index, isFirst, isLast);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation,
        child: FloatingActionButton(
          onPressed: _addNewDay,
          backgroundColor: const Color(0xFFE30A17),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCards() {
    return Container(
      height: 100,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _dashboardCard(
            'M\u00E9t\u00E9o',
            Icons.wb_sunny,
            const Color(0xFF003B66),
            'Pr\u00E9visions',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WeatherScreen())),
          ),
          _dashboardCard(
            'Pri\u00E8re',
            Icons.mosque,
            const Color(0xFF1B5E20),
            'Horaires',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerTimesScreen())),
          ),
          _dashboardCard(
            'Urgences',
            Icons.emergency,
            Colors.red.shade700,
            'Appels',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyScreen())),
          ),
          _dashboardCard(
            'Bagages',
            Icons.checklist,
            const Color(0xFF6A1B9A),
            'Checklist',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PackingChecklistScreen())),
          ),
          _dashboardCard(
            'Budget',
            Icons.account_balance_wallet,
            const Color(0xFFE65100),
            'D\u00E9penses',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetTrackerScreen())),
          ),
        ],
      ),
    );
  }

  Widget _dashboardCard(String title, IconData icon, Color color, String subtitle, VoidCallback onTap) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 6),
                Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey[800])),
                Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(ItineraryItem itinerary, int index, bool isFirst, bool isLast) {
    final dayNumber = index + 1;
    final gradientColors = [
      const Color(0xFFE30A17),
      const Color(0xFF003B66),
      const Color(0xFF1E88E5),
      const Color(0xFF43A047),
      const Color(0xFFFF6D00),
      const Color(0xFF8E24AA),
      const Color(0xFF00ACC1),
      const Color(0xFFE53935),
      const Color(0xFF1A1A2E),
      const Color(0xFF546E7A),
      const Color(0xFFD81B60),
    ];
    final cardColor = gradientColors[index % gradientColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: cardColor.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$dayNumber',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 120,
                  color: cardColor.withValues(alpha: 0.3),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ItineraryScreen(itinerary: itinerary),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: cardColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                itinerary.dayName,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: cardColor,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const Spacer(),
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
                              padding: EdgeInsets.zero,
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editDay(itinerary);
                                } else if (value == 'delete') {
                                  _deleteDay(itinerary);
                                } else if (value == 'map') {
                                  Navigator.pushNamed(context, '/map-day', arguments: itinerary);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'map',
                                  child: Row(
                                    children: [
                                      Icon(Icons.map, size: 18),
                                      SizedBox(width: 8),
                                      Text('Voir sur carte'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 18),
                                      SizedBox(width: 8),
                                      Text('Modifier'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 18, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Supprimer', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          itinerary.location,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          itinerary.date,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (itinerary.activities.isNotEmpty) ...[
                          ...itinerary.activities.take(3).map((activity) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.access_time, size: 14, color: cardColor),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    activity.description,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )),
                          if (itinerary.activities.length > 3)
                            Text(
                              '+${itinerary.activities.length - 3} autres activités',
                              style: TextStyle(
                                fontSize: 12,
                                color: cardColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: cardColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.arrow_forward, size: 14, color: cardColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Détails',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: cardColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}