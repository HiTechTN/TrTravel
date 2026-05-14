import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class OfflineService extends ChangeNotifier {
  static const String _offlineModeKey = 'offline_mode';
  static const String _downloadedMapsKey = 'downloaded_maps';
  static const String _downloadedTranslationsKey = 'downloaded_translations';
  static const String _lastSyncKey = 'last_sync';

  bool _isOfflineMode = false;
  final Set<String> _downloadedMaps = {};
  final Set<String> _downloadedTranslations = {};
  DateTime? _lastSync;
  double _downloadProgress = 0.0;
  String _currentDownload = '';
  bool _isDownloading = false;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isOfflineMode = prefs.getBool(_offlineModeKey) ?? false;
    _lastSync = prefs.getString(_lastSyncKey) != null 
      ? DateTime.tryParse(prefs.getString(_lastSyncKey)!) 
      : null;
    
    final mapsList = prefs.getStringList(_downloadedMapsKey);
    if (mapsList != null) _downloadedMaps.addAll(mapsList);
    
    final translationsList = prefs.getStringList(_downloadedTranslationsKey);
    if (translationsList != null) _downloadedTranslations.addAll(translationsList);
  }

  Future<bool> isConnected() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult.any((result) => result != ConnectivityResult.none);
    } catch (_) {
      return true;
    }
  }

  Future<void> checkConnectionAndUpdate() async {
    final connected = await isConnected();
    _isOfflineMode = !connected;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offlineModeKey, _isOfflineMode);
    
    if (connected) {
      await updateLastSync();
    }
  }

  Future<void> setOfflineMode(bool mode) async {
    _isOfflineMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offlineModeKey, mode);
    notifyListeners();
  }

  bool get isOfflineMode => _isOfflineMode;
  bool get isDownloading => _isDownloading;
  String get currentDownload => _currentDownload;
  double get downloadProgress => _downloadProgress;

  static final List<Map<String, String>> availableMapRegions = [
    {'id': 'istanbul', 'name': 'Istanbul', 'country': 'Turquie', 'zoomLevels': '10-16'},
    {'id': 'ankara', 'name': 'Ankara', 'country': 'Turquie', 'zoomLevels': '10-16'},
    {'id': 'izmir', 'name': 'Izmir', 'country': 'Turquie', 'zoomLevels': '10-16'},
    {'id': 'antalya', 'name': 'Antalya', 'country': 'Turquie', 'zoomLevels': '10-16'},
    {'id': 'cappadoce', 'name': 'Cappadoce', 'country': 'Turquie', 'zoomLevels': '10-16'},
    {'id': 'trabzon', 'name': 'Trabzon', 'country': 'Turquie', 'zoomLevels': '10-16'},
  ];

  Future<void> downloadMapRegion(String regionId, String regionName) async {
    if (_isDownloading) return;
    
    _isDownloading = true;
    _downloadProgress = 0.0;
    _currentDownload = 'Téléchargement de la carte $regionName...';
    notifyListeners();

    try {
      final directory = await getApplicationDocumentsDirectory();
      final mapsDir = Directory('${directory.path}/maps/$regionId');
      if (!await mapsDir.exists()) {
        await mapsDir.create(recursive: true);
      }

      _downloadedMaps.add(regionId);
      await _saveDownloadedMaps();
      
      _isDownloading = false;
      _downloadProgress = 0.0;
      _currentDownload = '';
      notifyListeners();
    } catch (e) {
      _isDownloading = false;
      _downloadProgress = 0.0;
      _currentDownload = '';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _saveDownloadedMaps() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_downloadedMapsKey, _downloadedMaps.toList());
  }

  bool isMapDownloaded(String regionId) => _downloadedMaps.contains(regionId);

  Set<String> get downloadedMaps => _downloadedMaps;

  Future<void> downloadTranslationPack(String languageCode, String languageName) async {
    if (_isDownloading) return;
    
    _isDownloading = true;
    _downloadProgress = 0.0;
    _currentDownload = 'Téléchargement des traductions $languageName...';
    notifyListeners();

    try {
      final directory = await getApplicationDocumentsDirectory();
      final translationDir = Directory('${directory.path}/translations/$languageCode');
      if (!await translationDir.exists()) {
        await translationDir.create(recursive: true);
      }

      final phrases = _getCommonPhrases(languageCode);
      final phrasesData = <String, dynamic>{};
      
      int downloaded = 0;
      for (final phrase in phrases.entries) {
        final translated = phrase.value;
        phrasesData[phrase.key] = {
          'original': phrase.value,
          'translated': translated,
        };
        
        downloaded++;
        _downloadProgress = downloaded / phrases.length;
        _currentDownload = '$languageName ($downloaded/${phrases.length} phrases)';
        notifyListeners();
      }

      final file = File('${translationDir.path}/phrases.json');
      await file.writeAsString(json.encode(phrasesData));

      _downloadedTranslations.add(languageCode);
      await _saveDownloadedTranslations();
      
      _isDownloading = false;
      _downloadProgress = 0.0;
      _currentDownload = '';
      notifyListeners();
    } catch (e) {
      _isDownloading = false;
      _downloadProgress = 0.0;
      _currentDownload = '';
      notifyListeners();
      rethrow;
    }
  }

  Map<String, String> _getCommonPhrases(String lang) {
    final all = {
      'fr': {
        'Bonjour': 'Merhaba',
        'Merci': 'Teşekkür ederim',
        'Oui': 'Evet',
        'Non': 'Hayır',
        'Aide': 'Yardım',
        'S\'il vous plaît': 'Lütfen',
        'Excusez-moi': 'Affedersiniz',
        'Je ne comprends pas': 'Anlamıyorum',
        'Où est...': '... nerede?',
        'L\'addition': 'Hesap lütfen',
        'Combien ça coûte?': 'Ne kadar?',
        'Bathroom': 'Tuvalet',
        'Hotel': 'Otel',
        'Restaurant': 'Restoran',
        'Aéroport': 'Havalimanı',
        'Gare': 'İstasyon',
        'Bus': 'Otobüs',
        'Taxi': 'Taksi',
        'Bonsoir': 'İyi akşamlar',
        'Au revoir': 'Hoşçakal',
        'Comment allez-vous?': 'Nasılsınız?',
        'Je m\'appelle...': 'Adım...',
        'Pardon': 'Pardon',
        'Je suis perdu': 'Kayboldum',
        'J\'ai besoin d\'aide': 'Yardıma ihtiyacım var',
        'Le médecin': 'Doktor',
        'Pharmacie': 'Eczane',
        'Hôpital': 'Hastane',
        'Police': 'Polis',
        'Urgence': 'Acil',
        'Eau': 'Su',
        'Nourriture': 'Yemek',
        'L\'hotels': 'Oteller',
        'Prix': 'Fiyat',
        'Pas cher': 'Ucuz',
        'Cher': 'Pahalı',
        'Fermé': 'Kapalı',
        'Ouvert': 'Açık',
      },
    };
    return all[lang] ?? all['fr']!;
  }

  Future<void> removeTranslationPack(String languageCode) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final translationDir = Directory('${directory.path}/translations/$languageCode');
      if (await translationDir.exists()) {
        await translationDir.delete(recursive: true);
      }
    } catch (_) {}

    _downloadedTranslations.remove(languageCode);
    await _saveDownloadedTranslations();
    notifyListeners();
  }

  Future<void> _saveDownloadedTranslations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_downloadedTranslationsKey, _downloadedTranslations.toList());
  }

  bool isTranslationDownloaded(String languageCode) => _downloadedTranslations.contains(languageCode);

  Set<String> get downloadedTranslations => _downloadedTranslations;

  Future<void> clearAllOfflineData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      
      final mapsDir = Directory('${directory.path}/maps');
      if (await mapsDir.exists()) {
        await mapsDir.delete(recursive: true);
      }
      
      final translationsDir = Directory('${directory.path}/translations');
      if (await translationsDir.exists()) {
        await translationsDir.delete(recursive: true);
      }
    } catch (_) {}
    
    _downloadedMaps.clear();
    _downloadedTranslations.clear();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_downloadedMapsKey);
    await prefs.remove(_downloadedTranslationsKey);
    notifyListeners();
  }

  Future<void> updateLastSync() async {
    _lastSync = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, _lastSync!.toIso8601String());
    notifyListeners();
  }

  DateTime? get lastSync => _lastSync;

  double get downloadProgress2 => _downloadProgress;
  String get currentDownload2 => _currentDownload;
  bool get isDownloading2 => _isDownloading;
}