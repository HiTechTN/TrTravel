import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_radius.dart';
import 'package:trtravel/l10n/app_localizations.dart';
import 'package:trtravel/shared/widgets/gradient_header.dart';
import 'package:trtravel/features/offline/services/offline_service.dart';
import 'package:trtravel/features/offline/widgets/offline_indicator.dart';
import 'package:trtravel/features/offline/widgets/sync_queue_tile.dart';

class OfflineDashboardScreen extends StatefulWidget {
  const OfflineDashboardScreen({super.key});

  @override
  State<OfflineDashboardScreen> createState() => _OfflineDashboardScreenState();
}

class _OfflineDashboardScreenState extends State<OfflineDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: Column(
        children: [
          GradientHeader(
            title: l.offlineMode,
            subtitle: 'Gérez vos données hors connexion',
            icon: Icons.wifi_off_rounded,
          ),
          Expanded(
            child: Consumer<OfflineService>(
              builder: (_, service, __) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildConnectionCard(service),
                    const SizedBox(height: 16),
                    _buildStatsRow(service),
                    const SizedBox(height: 16),
                    _buildSyncActions(service),
                    if (service.totalQueueCount > 0) ...[
                      const SizedBox(height: 20),
                      _buildQueueSection(service),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionCard(OfflineService service) {
    final online = service.isOnline;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: online
              ? [AppColors.success.withValues(alpha: 0.1), AppColors.success.withValues(alpha: 0.05)]
              : [AppColors.error.withValues(alpha: 0.1), AppColors.error.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: online
              ? AppColors.success.withValues(alpha: 0.2)
              : AppColors.error.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: online
                  ? AppColors.success.withValues(alpha: 0.15)
                  : AppColors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              online ? Icons.wifi : Icons.wifi_off,
              color: online ? AppColors.success : AppColors.error,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  online ? 'Connecté' : 'Hors-ligne',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  online
                      ? 'Les données seront synchronisées automatiquement'
                      : 'Mode hors-ligne actif - Les actions sont mises en file d\'attente',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const OfflineIndicator(),
        ],
      ),
    );
  }

  Widget _buildStatsRow(OfflineService service) {
    return Row(
      children: [
        _buildStatCard(
          icon: Icons.sync_rounded,
          label: 'En attente',
          value: '${service.pendingCount}',
          color: AppColors.warning,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.error_outline,
          label: 'Échecs',
          value: '${service.failedCount}',
          color: AppColors.error,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.storage_rounded,
          label: 'Cache',
          value: service.getCacheSizeFormatted(),
          color: AppColors.info,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncActions(OfflineService service) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: service.isSyncing
                      ? null
                      : () => service.processQueue(),
                  icon: service.isSyncing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync),
                  label: Text(service.isSyncing ? 'Synchronisation...' : 'Synchroniser'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: service.failedCount == 0
                      ? null
                      : () => service.retryFailed(),
                  icon: const Icon(Icons.refresh),
                      label: Text(l.retry),
                ),
              ),
            ],
          ),
          if (service.totalQueueCount > 0) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Vider la file d\'attente'),
                      content: const Text('Voulez-vous supprimer tous les éléments en attente ?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(l.cancel),
                        ),
                        TextButton(
                          onPressed: () {
                            service.clearQueue();
                            Navigator.pop(ctx);
                          },
                          child: const Text('Vider', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete_sweep, color: AppColors.error),
                label: const Text('Vider la file', style: TextStyle(color: AppColors.error)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQueueSection(OfflineService service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'File d\'attente',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.round),
              ),
              child: Text(
                '${service.totalQueueCount}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...service.queue.map((item) => SyncQueueTile(
              item: item,
              onRetry: () => service.retryFailed(),
              onRemove: () {
                service.clearQueue();
              },
            )),
      ],
    );
  }
}
