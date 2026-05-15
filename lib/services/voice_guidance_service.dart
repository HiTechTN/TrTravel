import 'package:flutter_tts/flutter_tts.dart';
import '../models/route_info.dart';

class VoiceGuidanceService {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  bool _isEnabled = false;
  List<RouteStep>? _currentSteps;
  int _currentStepIndex = 0;

  bool get isEnabled => _isEnabled;

  VoiceGuidanceService() {
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('fr-FR');
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      _tts.setCompletionHandler(() {
        _isSpeaking = false;
      });
    } catch (_) {}
  }

  Future<void> toggle() async {
    _isEnabled = !_isEnabled;
    if (_isEnabled) {
      if (_currentSteps != null && _currentStepIndex < _currentSteps!.length) {
        await _announceStep(_currentSteps![_currentStepIndex]);
      }
    } else {
      await stop();
    }
  }

  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    if (!enabled) await stop();
  }

  Future<void> startGuidance(List<RouteStep> steps) async {
    _currentSteps = steps;
    _currentStepIndex = 0;
    if (_isEnabled && steps.isNotEmpty) {
      await _announceStep(steps[0]);
    }
  }

  Future<void> nextStep(int index) async {
    _currentStepIndex = index;
    if (_isEnabled && _currentSteps != null && index < _currentSteps!.length) {
      await _announceStep(_currentSteps![index]);
    }
  }

  Future<void> _announceStep(RouteStep step) async {
    if (!_isEnabled || _isSpeaking) return;
    _isSpeaking = true;

    String text;
    switch (step.maneuverType) {
      case 'depart':
        text = 'Départ. ${step.simplifiedInstruction}';
        break;
      case 'arrive':
        text = 'Vous êtes arrivé à destination. Bonne visite !';
        break;
      case 'turn':
        final dir = step.maneuverModifier ?? '';
        text = 'Dans ${step.distance.toStringAsFixed(0)} mètres, tournez $dir';
        if (step.streetName != null && step.streetName!.isNotEmpty) {
          text += ' sur ${step.streetName}';
        }
        break;
      case 'continue':
        text = 'Continuez tout droit sur ${step.distance.toStringAsFixed(0)} mètres';
        break;
      case 'transit':
        text = 'Prenez le transport en commun ici';
        break;
      default:
        text = step.instruction;
    }

    try {
      await _tts.speak(text);
    } catch (_) {
      _isSpeaking = false;
    }
  }

  Future<void> announceArrival() async {
    if (!_isEnabled) return;
    try {
      await _tts.speak('Vous êtes arrivé à destination. Merci d\'avoir utilisé TrTravel !');
    } catch (_) {}
  }

  Future<void> speak(String text) async {
    if (!_isEnabled) return;
    try {
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> stop() async {
    _isSpeaking = false;
    try {
      await _tts.stop();
    } catch (_) {}
  }

  void dispose() {
    _tts.stop();
    _tts.setCompletionHandler(() {});
  }
}
