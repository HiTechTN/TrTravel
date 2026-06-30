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
    TravelInterest(id: 'culture', name: 'Culture & Histoire', emoji: '🏛️'),
    TravelInterest(id: 'food', name: 'Gastronomie', emoji: '🍽️'),
    TravelInterest(id: 'nature', name: 'Nature & Plages', emoji: '🏖️'),
    TravelInterest(id: 'shopping', name: 'Shopping', emoji: '🛍️'),
    TravelInterest(id: 'nightlife', name: 'Vie Nocturne', emoji: '🌙'),
    TravelInterest(id: 'adventure', name: 'Aventure & Sport', emoji: '🧗'),
    TravelInterest(id: 'relaxation', name: 'Détente & Bien-être', emoji: '🧘'),
    TravelInterest(id: 'photography', name: 'Photographie', emoji: '📸'),
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
