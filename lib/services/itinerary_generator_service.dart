import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart';

class Place {
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String category;
  final double rating;
  final List<String> photos;
  final String address;
  final String? openingHours;
  final double? estimatedVisitDuration;

  Place({
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.category,
    this.rating = 4.0,
    this.photos = const [],
    this.address = '',
    this.openingHours,
    this.estimatedVisitDuration,
  });

  LatLng get location => LatLng(latitude, longitude);

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'latitude': latitude,
    'longitude': longitude,
    'category': category,
    'rating': rating,
    'photos': photos,
    'address': address,
    'openingHours': openingHours,
    'estimatedVisitDuration': estimatedVisitDuration,
  };

  factory Place.fromJson(Map<String, dynamic> json) => Place(
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    latitude: (json['latitude'] ?? 0.0).toDouble(),
    longitude: (json['longitude'] ?? 0.0).toDouble(),
    category: json['category'] ?? 'other',
    rating: (json['rating'] ?? 4.0).toDouble(),
    photos: List<String>.from(json['photos'] ?? []),
    address: json['address'] ?? '',
    openingHours: json['openingHours'],
    estimatedVisitDuration: json['estimatedVisitDuration']?.toDouble(),
  );
}

class ItineraryDay {
  final DateTime date;
  final List<Place> places;
  final String theme;
  final String? notes;

  ItineraryDay({
    required this.date,
    required this.places,
    required this.theme,
    this.notes,
  });

  double get totalDuration {
    return places.fold(0.0, (sum, place) => 
      sum + (place.estimatedVisitDuration ?? 1.5));
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'places': places.map((p) => p.toJson()).toList(),
    'theme': theme,
    'notes': notes,
  };

  factory ItineraryDay.fromJson(Map<String, dynamic> json) => ItineraryDay(
    date: DateTime.parse(json['date']),
    places: (json['places'] as List).map((p) => Place.fromJson(p)).toList(),
    theme: json['theme'] ?? '',
    notes: json['notes'],
  );
}

class GeneratedItinerary {
  final String id;
  final String title;
  final List<ItineraryDay> days;
  final DateTime createdAt;
  final double userLatitude;
  final double userLongitude;
  final List<String> preferences;
  final int duration;

