import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_radius.dart';
import 'package:trtravel/l10n/app_localizations.dart';
import 'package:trtravel/shared/widgets/widgets.dart';
import '../services/booking_service.dart';
import '../models/booking_models.dart';
import '../widgets/booking_card.dart';
import 'add_booking_screen.dart';

class BookingListScreen extends StatelessWidget {
  const BookingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppScaffold(
      body: Column(
        children: [
          AppHeader(
            title: 'Mes Réservations',
            subtitle: 'Gérez vos hôtels, activités et transports',
            icon: Icons.book_online_rounded,
          ),
          Expanded(
            child: Consumer<BookingService>(
              builder: (_, service, __) {
                if (service.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (service.bookings.isEmpty) {
                  return AppEmpty(
                    icon: Icons.book_online_rounded,
                    title: 'Aucune réservation',
                    subtitle: 'Ajoutez votre première réservation',
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildUpcomingSection(service),
                    const SizedBox(height: 16),
                    _buildTypeFilter(service),
                    const SizedBox(height: 12),
                    ...service.bookings.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: BookingCard(
                        booking: b,
                        onTap: () => _showBookingDetails(context, b),
                        onDelete: () => _confirmDelete(context, b, service),
                      ),
                    )),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddBookingScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUpcomingSection(BookingService service) {
    final upcoming = service.getUpcomingBookings();
    if (upcoming.isEmpty) return const SizedBox.shrink();

    return AppCard(
      margin: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          gradient: const LinearGradient(
            colors: [AppColors.secondary, Color(0xFF005A99)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.notifications_active, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('À venir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            ...upcoming.take(3).map((b) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(b.type.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(b.title,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  Text(
                    '${b.date.day}/${b.date.month} ${b.date.hour}h${b.date.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeFilter(BookingService service) {
    final types = BookingType.values;
    final counts = types.map((t) => service.getBookingsByType(t).length).toList();

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => Chip(
          avatar: Text(types[i].emoji, style: const TextStyle(fontSize: 16)),
          label: Text('${types[i].label} (${counts[i]})'),
        ),
      ),
    );
  }

  void _showBookingDetails(BuildContext context, Booking booking) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(
              color: AppColors.divider, borderRadius: BorderRadius.circular(2),
            ))),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(booking.type.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(booking.type.label, style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _detailRow(Icons.calendar_today, '${booking.date.day}/${booking.date.month}/${booking.date.year}'),
            if (booking.location.isNotEmpty)
              _detailRow(Icons.location_on, booking.location),
            if (booking.price > 0)
              _detailRow(Icons.attach_money, '${booking.price.toStringAsFixed(0)} ${booking.currency}'),
            if (booking.confirmationCode.isNotEmpty)
              _detailRow(Icons.confirmation_number, 'Confirmation: ${booking.confirmationCode}'),
            if (booking.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(booking.description, style: TextStyle(color: AppColors.textSecondary)),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Booking booking, BookingService service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text('Supprimer "${booking.title}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              service.deleteBooking(booking.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
