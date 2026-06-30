import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/services/local_storage.dart';
import 'core/services/auth_service.dart';
import 'core/services/sync_service.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/translation/services/translation_service.dart';
import 'features/translation/services/translation_pack_service.dart';
import 'features/currency/services/currency_service.dart';
import 'features/journal/services/journal_service.dart';
import 'features/assistant/services/assistant_service.dart';
import 'features/settings/services/settings_service.dart';
import 'features/budget/services/budget_service.dart';
import 'features/weather/services/weather_service.dart';
import 'features/settings/services/offline_map_service.dart';
import 'features/itinerary/services/itinerary_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LocalStorage.init();
  runApp(const TrTravelApp());
}

class TrTravelApp extends StatefulWidget {
  const TrTravelApp({super.key});

  @override
  State<TrTravelApp> createState() => _TrTravelAppState();
}

class _TrTravelAppState extends State<TrTravelApp> {
  late SettingsService _settingsService;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _settingsService = SettingsService();
    _authService = AuthService();
    _settingsService.addListener(_onSettingsChanged);
    _authService.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _settingsService.removeListener(_onSettingsChanged);
    _authService.removeListener(_onAuthChanged);
    _settingsService.dispose();
    _authService.dispose();
    super.dispose();
  }

  void _onSettingsChanged() => setState(() {});
  void _onAuthChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _settingsService),
        ChangeNotifierProvider.value(value: _authService),
        ChangeNotifierProvider(create: (_) => SyncService(_authService)),
        ChangeNotifierProvider(create: (_) => TranslationService()),
        ChangeNotifierProvider(create: (_) => CurrencyService()),
        ChangeNotifierProvider(create: (_) => JournalService()),
        ChangeNotifierProvider(create: (_) => AssistantService()),
        ChangeNotifierProvider(create: (_) => BudgetService()),
        ChangeNotifierProvider(create: (_) => WeatherService()),
        ChangeNotifierProvider(create: (_) => OfflineMapService()..init()),
        ChangeNotifierProvider(create: (_) => TranslationPackService()),
        ChangeNotifierProvider(create: (_) => ItineraryService()),
      ],
      child: MaterialApp(
        title: 'TrTravel - Voyage en Turquie',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _settingsService.darkMode ? ThemeMode.dark : ThemeMode.light,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('fr', 'FR'),
          Locale('en', 'US'),
          Locale('tr', 'TR'),
        ],
        locale: const Locale('fr', 'FR'),
        home: const SplashScreen(),
      ),
    );
  }
}
