import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const String _savedLocationsKey = 'saved_locations';

  Future<void> saveLocationInfo({
    required String locationName,
    required String description,
    String? notes,
    List<String>? tags,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final locationData = {
      'name': locationName,
      'description': description,
      'notes': notes ?? '',
      'tags': tags ?? [],
      'timestamp': DateTime.now().toIso8601String(),
    };

    final List<String>? locationStrings =
        prefs.getStringList(_savedLocationsKey);
    final List<String> updatedLocationStrings =
        (locationStrings ?? [])..add(json.encode(locationData));
    await prefs.setStringList(_savedLocationsKey, updatedLocationStrings);
  }

  Future<List<Map<String, dynamic>>> loadSavedLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonStrings =
        prefs.getStringList(_savedLocationsKey);
    if (jsonStrings == null || jsonStrings.isEmpty) {
      return [];
    }
    return jsonStrings
        .map((jsonString) => json.decode(jsonString) as Map<String, dynamic>)
        .toList();
  }

  Future<void> deleteLocation(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonStrings =
        prefs.getStringList(_savedLocationsKey);
    if (jsonStrings == null || jsonStrings.isEmpty) return;

    final List<String> updatedJsonStrings = List.from(jsonStrings)
      ..removeAt(index);
    await prefs.setStringList(_savedLocationsKey, updatedJsonStrings);
  }

  Future<void> updateLocation({
    required int index,
    required String locationName,
    required String description,
    String? notes,
    List<String>? tags,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonStrings =
        prefs.getStringList(_savedLocationsKey);
    if (jsonStrings == null || jsonStrings.isEmpty) return;

    final locationData = {
      'name': locationName,
      'description': description,
      'notes': notes ?? '',
      'tags': tags ?? [],
      'timestamp': DateTime.now().toIso8601String(),
    };

    final List<String> updatedJsonStrings = List.from(jsonStrings);
    updatedJsonStrings[index] = json.encode(locationData);
    await prefs.setStringList(_savedLocationsKey, updatedJsonStrings);
  }
}