  GeneratedItinerary({
    required this.id,
    required this.title,
    required this.days,
    required this.createdAt,
    required this.userLatitude,
    required this.userLongitude,
    required this.preferences,
    required this.duration,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'days': days.map((d) => d.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'userLatitude': userLatitude,
    'userLongitude': userLongitude,
    'preferences': preferences,
    'duration': duration,
  };

  factory GeneratedItinerary.fromJson(Map<String, dynamic> json) => GeneratedItinerary(
    id: json['id'],
    title: json['title'],
    days: (json['days'] as List).map((d) => ItineraryDay.fromJson(d)).toList(),
    createdAt: DateTime.parse(json['createdAt']),
    userLatitude: (json['userLatitude'] ?? 0.0).toDouble(),
    userLongitude: (json['userLongitude'] ?? 0.0).toDouble(),
    preferences: List<String>.from(json['preferences'] ?? []),
    duration: json['duration'] ?? 1,
  );
}

class ItineraryGeneratorService extends ChangeNotifier {
  static const String _itinerariesKey = 'generated_itineraries';

  Position? _currentPosition;
  List<GeneratedItinerary> _savedItineraries = [];

  static final Map<String, List<Place>> _turkeyPlaces = {
    'Istanbul': [
      Place(name: 'Sainte-Sophie', description: 'Basilique antique transformée en mosquée', latitude: 41.0086, longitude: 28.9802, category: 'historical', rating: 4.9, address: 'Sultan Ahmet Mahallesi, Istanbul', openingHours: '09:00 - 18:00', estimatedVisitDuration: 2.0),
      Place(name: 'Mosquée Bleue', description: 'Mosquée ottomane emblématique du XVIe siècle', latitude: 41.0054, longitude: 28.9768, category: 'religious', rating: 4.8, address: 'Sultan Ahmet Mahallesi, Istanbul', openingHours: '08:00 - 18:00', estimatedVisitDuration: 1.5),
      Place(name: 'Grand Bazar', description: 'L\'un des plus grands marchés couverts du monde', latitude: 41.0097, longitude: 28.9702, category: 'shopping', rating: 4.5, address: 'Beyazıt Mahallesi, Istanbul', openingHours: '08:30 - 19:00', estimatedVisitDuration: 3.0),
      Place(name: 'Palais de Topkapi', description: 'Résidence des sultans ottomans pendant 400 ans', latitude: 41.0045, longitude: 28.9838, category: 'palace', rating: 4.8, address: 'Cankurtaran Mahallesi, Istanbul', openingHours: '09:00 - 17:00', estimatedVisitDuration: 3.0),
      Place(name: 'Basilique Cistern', description: 'Citerne souterraine byzantine', latitude: 41.0084, longitude: 28.9759, category: 'historical', rating: 4.6, address: 'Sultan Ahmet Mahallesi, Istanbul', openingHours: '09:00 - 18:30', estimatedVisitDuration: 1.0),
      Place(name: 'Tour de Galata', description: 'Tour médiévale avec vue panoramique', latitude: 41.0527, longitude: 28.9745, category: 'landmark', rating: 4.7, address: 'Bereketzade Mahallesi, Istanbul', openingHours: '08:00 - 22:00', estimatedVisitDuration: 1.5),
      Place(name: 'Palais Dolmabahçe', description: 'Résidence somptueuse des sultans ottomans', latitude: 41.0401, longitude: 29.0014, category: 'palace', rating: 4.8, address: 'Dolmabahçe Mahallesi, Istanbul', openingHours: '09:00 - 16:00', estimatedVisitDuration: 2.5),
      Place(name: 'Musée archéologique', description: 'Riche collection d\'artéfacts anatoliens', latitude: 41.0059, longitude: 28.9826, category: 'museum', rating: 4.5, address: 'Sarayburnu, Istanbul', openingHours: '09:00 - 17:00', estimatedVisitDuration: 2.0),
    ],
    'Cappadoce': [
      Place(name: 'Vallée de Göreme', description: 'Vallée avec formations rocheuses uniques', latitude: 38.6431, longitude: 34.8289, category: 'nature', rating: 4.9, address: 'Göreme, Nevşehir', openingHours: '24h', estimatedVisitDuration: 4.0),
      Place(name: 'Cheminées de fées', description: 'Formations rocheuses emblématiques', latitude: 38.6514, longitude: 34.8356, category: 'nature', rating: 4.8, address: 'Paşabağı, Nevşehir', openingHours: '24h', estimatedVisitDuration: 2.0),
      Place(name: 'Uçhisar', description: 'Village avec forteresse troglodyte', latitude: 38.6269, longitude: 34.8017, category: 'village', rating: 4.6, address: 'Uçhisar, Nevşehir', openingHours: '24h', estimatedVisitDuration: 2.0),
      Place(name: 'Grotte de Kaymaklı', description: 'Ville souterraine antique', latitude: 38.4583, longitude: 34.8644, category: 'historical', rating: 4.7, address: 'Kaymaklı, Nevşehir', openingHours: '08:00 - 17:00', estimatedVisitDuration: 1.5),
      Place(name: 'Vallée d\'Ihlara', description: 'Vallée naturelle avec temples rupestres', latitude: 38.2428, longitude: 34.3044, category: 'nature', rating: 4.8, address: 'Ihlara, Aksaray', openingHours: '24h', estimatedVisitDuration: 3.0),
    ],
    'Ankara': [
      Place(name: 'Anıtkabir', description: 'Mausolée d\'Atatürk', latitude: 39.9254, longitude: 32.8378, category: 'historical', rating: 4.8, address: 'Anıtkabir, Ankara', openingHours: '09:00 - 17:00', estimatedVisitDuration: 2.0),
      Place(name: 'Musée des civilisations anatoliennes', description: 'Musée avec artéfacts historiques', latitude: 39.9383, longitude: 32.8597, category: 'museum', rating: 4.7, address: 'Ulus, Ankara', openingHours: '08:30 - 17:00', estimatedVisitDuration: 2.5),
      Place(name: 'Citadelle d\'Ankara', description: 'Forteresse romaine et ottomane', latitude: 39.9355, longitude: 32.8647, category: 'historical', rating: 4.5, address: 'Altındağ, Ankara', openingHours: '24h', estimatedVisitDuration: 1.5),
    ],
    'Izmir': [
      Place(name: 'Ephèse', description: 'Ruines de l\'antique ville grecque', latitude: 37.9411, longitude: 27.3419, category: 'historical', rating: 4.9, address: 'Selçuk, İzmir', openingHours: '08:00 - 18:00', estimatedVisitDuration: 4.0),
      Place(name: 'Agora de Smyrne', description: 'Ruines de l\'agora grec antique', latitude: 38.4192, longitude: 27.1336, category: 'historical', rating: 4.4, address: 'Kemeraltı, İzmir', openingHours: '08:30 - 17:30', estimatedVisitDuration: 1.5),
      Place(name: 'Tour de l\'horloge', description: 'Symbole d\'Izmir', latitude: 38.4187, longitude: 27.1286, category: 'landmark', rating: 4.3, address: 'Konak, İzmir', openingHours: '24h', estimatedVisitDuration: 0.5),
      Place(name: 'Pamukkale', description: 'Terrasses de travertin blanc et Hiérapolis', latitude: 37.9201, longitude: 29.1176, category: 'nature', rating: 5.0, address: 'Pamukkale, Denizli', openingHours: '06:00 - 22:00', estimatedVisitDuration: 4.0),
    ],
    'Antalya': [
      Place(name: 'Kaleiçi', description: 'Vieux quartier historique', latitude: 36.8878, longitude: 30.7013, category: 'old_town', rating: 4.6, address: 'Kaleiçi, Antalya', openingHours: '24h', estimatedVisitDuration: 3.0),
      Place(name: 'Plage de Konyaaltı', description: 'Plage emblématique d\'Antalya', latitude: 36.8833, longitude: 30.6333, category: 'beach', rating: 4.5, address: 'Konyaaltı, Antalya', openingHours: '24h', estimatedVisitDuration: 2.0),
      Place(name: 'Plage de Lara', description: 'Plage de sable fin de 15 km', latitude: 36.8535, longitude: 30.7838, category: 'beach', rating: 4.7, address: 'Lara, Antalya', openingHours: '24h', estimatedVisitDuration: 2.0),
      Place(name: 'Port de Kaleiçi', description: 'Port historique avec marina', latitude: 36.8911, longitude: 30.6985, category: 'port', rating: 4.4, address: 'Kaleiçi, Antalya', openingHours: '24h', estimatedVisitDuration: 1.5),
      Place(name: 'Musée d\'Antalya', description: 'Riche collection archéologique', latitude: 36.8892, longitude: 30.7158, category: 'museum', rating: 4.6, address: 'Konyaaltı, Antalya', openingHours: '08:00 - 20:00', estimatedVisitDuration: 2.0),
      Place(name: 'Canyon de Koprulü', description: 'Canyon spectaculaire pour rafting', latitude: 37.0958, longitude: 31.2528, category: 'nature', rating: 4.8, address: 'Köprülü, Antalya', openingHours: '08:00 - 18:00', estimatedVisitDuration: 3.0),
      Place(name: 'Aspendos', description: 'Théâtre romain bien conservé', latitude: 36.9388, longitude: 31.0477, category: 'historical', rating: 4.7, address: 'Serik, Antalya', openingHours: '08:00 - 19:00', estimatedVisitDuration: 2.0),
    ],
    'Trabzon': [
      Place(name: 'Sainte-Sophie de Trabzon', description: 'Église byzantine transformée en musée', latitude: 41.0025, longitude: 39.7164, category: 'historical', rating: 4.7, address: 'Trabzon', openingHours: '08:00 - 17:00', estimatedVisitDuration: 1.5),
      Place(name: 'Monastère de Sumela', description: 'Monastère médiéval dans les montagnes', latitude: 40.7631, longitude: 39.6844, category: 'religious', rating: 4.9, address: 'Maçka, Trabzon', openingHours: '08:00 - 19:00', estimatedVisitDuration: 3.0),
      Place(name: 'Forteresse de Trabzon', description: 'Forteresse byzantine et ottomane', latitude: 41.0225, longitude: 39.7317, category: 'historical', rating: 4.5, address: 'Trabzon', openingHours: '08:00 - 20:00', estimatedVisitDuration: 1.5),
    ],
  };

  List<String> get availablePreferences => [
    'historical',
    'religious',
    'nature',
    'beach',
    'museum',
    'shopping',
    'food',
    'adventure',
  ];

  List<String> get availableCities => _turkeyPlaces.keys.toList();

  List<Place> getPlacesForCity(String city) {
    return _turkeyPlaces[city] ?? [];
  }

  Future<void> init() async {
    await _loadSavedItineraries();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      _currentPosition = null;
    }
  }

  String _getNearestCity(double lat, double lon) {
    final cities = {
      'Istanbul': [41.0086, 28.9802],
      'Ankara': [39.9254, 32.8378],
      'Izmir': [38.4192, 27.1336],
      'Antalya': [36.8878, 30.7013],
      'Trabzon': [41.0025, 39.7164],
      'Cappadoce': [38.6431, 34.8289],
    };

    String nearestCity = 'Istanbul';
    double minDistance = double.infinity;

    for (final entry in cities.entries) {
      final distance = Geolocator.distanceBetween(
        lat, lon, entry.value[0], entry.value[1]
      );
      if (distance < minDistance) {
        minDistance = distance;
        nearestCity = entry.key;
      }
    }

    return nearestCity;
  }

  Future<GeneratedItinerary> generateItinerary({
    required List<String> preferences,
    required int days,
    String? city,
  }) async {
    final lat = _currentPosition?.latitude ?? 41.0086;
    final lon = _currentPosition?.longitude ?? 28.9802;

    final selectedCity = city ?? _getNearestCity(lat, lon);
    final cityPlaces = _turkeyPlaces[selectedCity] ?? _turkeyPlaces['Istanbul']!;

    final filteredPlaces = _filterByPreferences(cityPlaces, preferences);
    final selectedPlaces = _selectPlacesForDays(filteredPlaces, days);
    final itineraryDays = _createItineraryDays(selectedPlaces, days, selectedCity);

    final itinerary = GeneratedItinerary(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Exploration de $selectedCity',
      days: itineraryDays,
      createdAt: DateTime.now(),
      userLatitude: lat,
      userLongitude: lon,
      preferences: preferences,
      duration: days,
    );

    await _saveItinerary(itinerary);
    notifyListeners();
    return itinerary;
  }

  List<Place> _filterByPreferences(List<Place> places, List<String> preferences) {
    if (preferences.isEmpty) return places;

    return places.where((place) {
      final category = place.category.toLowerCase();
      return preferences.any((pref) => category.contains(pref.toLowerCase()));
    }).toList();
  }

  List<Place> _selectPlacesForDays(List<Place> places, int days) {
    if (places.isEmpty) return [];
    final result = <Place>[];
    final shuffled = List<Place>.from(places)..shuffle();
    
    final placesPerDay = (shuffled.length / days).ceil();
    for (int i = 0; i < days && i * placesPerDay < shuffled.length; i++) {
      final dayPlaces = shuffled.sublist(
        i * placesPerDay,
        (i + 1) * placesPerDay > shuffled.length 
          ? shuffled.length 
          : (i + 1) * placesPerDay
      );
      result.addAll(dayPlaces);
    }
    
    return result;
  }

  List<ItineraryDay> _createItineraryDays(List<Place> places, int days, String city) {
    final themeDays = [
      'Découverte historique',
      'Architecture et culture',
      'Nature et paysages',
      'Gastronomie locale',
      'Shopping et artisanat',
      'Détente et découverte',
      'Aventure et exploration',
    ];

    final List<ItineraryDay> itineraryDays = [];
    final placesPerDay = places.isEmpty ? 0 : (places.length / days).ceil();

    for (int i = 0; i < days; i++) {
      final startIdx = i * placesPerDay;
      final endIdx = startIdx + placesPerDay > places.length ? places.length : startIdx + placesPerDay;
      
      if (startIdx < places.length) {
        final dayPlaces = places.sublist(startIdx, endIdx);
        itineraryDays.add(ItineraryDay(
          date: DateTime.now().add(Duration(days: i)),
          places: dayPlaces,
          theme: themeDays[i % themeDays.length],
        ));
      }
    }

    return itineraryDays;
  }

  Future<void> _saveItinerary(GeneratedItinerary itinerary) async {
    final prefs = await SharedPreferences.getInstance();
    _savedItineraries.add(itinerary);
    
    await prefs.setString(
      _itinerariesKey,
      json.encode(_savedItineraries.map((i) => i.toJson()).toList())
    );
  }

  Future<void> _loadSavedItineraries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_itinerariesKey);
      
      if (data != null) {
        final List<dynamic> jsonList = json.decode(data);
        _savedItineraries = jsonList.map((j) => GeneratedItinerary.fromJson(j)).toList();
      }
    } catch (_) {
      _savedItineraries = [];
    }
  }

  Future<List<GeneratedItinerary>> getSavedItineraries() async {
    if (_savedItineraries.isEmpty) {
      await _loadSavedItineraries();
    }
    return _savedItineraries;
  }

  Future<void> deleteItinerary(String id) async {
    _savedItineraries.removeWhere((i) => i.id == id);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _itinerariesKey,
      json.encode(_savedItineraries.map((i) => i.toJson()).toList())
    );
    notifyListeners();
  }

  List<Place> getSuggestedPlaces(String city) {
    return _turkeyPlaces[city] ?? [];
  }
}