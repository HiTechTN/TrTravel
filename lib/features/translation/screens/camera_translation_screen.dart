import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/shared/widgets/widgets.dart';

class CameraTranslationScreen extends StatefulWidget {
  const CameraTranslationScreen({super.key});

  @override
  State<CameraTranslationScreen> createState() => _CameraTranslationScreenState();
}

class _CameraTranslationScreenState extends State<CameraTranslationScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  String _detectedText = '';
  String? _error;

  static const _dictionary = {
    'merhaba': 'Bonjour',
    'teşekkür ederim': 'Merci',
    'lütfen': 'S\'il vous plaît',
    'evet': 'Oui',
    'hayır': 'Non',
    'hoşça kal': 'Au revoir',
    'güle güle': 'Au revoir',
    'nasılsınız': 'Comment allez-vous?',
    'iyiyim': 'Je vais bien',
    'kaç para': 'Combien ça coûte?',
    'pahalı': 'Cher',
    'ucuz': 'Bon marché',
    'yardım': 'Aide',
    'acil': 'Urgence',
    'hastane': 'Hôpital',
    'eczane': 'Pharmacie',
    'polis': 'Police',
    'restoran': 'Restaurant',
    'tuvalet': 'Toilettes',
    'giriş': 'Entrée',
    'çıkış': 'Sortie',
    'açık': 'Ouvert',
    'kapalı': 'Fermé',
    'sokak': 'Rue',
    'cadde': 'Avenue',
    'meydan': 'Place',
    'köprü': 'Pont',
    'cami': 'Mosquée',
    'müze': 'Musée',
    'saray': 'Palais',
    'plaj': 'Plage',
    'otel': 'Hôtel',
    'market': 'Magasin',
    'su': 'Eau',
    'ekmek': 'Pain',
    'et': 'Viande',
    'tavuk': 'Poulet',
    'balık': 'Poisson',
    'sebze': 'Légumes',
    'meyve': 'Fruits',
    'kahve': 'Café',
    'çay': 'Thé',
    'limonata': 'Limonade',
    'hesap': 'Addition',
    'menü': 'Menu',
    'doktor': 'Médecin',
    'dişçi': 'Dentiste',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    if (state == AppLifecycleState.resumed) {
      _cameraController?.resumePreview();
    } else if (state == AppLifecycleState.paused) {
      _cameraController?.dispose();
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(_cameras!.first, ResolutionPreset.high);
        await _cameraController!.initialize();
        if (mounted) setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      setState(() => _error = 'Caméra non disponible');
    }
  }

  String _translateOffline(String text) {
    final lower = text.toLowerCase().trim();
    if (_dictionary.containsKey(lower)) {
      return _dictionary[lower]!;
    }
    for (final entry in _dictionary.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }
    final words = lower.split(RegExp(r'[\s,;:.!?]+'));
    final translated = <String>[];
    for (final word in words) {
      if (_dictionary.containsKey(word)) {
        translated.add(_dictionary[word]!);
      } else {
        translated.add(word);
      }
    }
    if (translated.join(' ') != lower) {
      return translated.join(' ');
    }
    return text;
  }

  Future<void> _captureAndTranslate() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final picture = await _cameraController!.takePicture();
      final file = File(picture.path);
      final textRecognizer = TextRecognizer();
      final inputImage = InputImage.fromFile(file);
      final recognizedText = await textRecognizer.processImage(inputImage);
      final rawText = recognizedText.text;
      await textRecognizer.close();

      if (mounted) {
        setState(() {
          _detectedText = rawText;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _error = 'Erreur de reconnaissance';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        children: [
          const AppHeader(
            title: 'Traduction Caméra',
            subtitle: 'Scannez le texte - 100% hors-ligne',
            icon: Icons.camera_alt_rounded,
          ),
          Expanded(
            child: Stack(
              children: [
                if (_isCameraInitialized && _cameraController != null)
                  CameraPreview(_cameraController!)
                else
                  _buildPlaceholder(),
                if (_isCameraInitialized)
                  Center(
                    child: Container(
                      width: 300, height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                if (_detectedText.isNotEmpty)
                  Positioned(
                    bottom: 20, left: 16, right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(children: [
                            const Icon(Icons.text_fields, size: 18, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            const Text('Texte détecté:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => setState(() => _detectedText = ''),
                              child: const Icon(Icons.close, size: 18, color: AppColors.textHint),
                            ),
                          ]),
                          const SizedBox(height: 6),
                          Text(_detectedText, style: const TextStyle(fontSize: 16)),
                          const Divider(),
                          Row(children: [
                            const Icon(Icons.translate, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            const Text('Traduction:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ]),
                          const SizedBox(height: 6),
                          Text(_translateOffline(_detectedText),
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.wifi_off, size: 14, color: AppColors.success),
                              SizedBox(width: 4),
                              Text('Traduction hors-ligne', style: TextStyle(fontSize: 11, color: AppColors.success)),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_error != null)
                  Positioned(top: 16, left: 16, right: 16, child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)),
                    child: Text(_error!, style: const TextStyle(color: Colors.white)),
                  )),
                if (_isProcessing)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text('Analyse en cours...', style: TextStyle(color: Colors.white)),
                      ]),
                    ),
                  ),
              ],
            ),
          ),
          if (_isCameraInitialized)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black87,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.flash_on, color: Colors.white),
                    onPressed: () => _cameraController?.setFlashMode(FlashMode.torch),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: _captureAndTranslate,
                    child: Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 32),
                    ),
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                    onPressed: () async {
                      if (_cameras != null && _cameras!.length > 1) {
                        final newCam = _cameras!.firstWhere(
                          (c) => c.lensDirection != _cameraController!.description.lensDirection,
                        );
                        await _cameraController?.dispose();
                        _cameraController = CameraController(newCam, ResolutionPreset.high);
                        await _cameraController!.initialize();
                        if (mounted) setState(() {});
                      }
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.camera_alt, size: 64, color: Colors.white38),
          SizedBox(height: 16),
          Text('Initialisation de la caméra...', style: TextStyle(color: Colors.white54)),
          SizedBox(height: 16),
          CircularProgressIndicator(color: Colors.white38),
        ]),
      ),
    );
  }
}
