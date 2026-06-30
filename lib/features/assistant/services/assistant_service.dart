import 'package:flutter/foundation.dart';
import 'package:trtravel/core/services/local_storage.dart';
import 'package:trtravel/data/poi_database.dart';
import 'package:trtravel/features/assistant/models/assistant_models.dart';

class AssistantService extends ChangeNotifier {
  final List<ConversationMessage> _messages = [];
  List<ConversationMessage> get messages => List.unmodifiable(_messages);

  ConversationContext _context = const ConversationContext();
  ConversationContext get context => _context;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  static const String _historyKey = 'assistant_conversation_history';
  static const String _contextKey = 'assistant_context';

  AssistantService() {
    _loadHistory();
  }

  void _loadHistory() {
    final jsonHist = LocalStorage.getJsonList(_historyKey);
    if (jsonHist != null) {
      for (final j in jsonHist) {
        _messages.add(ConversationMessage(
          id: j['id'] as String,
          text: j['text'] as String,
          isUser: j['isUser'] as bool,
          timestamp: DateTime.parse(j['timestamp'] as String),
          response: j['response'] != null
              ? AIResponse(
                  message: j['response']['message'] as String,
                  confidence: (j['response']['confidence'] as num).toDouble(),
                  suggestions: (j['response']['suggestions'] as List?)?.cast<String>() ?? [],
                  intent: IntentType.values.firstWhere(
                    (e) => e.name == j['response']['intent'],
                    orElse: () => IntentType.generalHelp,
                  ),
                )
              : null,
        ));
      }
    }
    final jsonCtx = LocalStorage.getJson(_contextKey);
    if (jsonCtx != null) {
      _context = ConversationContext.fromJson(jsonCtx);
    }
  }

  void _saveHistory() {
    final list = _messages.map((m) {
      return {
        'id': m.id,
        'text': m.text,
        'isUser': m.isUser,
        'timestamp': m.timestamp.toIso8601String(),
        if (m.response != null)
          'response': {
            'message': m.response!.message,
            'confidence': m.response!.confidence,
            'suggestions': m.response!.suggestions,
            'intent': m.response!.intent.name,
          },
      };
    }).toList();
    LocalStorage.setJsonList(_historyKey, list);
  }

  void _saveContext() {
    LocalStorage.setJson(_contextKey, _context.toJson());
  }

  void updateContext(ConversationContext newContext) {
    _context = newContext;
    _saveContext();
    notifyListeners();
  }

  void setCity(String city) {
    _context = _context.copyWith(city: city);
    _saveContext();
    notifyListeners();
  }

  void setDuration(int days) {
    _context = _context.copyWith(tripDuration: days.clamp(1, 7));
    _saveContext();
    notifyListeners();
  }

  void toggleInterest(String id) {
    final interests = List<String>.from(_context.interests);
    if (interests.contains(id)) {
      interests.remove(id);
    } else {
      interests.add(id);
    }
    _context = _context.copyWith(interests: interests);
    _saveContext();
    notifyListeners();
  }

  static const cities = ['Istanbul', 'Antalya', 'Cappadoce', 'Izmir', 'Ankara'];

  IntentType _detectIntent(String text) {
    final q = text.toLowerCase();
    if (q.contains('météo') || q.contains('temps') || q.contains('pluie') || q.contains('soleil') || q.contains('température') || q.contains('degré')) {
      return IntentType.weatherRequest;
    }
    if (q.contains('direction') || q.contains('aller') || q.contains('comment') || q.contains('transport') || q.contains('taxi') || q.contains('métro') || q.contains('bus') || q.contains('train') || q.contains('route') || q.contains('navette')) {
      return IntentType.directionRequest;
    }
    if (q.contains('restaurant') || q.contains('manger') || q.contains('café') || q.contains('mangé') || q.contains('nourriture') || q.contains('food') || q.contains('visiter') || q.contains('voir') || q.contains('quoi') || q.contains('activity') || q.contains('activité') || q.contains('hôtel') || q.contains('hotel') || q.contains('dormir') || q.contains('hébergement') || q.contains('budget') || q.contains('coûte') || q.contains('prix') || q.contains('combien') || q.contains('cher')) {
      return IntentType.recommendationRequest;
    }
    if (q.contains('traduire') || q.contains('mot') || q.contains('phrase') || q.contains('traduction') || q.contains('dire') || q.contains('traduit') || q.contains('langue') || q.contains('türkçe') || q.contains('turkish') || q.contains('anglais')) {
      return IntentType.translationRequest;
    }
    return IntentType.generalHelp;
  }

