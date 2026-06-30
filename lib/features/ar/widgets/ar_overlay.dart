import 'package:flutter/material.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_radius.dart';
import 'package:trtravel/features/ar/models/ar_models.dart';

class AROverlay extends StatelessWidget {
  final ARLandmark landmark;
  final VoidCallback onDismiss;
  final VoidCallback onVisit;

  const AROverlay({
    super.key,
    required this.landmark,
    required this.onDismiss,
    required this.onVisit,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(_categoryIcon(landmark.category), style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(landmark.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 2),
                      Text(_categoryLabel(landmark.category),
                          style: TextStyle(color: AppColors.secondary, fontSize: 13)),
                      if (landmark.distance > 0) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.near_me, size: 14, color: AppColors.textHint),
                            const SizedBox(width: 4),
                            Text('${landmark.distance.toStringAsFixed(1)} km',
                                style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            if (landmark.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(landmark.description,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4)),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDismiss,
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Fermer'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onVisit,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Visité'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _categoryIcon(String cat) {
    switch (cat) {
      case 'mosquée': return '🕌';
      case 'musée': return '🏛️';
      case 'plage': return '🏖️';
      case 'shopping': return '🛍️';
      case 'restaurant': return '🍽️';
      case 'parc': return '🎡';
      case 'port': return '⛵';
      case 'nature': return '🌿';
      default: return '📍';
    }
  }

  String _categoryLabel(String cat) {
    switch (cat) {
      case 'mosquée': return 'Mosquée';
      case 'musée': return 'Musée';
      case 'plage': return 'Plage';
      case 'shopping': return 'Shopping';
      case 'restaurant': return 'Restaurant';
      case 'parc': return 'Parc';
      case 'port': return 'Port / Marina';
      case 'nature': return 'Nature';
      default: return 'Monument';
    }
  }
}
