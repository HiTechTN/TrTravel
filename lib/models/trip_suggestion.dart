class TripSuggestion {
  final String id;
  final String title;
  final String description;
  final String city;
  final String category;
  final int priority;
  final String icon;
  final String duration;
  final String estimatedCost;

  TripSuggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.city,
    required this.category,
    required this.priority,
    required this.icon,
    required this.duration,
    required this.estimatedCost,
  });
}
