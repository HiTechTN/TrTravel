enum IntentType {
  weatherRequest,
  directionRequest,
  recommendationRequest,
  translationRequest,
  generalHelp,
}

class ConversationContext {
  final String city;
  final List<String> interests;
  final int tripDuration;

  const ConversationContext({
    this.city = 'Istanbul',
    this.interests = const ['culture', 'food'],
    this.tripDuration = 3,
  });

  ConversationContext copyWith({
    String? city,
    List<String>? interests,
    int? tripDuration,
  }) {
    return ConversationContext(
      city: city ?? this.city,
      interests: interests ?? this.interests,
      tripDuration: tripDuration ?? this.tripDuration,
    );
  }

  Map<String, dynamic> toJson() => {
        'city': city,
        'interests': interests,
        'tripDuration': tripDuration,
      };

  factory ConversationContext.fromJson(Map<String, dynamic> json) {
    return ConversationContext(
      city: json['city'] as String? ?? 'Istanbul',
      interests: (json['interests'] as List?)?.cast<String>() ?? ['culture', 'food'],
      tripDuration: json['tripDuration'] as int? ?? 3,
    );
  }
}

class AIResponse {
  final String message;
  final double confidence;
  final List<String> suggestions;
  final IntentType intent;
  final DateTime timestamp;

  AIResponse({
    required this.message,
    this.confidence = 1.0,
    this.suggestions = const [],
    this.intent = IntentType.generalHelp,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ConversationMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final AIResponse? response;

  ConversationMessage({
    required this.id,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.response,
  }) : timestamp = timestamp ?? DateTime.now();
}

class TravelSuggestion {
  final String id;
  final String title;
  final String description;
  final String category;
  final String city;
  final String icon;
  final String estimatedCost;
  final String duration;
  final int priority;

  const TravelSuggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.city,
    required this.icon,
    required this.estimatedCost,
    required this.duration,
    this.priority = 0,
  });
}

class TravelInterest {
  final String id;
  final String name;
  final String emoji;

  const TravelInterest({required this.id, required this.name, required this.emoji});

  static const List<TravelInterest> all = [
    TravelInterest(id: 'culture', name: 'Culture & Histoire', emoji: '\u{1F3DB}\u{FE0F}'),
    TravelInterest(id: 'food', name: 'Gastronomie', emoji: '\u{1F37D}\u{FE0F}'),
    TravelInterest(id: 'nature', name: 'Nature & Plages', emoji: '\u{1F3D6}\u{FE0F}'),
    TravelInterest(id: 'shopping', name: 'Shopping', emoji: '\u{1F6CD}\u{FE0F}'),
    TravelInterest(id: 'nightlife', name: 'Vie Nocturne', emoji: '\u{1F319}'),
    TravelInterest(id: 'adventure', name: 'Aventure & Sport', emoji: '\u{1F9D7}'),
    TravelInterest(id: 'relaxation', name: 'Détente & Bien-être', emoji: '\u{1F9D8}'),
    TravelInterest(id: 'photography', name: 'Photographie', emoji: '\u{1F4F8}'),
  ];
}

class TripPlan {
  final String id;
  final String title;
  final String city;
  final int duration;
  final List<String> interests;
  final String estimatedBudget;
  final List<PlanDay> days;
  final DateTime createdAt;

  TripPlan({
    required this.id,
    required this.title,
    required this.city,
    required this.duration,
    required this.interests,
    required this.estimatedBudget,
    required this.days,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class PlanDay {
  final int dayNumber;
  final String theme;
  final List<String> activities;
  final String mealSuggestion;
  final String estimatedCost;

  const PlanDay({
    required this.dayNumber,
    required this.theme,
    required this.activities,
    required this.mealSuggestion,
    required this.estimatedCost,
  });
}