  String _getWeatherResponse(String city) {
    const weather = {
      'Istanbul': '🌤 **Météo à Istanbul**\n\nTempérature: 28°C\nCondition: Ensoleillé\nHumidité: 60%\nVent: 15 km/h\n\n💡 Conseil: Prévoir une veste légère pour le soir.',
      'Antalya': '☀️ **Météo à Antalya**\n\nTempérature: 32°C\nCondition: Ensoleillé\nHumidité: 55%\nVent: 10 km/h\n\n💡 Conseil: Protection solaire obligatoire !',
      'Cappadoce': '⛅ **Météo en Cappadoce**\n\nTempérature: 25°C\nCondition: Dégagé\nHumidité: 40%\nVent: 20 km/h\n\n💡 Conseil: Matinées fraîches, prévoir un sweat.',
      'Izmir': '🌤 **Météo à Izmir**\n\nTempérature: 30°C\nCondition: Ensoleillé\nHumidité: 50%\nVent: 18 km/h\n\n💡 Conseil: Idéal pour la plage !',
      'Ankara': '🌥 **Météo à Ankara**\n\nTempérature: 26°C\nCondition: Partiellement nuageux\nHumidité: 45%\nVent: 12 km/h\n\n💡 Conseil: Agréable pour les visites.',
    };
    return weather[city] ?? 'Données météo non disponibles pour cette ville.';
  }

  String _getRecommendationResponse(String text) {
    final q = text.toLowerCase();
    final city = _context.city;

    if (q.contains('manger') || q.contains('mangé') || q.contains('restaurant') || q.contains('nourriture') || q.contains('food') || q.contains('café')) {
      final pois = POIDatabase.getByCity(city).where((p) => p.category == 'restaurant').take(5).toList();
      if (pois.isNotEmpty) {
        String resp = '🍽 **Restaurants à $city :**\n\n';
        for (final p in pois) {
          resp += '• **${p.name}** ${p.averagePrice != null ? '(${p.averagePrice!.round()} TL/pers)' : ''}\n';
          resp += '  ${p.description}\n';
          if (p.tags.isNotEmpty) resp += '  🏷 ${p.tags.take(3).join(', ')}\n';
          resp += '\n';
        }
        return resp;
      }
      return _foodResponse(city);
    }

    if (q.contains('hôtel') || q.contains('hotel') || q.contains('dormir') || q.contains('hébergement')) {
      return '🏨 **Hébergement à $city :**\n\n'
          '💰 **Budget :**\n'
          '• Auberge/Hostel : 300-600 TL/nuit\n'
          '• Hôtel 3* : 1000-2000 TL/nuit\n'
          '• Hôtel 4-5* : 2500-5000 TL/nuit\n'
          '• Boutique/Hôtel de charme : 1500-4000 TL/nuit\n\n'
          '📌 **Quartiers recommandés :**\n'
          '${city == "Istanbul" ? "Sultanahmet (historique), Taksim (animé), Karaköy (tendance), Beşiktaş (local)" : city == "Antalya" ? "Kaleiçi (historique), Konyaaltı (plage), Lara (station balnéaire)" : "Centre-ville, quartier historique"}';
    }

    if (q.contains('visiter') || q.contains('voir') || q.contains('quoi') || q.contains('activity') || q.contains('activité')) {
      final pois = POIDatabase.getByCity(city).where((p) => p.rating >= 4.5).take(8).toList();
      if (pois.isNotEmpty) {
        String resp = '🎯 **Incontournables à $city :**\n\n';
        for (final p in pois) {
          final icon = _categoryIcon(p.category);
          resp += '$icon **${p.name}** (${p.rating}) - ${p.getEntranceFeeText()}\n';
          resp += '  ${p.description}\n\n';
        }
        return resp;
      }
      return _activitiesResponse(city);
    }

    if (q.contains('budget') || q.contains('coûte') || q.contains('prix') || q.contains('combien') || q.contains('cher')) {
      return '💰 **Budget estimé pour ${_context.tripDuration} jours à $city :**\n\n'
          '🏨 **Hébergement :** 1000-3000 TL/nuit\n'
          '🍽 **Repas :** 300-800 TL/jour\n'
          '🚇 **Transport :** 100-300 TL/jour\n'
          '🎟 **Activités/Visites :** 500-1500 TL/jour\n\n'
          '📊 **Budget total estimé :** ${_context.tripDuration * 2000}-${_context.tripDuration * 5000} TL\n'
          '💵 **Soit environ :** ${(_context.tripDuration * 2000 / 35).toStringAsFixed(0)}-${(_context.tripDuration * 5000 / 35).toStringAsFixed(0)} €';
    }

    final pois = POIDatabase.getByCity(city);
    if (pois.isNotEmpty) {
      String resp = '🤖 **Recommandations personnalisées pour $city :**\n\n';
      resp += 'Basé sur vos centres d\'intérêt : ${_context.interests.join(', ')}\n\n';
      for (final p in pois.take(5)) {
        final icon = _categoryIcon(p.category);
        resp += '$icon **${p.name}** - ${p.rating}/5\n';
        resp += '  ${p.description}\n\n';
      }
      return resp;
    }

    return _foodResponse(city);
  }

