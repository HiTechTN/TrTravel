import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CameraTranslationService extends ChangeNotifier {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  
  bool _isInitialized = false;
  bool _isProcessing = false;
  String _lastRecognizedText = '';
  String _translatedText = '';
  String _sourceLanguage = 'fr';
  String _targetLanguage = 'tr';
  double _confidence = 0.0;
  String? _errorMessage;
  List<RecognizedTextBlock> _blocks = [];
  
  static const String _sourceLangKey = 'camera_source_lang';
  static const String _targetLangKey = 'camera_target_lang';

  bool get isInitialized => _isInitialized;
  bool get isProcessing => _isProcessing;
  String get lastRecognizedText => _lastRecognizedText;
  String get translatedText => _translatedText;
  double get confidence => _confidence;
  String? get errorMessage => _errorMessage;
  List<RecognizedTextBlock> get blocks => _blocks;
  String get sourceLanguage => _sourceLanguage;
  String get targetLanguage => _targetLanguage;

  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'fr', 'name': 'Français', 'nameTr': 'Fransızca'},
    {'code': 'en', 'name': 'English', 'nameTr': 'İngilizce'},
    {'code': 'tr', 'name': 'Türkçe', 'nameTr': 'Türkçe'},
    {'code': 'de', 'name': 'Deutsch', 'nameTr': 'Almanca'},
    {'code': 'es', 'name': 'Español', 'nameTr': 'İspanyolca'},
    {'code': 'it', 'name': 'Italiano', 'nameTr': 'İtalyanca'},
    {'code': 'ar', 'name': 'العربية', 'nameTr': 'Arapça'},
    {'code': 'ru', 'name': 'Русский', 'nameTr': 'Rusça'},
  ];

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _sourceLanguage = prefs.getString(_sourceLangKey) ?? 'fr';
      _targetLanguage = prefs.getString(_targetLangKey) ?? 'tr';
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to initialize: $e';
      notifyListeners();
    }
  }

  Future<void> setSourceLanguage(String langCode) async {
    _sourceLanguage = langCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sourceLangKey, langCode);
    notifyListeners();
  }

  Future<void> setTargetLanguage(String langCode) async {
    _targetLanguage = langCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_targetLangKey, langCode);
    notifyListeners();
  }

  void swapLanguages() {
    final temp = _sourceLanguage;
    _sourceLanguage = _targetLanguage;
    _targetLanguage = temp;
    notifyListeners();
  }

  Future<String?> processImage(File imageFile) async {
    if (_isProcessing) return null;
    
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      _lastRecognizedText = recognizedText.text;
      _blocks = recognizedText.blocks.map((block) => RecognizedTextBlock(
        text: block.text,
        boundingBox: block.boundingBox,
        lines: block.lines.map((l) => l.text).toList(),
      )).toList();
      
      double totalConfidence = 0;
      int count = 0;
      for (var block in recognizedText.blocks) {
        for (var line in block.lines) {
          totalConfidence += line.confidence ?? 0;
          count++;
        }
      }
      _confidence = count > 0 ? totalConfidence / count : 0;
      
      _translatedText = await _translateText(_lastRecognizedText);
      
      _isProcessing = false;
      notifyListeners();
      return _translatedText;
    } catch (e) {
      _errorMessage = 'Text recognition failed: $e';
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }

  Future<String?> processImageFromPath(String imagePath) async {
    return processImage(File(imagePath));
  }

  Future<String> _translateText(String text) async {
    if (text.isEmpty) return '';
    
    return text;
  }

  String getLanguageName(String code) {
    try {
      return supportedLanguages.firstWhere((l) => l['code'] == code)['name'] ?? code;
    } catch (_) {
      return code;
    }
  }

  String getTranslatedLanguageName(String code) {
    try {
      return supportedLanguages.firstWhere((l) => l['code'] == code)['nameTr'] ?? code;
    } catch (_) {
      return code;
    }
  }

  void clearLastResult() {
    _lastRecognizedText = '';
    _translatedText = '';
    _blocks = [];
    _confidence = 0.0;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _textRecognizer.close();
    super.dispose();
  }
}

class RecognizedTextBlock {
  final String text;
  final Rect boundingBox;
  final List<String> lines;

  RecognizedTextBlock({
    required this.text,
    required this.boundingBox,
    required this.lines,
  });
}