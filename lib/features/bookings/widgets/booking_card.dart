import 'package:flutter/material.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_radius.dart';
import 'package:trtravel/features/bookings/models/booking_models.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  color: _typeColor().withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(booking.type.emoji, style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.title,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(booking.type.label,
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(width: 8),
                        Icon(Icons.calendar_today, size: 12, color: AppColors.textHint),
                        const SizedBox(width: 3),
                        Text(
                          '${booking.date.day}/${booking.date.month}/${booking.date.year}',
                          style: TextStyle(color: AppColors.textHint, fontSize: 12),
                        ),
                      ],
                    ),
                    if (booking.location.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 12, color: AppColors.textHint),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(booking.location,
                                style: TextStyle(color: AppColors.textHint, fontSize: 12),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (booking.price > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${booking.price.toStringAsFixed(0)} ${booking.currency}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              if (onDelete != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _typeColor() {
    switch (booking.type) {
      case BookingType.hotel:
        return AppColors.hotel;
      case BookingType.activity:
        return AppColors.museum;
      case BookingType.restaurant:
        return AppColors.food;
      case BookingType.transport:
        return AppColors.transport;
    }
  }
}