  String _categoryIcon(String category) {
    switch (category) {
      case 'restaurant':
        return '🍽';
      case 'museum':
        return '🏛';
      case 'historical':
        return '🏛';
      case 'religious':
        return '🕌';
      case 'shopping':
        return '🛍';
      case 'nature':
      case 'beach':
        return '🏖';
      case 'palace':
        return '🏯';
      case 'landmark':
        return '🗼';
      default:
        return '📍';
    }
  }

  String _foodResponse(String city) {
    if (city == 'Istanbul') {
      return '🍽 **Street food et restaurants à Istanbul :**\n\n'
          '**Incontournables :**\n'
          '• Balık ekmek au pont de Galata (50 TL)\n'
          '• Kumpir à Ortaköy (100 TL)\n'
          '• Midye dolma (20 TL/pièce)\n'
          '• Çiya Sofrası (Kadıköy) - Cuisine anatolienne\n'
          '• Karaköy Güllüoğlu - Meilleur baklava\n\n'
          '💰 Budget repas/jour : 300-800 TL/pers';
    }
    if (city == 'Antalya') {
      return '🍽 **Restaurants à Antalya :**\n\n'
          '• 7 Mehmet - Cuisine turque moderne\n'
          '• Seraser Fine Dining - Gastronomique\n'
          '• Vanilla Lounge - International\n'
          '• Selamlık - Cuisine anatolienne\n\n'
          '🥙 **Spécialités locales :**\n'
          '• Pişmaniye (cheveux d\'ange)\n'
          '• Antalya şiş kebap\n'
          '• Dondurma (glace turque)\n\n'
          '💰 Budget repas/jour : 250-600 TL/pers';
    }
    return 'Les spécialités turques varient selon la région. Essayez les mezes, kebabs et baklavas !';
  }

