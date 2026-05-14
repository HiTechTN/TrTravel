import 'package:flutter/foundation.dart';
import '../data/shopping_database.dart';

class ShoppingService extends ChangeNotifier {
  List<ShoppingCenter> _shoppingCenters = [];
  String _filterCity = 'all';
  String _filterType = 'all';
  String _searchQuery = '';

  List<ShoppingCenter> get allCenters => _shoppingCenters;

  List<ShoppingCenter> get filteredCenters {
    var result = _shoppingCenters;
    
    if (_filterCity != 'all') {
      final filtered = result.where((s) => s.city == _filterCity);
      result = filtered.toList();
    }
    
    if (_filterType != 'all') {
      final filtered = result.where((s) => s.type == _filterType);
      result = filtered.toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      final filtered = result.where((s) =>
        s.name.toLowerCase().contains(q) ||
        s.district.toLowerCase().contains(q) ||
        s.city.toLowerCase().contains(q) ||
        s.brands.any((b) => b.toLowerCase().contains(q))
      );
      return filtered.toList();
    }
    
    return result;
  }

  List<ShoppingCenter> get malls => _shoppingCenters.where((s) => s.type == 'mall').toList();
  List<ShoppingCenter> get outlets => _shoppingCenters.where((s) => s.type == 'outlet').toList();
  List<ShoppingCenter> get markets => _shoppingCenters.where((s) => s.type == 'market').toList();

  List<String> get availableCities {
    final cities = _shoppingCenters.map((s) => s.city).toSet().toList();
    cities.sort();
    return ['all', ...cities];
  }

  List<String> get availableTypes {
    return ['all', 'mall', 'outlet', 'market'];
  }

  void setCityFilter(String city) {
    _filterCity = city;
    notifyListeners();
  }

  void setTypeFilter(String type) {
    _filterType = type;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void init() {
    _shoppingCenters = ShoppingDatabase.allShoppingCenters;
    notifyListeners();
  }

  List<ShoppingCenter> getMallsByCity(String city) {
    return _shoppingCenters.where((s) => s.city == city && s.type == 'mall').toList();
  }

  List<ShoppingCenter> getOutletsByCity(String city) {
    return _shoppingCenters.where((s) => s.city == city && s.type == 'outlet').toList();
  }

  List<ShoppingCenter> getMarketsByCity(String city) {
    return _shoppingCenters.where((s) => s.city == city && s.type == 'market').toList();
  }

  ShoppingCenter? getById(String id) {
    try {
      return _shoppingCenters.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  List<ShoppingCenter> getNearby(double lat, double lon, {double radiusKm = 10}) {
    final latDiff = lat - 0.1;
    final lonDiff = lon - 0.1;
    return _shoppingCenters.where((s) {
      final latDiff2 = (s.latitude - lat).abs();
      final lonDiff2 = (s.longitude - lon).abs();
      return latDiff2 < 0.1 && lonDiff2 < 0.1;
    }).toList();
  }

  int get totalCount => _shoppingCenters.length;
  int get istanbulCount => _shoppingCenters.where((s) => s.city == 'Istanbul').length;
  int get antalyaCount => _shoppingCenters.where((s) => s.city == 'Antalya').length;

  Map<String, int> getStatsByCity() {
    final stats = <String, int>{};
    for (final city in availableCities) {
      if (city != 'all') {
        stats[city] = _shoppingCenters.where((s) => s.city == city).length;
      }
    }
    return stats;
  }

  List<ShoppingCenter> getTopRated({int limit = 5}) {
    final sorted = List<ShoppingCenter>.from(_shoppingCenters);
    sorted.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    return sorted.take(limit).toList();
  }
}