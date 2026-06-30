import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
export '../models/trip_suggestion.dart';
export '../models/trip_day.dart';
export '../models/trip_activity.dart';
import '../models/trip_suggestion.dart';
import '../models/trip_day.dart';
import '../models/trip_activity.dart';

class TravelAssistant extends ChangeNotifier {
  String _currentLanguage = 'fr';
  String _currentCity = 'Istanbul';
  int _tripDuration = 5;
  final Set<String> _interests = {};
  final List<TripSuggestion> _suggestions = [];
  final List<TripDay> _plannedDays = [];

  String get currentLanguage => _currentLanguage;
  String get currentCity => _currentCity;
  int get tripDuration => _tripDuration;
  Set<String> get interests => _interests;
  List<TripSuggestion> get suggestions => _suggestions;
  List<TripDay> get plannedDays => _plannedDays;

  void setLanguage(String lang) {
    _currentLanguage = lang;
    _generateSuggestions();
    notifyListeners();
  }

  void setCity(String city) {
    _currentCity = city;
    _generateSuggestions();
    notifyListeners();
  }

  void setTripDuration(int days) {
    _tripDuration = days;
    _generateSuggestions();
    notifyListeners();
  }

  void toggleInterest(String interest) {
    if (_interests.contains(interest)) {
      _interests.remove(interest);
    } else {
      _interests.add(interest);
    }
    _generateSuggestions();
    notifyListeners();
  }

  void setUserProfile(String profile) {
    _generateSuggestions();
    notifyListeners();
  }

  void _generateSuggestions() {
    _suggestions.clear();

    final allSuggestions = _getBaseSuggestions();
    
    if (_interests.isEmpty) {
      _suggestions.addAll(allSuggestions.take(10));
    } else {
      for (final interest in _interests) {
        final filtered = allSuggestions.where((s) => s.category == interest).toList();
        _suggestions.addAll(filtered);
      }
      if (_suggestions.length < 5) {
        _suggestions.addAll(allSuggestions.take(5));
      }
    }
    
    _suggestions.sort((a, b) => b.priority.compareTo(a.priority));
    _suggestions.removeWhere((s) => s.city.toLowerCase() != _currentCity.toLowerCase());
  }

  List<TripSuggestion> _getBaseSuggestions() {
    return [
      TripSuggestion(id: '1', title: 'Découvrez les essentiels d\'Istanbul', description: 'Un parcours à travers les lieux emblématiques de la ville.', city: 'Istanbul', category: 'historical', priority: 10, icon: '📍', duration: '2-3 jours', estimatedCost: '200-400 TL'),
      TripSuggestion(id: '2', title: 'Romance au Bosphore', description: 'Croisières, couchers de soleil et diners en bord de mer.', city: 'Istanbul', category: 'romantic', priority: 9, icon: '❤️', duration: '1-2 jours', estimatedCost: '150-300 TL'),
      TripSuggestion(id: '3', title: 'Aventure gastronomique', description: 'Goûtez à la cuisine de rue, marchés et restaurants locaux.', city: 'Istanbul', category: 'food', priority: 8, icon: '🍽️', duration: '2-3 jours', estimatedCost: '100-250 TL'),
      TripSuggestion(id: '4', title: 'Balade photography de rue', description: 'Les quartiers les plus photogéniques d\'Istanbul.', city: 'Istanbul', category: 'photography', priority: 7, icon: '📸', duration: '1 jour', estimatedCost: '50-100 TL'),
      TripSuggestion(id: '5', title: 'Week-end shopping', description: 'Du bazar aux malls modernes.', city: 'Istanbul', category: 'shopping', priority: 7, icon: '🛍️', duration: '2 jours', estimatedCost: '300-1000 TL'),
      TripSuggestion(id: '6', title: 'Lieux historiques d\'Antalya', description: 'Kaleiçi, musée, porte d\'Hadrien.', city: 'Antalya', category: 'historical', priority: 10, icon: '🏛️', duration: '2-3 jours', estimatedCost: '150-300 TL'),
      TripSuggestion(id: '7', title: 'Plages de rêve', description: 'Konyaaltı, Lara, Çıralı.', city: 'Antalya', category: 'beach', priority: 9, icon: '🏖️', duration: '3-5 jours', estimatedCost: '100-300 TL'),
      TripSuggestion(id: '8', title: 'Aventure nature', description: 'Canyon de Koprulü, rafting, randonn\u00e9e.', city: 'Antalya', category: 'adventure', priority: 8, icon: '🏔️', duration: '1-2 jours', estimatedCost: '200-400 TL'),
      TripSuggestion(id: '9', title: 'Road trip antiques', description: 'Aspendos, Perge, Side, Termessos.', city: 'Antalya', category: 'historical', priority: 9, icon: '🚗', duration: '2-3 jours', estimatedCost: '250-500 TL'),
      TripSuggestion(id: '10', title: 'Culture et museums', description: 'Musées, galeries et centres culturels.', city: 'Istanbul', category: 'culture', priority: 6, icon: '🎨', duration: '2-3 jours', estimatedCost: '100-200 TL'),
      TripSuggestion(id: '11', title: 'Vie nocturne', description: 'Bars, clubs et rooftops.', city: 'Istanbul', category: 'nightlife', priority: 6, icon: '🌃', duration: '1-2 jours', estimatedCost: '200-500 TL'),
      TripSuggestion(id: '12', title: 'Escapade spirituelle', description: 'Mosquées, churches et sites religieux.', city: 'Istanbul', category: 'religious', priority: 7, icon: '🕌', duration: '1-2 jours', estimatedCost: '50-150 TL'),
      TripSuggestion(id: '13', title: 'Famille avec enfants', description: 'Activités adaptées à tous les âges.', city: 'Antalya', category: 'family', priority: 8, icon: '👨‍👩‍👧‍👦', duration: '3-5 jours', estimatedCost: '200-500 TL'),
      TripSuggestion(id: '14', title: 'Budget serré', description: 'Profitez d\'Istanbul sans dépenser beaucoup.', city: 'Istanbul', category: 'budget', priority: 9, icon: '💰', duration: '3-5 jours', estimatedCost: '50-150 TL'),
      TripSuggestion(id: '15', title: 'Luxue et détente', description: 'Hôtels 5 étoiles, spas et resorts.', city: 'Antalya', category: 'luxury', priority: 8, icon: '✨', duration: '3-7 jours', estimatedCost: '1000-3000 TL'),
    ];
  }

