import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_radius.dart';
import 'package:trtravel/features/offline/services/offline_service.dart';

class OfflineIndicator extends StatelessWidget {
  final bool compact;

  const OfflineIndicator({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<OfflineService>(
      builder: (_, service, __) {
        final online = service.isOnline;
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 12,
            vertical: compact ? 4 : 6,
          ),
          decoration: BoxDecoration(
            color: online
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.round),
            border: Border.all(
              color: online
                  ? AppColors.success.withValues(alpha: 0.3)
                  : AppColors.error.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: compact ? 6 : 8,
                height: compact ? 6 : 8,
                decoration: BoxDecoration(
                  color: online ? AppColors.success : AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: compact ? 4 : 6),
              Text(
                online ? 'En ligne' : 'Hors-ligne',
                style: TextStyle(
                  fontSize: compact ? 11 : 13,
                  fontWeight: FontWeight.w500,
                  color: online ? AppColors.success : AppColors.error,
                ),
              ),
              if (!compact && service.pendingCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.round),
                  ),
                  child: Text(
                    '${service.pendingCount}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
