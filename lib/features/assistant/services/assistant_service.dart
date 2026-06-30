import 'package:flutter/foundation.dart';
import 'package:trtravel/features/assistant/models/assistant_models.dart';

class AssistantService extends ChangeNotifier {
  String _selectedCity = 'Istanbul';
  int _tripDuration = 3;
  List<String> _selectedInterests = ['culture', 'food'];
  String _question = '';
  String? _answer;
  bool _isLoading = false;

  String get selectedCity => _selectedCity;
  int get tripDuration => _tripDuration;
  List<String> get selectedInterests => _selectedInterests;
  String get question => _question;
  String? get answer => _answer;
  bool get isLoading => _isLoading;

  static const cities = ['Istanbul', 'Antalya', 'Cappadoce', 'Izmir', 'Ankara'];

  void setCity(String city) {
    _selectedCity = city;
    notifyListeners();
  }

  void setDuration(int days) {
    _tripDuration = days.clamp(1, 7);
    notifyListeners();
  }

  void toggleInterest(String id) {
    if (_selectedInterests.contains(id)) {
      _selectedInterests.remove(id);
    } else {
      _selectedInterests.add(id);
    }
    notifyListeners();
  }

  void setQuestion(String q) {
    _question = q;
    notifyListeners();
  }

  String generateAnswer(String question) {
    final q = question.toLowerCase();
    final interests = _selectedInterests;

    if (q.contains('manger') || q.contains('mangé') || q.contains('restaurant') || q.contains('nourriture') || q.contains('food')) {
      if (_selectedCity == 'Istanbul') {
        return 'À Istanbul, je vous recommande :\n\n'
            '🍽 **Street food incontournable :**\n'
            '• Balık ekmek au pont de Galata (50 TL)\n'
            '• Kumpir à Ortaköy (100 TL)\n'
            '• Midye dolma (20 TL/pièce)\n\n'
            '🍴 **Restaurants :**\n'
            '• Çiya Sofrası (Kadıköy) - Cuisine anatolienne\n'
            '• Karaköy Güllüoğlu - Meilleur baklava\n'
            '• Nusr-Et - Steakhouse (cher mais expérience)\n\n'
            '💰 Budget repas/jour : 300-800 TL/pers';
      } else if (_selectedCity == 'Antalya') {
        return 'À Antalya, voici mes suggestions :\n\n'
            '🍽 **Restaurants :**\n'
            '• 7 Mehmet - Cuisine turque moderne\n'
            '• Seraser Fine Dining - Gastronomique\n'
            '• Vanilla Lounge - International\n\n'
            '🥙 **Spécialités locales :**\n'
            '• Pişmaniye (cheveux d\'ange)\n'
            '• Antalya şiş kebap\n'
            '• Dondurma (glace turque)\n\n'
            '💰 Budget repas/jour : 250-600 TL/pers';
      }
      return 'Les spécialités turques varient selon la région. Essayez les mezes, kebabs et baklavas !';
    }

    if (q.contains('transport') || q.contains('aller') || q.contains('comment')) {
      if (_selectedCity == 'Istanbul') {
        return '🚇 **Transport à Istanbul :**\n\n'
            '🚕 **Taxi :** Utilisez BiTaksi ou Uber. Compteur obligatoire. Budget: ~25 TL/km\n\n'
            '🚇 **Métro/Tram :** Achetez Istanbulkart (130 TL), rechargez-la. Trajet: 15-20 TL\n\n'
            '🚢 **Ferry :** Traversée Eminönü-Kadıköy: 20 TL, vue magnifique\n\n'
            '🚌 **Bus :** Réseau étendu mais attention aux embouteillages\n\n'
            '💰 **Budget transport/jour :** 100-300 TL';
      }
      return 'Les transports en commun sont abordables en Turquie. Les taxis sont jaunes et utilisent le compteur.';
    }

    if (q.contains('budget') || q.contains('coûte') || q.contains('prix') || q.contains('combien') || q.contains('cher')) {
      return '💰 **Budget estimé pour $_tripDuration jours à $_selectedCity :**\n\n'
          '🏨 **Hébergement :** 1000-3000 TL/nuit\n'
          '🍽 **Repas :** 300-800 TL/jour\n'
          '🚇 **Transport :** 100-300 TL/jour\n'
          '🎟 **Activités/Visites :** 500-1500 TL/jour\n\n'
          '📊 **Budget total estimé :** ${_tripDuration * 2000}-${_tripDuration * 5000} TL\n'
          '💵 **Soit environ :** ${(_tripDuration * 2000 / 35).toStringAsFixed(0)}-${(_tripDuration * 5000 / 35).toStringAsFixed(0)} €';
    }

    if (q.contains('visiter') || q.contains('voir') || q.contains('quoi') || q.contains('activity') || q.contains('activité')) {
      if (_selectedCity == 'Istanbul') {
        String suggestions = '🎯 **Que faire à Istanbul pendant $_tripDuration jours :**\n\n';
        if (interests.contains('culture')) {
          suggestions += '🏛 **Jour 1 - Historique :** Sainte-Sophie, Mosquée Bleue, Palais Topkapi, Citerne Basilique, Grand Bazar\n';
        }
        if (interests.contains('food')) {
          suggestions += '🍽 **Jour 2 - Gastronomie :** Petit-déjeuner turc, Balık ekmek, cours de cuisine, dîner à Kadıköy\n';
        }
        if (interests.contains('shopping')) {
          suggestions += '🛍 **Shopping :** Grand Bazar, Bazar aux Épices, Istinye Park, Zorlu Center\n';
        }
        if (interests.contains('nature')) {
          suggestions += '🌿 **Nature :** Croisière Bosphore, Îles aux Princes, Parc Emirgan, Belgrad Ormanı\n';
        }
        suggestions += '\n💡 Conseil : Commencez tôt (8h) pour éviter la foule aux sites populaires.';
        return suggestions;
      } else if (_selectedCity == 'Antalya') {
        String suggestions = '🎯 **Que faire à Antalya pendant $_tripDuration jours :**\n\n';
        suggestions += '🏛 **Jour 1 - Vieille Ville :** Kaleiçi, Porte d\'Hadrien, Tour Hidirlik, Marina\n';
        suggestions += '🏖 **Jour 2 - Plages & Nature :** Konyaaltı, Lara, Cascades Düden\n';
        if (interests.contains('adventure')) {
          suggestions += '🧗 **Aventure :** Parapente à Ölüdeniz, Plongée, Randonnée dans le Taurus\n';
        }
        suggestions += '\n💡 Conseil : Louez une voiture pour explorer la côte (300-500 TL/jour).';
        return suggestions;
      }
      return 'Découvrez les merveilles de $selectedCity : sites historiques, plages, restaurants et activités !';
    }

    if (q.contains('hôtel') || q.contains('hotel') || q.contains('dormir') || q.contains('hébergement')) {
      return '🏨 **Hébergement à $_selectedCity :**\n\n'
          '💰 **Budget :**\n'
          '• Auberge/Hostel : 300-600 TL/nuit\n'
          '• Hôtel 3* : 1000-2000 TL/nuit\n'
          '• Hôtel 4-5* : 2500-5000 TL/nuit\n'
          '• Boutique/Hôtel de charme : 1500-4000 TL/nuit\n\n'
          '📌 **Quartiers recommandés à $_selectedCity :**\n'
          '${_selectedCity == "Istanbul" ? "Sultanahmet (historique), Taksim (animé), Karaköy (tendance), Beşiktaş (local)" : "Kaleiçi (historique), Konyaaltı (plage), Lara (station balnéaire)"}';
    }

    // Default response based on interests
    String response = '🤖 **Recommandations personnalisées pour $_selectedCity :**\n\n';
    response += 'Basé sur vos centres d\'intérêt : ${interests.map((i) {
      return TravelInterest.all.firstWhere((ti) => ti.id == i).name;
    }).join(', ')}\n\n';

    if (interests.contains('culture')) {
      response += '🏛 Visitez les sites historiques incontournables\n';
    }
    if (interests.contains('food')) {
      response += '🍽 Goûtez aux spécialités locales et street food\n';
    }
    if (interests.contains('nature')) {
      response += '🏖 Explorez les plages et espaces naturels\n';
    }
    if (interests.contains('shopping')) {
      response += '🛍 Découvrez les bazars et centres commerciaux\n';
    }
    response += '\n💡 Posez-moi des questions spécifiques sur :\n';
    response += '• Les restaurants et la nourriture\n';
    response += '• Les transports et comment se déplacer\n';
    response += '• Le budget et les coûts\n';
    response += '• Les choses à voir et à faire\n';
    response += '• Les hôtels et l\'hébergement';

    return response;
  }

  TripPlan generatePlan() {
    final plans = <PlanDay>[];
    for (int i = 1; i <= _tripDuration; i++) {
      String theme;
      List<String> activities;
      String meal;
      String cost;

      if (_selectedCity == 'Istanbul') {
        if (i == 1) {
          theme = 'Découverte Historique';
          activities = ['Sainte-Sophie', 'Mosquée Bleue', 'Palais de Topkapi', 'Citerne Basilique', 'Grand Bazar'];
          meal = 'Déjeuner: Balık ekmek au pont de Galata';
          cost = '500-800 TL';
        } else if (i == 2) {
          theme = 'Bosphore & Shopping';
          activities = ['Croisière Bosphore', 'Palais Dolmabahçe', 'Istinye Park', 'Tour Galata', 'Bazar aux Épices'];
          meal = 'Déjeuner: Meze chez Çiya Sofrası';
          cost = '600-1000 TL';
        } else if (i == 3) {
          theme = 'Culture & Détente';
          activities = ['Hammam traditionnel', 'Quartier de Kadıköy', 'Mosquée Süleymaniye', 'Thé à Pierre Loti'];
          meal = 'Dîner: Poisson à Kumkapı';
          cost = '400-700 TL';
        } else {
          theme = 'Exploration & Aventure';
          activities = ['Îles aux Princes', 'Balade à Üsküdar', 'Marché aux poissons', 'Thé dans un çay bahçesi'];
          meal = 'Déjeuner: Pide/Lahmacun';
          cost = '300-600 TL';
        }
      } else {
        if (i == 1) {
          theme = 'Vieille Ville & Histoire';
          activities = ['Kaleiçi', 'Porte d\'Hadrien', 'Tour Hidirlik', 'Musée d\'Antalya', 'Marina'];
          meal = 'Déjeuner: Restaurant 7 Mehmet';
          cost = '400-700 TL';
        } else if (i == 2) {
          theme = 'Plages & Cascades';
          activities = ['Plage Konyaaltı', 'Cascades Düden', 'Plage Lara', 'Dîner au bord de mer'];
          meal = 'Déjeuner: Poisson grillé';
          cost = '300-600 TL';
        } else {
          theme = 'Nature & Détente';
          activities = ['Olympos/Çıralı', 'Yanartaş (feu éternel)', 'Plage Kaputaş', 'Coucher de soleil'];
          meal = 'Déjeuner: Gözleme fait maison';
          cost = '350-650 TL';
        }
      }

      plans.add(PlanDay(
        dayNumber: i,
        theme: theme,
        activities: activities,
        mealSuggestion: meal,
        estimatedCost: cost,
      ));
    }

    return TripPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Séjour à $_selectedCity',
      city: _selectedCity,
      duration: _tripDuration,
      interests: _selectedInterests,
      estimatedBudget: '${_tripDuration * 2000}-${_tripDuration * 5000} TL',
      days: plans,
    );
  }

  Future<void> askQuestion(String question) async {
    _isLoading = true;
    _question = question;
    _answer = null;
    notifyListeners();

    // Simulate processing time
    await Future.delayed(const Duration(milliseconds: 500));
    _answer = generateAnswer(question);
    _isLoading = false;
    notifyListeners();
  }
}