  List<TripSuggestion> getRecommendations() => _suggestions;

  Future<void> saveTripPlan(TripDay day) async {
    _plannedDays.add(day);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('trip_days', json.encode(_plannedDays.map((d) => d.toJson()).toList()));
    notifyListeners();
  }

  Future<void> removePlannedDay(String dayId) async {
    _plannedDays.removeWhere((d) => d.id == dayId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('trip_days', json.encode(_plannedDays.map((d) => d.toJson()).toList()));
    notifyListeners();
  }

  Future<void> loadPlannedDays() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('trip_days');
    if (data != null) {
      final List<dynamic> jsonList = json.decode(data);
      _plannedDays.clear();
      _plannedDays.addAll(jsonList.map((j) => TripDay.fromJson(j)));
    }
    notifyListeners();
  }

  TripDay generateDayPlan(int dayNumber, String city, Set<String> interests) {
    final activities = <TripActivity>[];
    
    final morningActivity = _getActivityForTime(city, 'morning', interests);
    final afternoonActivity = _getActivityForTime(city, 'afternoon', interests);
    final eveningActivity = _getActivityForTime(city, 'evening', interests);

    if (morningActivity != null) activities.add(morningActivity);
    if (afternoonActivity != null) activities.add(afternoonActivity);
    if (eveningActivity != null) activities.add(eveningActivity);

    return TripDay(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dayNumber: dayNumber,
      city: city,
      theme: _getThemeForDay(dayNumber, interests),
      activities: activities,
      estimatedCost: activities.fold(0.0, (sum, a) => sum + (a.estimatedCost ?? 0)),
      tips: _getTipsForDay(dayNumber, city),
    );
  }

  TripActivity? _getActivityForTime(String city, String timeOfDay, Set<String> interests) {
    final allActivities = _getAllActivities(city);
    final filtered = allActivities.where((a) {
      if (timeOfDay == 'morning') return a.suggestedTime == 'morning';
      if (timeOfDay == 'afternoon') return a.suggestedTime == 'afternoon' || a.suggestedTime == 'all';
      return a.suggestedTime == 'evening';
    }).toList();
    
    if (filtered.isEmpty) return null;
    filtered.shuffle();
    return filtered.first;
  }

