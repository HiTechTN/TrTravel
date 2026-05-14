import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class AppUpdateService extends ChangeNotifier {
  static const String _baseUrl = 'https://api.trtravel.app';
  static const String _versionEndpoint = '/api/v1/version';

  String _currentVersion = '1.0.0';
  String? _latestVersion;
  bool _isUpdateAvailable = false;
  String? _downloadUrl;
  String? _releaseNotes;
  bool _isChecking = false;
  String? _errorMessage;

  String get currentVersion => _currentVersion;
  String get latestVersion => _latestVersion ?? _currentVersion;
  bool get isUpdateAvailable => _isUpdateAvailable;
  String? get downloadUrl => _downloadUrl;
  String? get releaseNotes => _releaseNotes;
  bool get isChecking => _isChecking;
  String? get errorMessage => _errorMessage;

  Future<void> checkForUpdates() async {
    _isChecking = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_versionEndpoint?platform=android&current=$_currentVersion'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = _parseResponse(response.body);
        _latestVersion = data['version'] as String?;
        _downloadUrl = data['downloadUrl'] as String?;
        _releaseNotes = data['releaseNotes'] as String?;
        
        if (_latestVersion != null) {
          _isUpdateAvailable = _compareVersions(_latestVersion!, _currentVersion) > 0;
        }
      } else if (response.statusCode == 404) {
        _latestVersion = _currentVersion;
        _isUpdateAvailable = false;
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
        _latestVersion = _currentVersion;
        _isUpdateAvailable = false;
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      _latestVersion = _currentVersion;
      _isUpdateAvailable = false;
      debugPrint('Error checking for updates: $e');
    }

    _isChecking = false;
    notifyListeners();
  }

  Map<String, dynamic> _parseResponse(String responseBody) {
    try {
      final Map<String, dynamic> data = {};
      
      final versionMatch = RegExp(r'"version"\s*:\s*"([^"]+)"').firstMatch(responseBody);
      if (versionMatch != null) {
        data['version'] = versionMatch.group(1);
      }
      
      final urlMatch = RegExp(r'"downloadUrl"\s*:\s*"([^"]+)"').firstMatch(responseBody);
      if (urlMatch != null) {
        data['downloadUrl'] = urlMatch.group(1);
      }
      
      final notesMatch = RegExp(r'"releaseNotes"\s*:\s*"([^"]+)"').firstMatch(responseBody);
      if (notesMatch != null) {
        data['releaseNotes'] = notesMatch.group(1);
      }
      
      return data;
    } catch (e) {
      return {};
    }
  }

  int _compareVersions(String latest, String current) {
    final latestParts = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    
    for (int i = 0; i < 3; i++) {
      final l = i < latestParts.length ? latestParts[i] : 0;
      final c = i < currentParts.length ? currentParts[i] : 0;
      if (l > c) return 1;
      if (l < c) return -1;
    }
    return 0;
  }

  Future<void> downloadUpdate() async {
    if (_downloadUrl == null) return;
    
    try {
      final uri = Uri.parse(_downloadUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching download URL: $e');
    }
  }

  bool shouldShowUpdateDialog() {
    return _isUpdateAvailable && !_isChecking;
  }

  void dismissUpdate() {
    _isUpdateAvailable = false;
    notifyListeners();
  }

  void resetUpdateState() {
    _isUpdateAvailable = false;
    _latestVersion = null;
    _downloadUrl = null;
    _releaseNotes = null;
    _errorMessage = null;
    notifyListeners();
  }
}