  String _activitiesResponse(String city) {
    if (city == 'Istanbul') {
      String suggestions = '🎯 **Que faire à Istanbul pendant ${_context.tripDuration} jours :**\n\n';
      if (_context.interests.contains('culture')) {
        suggestions += '🏛 **Culture :** Sainte-Sophie, Mosquée Bleue, Palais Topkapi, Citerne Basilique, Grand Bazar\n';
      }
      if (_context.interests.contains('food')) {
        suggestions += '🍽 **Gastronomie :** Petit-déjeuner turc, Balık ekmek, cours de cuisine, dîner à Kadıköy\n';
      }
      if (_context.interests.contains('shopping')) {
        suggestions += '🛍 **Shopping :** Grand Bazar, Bazar aux Épices, Istinye Park, Zorlu Center\n';
      }
      if (_context.interests.contains('nature')) {
        suggestions += '🌿 **Nature :** Croisière Bosphore, Îles aux Princes, Parc Emirgan, Belgrad Ormanı\n';
      }
      suggestions += '\n💡 Conseil : Commencez tôt (8h) pour éviter la foule aux sites populaires.';
      return suggestions;
    }
    if (city == 'Antalya') {
      String suggestions = '🎯 **Que faire à Antalya pendant ${_context.tripDuration} jours :**\n\n';
      suggestions += '🏛 **Jour 1 - Vieille Ville :** Kaleiçi, Porte d\'Hadrien, Tour Hidirlik, Marina\n';
      suggestions += '🏖 **Jour 2 - Plages & Nature :** Konyaaltı, Lara, Cascades Düden\n';
      if (_context.interests.contains('adventure')) {
        suggestions += '🧗 **Aventure :** Parapente à Ölüdeniz, Plongée, Randonnée dans le Taurus\n';
      }
      suggestions += '\n💡 Conseil : Louez une voiture pour explorer la côte (300-500 TL/jour).';
      return suggestions;
    }
    return 'Découvrez les merveilles de $city : sites historiques, plages, restaurants et activités !';
  }

  String _getDirectionResponse(String text) {
    final city = _context.city;
    if (city == 'Istanbul') {
      return '🚇 **Transport à Istanbul :**\n\n'
          '🚕 **Taxi :** Utilisez BiTaksi ou Uber. Compteur obligatoire. ~25 TL/km\n\n'
          '🚇 **Métro/Tram :** Achetez Istanbulkart (130 TL), rechargez-la. Trajet: 15-20 TL\n\n'
          '🚢 **Ferry :** Traversée Eminönü-Kadıköy: 20 TL, vue magnifique\n\n'
          '🚌 **Bus :** Réseau étendu mais attention aux embouteillages\n\n'
          '💰 **Budget transport/jour :** 100-300 TL';
    }
    if (city == 'Antalya') {
      return '🚇 **Transport à Antalya :**\n\n'
          '🚌 **Bus :** Antalyakart (130 TL), trajet 15-20 TL\n\n'
          '🚕 **Taxi :** BiTaksi disponible, ~20 TL/km\n\n'
          '🚎 **Tramway :** Ligne T1 centre-ville - plage Konyaaltı\n\n'
          '🚗 **Location voiture :** 300-500 TL/jour\n\n'
          '💰 **Budget transport/jour :** 80-250 TL';
    }
    return 'Les transports en commun sont abordables en Turquie. Les taxis sont jaunes et utilisent le compteur.';
  }

  String _getTranslationResponse(String text) {
    return '🌐 **Aide à la traduction :**\n\n'
        'Phrases utiles en turc :\n'
        '• Bonjour - **Merhaba**\n'
        '• Merci - **Teşekkür ederim**\n'
        '• S\'il vous plaît - **Lütfen**\n'
        '• Oui/Non - **Evet/Hayır**\n'
        '• Combien ça coûte ? - **Bu ne kadar?**\n'
        '• Où est... ? - **... nerede?**\n'
        '• L\'addition - **Hesap lütfen**\n'
        '• Délicieux - **Lezzetli**\n\n'
        '💡 Conseil : Les Turcs apprécient quand vous faites l\'effort de parler turc !';
  }