  List<TripActivity> _getAllActivities(String city) {
    final activities = <TripActivity>[];
    
    if (city.toLowerCase() == 'istanbul') {
      activities.addAll([
        TripActivity(id: 'a1', name: 'Sainte-Sophie', category: 'historical', suggestedTime: 'morning', duration: 120, cost: 25, description: 'Basilique byzantine transformée en mosquée', tips: 'Arrivez tôt pour éviter la foule'),
        TripActivity(id: 'a2', name: 'Mosquée Bleue', category: 'religious', suggestedTime: 'morning', duration: 90, cost: 0, description: 'Mosquée ottomane emblématique', tips: 'Couvrez-vous correctement'),
        TripActivity(id: 'a3', name: 'Grand Bazar', category: 'shopping', suggestedTime: 'all', duration: 180, cost: 0, description: 'Plus grand marché couvert du monde', tips: 'Négociez toujours'),
        TripActivity(id: 'a4', name: 'Basilique Citerne', category: 'historical', suggestedTime: 'morning', duration: 60, cost: 15, description: 'Citerne souterraine byzantine', tips: 'Atmosphère mystérieuse'),
        TripActivity(id: 'a5', name: 'Palais de Topkapi', category: 'palace', suggestedTime: 'afternoon', duration: 180, cost: 20, description: 'Résidence des sultans', tips: 'Prévoyez 3h minimum'),
        TripActivity(id: 'a6', name: 'Rue Istiklal', category: 'shopping', suggestedTime: 'afternoon', duration: 120, cost: 0, description: 'Rue piétonne animée', tips: 'Prenez le tramway Nostalgie'),
        TripActivity(id: 'a7', name: 'Tour de Galata', category: 'landmark', suggestedTime: 'evening', duration: 90, cost: 10, description: 'Vue panoramique', tips: 'Coucher de soleil inoubliable'),
        TripActivity(id: 'a8', name: 'Marché aux épices', category: 'food', suggestedTime: 'morning', duration: 60, cost: 0, description: 'Épices et thés', tips: 'Goûtez le thé de pommes'),
        TripActivity(id: 'a9', name: 'Palais Dolmabahçe', category: 'palace', suggestedTime: 'morning', duration: 150, cost: 30, description: 'Palais somptueux', tips: 'La salle du trône est impressionnante'),
        TripActivity(id: 'a10', name: 'Balat & Fener', category: 'photography', suggestedTime: 'afternoon', duration: 120, cost: 0, description: 'Quartiers colorés', tips: 'Meilleur pour la photography de rue'),
        TripActivity(id: 'a11', name: 'Café Pierre Loti', category: 'romantic', suggestedTime: 'evening', duration: 90, cost: 5, description: 'Vue Corne d\'Or', tips: 'Tapis d\'Orient et narguilé'),
        TripActivity(id: 'a12', name: 'Ortaköy', category: 'romantic', suggestedTime: 'evening', duration: 120, cost: 0, description: 'Mosquée au bord du Bosphore', tips: 'Marché aux puces le week-end'),
      ]);
    } else if (city.toLowerCase() == 'antalya') {
      activities.addAll([
        TripActivity(id: 'b1', name: 'Kaleiçi', category: 'historical', suggestedTime: 'morning', duration: 120, cost: 0, description: 'Vieux quartier', tips: 'Perdez-vous dans les ruelles'),
        TripActivity(id: 'b2', name: 'Porte d\'Hadrien', category: 'historical', suggestedTime: 'morning', duration: 30, cost: 0, description: 'Monument romain', tips: 'Photo au coucher de soleil'),
        TripActivity(id: 'b3', name: 'Musée d\'Antalya', category: 'museum', suggestedTime: 'morning', duration: 120, cost: 12, description: 'Archéologie romaine', tips: 'Salles des sarcophages'),
        TripActivity(id: 'b4', name: 'Plage de Konyaaltı', category: 'beach', suggestedTime: 'all', duration: 180, cost: 0, description: 'Plage urbaine', tips: 'Location de parasol recommandée'),
        TripActivity(id: 'b5', name: 'Plage de Lara', category: 'beach', suggestedTime: 'all', duration: 180, cost: 0, description: 'Sable fin', tips: 'Resorts de luxe'),
        TripActivity(id: 'b6', name: 'Cascade de Düden', category: 'nature', suggestedTime: 'afternoon', duration: 90, cost: 0, description: 'Cascade naturelle', tips: 'Restaurant en face'),
        TripActivity(id: 'b7', name: 'Canyon de Koprulü', category: 'adventure', suggestedTime: 'all', duration: 240, cost: 50, description: 'Rafting et canyoning', tips: 'Réservez à l\'avance'),
        TripActivity(id: 'b8', name: 'Aspendos', category: 'historical', suggestedTime: 'morning', duration: 120, cost: 15, description: 'Théâtre romain', tips: 'Opéra en été'),
        TripActivity(id: 'b9', name: 'Perge', category: 'historical', suggestedTime: 'morning', duration: 150, cost: 12, description: 'Ruines antiques', tips: 'Combinez avec Aspendos'),
        TripActivity(id: 'b10', name: 'Side', category: 'historical', suggestedTime: 'all', duration: 180, cost: 15, description: 'Temple d\'Apollon', tips: 'Magnifique au coucher de soleil'),
        TripActivity(id: 'b11', name: 'Restaurants Kaleiçi', category: 'food', suggestedTime: 'evening', duration: 120, cost: 15, description: 'Cuisine locale', tips: 'Essayez le poisson grillé'),
        TripActivity(id: 'b12', name: 'Aqualand', category: 'family', suggestedTime: 'all', duration: 240, cost: 25, description: 'Parc aquatique', tips: 'Évitez les heures de pointe'),
      ]);
    }
    
    return activities;
  }

