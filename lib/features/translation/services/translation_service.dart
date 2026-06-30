import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:trtravel/core/services/local_storage.dart';
import 'package:trtravel/core/services/logger.dart';
import '../models/translation_phrase.dart';

enum TranslationLanguage {
  french('fr', 'Français', 'FR'),
  turkish('tr', 'Türkçe', 'TR'),
  english('en', 'English', 'US');

  final String code;
  final String label;
  final String locale;
  const TranslationLanguage(this.code, this.label, this.locale);
}

class TranslationService extends ChangeNotifier {
  TranslationLanguage _from = TranslationLanguage.french;
  TranslationLanguage _to = TranslationLanguage.turkish;
  String _inputText = '';
  String _translatedText = '';
  bool _isLoading = false;
  bool _useOffline = true;
  String? _error;

  TranslationLanguage get from => _from;
  TranslationLanguage get to => _to;
  String get inputText => _inputText;
  String get translatedText => _translatedText;
  bool get isLoading => _isLoading;
  bool get useOffline => _useOffline;
  String? get error => _error;
  List<PhraseCategory> get categories => TranslationPhraseBook.all;

  TranslationService() {
    _loadPreferences();
  }

  void _loadPreferences() {
    final savedFrom = LocalStorage.getString('translation_from');
    final savedTo = LocalStorage.getString('translation_to');
    if (savedFrom != null) {
      _from = TranslationLanguage.values.firstWhere(
        (l) => l.code == savedFrom,
        orElse: () => TranslationLanguage.french,
      );
    }
    if (savedTo != null) {
      _to = TranslationLanguage.values.firstWhere(
        (l) => l.code == savedTo,
        orElse: () => TranslationLanguage.turkish,
      );
    }
  }

  void setFrom(TranslationLanguage lang) {
    _from = lang;
    LocalStorage.setString('translation_from', lang.code);
    notifyListeners();
  }

  void setTo(TranslationLanguage lang) {
    _to = lang;
    LocalStorage.setString('translation_to', lang.code);
    notifyListeners();
  }

  void swapLanguages() {
    final temp = _from;
    _from = _to;
    _to = temp;
    _inputText = _translatedText;
    _translatedText = _inputText;
    LocalStorage.setString('translation_from', _from.code);
    LocalStorage.setString('translation_to', _to.code);
    notifyListeners();
  }

  void setInput(String text) {
    _inputText = text;
    notifyListeners();
  }

  Future<void> translate() async {
    if (_inputText.trim().isEmpty) {
      _translatedText = '';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // First try offline dictionary
      final offlineResult = TranslationPhraseBook.translate(
        _inputText,
        from: _from.code,
        to: _to.code,
      );

      if (offlineResult.isNotEmpty) {
        _translatedText = offlineResult;
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Fall back to online API
      if (!_useOffline) {
        await _translateOnline();
      } else {
        _translatedText = 'Traduction non disponible hors ligne';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      LogService.error('Translation', 'Failed to translate', e);
      _error = 'Erreur de traduction. Veuillez réessayer.';
      _translatedText = '';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _translateOnline() async {
    final url = Uri.parse(
      'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(_inputText)}&langpair=${_from.code}|${_to.code}',
    );
    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _translatedText = data['responseData']?['translatedText'] as String? ?? '';
      if (_translatedText.isEmpty) {
        throw Exception('Empty translation response');
      }
    } else {
      throw Exception('Translation API error: ${response.statusCode}');
    }
  }

  void setOfflineMode(bool offline) {
    _useOffline = offline;
    notifyListeners();
  }

  void clear() {
    _inputText = '';
    _translatedText = '';
    _error = null;
    notifyListeners();
  }
}
