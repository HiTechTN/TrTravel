class ARLandmark {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final String category;
  final double distance;

  const ARLandmark({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    this.category = 'landmark',
    this.distance = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'latitude': latitude,
    'longitude': longitude,
    'imageUrl': imageUrl,
    'category': category,
    'distance': distance,
  };

  factory ARLandmark.fromJson(Map<String, dynamic> json) => ARLandmark(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    imageUrl: json['imageUrl'] as String?,
    category: json['category'] as String? ?? 'landmark',
    distance: (json['distance'] as num?)?.toDouble() ?? 0,
  );
}

class ARTrackingSession {
  final String id;
  final DateTime startTime;
  final List<String> recognizedLandmarks;
  final int totalScans;
  bool isActive;

  ARTrackingSession({
    required this.id,
    DateTime? startTime,
    this.recognizedLandmarks = const [],
    this.totalScans = 0,
    this.isActive = true,
  }) : startTime = startTime ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'startTime': startTime.toIso8601String(),
    'recognizedLandmarks': recognizedLandmarks,
    'totalScans': totalScans,
    'isActive': isActive,
  };

  factory ARTrackingSession.fromJson(Map<String, dynamic> json) => ARTrackingSession(
    id: json['id'] as String,
    startTime: DateTime.parse(json['startTime'] as String),
    recognizedLandmarks: (json['recognizedLandmarks'] as List?)?.cast<String>() ?? [],
    totalScans: (json['totalScans'] as num?)?.toInt() ?? 0,
    isActive: json['isActive'] as bool? ?? true,
  );
}
