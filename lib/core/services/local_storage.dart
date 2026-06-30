import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorage {
  static late SharedPreferences _prefs;
  static bool _initialized = false;

  static Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  // String
  static String? getString(String key) => _prefs.getString(key);
  static Future<bool> setString(String key, String value) => _prefs.setString(key, value);

  // Bool
  static bool? getBool(String key) => _prefs.getBool(key);
  static Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  // Int
  static int? getInt(String key) => _prefs.getInt(key);
  static Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  // Double
  static double? getDouble(String key) => _prefs.getDouble(key);
  static Future<bool> setDouble(String key, double value) => _prefs.setDouble(key, value);

  // List<String>
  static List<String>? getStringList(String key) => _prefs.getStringList(key);
  static Future<bool> setStringList(String key, List<String> value) => _prefs.setStringList(key, value);

  // JSON
  static Map<String, dynamic>? getJson(String key) {
    final json = _prefs.getString(key);
    if (json == null) return null;
    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> setJson(String key, Map<String, dynamic> value) {
    return _prefs.setString(key, jsonEncode(value));
  }

  // JSON List
  static List<Map<String, dynamic>>? getJsonList(String key) {
    final json = _prefs.getString(key);
    if (json == null) return null;
    try {
      final list = jsonDecode(json) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  static Future<bool> setJsonList(String key, List<Map<String, dynamic>> value) {
    return _prefs.setString(key, jsonEncode(value));
  }

  static Future<bool> remove(String key) => _prefs.remove(key);
  static Future<bool> clear() => _prefs.clear();
  static Set<String> getKeys() => _prefs.getKeys();
}
