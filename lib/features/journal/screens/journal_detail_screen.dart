import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_radius.dart';
import 'package:trtravel/shared/widgets/widgets.dart';
import 'package:trtravel/l10n/app_localizations.dart';
import '../services/journal_service.dart';
import '../models/journal_entry.dart';

class JournalDetailScreen extends StatelessWidget {
  final JournalEntry entry;
  const JournalDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final months = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
                    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];

    return AppScaffold(
      appBar: AppBar(
        title: Text(entry.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l.delete),
                  content: const Text('Voulez-vous vraiment supprimer cette entrée ?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
                    TextButton(
                      onPressed: () {
                        context.read<JournalService>().deleteEntry(entry.id);
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      child: Text(l.delete, style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    '${entry.date.day} ${months[entry.date.month - 1]} ${entry.date.year}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  if (entry.location != null) ...[
                    const SizedBox(width: 16),
                    const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(entry.location!, style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              entry.content,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
            if (entry.tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 6,
                  children: entry.tags.map((t) => Chip(label: Text(t))).toList(),
                ),
              ),
            ],
            if (entry.photoPaths.isNotEmpty) ...[
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: entry.photoPaths.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Image.network(entry.photoPaths[i], width: 120, height: 120, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
