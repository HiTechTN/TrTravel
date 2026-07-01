import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_radius.dart';
import 'package:trtravel/l10n/app_localizations.dart';
import 'package:trtravel/shared/widgets/app_scaffold.dart';
import 'package:trtravel/shared/widgets/app_card.dart';
import 'package:trtravel/shared/widgets/app_header.dart';
import '../data/exchange_data.dart';

class ExchangeScreen extends StatelessWidget {
  const ExchangeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppScaffold(
      body: Column(
        children: [
          AppHeader(
            title: 'Bureaux de Change',
            subtitle: '30+ bureaux à Istanbul & Antalya',
            icon: Icons.monetization_on_rounded,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _buildBestRates(),
                const SizedBox(height: 16),
                _buildRateChart(),
                const SizedBox(height: 16),
                _buildCitySection('Istanbul', ExchangeData.getByCity('Istanbul')),
                const SizedBox(height: 12),
                _buildCitySection('Antalya', ExchangeData.getByCity('Antalya')),
                const SizedBox(height: 12),
                _buildTips(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestRates() {
    final bestIstanbul = ExchangeData.getBestRate('Istanbul');
    final bestAntalya = ExchangeData.getBestRate('Antalya');

    return AppCard(
      child: Column(
        children: [
          const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 36),
          const SizedBox(height: 8),
          const Text('Meilleurs taux', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('1 € → TL (achat)', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _miniRateCard('Istanbul', bestIstanbul)),
              const SizedBox(width: 12),
              Expanded(child: _miniRateCard('Antalya', bestAntalya)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniRateCard(String city, ExchangeOffice? office) {
    if (office == null) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Text(city, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const Divider(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Achat', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text('${office.buyRate.toStringAsFixed(3)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Vente', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text('${office.sellRate.toStringAsFixed(3)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(office.name,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildRateChart() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Comparateur de taux', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(width: 100, child: Text('', style: TextStyle(fontSize: 12))),
              const Expanded(child: Text('Achat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success))),
              Expanded(child: Text('Vente', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
              Expanded(child: Text('Marge', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
            ],
          ),
          const Divider(height: 8),
          ...ExchangeData.getByCity('Istanbul').take(5).map((o) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(width: 100,
                    child: Text(o.name, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis)),
                Expanded(child: Text(o.buyRate.toStringAsFixed(3),
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: AppColors.success))),
                Expanded(child: Text(o.sellRate.toStringAsFixed(3),
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12))),
                Expanded(child: Text('${(o.sellRate - o.buyRate).toStringAsFixed(3)}',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCitySection(String city, List<ExchangeOffice> offices) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(Icons.location_city_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(city, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                const Spacer(),
                Text('${offices.length} bureaux', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          ...offices.map((office) => _buildOfficeTile(office)),
        ],
      ),
    );
  }

  Widget _buildOfficeTile(ExchangeOffice office) {
    return AppCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      onTap: () => _openDirections(office),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Icon(Icons.currency_exchange_rounded, color: AppColors.success, size: 20),
        ),
        title: Row(
          children: [
            Expanded(child: Text(office.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14))),
            if (office.rating >= 4.5)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(4)),
                child: Text('TOP',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on_rounded, size: 13, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                      child: Text('${office.district} • ${office.address}',
                          style: const TextStyle(fontSize: 11))),
                ],
              ),
              if (office.openingHours != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(office.openingHours!,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('A:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(width: 2),
                Text(office.buyRate.toStringAsFixed(3),
                    style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('V:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(width: 2),
                Text(office.sellRate.toStringAsFixed(3),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  void _openDirections(ExchangeOffice office) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${office.latitude},${office.longitude}&travelmode=walking');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildTips() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: AppColors.info),
              SizedBox(width: 8),
              Text('Conseils change', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          _tip(
              'Comparez toujours entre plusieurs bureaux pour obtenir le meilleur taux'),
          _tip(
              'Évitez les bureaux à l\'aéroport (taux jusqu\'à 5% moins avantageux)'),
          _tip(
              'Les Grands Bazars ont souvent les meilleurs taux - négociez !'),
          _tip(
              'Préférez les bureaux dans les quartiers résidentiels pour de meilleurs taux'),
          _tip(
              '1 € ≈ ${ExchangeData.getBestRate("Istanbul")?.buyRate.toStringAsFixed(2) ?? "35"} TL (moyenne)'),
        ],
      ),
    );
  }

  Widget _tip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_rounded, size: 16, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
