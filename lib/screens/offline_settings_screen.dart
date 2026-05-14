import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/offline_service.dart';

class OfflineSettingsScreen extends StatefulWidget {
  const OfflineSettingsScreen({super.key});

  @override
  State<OfflineSettingsScreen> createState() => _OfflineSettingsScreenState();
}

class _OfflineSettingsScreenState extends State<OfflineSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final service = context.watch<OfflineService>();
    final mapRegions = OfflineService.availableMapRegions;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF546E7A),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF546E7A), Color(0xFF37474F)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                service.isOfflineMode ? Icons.cloud_off : Icons.cloud_done,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Mode hors-ligne',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    service.isOfflineMode ? 'Données en cache' : 'Synchronisé',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.85),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: service.isOfflineMode 
                                  ? Colors.orange.withValues(alpha: 0.2)
                                  : Colors.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    service.isOfflineMode ? Icons.cloud_off : Icons.cloud_done,
                                    size: 16,
                                    color: service.isOfflineMode ? Colors.orange : Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    service.isOfflineMode ? 'Hors-ligne' : 'Connecté',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: service.isOfflineMode ? Colors.orange : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Switch(
                value: service.isOfflineMode,
                activeThumbColor: const Color(0xFF43A047),
                onChanged: (value) => service.setOfflineMode(value),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (service.isDownloading) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE30A17).withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE30A17).withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE30A17)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  service.currentDownload,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: service.downloadProgress,
                              backgroundColor: const Color(0xFFE30A17).withValues(alpha: 0.1),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE30A17)),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(service.downloadProgress * 100).toStringAsFixed(0)}%',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildSection(
                    title: 'Cartes régionales',
                    icon: Icons.map,
                    subtitle: 'Stockage utilisé: ${_formatSize(service.downloadedMaps.length * 50)} MB',
                    child: Column(
                      children: [
                        ...mapRegions.map((region) {
                          final isDownloaded = service.isMapDownloaded(region['id']!);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(14),
                              border: isDownloaded 
                                ? Border.all(color: const Color(0xFF43A047).withValues(alpha: 0.3))
                                : null,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isDownloaded 
                                      ? const Color(0xFF43A047).withValues(alpha: 0.1)
                                      : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.map,
                                    color: isDownloaded ? const Color(0xFF43A047) : Colors.grey[400],
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        region['name']!,
                                        style: const TextStyle(fontWeight: FontWeight.w700),
                                      ),
                                      Text(
                                        'Zoom: ${region['zoomLevels']}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isDownloaded)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF43A047).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle, size: 14, color: Color(0xFF43A047)),
                                        SizedBox(width: 4),
                                        Text(
                                          'Télécharger',
                                          style: TextStyle(fontSize: 11, color: Color(0xFF43A047), fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  service.isDownloading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : IconButton(
                                        icon: const Icon(Icons.download, color: Color(0xFF43A047)),
                                        onPressed: () async {
                                          try {
                                            await service.downloadMapRegion(region['id']!, region['name']!);
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Carte "${region['name']}" téléchargée!'),
                                                  backgroundColor: const Color(0xFF43A047),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Erreur: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    title: 'Traductions offline',
                    icon: Icons.translate,
                    subtitle: '${service.downloadedTranslations.length} packs téléchargés',
                    child: Column(
                      children: [
                        ...[
                          {'code': 'tr', 'name': 'Turc', 'flag': '🇹🇷'},
                          {'code': 'en', 'name': 'Anglais', 'flag': '🇬🇧'},
                          {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
                          {'code': 'de', 'name': 'Allemand', 'flag': '🇩🇪'},
                          {'code': 'es', 'name': 'Espagnol', 'flag': '🇪🇸'},
                        ].map((lang) {
                          final isDownloaded = service.isTranslationDownloaded(lang['code']!);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(14),
                              border: isDownloaded 
                                ? Border.all(color: const Color(0xFF43A047).withValues(alpha: 0.3))
                                : null,
                            ),
                            child: Row(
                              children: [
                                Text(lang['flag']!, style: const TextStyle(fontSize: 28)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    lang['name']!,
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                if (isDownloaded)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF43A047).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle, size: 14, color: Color(0xFF43A047)),
                                        SizedBox(width: 4),
                                        Text(
                                          'Prêt',
                                          style: TextStyle(fontSize: 11, color: Color(0xFF43A047), fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  service.isDownloading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : IconButton(
                                        icon: const Icon(Icons.download, color: Color(0xFF43A047)),
                                        onPressed: () async {
                                          try {
                                            await service.downloadTranslationPack(lang['code']!, lang['name']!);
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Pack "${lang['name']}" téléchargé!'),
                                                  backgroundColor: const Color(0xFF43A047),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Erreur: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Danger zone',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.delete_sweep, size: 20),
                            label: const Text('Effacer toutes les données'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.all(14),
                            ),
                            onPressed: _clearAllData,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF546E7A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF546E7A), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Effacer toutes les données?'),
        content: const Text('Cela supprimera toutes les cartes et traductions téléchargées. Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Effacer', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final service = context.read<OfflineService>();
      await service.clearAllOfflineData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Données effacées avec succès!'),
            backgroundColor: Color(0xFF43A047),
          ),
        );
      }
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}