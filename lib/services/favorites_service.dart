import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/map_place.dart';
import '../data/map_places_data.dart';

class FavoritesService extends ChangeNotifier {
  static const String _key = 'favorite_places';
  Set<String> _favoriteNames = {};

  Set<String> get favoriteNames => Set.unmodifiable(_favoriteNames);

  List<MapPlace> get favoritePlaces =>
      MapPlacesData.allPlaces.where((p) => _favoriteNames.contains(p.name)).toList();

  int get count => _favoriteNames.length;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_key) ?? [];
      _favoriteNames = list.toSet();
      notifyListeners();
    } catch (_) {
      _favoriteNames = {};
    }
  }

  bool isFavorite(String placeName) => _favoriteNames.contains(placeName);

  Future<void> toggle(String placeName) async {
    if (_favoriteNames.contains(placeName)) {
      _favoriteNames.remove(placeName);
    } else {
      _favoriteNames.add(placeName);
    }
    await _save();
    notifyListeners();
  }

  Future<void> add(String placeName) async {
    _favoriteNames.add(placeName);
    await _save();
    notifyListeners();
  }

  Future<void> remove(String placeName) async {
    _favoriteNames.remove(placeName);
    await _save();
    notifyListeners();
  }

  Future<void> clear() async {
    _favoriteNames.clear();
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, _favoriteNames.toList());
    } catch (_) {}
  }
}
