import 'package:flutter/foundation.dart';

class LogService {
  static bool _debugMode = kDebugMode;

  static void setDebugMode(bool enabled) {
    _debugMode = enabled;
  }

  static void info(String tag, String message) {
    if (_debugMode) debugPrint('[$tag] $message');
  }

  static void warning(String tag, String message) {
    if (_debugMode) debugPrint('[$tag ⚠️] $message');
  }

  static void error(String tag, String message, [Object? error, StackTrace? stack]) {
    if (_debugMode) {
      debugPrint('[$tag ❌] $message');
      if (error != null) debugPrint('Error: $error');
      if (stack != null) debugPrint('Stack: $stack');
    }
  }

  static void api(String tag, String endpoint, int statusCode, [String? body]) {
    if (_debugMode) {
      debugPrint('[$tag 🌐] $endpoint → $statusCode');
      if (body != null && body.length < 500) debugPrint('Body: $body');
    }
  }
}
