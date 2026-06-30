import 'package:flutter/material.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_radius.dart';
import 'package:trtravel/features/offline/models/offline_models.dart';

class SyncQueueTile extends StatelessWidget {
  final OfflineQueueItem item;
  final VoidCallback? onRetry;
  final VoidCallback? onRemove;

  const SyncQueueTile({
    super.key,
    required this.item,
    this.onRetry,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _buildActionIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.collection,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getActionLabel(item.action),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildStatusBadge(),
            if (item.status == QueueStatus.failed && onRetry != null) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                color: AppColors.warning,
                onPressed: onRetry,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
            if (onRemove != null) ...[
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                color: AppColors.textHint,
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcon() {
    IconData icon;
    Color color;

    switch (item.action) {
      case QueueAction.create:
        icon = Icons.add_circle_outline;
        color = AppColors.success;
        break;
      case QueueAction.update:
        icon = Icons.edit_outlined;
        color = AppColors.info;
        break;
      case QueueAction.delete:
        icon = Icons.delete_outline;
        color = AppColors.error;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    String label;

    switch (item.status) {
      case QueueStatus.pending:
        bgColor = AppColors.warning.withValues(alpha: 0.15);
        textColor = AppColors.warning;
        label = 'En attente';
        break;
      case QueueStatus.syncing:
        bgColor = AppColors.info.withValues(alpha: 0.15);
        textColor = AppColors.info;
        label = 'Synchro...';
        break;
      case QueueStatus.failed:
        bgColor = AppColors.error.withValues(alpha: 0.15);
        textColor = AppColors.error;
        label = 'Échec';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.round),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          if (item.retryCount > 0)
            Text(
              'x${item.retryCount}',
              style: TextStyle(
                fontSize: 10,
                color: textColor.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );
  }

  String _getActionLabel(QueueAction action) {
    switch (action) {
      case QueueAction.create:
        return 'Création';
      case QueueAction.update:
        return 'Modification';
      case QueueAction.delete:
        return 'Suppression';
    }
  }
}
