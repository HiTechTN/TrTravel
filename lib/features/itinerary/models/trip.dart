import 'day_trip.dart';

class Trip {
  final String id;
  String title;
  String description;
  DateTime startDate;
  DateTime endDate;
  String location;
  List<DayTrip> days;

  Trip({
    required this.id,
    required this.title,
    this.description = '',
    required this.startDate,
    required this.endDate,
    this.location = '',
    this.days = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'location': location,
    'days': days.map((d) => d.toJson()).toList(),
  };

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      location: json['location'] as String? ?? '',
      days: (json['days'] as List?)
              ?.map((d) => DayTrip.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
