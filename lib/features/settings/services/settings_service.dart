import 'package:flutter/foundation.dart';
import 'package:trtravel/core/services/local_storage.dart';

class _MapRegion {
  final String name;
  final String size;
  bool downloaded;

  _MapRegion(this.name, this.size, this.downloaded);
}

class SettingsService extends ChangeNotifier {
  bool _offlineMode = false;
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  String _language = 'fr';
  double _storageUsed = 0;
  final List<_MapRegion> _regions = [
    _MapRegion('Istanbul', '25 MB', false),
    _MapRegion('Antalya', '18 MB', false),
    _MapRegion('Cappadoce', '12 MB', false),
    _MapRegion('Izmir', '15 MB', false),
    _MapRegion('Ankara', '10 MB', false),
    _MapRegion('Bursa', '8 MB', false),
    _MapRegion('Pamukkale', '6 MB', false),
    _MapRegion('Côte Turquoise', '22 MB', false),
  ];

  bool get offlineMode => _offlineMode;
  bool get darkMode => _darkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  String get language => _language;
  double get storageUsed => _storageUsed;

  SettingsService() {
    LocalStorage.init().then((_) => _load());
  }

  void _load() {
    _offlineMode = LocalStorage.getBool('offline_mode') ?? false;
    _darkMode = LocalStorage.getBool('dark_mode') ?? false;
    _notificationsEnabled = LocalStorage.getBool('notifications') ?? true;
    _language = LocalStorage.getString('language') ?? 'fr';
    _storageUsed = LocalStorage.getDouble('storage_used') ?? 0;
    notifyListeners();
  }

  void toggleOfflineMode() {
    _offlineMode = !_offlineMode;
    LocalStorage.setBool('offline_mode', _offlineMode);
    notifyListeners();
  }

  void toggleDarkMode() {
    _darkMode = !_darkMode;
    LocalStorage.setBool('dark_mode', _darkMode);
    notifyListeners();
  }

  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    LocalStorage.setBool('notifications', _notificationsEnabled);
    notifyListeners();
  }

  void setLanguage(String lang) {
    _language = lang;
    LocalStorage.setString('language', lang);
    notifyListeners();
  }

  int get regionCount => _regions.length;
  String getRegionName(int index) => _regions[index].name;
  String getRegionSize(int index) => _regions[index].size;
  bool isRegionDownloaded(int index) => _regions[index].downloaded;

  void downloadRegion(int index) {
    if (index < _regions.length) {
      _regions[index].downloaded = true;
      _storageUsed += 25;
      LocalStorage.setDouble('storage_used', _storageUsed);
      notifyListeners();
    }
  }

  void deleteRegion(int index) {
    if (index < _regions.length) {
      _regions[index].downloaded = false;
      _storageUsed = (_storageUsed - 25).clamp(0, double.infinity);
      LocalStorage.setDouble('storage_used', _storageUsed);
      notifyListeners();
    }
  }

  void clearAllData() {
    for (final region in _regions) {
      region.downloaded = false;
    }
    _storageUsed = 0;
    LocalStorage.setDouble('storage_used', 0);
    notifyListeners();
  }
}
