import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/offline_map_manager.dart';

class MapDownloadScreen extends StatelessWidget {
  const MapDownloadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartes hors-ligne'),
        backgroundColor: const Color(0xFFE30A17),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<OfflineMapManager>(
        builder: (context, manager, _) {
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE30A17), Color(0xFFCC0815)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Téléchargez les cartes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sélectionnez une région à télécharger pour une utilisation sans internet',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<double>(
                      future: manager.getStorageUsed(),
                      builder: (context, snapshot) {
                        final mb = snapshot.data ?? 0;
                        return Text(
                          'Stockage utilisé: ${mb.toStringAsFixed(1)} MB',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: manager.regions.length,
                  itemBuilder: (context, index) {
                    final region = manager.regions[index];
                    return _buildRegionCard(context, region, manager);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRegionCard(BuildContext context, MapRegion region, OfflineMapManager manager) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: region.isDownloaded
                      ? const Color(0xFF43A047).withValues(alpha: 0.1)
                      : region.isDownloading
                          ? const Color(0xFFE30A17).withValues(alpha: 0.1)
                          : const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(region.emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      region.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${region.cities.join(", ")} • ${region.sizeFormatted}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    if (region.isDownloading) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: region.downloadProgress,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE30A17)),
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        region.progressLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFE30A17),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (region.isDownloaded)
                SizedBox(
                  height: 36,
                  child: OutlinedButton(
                    onPressed: () => _confirmDelete(context, region, manager),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Suppr.', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                  ),
                )
              else if (region.isDownloading)
                const SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(strokeWidth: 3),
                )
              else
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      manager.downloadRegion(region);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE30A17),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('DL', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, MapRegion region, OfflineMapManager manager) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la région?'),
        content: Text('Voulez-vous supprimer les cartes hors-ligne de "${region.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              manager.deleteRegion(region);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
