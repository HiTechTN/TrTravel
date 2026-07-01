import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_radius.dart';
import 'package:trtravel/l10n/app_localizations.dart';
import 'package:trtravel/shared/widgets/widgets.dart';
import 'package:trtravel/features/ar/services/ar_service.dart';
import 'package:trtravel/features/ar/models/ar_models.dart';
import 'package:trtravel/features/ar/widgets/ar_overlay.dart';

class ARCameraScreen extends StatefulWidget {
  const ARCameraScreen({super.key});

  @override
  State<ARCameraScreen> createState() => _ARCameraScreenState();
}

class _ARCameraScreenState extends State<ARCameraScreen> {
  bool _showInfo = false;
  ARLandmark? _selectedLandmark;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ARService>().startSession();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppScaffold(
      body: Consumer<ARService>(
        builder: (_, service, __) {
          final nearby = service.getNearbyLandmarks();

          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () {
                                service.endSession();
                                Navigator.pop(context);
                              },
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.near_me, color: Colors.white70, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${nearby.length} lieux',
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: nearby.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.explore, size: 64, color: Colors.white38),
                                    SizedBox(height: 16),
                                    Text('Aucun lieu à proximité',
                                        style: TextStyle(color: Colors.white54, fontSize: 16)),
                                    SizedBox(height: 8),
                                    Text('Déplacez-vous pour découvrir des monuments',
                                        style: TextStyle(color: Colors.white38, fontSize: 14)),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: nearby.length,
                                itemBuilder: (_, i) {
                                  final lm = nearby[i];
                                  final visited = service.isVisited(lm.id);
                                  return _buildLandmarkCard(lm, visited, service);
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_selectedLandmark != null && _showInfo)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                  child: AROverlay(
                    landmark: _selectedLandmark!,
                    onDismiss: () {
                      setState(() {
                        _showInfo = false;
                        _selectedLandmark = null;
                      });
                    },
                    onVisit: () {
                      service.markVisited(_selectedLandmark!.id);
                      setState(() {
                        _showInfo = false;
                        _selectedLandmark = null;
                      });
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLandmarkCard(ARLandmark lm, bool visited, ARService service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withValues(alpha: 0.95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: visited ? const BorderSide(color: AppColors.success, width: 1.5) : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () {
          setState(() {
            _selectedLandmark = lm;
            _showInfo = true;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: _categoryColor(lm.category).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(_categoryIcon(lm.category), style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(lm.name,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        if (visited)
                          const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(_categoryLabel(lm.category),
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    if (lm.distance > 0)
                      Text('${lm.distance.toStringAsFixed(1)} km',
                          style: TextStyle(color: AppColors.textHint, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'mosquée':
        return AppColors.mosque;
      case 'musée':
        return AppColors.museum;
      case 'plage':
        return AppColors.nature;
      case 'shopping':
        return AppColors.shop;
      case 'restaurant':
        return AppColors.food;
      case 'parc':
        return AppColors.nature;
      case 'port':
        return AppColors.transport;
      case 'nature':
        return AppColors.nature;
      default:
        return AppColors.primary;
    }
  }

  String _categoryIcon(String cat) {
    switch (cat) {
      case 'mosquée':
        return '🕌';
      case 'musée':
        return '🏛️';
      case 'plage':
        return '🏖️';
      case 'shopping':
        return '🛍️';
      case 'restaurant':
        return '🍽️';
      case 'parc':
        return '🎡';
      case 'port':
        return '⛵';
      case 'nature':
        return '🌿';
      default:
        return '📍';
    }
  }

  String _categoryLabel(String cat) {
    switch (cat) {
      case 'mosquée':
        return 'Mosquée';
      case 'musée':
        return 'Musée';
      case 'plage':
        return 'Plage';
      case 'shopping':
        return 'Shopping';
      case 'restaurant':
        return 'Restaurant';
      case 'parc':
        return 'Parc';
      case 'port':
        return 'Port / Marina';
      case 'nature':
        return 'Nature';
      default:
        return 'Monument';
    }
  }
}
