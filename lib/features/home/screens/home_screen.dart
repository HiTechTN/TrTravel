import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_radius.dart';
import 'package:trtravel/core/utils/context_extensions.dart';
import 'package:trtravel/l10n/app_localizations.dart';
import 'package:trtravel/shared/widgets/gradient_header.dart';
import 'package:trtravel/shared/widgets/section_card.dart';
import 'package:trtravel/features/transport/screens/transport_screen.dart';
import 'package:trtravel/features/budget/screens/budget_screen.dart';
import 'package:trtravel/features/weather/screens/weather_screen.dart';
import 'package:trtravel/features/shopping/screens/shopping_screen.dart';
import 'package:trtravel/features/exchange/screens/exchange_screen.dart';
import 'package:trtravel/features/itinerary/screens/itinerary_list_screen.dart';
import 'package:trtravel/features/currency/services/currency_service.dart';
import 'package:trtravel/features/currency/models/currency_rate.dart';
import 'package:trtravel/features/ui_redesign/widgets/glass_effect.dart';
import 'package:trtravel/features/ui_redesign/widgets/animated_card.dart';
import 'package:trtravel/features/offline/screens/offline_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurrencyService>().updateRates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final quickServices = [
      _ServiceCard(icon: Icons.directions_bus_rounded, label: l.transport, color: AppColors.transport, screen: TransportScreen()),
      _ServiceCard(icon: Icons.account_balance_wallet_rounded, label: l.budget, color: AppColors.success, screen: BudgetScreen()),
      _ServiceCard(icon: Icons.wb_sunny_rounded, label: l.weather, color: AppColors.gold, screen: WeatherScreen()),
      _ServiceCard(icon: Icons.calendar_month_rounded, label: l.itinerary, color: AppColors.primary, screen: ItineraryListScreen()),
      _ServiceCard(icon: Icons.shopping_bag_rounded, label: l.shopping, color: AppColors.shop, screen: ShoppingScreen()),
      _ServiceCard(icon: Icons.currency_exchange_rounded, label: l.change, color: AppColors.mosque, screen: ExchangeScreen()),
    ];

    return Scaffold(
      body: Column(
        children: [
          GradientHeader(
            title: l.welcomeTitle,
            subtitle: l.welcomeSubtitle,
            icon: Icons.flight_rounded,
            height: 180,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 12, bottom: 12),
                  child: Text('⚡ ${l.quickServices}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: quickServices.map((s) => _QuickServiceCard(service: s)).toList(),
                ),
                const SizedBox(height: 20),
                _buildInfoCard(
                  context,
                  icon: Icons.info_rounded,
                  title: l.tipOfDay,
                  subtitle: l.tipContent,
                  color: AppColors.info,
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  context,
                  icon: Icons.wb_sunny_rounded,
                  title: l.weatherIstanbul,
                  subtitle: l.weatherContent,
                  color: AppColors.gold,
                ),
                const SizedBox(height: 12),
                Consumer<CurrencyService>(
                  builder: (_, service, __) {
                    final eurToTry = CurrencyData.convert(1, 'EUR', 'TRY');
                    final usdToTry = CurrencyData.convert(1, 'USD', 'TRY');
                    final eurToTnd = CurrencyData.convert(1, 'EUR', 'TND');
                    final subtitle = service.lastUpdated != null
                        ? '1 € ≈ $eurToTry TL • 1 \$ ≈ $usdToTry TL • 1 € ≈ $eurToTnd TND'
                        : l.rateLoading;
                    return _buildInfoCard(
                      context,
                      icon: Icons.monetization_on_rounded,
                      title: l.rateToday,
                      subtitle: subtitle,
                      color: AppColors.success,
                    );
                  },
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
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => context.push(const OfflineDashboardScreen()),
                  child: _buildInfoCard(
                    context,
                    icon: Icons.cloud_off_rounded,
                    title: l.offlineMode,
                    subtitle: l.offlineDesc,
                    color: AppColors.info,
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
        label: Text(l.addExpense),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required Color color}) {
    return GlassEffect(
      padding: const EdgeInsets.all(4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.md),
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
    return AnimatedCard(
      onTap: () => context.push(service.screen),
      elevation: 1,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        width: (MediaQuery.of(context).size.width - 56) / 3 - 32,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: service.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
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
