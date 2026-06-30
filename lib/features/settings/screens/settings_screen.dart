import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trtravel/core/services/auth_service.dart';
import 'package:trtravel/core/services/sync_service.dart';
import 'package:trtravel/shared/widgets/gradient_header.dart';
import '../services/settings_service.dart';
import '../services/offline_map_service.dart';
import '../../translation/services/translation_pack_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const GradientHeader(
            title: 'Paramètres',
            subtitle: 'Hors-ligne, langues, cartes',
            icon: Icons.settings_rounded,
          ),
          Expanded(
            child: Consumer<SettingsService>(
              builder: (_, settings, __) {
                final maps = context.watch<OfflineMapService>();
                final translation = context.watch<TranslationPackService>();
                final auth = context.watch<AuthService>();
                final sync = context.watch<SyncService>();
                return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSection('🔐 Compte Google', [
                    if (!auth.isAuthenticated)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => auth.signInWithGoogle(),
                          icon: const Icon(Icons.g_mobiledata_rounded, color: Color(0xFFE30A17)),
                          label: const Text('Se connecter avec Google'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    if (auth.isAuthenticated) ...[
                      ListTile(
                        leading: auth.photoUrl != null
                            ? CircleAvatar(radius: 18, backgroundImage: NetworkImage(auth.photoUrl!))
                            : const CircleAvatar(radius: 18, child: Icon(Icons.person)),
                        title: Text(auth.displayName ?? 'Utilisateur'),
                        subtitle: Text(auth.userEmail ?? '', style: const TextStyle(fontSize: 12)),
                        trailing: TextButton(
                          onPressed: () => auth.signOut(),
                          child: const Text('Déconnexion', style: TextStyle(color: Color(0xFFEF4444))),
                        ),
                      ),
                      if (sync.lastSync != null)
                        ListTile(
                          leading: const Icon(Icons.cloud_done_rounded, color: Color(0xFF10B981)),
                          title: const Text('Sauvegardé sur Google'),
                          subtitle: Text('Dernière synchro: ${_formatDate(sync.lastSync!)}', style: const TextStyle(fontSize: 12)),
                        ),
                    ],
                  ]),
                  const SizedBox(height: 12),
                  _buildSection('🔧 Général', [
                    _buildSwitch(settings.offlineMode, 'Mode hors-ligne', 'Tout utiliser sans connexion', (_) => settings.toggleOfflineMode()),
                    _buildSwitch(settings.darkMode, 'Mode sombre', 'Thème sombre pour la nuit', (_) => settings.toggleDarkMode()),
                    _buildSwitch(settings.notificationsEnabled, 'Notifications', 'Alertes et conseils de voyage', (_) => settings.toggleNotifications()),
                  ]),
                  const SizedBox(height: 12),
                  _buildSection('🌐 Langues & Traduction offline', [
                    ...TranslatableLanguage.values.map((lang) {
                      final downloaded = translation.isModelDownloaded(lang);
                      final progress = translation.getProgress(lang);
                      return ListTile(
                        leading: Icon(downloaded ? Icons.check_circle : Icons.translate, color: downloaded ? const Color(0xFF10B981) : const Color(0xFF9CA3AF)),
                        title: Text('${lang.name} (${lang.code})'),
                        subtitle: downloaded
                            ? const Text('Modèle installé', style: TextStyle(fontSize: 12, color: Color(0xFF10B981)))
                            : Text('${progress.toStringAsFixed(0)}% - Taille: ~50MB', style: const TextStyle(fontSize: 12)),
                        trailing: downloaded
                            ? IconButton(icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)), onPressed: () => translation.deleteModel(lang))
                            : ElevatedButton(onPressed: () => translation.downloadModel(lang), child: const Text('Télécharger')),
                      );
                    }),
                  ]),
                  const SizedBox(height: 12),
                  _buildSection('🗺 Cartes hors-ligne', [
                    for (int i = 0; i < maps.regionCount; i++)
                      ListTile(
                        leading: Icon(
                          maps.isRegionDownloaded(i) ? Icons.check_circle : Icons.cloud_download_rounded,
                          color: maps.isRegionDownloaded(i) ? const Color(0xFF10B981) : const Color(0xFF9CA3AF),
                        ),
                        title: Text(maps.getRegionName(i) + ' (${maps.getRegionSize(i)})'),
                        subtitle: Text(maps.isRegionDownloaded(i) ? 'Téléchargé' : 'Télécharger pour usage hors-ligne',
                            style: const TextStyle(fontSize: 12)),
                        trailing: maps.isRegionDownloaded(i)
                            ? IconButton(icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)), onPressed: () => maps.deleteRegion(i))
                            : ElevatedButton(onPressed: () => maps.downloadRegion(i), child: const Text('Télécharger')),
                      ),
                  ]),
                  const SizedBox(height: 12),
                  _buildSection('ℹ️ À propos', [
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('TrTravel v2.0'),
                      subtitle: const Text('Votre compagnon de voyage en Turquie'),
                    ),
                  ]),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF6B7280))),
        ),
        ...children,
        const SizedBox(height: 8),
      ]),
    );
  }

  Widget _buildSwitch(bool value, String title, String subtitle, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
      value: value, onChanged: onChanged,
      activeColor: const Color(0xFFE30A17),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
