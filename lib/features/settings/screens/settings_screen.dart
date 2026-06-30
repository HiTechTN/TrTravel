import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trtravel/core/services/auth_service.dart';
import 'package:trtravel/core/services/sync_service.dart';
import 'package:trtravel/l10n/app_localizations.dart';
import 'package:trtravel/shared/widgets/gradient_header.dart';
import '../services/settings_service.dart';
import '../services/offline_map_service.dart';
import '../../translation/services/translation_pack_service.dart';
import '../../guide/screens/guide_screen.dart';

const String _appVersion = '4.0.0';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: Column(
        children: [
          GradientHeader(
            title: l.settings,
            subtitle: l.settingsSubtitle,
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
                  _buildSection(l.accountGoogle, [
                    if (!auth.isAuthenticated)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => auth.signInWithGoogle(),
                          icon: const Icon(Icons.g_mobiledata_rounded, color: Color(0xFFE30A17)),
                          label: Text(l.signInGoogle),
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
                        title: Text(auth.displayName ?? ''),
                        subtitle: Text(auth.userEmail ?? '', style: const TextStyle(fontSize: 12)),
                        trailing: TextButton(
                          onPressed: () => auth.signOut(),
                          child: Text(l.signOut, style: const TextStyle(color: Color(0xFFEF4444))),
                        ),
                      ),
                      if (sync.lastSync != null)
                        ListTile(
                          leading: const Icon(Icons.cloud_done_rounded, color: Color(0xFF10B981)),
                          title: Text(l.savedOnGoogle),
                          subtitle: Text(l.lastSync(_formatDate(sync.lastSync!)), style: const TextStyle(fontSize: 12)),
                        ),
                    ],
                  ]),
                  const SizedBox(height: 12),
                  _buildSection(l.general, [
                    _buildSwitch(settings.offlineMode, l.offlineModeToggle, l.offlineModeDesc, (_) => settings.toggleOfflineMode()),
                    _buildSwitch(settings.darkMode, l.darkMode, l.darkModeDesc, (_) => settings.toggleDarkMode()),
                    _buildSwitch(settings.notificationsEnabled, l.notifications, l.notificationsDesc, (_) => settings.toggleNotifications()),
                  ]),
                  const SizedBox(height: 12),
                  _buildSection('🌐 ${l.langOffline}', [
                    ...TranslatableLanguage.values.map((lang) {
                      final downloaded = translation.isModelDownloaded(lang);
                      final progress = translation.getProgress(lang);
                      return ListTile(
                        leading: Icon(downloaded ? Icons.check_circle : Icons.translate, color: downloaded ? const Color(0xFF10B981) : const Color(0xFF9CA3AF)),
                        title: Text('${lang.name} (${lang.code})'),
                        subtitle: downloaded
                            ? Text(l.modelInstalled, style: const TextStyle(fontSize: 12, color: Color(0xFF10B981)))
                            : Text(l.modelProgress(progress.toStringAsFixed(0)), style: const TextStyle(fontSize: 12)),
                        trailing: downloaded
                            ? IconButton(icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)), onPressed: () => translation.deleteModel(lang))
                            : ElevatedButton(onPressed: () => translation.downloadModel(lang), child: Text(l.download)),
                      );
                    }),
                  ]),
                  const SizedBox(height: 12),
                  _buildSection('🗺 ${l.offlineMaps}', [
                    for (int i = 0; i < maps.regionCount; i++)
                      ListTile(
                        leading: Icon(
                          maps.isRegionDownloaded(i) ? Icons.check_circle : Icons.cloud_download_rounded,
                          color: maps.isRegionDownloaded(i) ? const Color(0xFF10B981) : const Color(0xFF9CA3AF),
                        ),
                        title: Text('${maps.getRegionName(i)} (${maps.getRegionSize(i)})'),
                        subtitle: Text(maps.isRegionDownloaded(i) ? l.downloaded : l.downloadOffline,
                            style: const TextStyle(fontSize: 12)),
                        trailing: maps.isRegionDownloaded(i)
                            ? IconButton(icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)), onPressed: () => maps.deleteRegion(i))
                            : ElevatedButton(onPressed: () => maps.downloadRegion(i), child: Text(l.download)),
                      ),
                  ]),
                  const SizedBox(height: 12),
                  _buildSection('📖 ${l.guide}', [
                    ListTile(
                      leading: const Icon(Icons.menu_book_rounded, color: Color(0xFF3B82F6)),
                      title: Text(l.guide),
                      subtitle: Text(l.guideSubtitle, style: const TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GuideScreen())),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  _buildSection('🌐 ${l.about}', [
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: Text(l.appTitle),
                      subtitle: Text(l.appSubtitle, style: const TextStyle(fontSize: 12)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(l.developerBy),
                    ),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: Text(l.appVersion(_appVersion)),
                      subtitle: Text(l.appSubtitle),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  _buildSection('🌐 Langue', [
                    _LanguageSelector(settings: settings),
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

class _LanguageSelector extends StatelessWidget {
  final SettingsService settings;

  const _LanguageSelector({required this.settings});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final lang in _languages)
          RadioListTile<String>(
            title: Text(lang.name),
            subtitle: Text(lang.native, style: const TextStyle(fontSize: 12)),
            value: lang.code,
            groupValue: settings.language,
            onChanged: (v) {
              if (v != null) settings.setLanguage(v);
            },
            activeColor: const Color(0xFFE30A17),
            dense: true,
          ),
      ],
    );
  }
}

const _languages = [
  _LangOption('Français', 'Français', 'fr'),
  _LangOption('English', 'English', 'en'),
  _LangOption('Türkçe', 'Türkçe', 'tr'),
  _LangOption('العربية', 'العربية', 'ar'),
];

class _LangOption {
  final String name;
  final String native;
  final String code;
  const _LangOption(this.name, this.native, this.code);
}
