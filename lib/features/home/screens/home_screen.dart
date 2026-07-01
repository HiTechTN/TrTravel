import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_radius.dart';
import 'package:trtravel/core/utils/context_extensions.dart';
import 'package:trtravel/l10n/app_localizations.dart';
import 'package:trtravel/shared/widgets/app_header.dart';
import 'package:trtravel/shared/widgets/app_card.dart';
import 'package:trtravel/shared/widgets/app_tile.dart';
import 'package:trtravel/features/transport/screens/transport_screen.dart';
import 'package:trtravel/features/budget/screens/budget_screen.dart';
import 'package:trtravel/features/weather/screens/weather_screen.dart';
import 'package:trtravel/features/shopping/screens/shopping_screen.dart';
import 'package:trtravel/features/exchange/screens/exchange_screen.dart';
import 'package:trtravel/features/itinerary/screens/itinerary_list_screen.dart';
import 'package:trtravel/features/currency/services/currency_service.dart';
import 'package:trtravel/features/currency/models/currency_rate.dart';
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
      _ServiceItem(icon: Icons.directions_bus_rounded, label: l.transport, color: AppColors.info, screen: const TransportScreen()),
      _ServiceItem(icon: Icons.account_balance_wallet_rounded, label: l.budget, color: AppColors.success, screen: const BudgetScreen()),
      _ServiceItem(icon: Icons.wb_sunny_rounded, label: l.weather, color: AppColors.warning, screen: const WeatherScreen()),
      _ServiceItem(icon: Icons.calendar_month_rounded, label: l.itinerary, color: AppColors.primary, screen: const ItineraryListScreen()),
      _ServiceItem(icon: Icons.shopping_bag_rounded, label: l.shopping, color: AppColors.accent, screen: const ShoppingScreen()),
      _ServiceItem(icon: Icons.currency_exchange_rounded, label: l.change, color: AppColors.mosque, screen: const ExchangeScreen()),
    ];

    return Scaffold(
      body: Column(
        children: [
          AppHeader(
            title: l.welcomeTitle,
            subtitle: l.welcomeSubtitle,
            icon: Icons.flight_rounded,
            height: 180,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              children: [
                _SectionTitle(title: l.quickServices),
                const SizedBox(height: 8),
                _QuickServiceGrid(items: quickServices),
                const SizedBox(height: 24),
                _SectionTitle(title: l.tipOfDay),
                const SizedBox(height: 8),
                AppTile(
                  icon: Icons.lightbulb_rounded,
                  iconColor: AppColors.warning,
                  title: l.tipContent,
                  subtitle: l.tipOfDay,
                ),
                const SizedBox(height: 16),
                _SectionTitle(title: l.weatherIstanbul),
                const SizedBox(height: 8),
                _WeatherCard(l: l),
                const SizedBox(height: 16),
                _SectionTitle(title: l.rateToday),
                const SizedBox(height: 8),
                Consumer<CurrencyService>(
                  builder: (_, service, __) {
                    final eurToTry = CurrencyData.convert(1, 'EUR', 'TRY');
                    final usdToTry = CurrencyData.convert(1, 'USD', 'TRY');
                    final eurToTnd = CurrencyData.convert(1, 'EUR', 'TND');
                    final subtitle = service.lastUpdated != null
                        ? '1 EUR = $eurToTry TL  •  1 USD = $usdToTry TL  •  1 EUR = $eurToTnd TND'
                        : l.rateLoading;
                    return AppTile(
                      icon: Icons.monetization_on_rounded,
                      iconColor: AppColors.success,
                      title: subtitle,
                      subtitle: service.lastUpdated != null ? 'Mis à jour ${service.lastUpdated}' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                _SectionTitle(title: '🇹🇷 ${l.offlineMode}'),
                const SizedBox(height: 8),
                AppTile(
                  icon: Icons.wifi_off_rounded,
                  iconColor: AppColors.info,
                  title: l.offlineMode,
                  subtitle: l.offlineDesc,
                  onTap: () => context.push(const OfflineDashboardScreen()),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(const BudgetScreen()),
        icon: const Icon(Icons.add_rounded),
        label: Text(l.addExpense),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}

class _QuickServiceGrid extends StatelessWidget {
  final List<_ServiceItem> items;
  const _QuickServiceGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildColumn(context, items.sublist(0, 3))),
        const SizedBox(width: 12),
        Expanded(child: _buildColumn(context, items.sublist(3, 6))),
      ],
    );
  }

  Widget _buildColumn(BuildContext context, List<_ServiceItem> items) {
    return Column(
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _QuickServiceCard(item: item),
              ))
          .toList(),
    );
  }
}

class _QuickServiceCard extends StatelessWidget {
  final _ServiceItem item;
  const _QuickServiceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push(item.screen),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 18),
        ],
      ),
    );
  }
}

class _ServiceItem {
  final IconData icon;
  final String label;
  final Color color;
  final Widget screen;
  const _ServiceItem({required this.icon, required this.label, required this.color, required this.screen});
}

class _WeatherCard extends StatelessWidget {
  final AppLocalizations l;
  const _WeatherCard({required this.l});

  @override
  Widget build(BuildContext context) {
    return AppTile(
      icon: Icons.wb_sunny_rounded,
      iconColor: AppColors.warning,
      title: l.weatherContent,
      subtitle: l.weatherIstanbul,
      onTap: () => context.push(const WeatherScreen()),
    );
  }
}
