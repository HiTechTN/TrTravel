import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';
import 'journal_screen.dart';
import 'map_screen.dart';
import 'translation_screen.dart';
import 'currency_screen.dart';
import 'itinerary_generator_screen.dart';
import 'offline_settings_screen.dart';
import 'camera_translation_screen.dart';
import 'exchange_offices_screen.dart';
import 'travel_assistant_screen.dart';
import 'travel_wikis_screen.dart';
import '../widgets/floating_travel_assistant.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    HapticFeedback.selectionClick();
  }

  void _showQuickActions() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) => _buildQuickActionsSheet(),
    );
  }

  Widget _buildQuickActionsSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.flash_on, color: Color(0xFFE30A17), size: 28),
                SizedBox(width: 12),
                Text(
                  'Actions rapides',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildActionTile(
            icon: Icons.translate,
            iconColor: const Color(0xFFE30A17),
            title: 'Traduire texte',
            subtitle: 'Saisissez ou collez du texte',
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 1);
            },
          ),
          _buildActionTile(
            icon: Icons.camera_alt,
            iconColor: const Color(0xFFE30A17),
            title: 'Traduire par caméra',
            subtitle: 'Scannez du texte avec la caméra',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CameraTranslationScreen()));
            },
          ),
          _buildActionTile(
            icon: Icons.currency_exchange,
            iconColor: const Color(0xFF003B66),
            title: 'Convertisseur de devises',
            subtitle: 'Convertissez entre devises',
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 2);
            },
          ),
          _buildActionTile(
            icon: Icons.account_balance,
            iconColor: const Color(0xFF003B66),
            title: 'Bureaux de change',
            subtitle: 'Trouvez le meilleur taux',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ExchangeOfficesScreen()));
            },
          ),
          _buildActionTile(
            icon: Icons.auto_awesome,
            iconColor: const Color(0xFF8E24AA),
            title: 'Générer itinéraire',
            subtitle: 'Créez un planning personnalisé',
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 3);
            },
          ),
          _buildActionTile(
            icon: Icons.support_agent,
            iconColor: const Color(0xFF00838F),
            title: 'Assistant voyage',
            subtitle: 'Planifiez votre voyage parfait',
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 6);
            },
          ),
          _buildActionTile(
            icon: Icons.menu_book,
            iconColor: const Color(0xFF2E7D32),
            title: 'Wiki voyage',
            subtitle: 'Encyclopédie de voyage',
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 7);
            },
          ),
          _buildActionTile(
            icon: Icons.offline_bolt,
            iconColor: const Color(0xFF546E7A),
            title: 'Mode hors-ligne',
            subtitle: 'Gérez vos données offline',
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 8);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFE30A17),
        extendBody: false,
        body: Stack(
          children: [
            // Background gradient layer
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE30A17),
                    Color(0xFFCC0815),
                  ],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
            // Active screen content rendered on top of gradient
            _buildCurrentScreen(),
            // Quick action FAB - positioned above bottom nav
            Positioned(
              right: 20,
              bottom: 88,
              child: _buildFAB(),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              backgroundColor: Colors.white,
              elevation: 0,
              height: 72,
              indicatorColor: const Color(0xFFE30A17).withValues(alpha: 0.1),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined, size: 26),
                  selectedIcon: Icon(Icons.home, size: 26, color: Color(0xFFE30A17)),
                  label: 'Accueil',
                ),
                NavigationDestination(
                  icon: Icon(Icons.translate_outlined, size: 26),
                  selectedIcon: Icon(Icons.translate, size: 26, color: Color(0xFFE30A17)),
                  label: 'Traduire',
                ),
                NavigationDestination(
                  icon: Icon(Icons.currency_exchange_outlined, size: 26),
                  selectedIcon: Icon(Icons.currency_exchange, size: 26, color: Color(0xFFE30A17)),
                  label: 'Change',
                ),
                NavigationDestination(
                  icon: Icon(Icons.route_outlined, size: 26),
                  selectedIcon: Icon(Icons.route, size: 26, color: Color(0xFFE30A17)),
                  label: 'Itinéraire',
                ),
                NavigationDestination(
                  icon: Icon(Icons.map_outlined, size: 26),
                  selectedIcon: Icon(Icons.map, size: 26, color: Color(0xFFE30A17)),
                  label: 'Carte',
                ),
                NavigationDestination(
                  icon: Icon(Icons.book_outlined, size: 26),
                  selectedIcon: Icon(Icons.book, size: 26, color: Color(0xFFE30A17)),
                  label: 'Journal',
                ),
                NavigationDestination(
                  icon: Icon(Icons.support_agent_outlined, size: 26),
                  selectedIcon: Icon(Icons.support_agent, size: 26, color: Color(0xFFE30A17)),
                  label: 'Assistant',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined, size: 26),
                  selectedIcon: Icon(Icons.menu_book, size: 26, color: Color(0xFFE30A17)),
                  label: 'Wiki',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined, size: 26),
                  selectedIcon: Icon(Icons.settings, size: 26, color: Color(0xFFE30A17)),
                  label: 'Paramètres',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    // No bottom padding needed - Scaffold's bottomNavigationBar
    // automatically prevents body from overlapping the nav bar.
    switch (_selectedIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const TranslationScreen();
      case 2:
        return const CurrencyScreen();
      case 3:
        return const ItineraryGeneratorScreen();
      case 4:
        return const MapScreen();
      case 5:
        return const JournalScreen();
      case 6:
        return const TravelAssistantScreen();
      case 7:
        return const TravelWikisScreen();
      case 8:
        return const OfflineSettingsScreen();
      default:
        return const HomeScreen();
    }
  }

  Widget _buildFAB() {
    return FloatingTravelAssistant(onQuickActions: _showQuickActions);
  }
}