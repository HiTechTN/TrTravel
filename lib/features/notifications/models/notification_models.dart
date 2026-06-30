import 'dart:convert';

class NotificationReminder {
  final String id;
  final String title;
  final String body;
  final String type;
  final String? itineraryId;
  final String? placeName;
  final double? latitude;
  final double? longitude;
  final double? radiusMeters;
  final DateTime? scheduledAt;
  final DateTime createdAt;
  bool isRead;
  bool isTriggered;

  NotificationReminder({
    required this.id,
    required this.title,
    required this.body,
    this.type = 'time',
    this.itineraryId,
    this.placeName,
    this.latitude,
    this.longitude,
    this.radiusMeters,
    this.scheduledAt,
    DateTime? createdAt,
    this.isRead = false,
    this.isTriggered = false,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isGeofence => type == 'geofence';
  bool get isTimeBased => type == 'time';

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'type': type,
    'itineraryId': itineraryId,
    'placeName': placeName,
    'latitude': latitude,
    'longitude': longitude,
    'radiusMeters': radiusMeters,
    'scheduledAt': scheduledAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
    'isTriggered': isTriggered,
  };

  factory NotificationReminder.fromJson(Map<String, dynamic> json) {
    return NotificationReminder(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String? ?? 'time',
      itineraryId: json['itineraryId'] as String?,
      placeName: json['placeName'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      radiusMeters: (json['radiusMeters'] as num?)?.toDouble(),
      scheduledAt: json['scheduledAt'] != null ? DateTime.parse(json['scheduledAt'] as String) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      isTriggered: json['isTriggered'] as bool? ?? false,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory NotificationReminder.fromJsonString(String jsonStr) {
    return NotificationReminder.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
  }
}

class SmartSuggestion {
  final String id;
  final String title;
  final String message;
  final String type;
  final String? actionRoute;
  final DateTime createdAt;

  SmartSuggestion({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.actionRoute,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
