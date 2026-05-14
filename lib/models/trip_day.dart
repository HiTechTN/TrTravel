import 'trip_activity.dart';

class TripDay {
  final String id;
  final int dayNumber;
  final String city;
  final String theme;
  final List<TripActivity> activities;
  final double estimatedCost;
  final List<String> tips;
  final DateTime? date;

  TripDay({
    required this.id,
    required this.dayNumber,
    required this.city,
    required this.theme,
    required this.activities,
    required this.estimatedCost,
    required this.tips,
    this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'dayNumber': dayNumber, 'city': city, 'theme': theme,
    'activities': activities.map((a) => a.toJson()).toList(),
    'estimatedCost': estimatedCost, 'tips': tips, 'date': date?.toIso8601String(),
  };

  factory TripDay.fromJson(Map<String, dynamic> json) => TripDay(
    id: json['id'],
    dayNumber: json['dayNumber'],
    city: json['city'],
    theme: json['theme'],
    activities: (json['activities'] as List).map((a) => TripActivity.fromJson(a)).toList(),
    estimatedCost: (json['estimatedCost'] ?? 0.0).toDouble(),
    tips: List<String>.from(json['tips'] ?? []),
    date: json['date'] != null ? DateTime.parse(json['date']) : null,
  );
}
