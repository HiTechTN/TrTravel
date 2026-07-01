import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_radius.dart';
import 'package:trtravel/core/utils/context_extensions.dart';
import 'package:trtravel/l10n/app_localizations.dart';
import 'package:trtravel/shared/widgets/app_scaffold.dart';
import 'package:trtravel/shared/widgets/app_card.dart';
import 'package:trtravel/shared/widgets/app_shimmer.dart';
import 'package:trtravel/shared/widgets/app_header.dart';
import 'package:trtravel/shared/widgets/app_empty.dart';
import 'package:trtravel/features/itinerary/services/itinerary_service.dart';
import 'package:trtravel/features/itinerary/screens/trip_detail_screen.dart';

class ItineraryListScreen extends StatelessWidget {
  const ItineraryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppScaffold(
      body: Column(
        children: [
          AppHeader(
            title: l.itinerary,
            subtitle: 'Votre programme de voyage',
            icon: Icons.map_rounded,
            height: 160,
          ),
          Expanded(
            child: Consumer<ItineraryService>(
              builder: (context, service, _) {
                if (service.isLoading) {
                  return const AppShimmerList(itemCount: 5);
                }
                if (service.trips.isEmpty) {
                  return const AppEmpty(
                    icon: Icons.map_rounded,
                    title: 'Aucun itinéraire',
                    subtitle: 'Votre programme de voyage apparaîtra ici',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: service.trips.length,
                  itemBuilder: (context, index) {
                    final trip = service.trips[index];
                    return _TripCard(trip: trip);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final dynamic trip;

  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final daysCount = trip.days.length;
    final startStr =
        '${trip.startDate.day.toString().padLeft(2, '0')}/${trip.startDate.month.toString().padLeft(2, '0')}/${trip.startDate.year}';
    final endStr =
        '${trip.endDate.day.toString().padLeft(2, '0')}/${trip.endDate.month.toString().padLeft(2, '0')}/${trip.endDate.year}';

    return AppCard(
      onTap: () => context.push(TripDetailScreen(tripId: trip.id)),
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, Color(0xFFE53935)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flight_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        trip.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (trip.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    trip.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _InfoChip(icon: Icons.calendar_today_rounded, label: '$startStr - $endStr'),
                const SizedBox(width: 12),
                _InfoChip(icon: Icons.wb_sunny_rounded, label: '$daysCount jours'),
                if (trip.location.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  _InfoChip(icon: Icons.location_on_rounded, label: trip.location),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
