import 'package:latlong2/latlong.dart';

class MapPlace {
  final String name;
  final String nameTr;
  final String description;
  final String descriptionTr;
  final LatLng location;
  final String category;
  final double rating;
  final String? openingHours;
  final double? estimatedDuration;
  final String? phone;
  final String? website;
  final String? address;
  final double? entranceFee;
  final String? bestTime;
  final List<String> tags;
  final String city;

  MapPlace({
    required this.name,
    required this.nameTr,
    required this.description,
    required this.descriptionTr,
    required this.location,
    required this.category,
    this.rating = 4.0,
    this.openingHours,
    this.estimatedDuration,
    this.phone,
    this.website,
    this.address,
    this.entranceFee,
    this.bestTime,
    this.tags = const [],
    this.city = 'Istanbul',
  });
}
