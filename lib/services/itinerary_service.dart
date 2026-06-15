import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/itinerary.dart';

class ItineraryService extends ChangeNotifier {
  static const String _itineraryKey = 'custom_itineraries';
  List<ItineraryItem> _cachedItems = [];

  Future<void> init() async {
    await loadItinerary();
  }

  Future<List<ItineraryItem>> loadItinerary() async {
    try {
      final jsonString = await rootBundle.loadString('assets/itinerary.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      final items = jsonList.map((j) => ItineraryItem.fromJson(j)).toList();
      
      final customItems = await _loadCustomItineraries();
      _cachedItems = [...items, ...customItems];
      notifyListeners();
      return _cachedItems;
    } catch (e) {
      final customItems = await _loadCustomItineraries();
      _cachedItems = customItems;
      return customItems;
    }
  }

  Future<List<ItineraryItem>> _loadCustomItineraries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_itineraryKey);
      if (data != null) {
        final List<dynamic> jsonList = json.decode(data);
        return jsonList.map((j) => ItineraryItem.fromJson(j)).toList();
      }
    } catch (e) {
      debugPrint('ItineraryService: error loading itinerary: $e');
    }
    return [];
  }

  Future<void> addItineraryDay(Map<String, dynamic> data) async {
    final item = ItineraryItem(
      date: data['date'] ?? '',
      dayName: data['dayName'] ?? '',
      location: data['location'] ?? '',
      activities: (data['activities'] as List<Map<String, String>>?)
          ?.map((a) => Activity(
                time: a['time'] ?? '',
                description: a['description'] ?? '',
                details: a['details'],
              ))
          .toList() ?? [],
    );

    final current = await _loadCustomItineraries();
    current.add(item);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _itineraryKey,
      json.encode(current.map((i) => i.toJson()).toList()),
    );
    notifyListeners();
  }

  Future<void> updateItineraryDay(ItineraryItem existing, Map<String, dynamic> data) async {
    final updated = ItineraryItem(
      date: data['date'] ?? existing.date,
      dayName: data['dayName'] ?? existing.dayName,
      location: data['location'] ?? existing.location,
      activities: (data['activities'] as List<Map<String, String>>?)
          ?.map((a) => Activity(
                time: a['time'] ?? '',
                description: a['description'] ?? '',
                details: a['details'],
              ))
          .toList() ?? existing.activities,
    );

    final current = await _loadCustomItineraries();
    final idx = current.indexWhere((i) => i.date == existing.date && i.location == existing.location);
    if (idx != -1) {
      current[idx] = updated;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _itineraryKey,
      json.encode(current.map((i) => i.toJson()).toList()),
    );
  }

  Future<void> deleteItineraryDay(ItineraryItem item) async {
    final current = await _loadCustomItineraries();
    current.removeWhere((i) => i.date == item.date && i.location == item.location);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _itineraryKey,
      json.encode(current.map((i) => i.toJson()).toList()),
    );
  }

  List<ItineraryItem> getCachedItinerary() => _cachedItems;
}