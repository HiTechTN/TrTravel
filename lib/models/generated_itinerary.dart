import 'itinerary_day.dart';

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
