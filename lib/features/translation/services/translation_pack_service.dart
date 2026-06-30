import 'package:flutter/foundation.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:trtravel/core/services/local_storage.dart';
import 'package:trtravel/core/services/logger.dart';

enum TranslatableLanguage {
  french('fr', 'Français', 'FR', TranslateLanguage.french),
  turkish('tr', 'Türkçe', 'TR', TranslateLanguage.turkish),
  english('en', 'English', 'US', TranslateLanguage.english);

  final String code;
  final String name;
  final String locale;
  final TranslateLanguage mlLanguage;
  const TranslatableLanguage(this.code, this.name, this.locale, this.mlLanguage);
}

class TranslationPackService extends ChangeNotifier {
  final Map<TranslatableLanguage, bool> _downloaded = {};
  final Map<TranslatableLanguage, double> _progress = {};

  TranslationPackService() {
    for (final lang in TranslatableLanguage.values) {
      _downloaded[lang] = LocalStorage.getBool('model_${lang.code}') ?? false;
      _progress[lang] = _downloaded[lang]! ? 100.0 : 0.0;
    }
  }

  bool isModelDownloaded(TranslatableLanguage lang) => _downloaded[lang] ?? false;
  double getProgress(TranslatableLanguage lang) => _progress[lang] ?? 0;

  Future<void> downloadModel(TranslatableLanguage lang) async {
    if (isModelDownloaded(lang)) return;
    _progress[lang] = 10;
    notifyListeners();

    try {
      final translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.english,
        targetLanguage: lang.mlLanguage,
      );
      _progress[lang] = 50;
      notifyListeners();

      await translator.translateText('test');
      _downloaded[lang] = true;
      _progress[lang] = 100;
      LocalStorage.setBool('model_${lang.code}', true);
      translator.close();
    } catch (e) {
      _downloaded[lang] = false;
      _progress[lang] = 0;
      LogService.error('TranslationPack', 'Failed: $e');
    }
    notifyListeners();
  }

  Future<void> deleteModel(TranslatableLanguage lang) async {
    _downloaded[lang] = false;
    _progress[lang] = 0;
    LocalStorage.setBool('model_${lang.code}', false);
    notifyListeners();
  }

  Future<String> translate(String text, TranslatableLanguage from, TranslatableLanguage to) async {
    if (!isModelDownloaded(from) || !isModelDownloaded(to)) {
      return 'Téléchargez les packs (Paramètres > Langues)';
    }
    try {
      final translator = OnDeviceTranslator(sourceLanguage: from.mlLanguage, targetLanguage: to.mlLanguage);
      final result = await translator.translateText(text);
      translator.close();
      return result;
    } catch (e) {
      return text;
    }
  }

  void clearAll() {
    for (final lang in TranslatableLanguage.values) {
      deleteModel(lang);
    }
  }
}
