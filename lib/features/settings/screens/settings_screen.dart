import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/services/auth_service.dart';
import 'package:trtravel/core/services/sync_service.dart';
import 'package:trtravel/l10n/app_localizations.dart';
import 'package:trtravel/shared/widgets/app_scaffold.dart';
import 'package:trtravel/shared/widgets/app_header.dart';
import 'package:trtravel/shared/widgets/app_card.dart';
import 'package:trtravel/shared/widgets/app_tile.dart';
import 'package:trtravel/shared/widgets/app_section.dart';
import '../services/settings_service.dart';
import '../services/offline_map_service.dart';
import '../../translation/services/translation_pack_service.dart';
import '../../guide/screens/guide_screen.dart';
import '../../translation/models/translation_phrase.dart';

const String _appVersion = '4.0.0';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppScaffold(
      body: Column(
        children: [
          AppHeader(
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
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
                  children: [
                    AppSection(title: l.accountGoogle, children: [
                      if (!auth.isAuthenticated)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => auth.signInWithGoogle(),
                              icon: const Icon(Icons.g_mobiledata_rounded, color: AppColors.primary),
                              label: Text(l.signInGoogle),
                            ),
                          ),
                        ),
                      if (auth.isAuthenticated) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                backgroundImage: auth.photoUrl != null ? NetworkImage(auth.photoUrl!) : null,
                                child: auth.photoUrl == null ? const Icon(Icons.person, color: AppColors.primary) : null,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(auth.displayName ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                    Text(auth.userEmail ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () => auth.signOut(),
                                child: Text(l.signOut, style: const TextStyle(color: AppColors.error)),
                              ),
                            ],
                          ),
                        ),
                        if (sync.lastSync != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: Row(
                              children: [
                                const Icon(Icons.cloud_done_rounded, color: AppColors.success, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  '${l.savedOnGoogle} • ${l.lastSync(_formatDate(sync.lastSync!))}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ]),
                    const SizedBox(height: 12),
                    AppSection(title: l.general, children: [
                      AppSwitchTile(
                        icon: Icons.wifi_off_rounded,
                        iconColor: AppColors.info,
                        title: l.offlineModeToggle,
                        subtitle: l.offlineModeDesc,
                        value: settings.offlineMode,
                        onChanged: (_) => settings.toggleOfflineMode(),
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16),
                      AppSwitchTile(
                        icon: Icons.dark_mode_rounded,
                        iconColor: AppColors.warning,
                        title: l.darkMode,
                        subtitle: l.darkModeDesc,
                        value: settings.darkMode,
                        onChanged: (_) => settings.toggleDarkMode(),
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16),
                      AppSwitchTile(
                        icon: Icons.notifications_rounded,
                        iconColor: AppColors.primary,
                        title: l.notifications,
                        subtitle: l.notificationsDesc,
                        value: settings.notificationsEnabled,
                        onChanged: (_) => settings.toggleNotifications(),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    AppSection(title: '${l.langOffline}', children: [
                      ...TranslatableLanguage.values.map((lang) {
                        final downloaded = translation.isModelDownloaded(lang);
                        final progress = translation.getProgress(lang);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Row(
                            children: [
                              Icon(
                                downloaded ? Icons.check_circle : Icons.translate_rounded,
                                color: downloaded ? AppColors.success : AppColors.textTertiary,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${lang.name} (${lang.code})', style: const TextStyle(fontWeight: FontWeight.w500)),
                                    Text(
                                      downloaded ? l.modelInstalled : l.modelProgress(progress.toStringAsFixed(0)),
                                      style: TextStyle(fontSize: 12, color: downloaded ? AppColors.success : AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              if (downloaded)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                  onPressed: () => translation.deleteModel(lang),
                                )
                              else
                                TextButton(
                                  onPressed: () => translation.downloadModel(lang),
                                  child: Text(l.download),
                                ),
                            ],
                          ),
                        );
                      }),
                    ]),
                    const SizedBox(height: 12),
                    AppSection(title: l.offlineMaps, children: [
                      for (int i = 0; i < maps.regionCount; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Row(
                            children: [
                              Icon(
                                maps.isRegionDownloaded(i) ? Icons.check_circle : Icons.cloud_download_rounded,
                                color: maps.isRegionDownloaded(i) ? AppColors.success : AppColors.textTertiary,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${maps.getRegionName(i)} (${maps.getRegionSize(i)})', style: const TextStyle(fontWeight: FontWeight.w500)),
                                    Text(
                                      maps.isRegionDownloaded(i) ? l.downloaded : l.downloadOffline,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              if (maps.isRegionDownloaded(i))
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                  onPressed: () => maps.deleteRegion(i),
                                )
                              else
                                TextButton(
                                  onPressed: () => maps.downloadRegion(i),
                                  child: Text(l.download),
                                ),
                            ],
                          ),
                        ),
                    ]),
                    const SizedBox(height: 12),
                    AppSection(title: l.guide, children: [
                      AppTile(
                        icon: Icons.menu_book_rounded,
                        iconColor: AppColors.info,
                        title: l.guide,
                        subtitle: l.guideSubtitle,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GuideScreen())),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    AppSection(title: l.about, children: [
                      AppTile(
                        icon: Icons.language_rounded,
                        iconColor: AppColors.primary,
                        title: l.appTitle,
                        subtitle: l.appSubtitle,
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16),
                      AppTile(
                        icon: Icons.person_rounded,
                        iconColor: AppColors.info,
                        title: l.developerBy,
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16),
                      AppTile(
                        icon: Icons.info_outline_rounded,
                        iconColor: AppColors.textSecondary,
                        title: l.appVersion(_appVersion),
                        subtitle: l.appSubtitle,
                      ),
                    ]),
                    const SizedBox(height: 12),
                    AppSection(title: 'Langue', children: [
                      _LanguageSelector(settings: settings),
                    ]),
                  ],
                );
              },
            ),
          ),
        ],
      ),
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
            title: Text(lang.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            subtitle: Text(lang.native, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            value: lang.code,
            groupValue: settings.language,
            onChanged: (v) {
              if (v != null) settings.setLanguage(v);
            },
            activeColor: AppColors.primary,
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
