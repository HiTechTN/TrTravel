import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/wiki_models.dart';

class WikiAudioGuide {
  static FlutterTts? _tts;

  static Future<void> init() async {
    _tts = FlutterTts();
    await _tts?.setLanguage('fr-FR');
    await _tts?.setSpeechRate(0.45);
    await _tts?.setVolume(1.0);
  }

  static Future<void> readSection(WikiSection section) async {
    if (_tts == null) await init();
    final text = '${section.localizedTitle}. ${section.localizedContent}';
    await _tts?.speak(text);
  }

  static Future<void> readItem(WikiItem item) async {
    if (_tts == null) await init();
    final buffer = StringBuffer();
    buffer.writeln(item.localizedTitle);
    buffer.writeln(item.localizedDescription);
    for (final section in item.sections) {
      buffer.writeln(section.localizedTitle);
      buffer.writeln(section.localizedContent);
    }
    await _tts?.speak(buffer.toString());
  }

  static Future<void> stop() async {
    await _tts?.stop();
  }

  static Future<void> setLanguage(String lang) async {
    await _tts?.setLanguage(lang);
  }

  static void dispose() {
    _tts?.stop();
    _tts = null;
  }
}

class AudioGuideButton extends StatefulWidget {
  final WikiItem item;
  final WikiSection? section;

  const AudioGuideButton({super.key, required this.item, this.section});

  @override
  State<AudioGuideButton> createState() => _AudioGuideButtonState();
}

class _AudioGuideButtonState extends State<AudioGuideButton> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(_isPlaying ? Icons.stop_circle_rounded : Icons.headphones_rounded),
      tooltip: _isPlaying ? 'Arrêter' : 'Écouter le guide audio',
      onPressed: () async {
        if (_isPlaying) {
          await WikiAudioGuide.stop();
          setState(() => _isPlaying = false);
        } else {
          setState(() => _isPlaying = true);
          if (widget.section != null) {
            await WikiAudioGuide.readSection(widget.section!);
          } else {
            await WikiAudioGuide.readItem(widget.item);
          }
          setState(() => _isPlaying = false);
        }
      },
    );
  }
}
