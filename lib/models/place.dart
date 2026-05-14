import 'package:latlong2/latlong.dart';

class Place {
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String category;
  final double rating;
  final List<String> photos;
  final String address;
  final String? openingHours;
  final double? estimatedVisitDuration;

  Place({
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.category,
    this.rating = 4.0,
    this.photos = const [],
    this.address = '',
    this.openingHours,
    this.estimatedVisitDuration,
  });

  LatLng get location => LatLng(latitude, longitude);

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'latitude': latitude,
    'longitude': longitude,
    'category': category,
    'rating': rating,
    'photos': photos,
    'address': address,
    'openingHours': openingHours,
    'estimatedVisitDuration': estimatedVisitDuration,
  };

  factory Place.fromJson(Map<String, dynamic> json) => Place(
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    latitude: (json['latitude'] ?? 0.0).toDouble(),
    longitude: (json['longitude'] ?? 0.0).toDouble(),
    category: json['category'] ?? 'other',
    rating: (json['rating'] ?? 4.0).toDouble(),
    photos: List<String>.from(json['photos'] ?? []),
    address: json['address'] ?? '',
    openingHours: json['openingHours'],
    estimatedVisitDuration: json['estimatedVisitDuration']?.toDouble(),
  );
}
