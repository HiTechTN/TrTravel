import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/l10n/app_localizations.dart';
import 'package:trtravel/shared/widgets/widgets.dart';
import '../data/shopping_data.dart';

class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppScaffold(
      body: Column(
        children: [
          AppHeader(
            title: l.shopping,
            subtitle: 'Centres commerciaux & Bazars',
            icon: Icons.shopping_bag_rounded,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSection('🏪 Centres Commerciaux - Istanbul',
                    ShoppingData.getByCity('Istanbul').where((c) => c.type == 'Centre Commercial').toList()),
                const SizedBox(height: 16),
                _buildSection('🏪 Centres Commerciaux - Antalya',
                    ShoppingData.getByCity('Antalya').where((c) => c.type == 'Centre Commercial').toList()),
                const SizedBox(height: 16),
                _buildSection('🏛 Bazars & Marchés',
                    ShoppingData.centers.where((c) => c.type == 'Bazar').toList()),
                const SizedBox(height: 16),
                _buildTips(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<ShoppingCenter> centers) {
    if (centers.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ...centers.map((c) => _buildCenterCard(c)),
      ],
    );
  }

  Widget _buildCenterCard(ShoppingCenter center) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            center.type == 'Bazar' ? Icons.store_rounded : Icons.store_mall_directory_rounded,
            color: AppColors.primary,
          ),
        ),
        title: Text(center.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${center.district} • ${center.priceRange ?? "Variable"}'),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(center.description, style: const TextStyle(fontSize: 14, height: 1.5)),
                const SizedBox(height: 12),
                if (center.openingHours != null)
                  _infoRow(Icons.access_time, 'Horaires', center.openingHours!),
                if (center.address.isNotEmpty)
                  _infoRow(Icons.location_on, 'Adresse', center.address),
                if (center.brands.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    children: center.brands.map((b) => Chip(
                      label: Text(b, style: const TextStyle(fontSize: 11)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    )).toList(),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (center.website != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => launchUrl(Uri.parse(center.website!)),
                          icon: const Icon(Icons.language, size: 16),
                          label: const Text('Site web', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          SizedBox(width: 70, child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildTips() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: AppColors.gold),
              SizedBox(width: 8),
              Text('Conseils shopping', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          _tip('Négociez dans les bazars - proposez 50% du prix annoncé'),
          _tip('Les cartes de crédit sont acceptées dans les centres commerciaux'),
          _tip('Préférez le liquide dans les bazars et petites boutiques'),
          _tip('Tax Free: récupérez la TVA (8-18%) à l\'aéroport'),
          _tip('Les tapis et céramiques sont moins chers hors des zones touristiques'),
        ],
      ),
    );
  }

  Widget _tip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, size: 16, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
