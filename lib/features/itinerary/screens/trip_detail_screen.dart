import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/utils/context_extensions.dart';
import 'package:trtravel/l10n/app_localizations.dart';
import 'package:trtravel/features/ui_redesign/widgets/modern_scaffold.dart';
import 'package:trtravel/features/ui_redesign/widgets/glass_effect.dart';
import 'package:trtravel/features/ui_redesign/widgets/animated_card.dart';
import 'package:trtravel/features/itinerary/services/itinerary_service.dart';
import 'package:trtravel/features/itinerary/screens/day_trip_edit_screen.dart';
import 'package:trtravel/shared/widgets/gradient_header.dart';

class TripDetailScreen extends StatelessWidget {
  final String tripId;

  const TripDetailScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Consumer<ItineraryService>(
      builder: (context, service, _) {
        final trip = service.getTrip(tripId);
        if (trip == null) {
          return ModernScaffold(
            appBar: AppBar(title: Text(l.itinerary)),
            body: const Center(child: Text('Voyage introuvable')),
          );
        }

        return ModernScaffold(
          body: Column(
            children: [
              GradientHeader(
                title: trip.title,
                subtitle: trip.description.replaceAll('\n', ' · '),
                icon: Icons.flight_rounded,
                height: 140,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                  onPressed: () => _deleteTrip(context, service, trip.id),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: trip.days.length,
                  itemBuilder: (context, index) {
                    final day = trip.days[index];
                    return _DayCard(
                      day: day,
                      onEdit: () => context.push(DayTripEditScreen(
                        tripId: tripId,
                        dayTripId: day.id,
                      )),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteTrip(BuildContext context, ItineraryService service, String id) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le voyage'),
        content: const Text('Voulez-vous vraiment supprimer cet itinéraire ?'),
        actions: [
          TextButton(onPressed: () => ctx.pop(), child: Text(l.cancel)),
          TextButton(
            onPressed: () {
              service.deleteTrip(id);
              ctx.pop();
              context.pop();
            },
            child: Text(l.delete, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final dynamic day;
  final VoidCallback onEdit;

  const _DayCard({required this.day, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final dayColors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.gold,
      AppColors.success,
      AppColors.mosque,
      AppColors.museum,
      AppColors.food,
      AppColors.shop,
      AppColors.transport,
      AppColors.hotel,
      AppColors.nature,
    ];

    final color = dayColors[day.dayNumber % dayColors.length];

    return GlassEffect(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'J${day.dayNumber}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Text(
          day.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          day.date,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary.withValues(alpha: 0.8)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_rounded, size: 18),
              color: AppColors.textSecondary,
              onPressed: onEdit,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
          ],
        ),
        children: [
          if (day.location.isNotEmpty) ...[
            _buildLocationChip(day.location),
            const SizedBox(height: 8),
          ],
          ...day.entries.map<Widget>((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    entry.time,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.activity,
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildLocationChip(String location) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on_rounded, size: 12, color: AppColors.textSecondary.withValues(alpha: 0.7)),
          const SizedBox(width: 4),
          Text(location, style: TextStyle(fontSize: 11, color: AppColors.textSecondary.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}
