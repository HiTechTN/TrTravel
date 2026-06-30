import 'package:flutter/material.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/l10n/app_localizations.dart';
import 'package:trtravel/features/map/screens/map_screen.dart';
import 'package:trtravel/features/journal/screens/journal_screen.dart';
import 'package:trtravel/features/translation/screens/translation_screen.dart';
import 'package:trtravel/features/currency/screens/currency_screen.dart';
import 'package:trtravel/features/assistant/screens/assistant_screen.dart';
import 'package:trtravel/features/wiki/screens/wiki_screen.dart';
import 'package:trtravel/features/emergency/screens/emergency_screen.dart';
import 'package:trtravel/features/settings/screens/settings_screen.dart';
import 'package:trtravel/features/itinerary/screens/itinerary_list_screen.dart';
import 'package:trtravel/features/platform/widgets/responsive_layout.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  List<_TabItem> _buildTabs(AppLocalizations l) => [
    _TabItem(icon: Icons.home_rounded, label: l.home),
    _TabItem(icon: Icons.translate_rounded, label: l.translate),
    _TabItem(icon: Icons.calendar_month_rounded, label: l.itinerary),
    _TabItem(icon: Icons.monetization_on_rounded, label: l.change),
    _TabItem(icon: Icons.map_rounded, label: l.map),
    _TabItem(icon: Icons.article_rounded, label: l.journal),
    _TabItem(icon: Icons.auto_awesome_rounded, label: l.assistant),
    _TabItem(icon: Icons.emergency_rounded, label: l.emergency),
    _TabItem(icon: Icons.menu_book_rounded, label: l.wiki),
    _TabItem(icon: Icons.settings_rounded, label: l.settingsTab),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tabs = _buildTabs(l);
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return ResponsiveLayout(
      mobile: (context, width) => Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            HomeScreen(),
            TranslationScreen(),
            ItineraryListScreen(),
            CurrencyScreen(),
            MapScreen(),
            JournalScreen(),
            AssistantScreen(),
            EmergencyScreen(),
            WikiScreen(),
            SettingsScreen(),
          ],
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(bottom: bottomPad > 0 ? 0 : 4),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),
            height: 64 + (bottomPad > 0 ? 0 : 4),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: tabs
                .map((t) => NavigationDestination(
                      icon: Icon(t.icon),
                      selectedIcon: Icon(t.icon, color: AppColors.primary),
                      label: t.label,
                    ))
                .toList(),
          ),
        ),
      ),
      tablet: (context, width) => Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) => setState(() => _currentIndex = index),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Icon(Icons.flight_rounded, color: AppColors.primary, size: 32),
              ),
              destinations: tabs
                  .map((t) => NavigationRailDestination(
                        icon: Icon(t.icon),
                        selectedIcon: Icon(t.icon, color: AppColors.primary),
                        label: Text(t.label, style: const TextStyle(fontSize: 11)),
                      ))
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: const [
                  HomeScreen(),
                  TranslationScreen(),
                  ItineraryListScreen(),
                  CurrencyScreen(),
                  MapScreen(),
                  JournalScreen(),
                  AssistantScreen(),
                  EmergencyScreen(),
                  WikiScreen(),
                  SettingsScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  const _TabItem({required this.icon, required this.label});
}
