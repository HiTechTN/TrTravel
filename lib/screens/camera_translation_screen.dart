import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/camera_translation_service.dart';
import '../services/translation_service.dart';

class CameraTranslationScreen extends StatefulWidget {
  const CameraTranslationScreen({super.key});

  @override
  State<CameraTranslationScreen> createState() => _CameraTranslationScreenState();
}

class _CameraTranslationScreenState extends State<CameraTranslationScreen> {
  CameraController? _cameraController;
  final List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isCapturing = false;
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameras.addAll(cameras);
        _cameraController = CameraController(
          _cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() => _isCameraInitialized = true);
        }
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _captureAndTranslate() async {
    if (_cameraController == null || _isCapturing) return;
    
    setState(() => _isCapturing = true);
    
    try {
      final image = await _cameraController!.takePicture();
      if (mounted) {
        final service = context.read<CameraTranslationService>();
        await service.processImageFromPath(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
    
    if (mounted) {
      setState(() => _isCapturing = false);
    }
  }

  Future<void> _speakText(String text) async {
    final service = context.read<CameraTranslationService>();
    await _flutterTts.setLanguage(service.targetLanguage == 'tr' ? 'tr-TR' : 
                                   service.targetLanguage == 'en' ? 'en-US' :
                                   service.targetLanguage == 'fr' ? 'fr-FR' : 'en-US');
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE30A17),
        title: const Text('Caméra de traduction', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () {
              if (_cameras.length > 1) {
                final currentIdx = _cameras.indexOf(_cameraController!.description);
                final nextIdx = (currentIdx + 1) % _cameras.length;
                _cameraController = CameraController(
                  _cameras[nextIdx],
                  ResolutionPreset.high,
                  enableAudio: false,
                );
                _cameraController!.initialize().then((_) {
                  setState(() {});
                });
              }
            },
          ),
        ],
      ),
      body: Consumer<CameraTranslationService>(
        builder: (context, service, _) {
          return Column(
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    if (_isCameraInitialized && _cameraController != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                        child: CameraPreview(_cameraController!),
                      )
                    else
                      const Center(
                        child: CircularProgressIndicator(color: Color(0xFFE30A17)),
                      ),
                    if (_isCapturing)
                      Container(
                        color: Colors.black54,
                        child: const Center(
                          child: CircularProgressIndicator(color: Color(0xFFE30A17)),
                        ),
                      ),
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: _captureAndTranslate,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(color: const Color(0xFFE30A17), width: 4),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Color(0xFFE30A17),
                              size: 35,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildLanguageSelector(
                          context,
                          service.sourceLanguage,
                          service.getLanguageName(service.sourceLanguage),
                          true,
                          (lang) => service.setSourceLanguage(lang),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: IconButton(
                            icon: const Icon(Icons.swap_horiz, color: Color(0xFFE30A17)),
                            onPressed: service.swapLanguages,
                          ),
                        ),
                        _buildLanguageSelector(
                          context,
                          service.targetLanguage,
                          service.getLanguageName(service.targetLanguage),
                          false,
                          (lang) => service.setTargetLanguage(lang),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (service.lastRecognizedText.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.text_fields, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  'Texte reconnu',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                if (service.lastRecognizedText.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.volume_up, size: 20, color: Color(0xFFE30A17)),
                                    onPressed: () => _speakText(service.lastRecognizedText),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              service.lastRecognizedText,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE30A17).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE30A17).withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.translate, size: 16, color: Color(0xFFE30A17)),
                                const SizedBox(width: 8),
                                Text(
                                  'Traduction',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                if (service.translatedText.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.volume_up, size: 20, color: Color(0xFFE30A17)),
                                    onPressed: () => _speakText(service.translatedText),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              service.translatedText,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (service.confidence > 0)
                        Row(
                          children: [
                            Icon(Icons.check_circle, size: 14, color: Colors.green.shade600),
                            const SizedBox(width: 4),
                            Text(
                              'Confiance: ${(service.confidence * 100).toStringAsFixed(0)}%',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                    ] else
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Icon(Icons.camera_alt_outlined, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                'Prenez une photo pour traduire',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLanguageSelector(
    BuildContext context,
    String currentCode,
    String currentName,
    bool isSource,
    Function(String) onChanged,
  ) {
    final languages = CameraTranslationService.supportedLanguages;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton<String>(
          value: currentCode,
          isExpanded: true,
          underline: const SizedBox(),
          items: languages.map((lang) {
            return DropdownMenuItem(
              value: lang['code'],
              child: Text(lang['name']!, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }
}