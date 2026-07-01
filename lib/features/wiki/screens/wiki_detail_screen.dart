import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/shared/widgets/widgets.dart';
import 'package:trtravel/l10n/app_localizations.dart';
import 'package:trtravel/features/assistant/widgets/itinerary_sharing.dart';
import '../models/wiki_models.dart';
import '../widgets/audio_guide.dart';

class WikiDetailScreen extends StatefulWidget {
  final WikiItem item;
  const WikiDetailScreen({super.key, required this.item});

  @override
  State<WikiDetailScreen> createState() => _WikiDetailScreenState();
}

class _WikiDetailScreenState extends State<WikiDetailScreen> {
  @override
  void initState() {
    super.initState();
    WikiAudioGuide.init();
  }

  @override
  void dispose() {
    WikiAudioGuide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final item = widget.item;
    return AppScaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(item.localizedTitle, style: const TextStyle(fontSize: 18)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white24,
                          child: Icon(item.icon, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Text(item.localizedTitle, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              AudioGuideButton(item: item),
              ShareButton(text: '${item.localizedTitle}\n\n${item.localizedDescription}'),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.localizedDescription, style: const TextStyle(fontSize: 16, height: 1.5, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  if (item.price != null || item.hours != null || item.address != null)
                    _buildInfoCards(item),
                  if (item.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    AppCard(
                      padding: const EdgeInsets.all(12),
                      child: Wrap(
                        spacing: 6, runSpacing: 4,
                        children: item.tags.map((t) => Chip(
                          label: Text(t, style: const TextStyle(fontSize: 12)),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        )).toList(),
                      ),
                    ),
                  ],
                  if (item.sections.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    ...item.sections.map((section) => _buildSection(context, section)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards(WikiItem item) {
    return AppCard(
      padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (item.price != null) _infoRow(Icons.monetization_on_rounded, 'Prix', item.price!),
            if (item.hours != null) _infoRow(Icons.access_time_rounded, 'Horaires', item.hours!),
            if (item.address != null) _infoRow(Icons.location_on_rounded, 'Adresse', item.address!),
            if (item.website != null) _actionRow(Icons.language_rounded, 'Site officiel', item.website!, () => launchUrl(Uri.parse(item.website!))),
            if (item.bookingUrl != null) _actionRow(Icons.confirmation_number_rounded, 'Réserver', 'Billets en ligne', () => launchUrl(Uri.parse(item.bookingUrl!), mode: LaunchMode.externalApplication)),
            if (item.phone != null) _actionRow(Icons.phone_rounded, 'Téléphone', item.phone!, () => launchUrl(Uri.parse('tel:${item.phone}'))),
          ],
        ),
      );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: AppColors.textSecondary))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _actionRow(IconData icon, String label, String value, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            SizedBox(width: 80, child: Text(label, style: const TextStyle(color: AppColors.textSecondary))),
            Expanded(
              child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.primary, decoration: TextDecoration.underline)),
            ),
            const Icon(Icons.open_in_new, size: 16, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, WikiSection section) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(child: Text(section.localizedTitle, style: const TextStyle(fontWeight: FontWeight.w600))),
            AudioGuideButton(item: widget.item, section: section),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(section.localizedContent, style: const TextStyle(fontSize: 15, height: 1.6)),
          ),
          if (section.subsections.isNotEmpty)
            ...section.subsections.map((sub) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sub.localizedTitle, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 8),
                  Text(sub.localizedContent, style: const TextStyle(fontSize: 14, height: 1.5)),
                ],
              ),
            )),
        ],
      ),
    );
  }
}
