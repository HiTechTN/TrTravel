import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trtravel/core/utils/context_extensions.dart';
import 'package:trtravel/l10n/app_localizations.dart';
import 'package:trtravel/features/ui_redesign/widgets/modern_scaffold.dart';
import 'package:trtravel/features/ui_redesign/widgets/glass_effect.dart';
import 'package:trtravel/features/ui_redesign/widgets/animated_card.dart';
import 'package:trtravel/shared/widgets/gradient_header.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/features/notifications/services/notification_service.dart';
import 'package:trtravel/features/notifications/widgets/reminder_card.dart';
import 'package:trtravel/features/notifications/screens/notification_settings_screen.dart';

class NotificationsListScreen extends StatelessWidget {
  const NotificationsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ModernScaffold(
      body: Column(
        children: [
          GradientHeader(
            title: l.notifications,
            subtitle: 'Rappels et suggestions',
            icon: Icons.notifications_rounded,
          ),
          Expanded(
            child: Consumer<NotificationService>(
              builder: (_, service, __) {
                final reminders = service.reminders;
                final suggestions = service.suggestions;

                if (reminders.isEmpty && suggestions.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.notifications_off_rounded, size: 48, color: AppColors.textHint),
                        SizedBox(height: 12),
                        Text('Aucune notification', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Rappels',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          if (service.unreadCount > 0)
                            TextButton(
                              onPressed: () => service.markAllAsRead(),
                              child: const Text('Tout marquer lu'),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...reminders.map((r) => ReminderCard(
                      reminder: r,
                      onDismiss: () => service.removeReminder(r.id),
                      onTap: () => service.markAsRead(r.id),
                    )),
                    if (suggestions.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Suggestions',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...suggestions.map((s) => _buildSuggestionCard(context, s, service)),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(const NotificationSettingsScreen()),
        child: const Icon(Icons.settings_rounded),
      ),
    );
  }

  Widget _buildSuggestionCard(BuildContext context, dynamic suggestion, NotificationService service) {
    return GlassEffect(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.lightbulb_rounded, color: AppColors.info, size: 20),
        ),
        title: Text(suggestion.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(suggestion.message, style: const TextStyle(fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.close, size: 18, color: AppColors.textHint),
          onPressed: () {
            service.clearSuggestions();
          },
        ),
      ),
    );
  }
}