  String _getGeneralHelpResponse(String text) {
    String response = '🤖 **Assistant TrTravel - Comment puis-je vous aider ?**\n\n';
    response += 'Voici ce que je peux faire pour vous :\n\n';
    response += '🌤 **Météo** - Donnez-moi le nom d\'une ville pour connaître la météo\n';
    response += '🍽 **Restaurants** - Je vous recommande les meilleures adresses\n';
    response += '🚇 **Transport** - Conseils pour se déplacer\n';
    response += '🏛 **Visites** - Que voir et que faire\n';
    response += '💰 **Budget** - Estimations des coûts\n';
    response += '🏨 **Hébergement** - Où dormir\n';
    response += '🌐 **Traduction** - Phrases utiles en turc\n\n';
    response += '💡 **Suggestions pour $_selectedCity :**\n';
    final pois = POIDatabase.getByCity(_selectedCity).take(3).toList();
    for (final p in pois) {
      final icon = _categoryIcon(p.category);
      response += '$icon **${p.name}** - ${p.rating}/5\n';
    }
    return response;
  }

  String get _selectedCity => _context.city;

  List<String> _getSuggestionsForIntent(IntentType intent) {
    switch (intent) {
      case IntentType.weatherRequest:
        return ['Météo Istanbul', 'Météo Antalya', 'Température Cappadoce'];
      case IntentType.directionRequest:
        return ['Comment aller à Sainte-Sophie ?', 'Transport à Istanbul', 'Taxi à Antalya'];
      case IntentType.recommendationRequest:
        return ['Où manger ?', 'Que visiter ?', 'Budget pour 3 jours'];
      case IntentType.translationRequest:
        return ['Traduire bonjour', 'Phrases utiles', 'Dire merci en turc'];
      case IntentType.generalHelp:
        return ['Où manger ?', 'Que visiter ?', 'Météo', 'Transport', 'Budget', 'Traduction'];
    }
  }

  Future<AIResponse> _generateResponse(String text) async {
    final intent = _detectIntent(text);

    await Future.delayed(const Duration(milliseconds: 400));

    String message;
    switch (intent) {
      case IntentType.weatherRequest:
        message = _getWeatherResponse(_context.city);
        break;
      case IntentType.directionRequest:
        message = _getDirectionResponse(text);
        break;
      case IntentType.recommendationRequest:
        message = _getRecommendationResponse(text);
        break;
      case IntentType.translationRequest:
        message = _getTranslationResponse(text);
        break;
      case IntentType.generalHelp:
        message = _getGeneralHelpResponse(text);
        break;
    }

    final suggestions = _getSuggestionsForIntent(intent);

    return AIResponse(
      message: message,
      confidence: intent != IntentType.generalHelp ? 0.85 : 0.7,
      suggestions: suggestions,
      intent: intent,
    );
  }

  Future<void> askQuestion(String text) async {
    if (text.trim().isEmpty) return;

    _isLoading = true;
    notifyListeners();

    final userMsg = ConversationMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      isUser: true,
    );
    _messages.add(userMsg);

    final response = await _generateResponse(text.trim());

    final botMsg = ConversationMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_resp',
      text: response.message,
      isUser: false,
      response: response,
    );
    _messages.add(botMsg);

    _saveHistory();

    _isLoading = false;
    notifyListeners();
  }

  void clearConversation() {
    _messages.clear();
    LocalStorage.setJsonList(_historyKey, []);
    notifyListeners();
  }

  TripPlan generatePlan() {
    final plans = <PlanDay>[];
    final city = _context.city;
    final duration = _context.tripDuration;

    for (int i = 1; i <= duration; i++) {
      String theme;
      List<String> activities;
      String meal;
      String cost;

      if (city == 'Istanbul') {
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
        } else {
          theme = 'Culture & Détente';
          activities = ['Hammam traditionnel', 'Quartier de Kadıköy', 'Mosquée Süleymaniye', 'Thé à Pierre Loti'];
          meal = 'Dîner: Poisson à Kumkapı';
          cost = '400-700 TL';
        }
      } else {
        if (i == 1) {
          theme = 'Vieille Ville & Histoire';
          activities = ['Kaleiçi', "Porte d'Hadrien", 'Tour Hidirlik', "Musée d'Antalya", 'Marina'];
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
      title: 'Séjour à $city',
      city: city,
      duration: duration,
      interests: _context.interests,
      estimatedBudget: '${duration * 2000}-${duration * 5000} TL',
      days: plans,
    );
  }
}
