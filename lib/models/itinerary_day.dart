import 'place.dart';

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
