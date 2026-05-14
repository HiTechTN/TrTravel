import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppUpdateService extends ChangeNotifier {
  String _currentVersion = '1.0.0';
  String? _latestVersion;
  bool _isUpdateAvailable = false;
  String? _downloadUrl;
  String? _releaseNotes;
  bool _isChecking = false;

  String get currentVersion => _currentVersion;
  String get latestVersion => _latestVersion ?? _currentVersion;
  bool get isUpdateAvailable => _isUpdateAvailable;
  String? get downloadUrl => _downloadUrl;
  String? get releaseNotes => _releaseNotes;
  bool get isChecking => _isChecking;

  Future<void> checkForUpdates() async {
    _isChecking = true;
    notifyListeners();

    try {
      // In production, replace with your actual API endpoint
      // For demo, we'll simulate an update check
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulated response - in production call your backend
      // final response = await http.get(Uri.parse('https://your-api.com/version'));
      
      // For now, simulate no update available
      _latestVersion = _currentVersion;
      _isUpdateAvailable = _compareVersions(_latestVersion!, _currentVersion) > 0;
      
      // Uncomment below to test update notification:
      // _isUpdateAvailable = true;
      // _latestVersion = '1.1.0';
      // _downloadUrl = 'https://example.com/trtravel-v1.1.0.apk';
      // _releaseNotes = 'Bug fixes and new features!\n\n- Improved performance\n- New travel guides\n- Better offline support';
      
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }

    _isChecking = false;
    notifyListeners();
  }

  int _compareVersions(String latest, String current) {
    final latestParts = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    
    for (int i = 0; i < 3; i++) {
      if (latestParts[i] > currentParts[i]) return 1;
      if (latestParts[i] < currentParts[i]) return -1;
    }
    return 0;
  }

  Future<void> downloadUpdate() async {
    if (_downloadUrl == null) return;
    
    // In production, this would trigger the actual download
    // You could use url_launcher or dio to download and install
    
    // For now, we'll just open the download URL in browser
    // import 'package:url_launcher/url_launcher.dart';
    // await launchUrl(Uri.parse(_downloadUrl!));
  }

  // Method to show update dialog
  bool shouldShowUpdateDialog() {
    return _isUpdateAvailable && !_isChecking;
  }

  void dismissUpdate() {
    _isUpdateAvailable = false;
    notifyListeners();
  }
}