  String _getThemeForDay(int dayNumber, Set<String> interests) {
    final themes = ['Découverte culturelle', 'Aventure nature', 'Détente plage', 'Gastronomie', 'Histoire antique', 'Romance', 'Shopping', 'Exploration'];
    return themes[dayNumber % themes.length];
  }

  List<String> _getTipsForDay(int dayNumber, String city) {
    final tips = {
      'istanbul': [
        'Les transports en commun sont très économiques - utilisez la Istanbulkart',
        'Les mosquées ont des horaires de prière - vérifiez avant de visiter',
        'Le ferry du Bosphore est une expérience incontournable',
        'Les taxis peuvent être chers - négociez ou utilisez l\'app BiTaksi',
        'Le thé est offert dans les boutiques - c\'est une forme de hospitality',
        'Portez des chaussures de marche confortables',
        'La monnaie est la Livre turque (TRY)',
        'Apprenez quelques mots de turc - les locals apprécient',
        'Évitez les week-ends pour les sites touristiques',
        'Le musée d\'Istanbul Card donne accès à plusieurs museums',
      ],
      'antalya': [
        'La carte Antalya card donne accès aux transports',
        'Les plages sont publiques mais les accès peuvent être payants',
        'Loué une voiture est recommandé pour les sites éloignés',
        'Les hôtels tout-inclus sont courants sur Lara et Kundu',
        'La saison haute est de mai à octobre',
        'Protégez-vous du soleil - il fait très chaud en été',
        'Les ruines antiques sont souvent mieux visitées le matin',
        'Le rafting nécessite une réservation préalable',
        'Les bus Dolmuş sont bon marché pour les trajets courts',
        'Nightlife concentrate around Kaleiçi',
      ],
    };
    return (tips[city.toLowerCase()] ?? []).take(3).toList();
  }

  List<TripSuggestion> getTripTemplates() {
    return [
      TripSuggestion(id: 't1', title: 'Week-end découverte Istanbul', description: '3 jours pour découvrir les essentiels.', city: 'Istanbul', category: 'historical', priority: 10, icon: '✈️', duration: '3 jours', estimatedCost: '400-800 TL'),
      TripSuggestion(id: 't2', title: 'Road trip Anatolie', description: '10 jours Istanbul vers Antalya.', city: 'Istanbul', category: 'adventure', priority: 8, icon: '🚗', duration: '10 jours', estimatedCost: '1500-3000 TL'),
      TripSuggestion(id: 't3', title: 'Vacances plages Antalya', description: '7 jours détente sur les plages.', city: 'Antalya', category: 'beach', priority: 9, icon: '🏖️', duration: '7 jours', estimatedCost: '800-2000 TL'),
      TripSuggestion(id: 't4', title: 'Circuit historique', description: 'Archaeology de Troie à Pamukkale.', city: 'Istanbul', category: 'historical', priority: 7, icon: '🏛️', duration: '7 jours', estimatedCost: '1000-2000 TL'),
      TripSuggestion(id: 't5', title: 'Voyage en famille', description: 'Activités pour tous les âges.', city: 'Antalya', category: 'family', priority: 8, icon: '👨‍👩‍👧‍👦', duration: '5 jours', estimatedCost: '600-1500 TL'),
      TripSuggestion(id: 't6', title: 'escapade romantique', description: 'honeymoon ou week-end en amoureux.', city: 'Istanbul', category: 'romantic', priority: 9, icon: '❤️', duration: '3-4 jours', estimatedCost: '500-1200 TL'),
      TripSuggestion(id: 't7', title: 'Voyage budget', description: 'Profitez sans beaucoup dépenser.', city: 'Istanbul', category: 'budget', priority: 8, icon: '💰', duration: '5-7 jours', estimatedCost: '200-500 TL'),
      TripSuggestion(id: 't8', title: 'Aventure extreme', description: 'Rafting, parapente, plongée.', city: 'Antalya', category: 'adventure', priority: 7, icon: '🏔️', duration: '5 jours', estimatedCost: '800-1500 TL'),
    ];
  }
}

