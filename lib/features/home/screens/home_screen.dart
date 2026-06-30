import 'package:flutter/material.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/utils/context_extensions.dart';
import 'package:trtravel/shared/widgets/gradient_header.dart';
import 'package:trtravel/shared/widgets/section_card.dart';
import 'package:trtravel/features/transport/screens/transport_screen.dart';
import 'package:trtravel/features/budget/screens/budget_screen.dart';
import 'package:trtravel/features/weather/screens/weather_screen.dart';
import 'package:trtravel/features/shopping/screens/shopping_screen.dart';
import 'package:trtravel/features/exchange/screens/exchange_screen.dart';
import 'package:trtravel/features/itinerary/screens/itinerary_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _quickServices = [
    _ServiceCard(icon: Icons.directions_bus_rounded, label: 'Transport', color: AppColors.transport, screen: TransportScreen()),
    _ServiceCard(icon: Icons.account_balance_wallet_rounded, label: 'Budget', color: AppColors.success, screen: BudgetScreen()),
    _ServiceCard(icon: Icons.wb_sunny_rounded, label: 'Météo', color: AppColors.gold, screen: WeatherScreen()),
    _ServiceCard(icon: Icons.calendar_month_rounded, label: 'Itinéraire', color: AppColors.primary, screen: ItineraryListScreen()),
    _ServiceCard(icon: Icons.shopping_bag_rounded, label: 'Shopping', color: AppColors.shop, screen: ShoppingScreen()),
    _ServiceCard(icon: Icons.currency_exchange_rounded, label: 'Change', color: AppColors.mosque, screen: ExchangeScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const GradientHeader(
            title: 'Bienvenue en Turquie !',
            subtitle: 'Votre voyage commence ici',
            icon: Icons.flight_rounded,
            height: 180,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 4, top: 12, bottom: 12),
                  child: Text('⚡ Services rapides', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _quickServices.map((s) => _QuickServiceCard(service: s)).toList(),
                ),
                const SizedBox(height: 20),
                _buildInfoCard(
                  context,
                  icon: Icons.info_rounded,
                  title: 'Conseil du jour',
                  subtitle: 'Pensez à acheter une Istanbulkart à l\'aéroport pour vos déplacements.',
                  color: AppColors.info,
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  context,
                  icon: Icons.wb_sunny_rounded,
                  title: 'Météo à Istanbul',
                  subtitle: '28°C - Ensoleillé. Idéal pour visiter !',
                  color: AppColors.gold,
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  context,
                  icon: Icons.monetization_on_rounded,
                  title: 'Taux du jour',
                  subtitle: '1 € ≈ 35.20 TL • 1 \$ ≈ 33.10 TL',
                  color: AppColors.success,
                ),
                const SizedBox(height: 12),
                SectionCard(
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.star_rounded, color: AppColors.primary),
                    ),
                    title: const Text('Sainte-Sophie'),
                    subtitle: const Text('Incontournable - Gratuit (mosquée)'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(const BudgetScreen()),
        icon: const Icon(Icons.account_balance_wallet_rounded),
        label: const Text('Ajouter dépense'),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required Color color}) {
    return SectionCard(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
      ),
    );
  }
}

class _ServiceCard {
  final IconData icon;
  final String label;
  final Color color;
  final Widget screen;

  const _ServiceCard({required this.icon, required this.label, required this.color, required this.screen});
}

class _QuickServiceCard extends StatelessWidget {
  final _ServiceCard service;

  const _QuickServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(service.screen),
      child: Container(
        width: (MediaQuery.of(context).size.width - 56) / 3,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: service.color.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: service.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(service.icon, color: service.color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(service.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
