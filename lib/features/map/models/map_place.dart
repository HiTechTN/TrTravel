import 'package:latlong2/latlong.dart';

class MapPlace {
  final String id;
  final String name;
  final String nameTr;
  final String nameEn;
  final String description;
  final String descriptionTr;
  final String descriptionEn;
  final LatLng location;
  final String category;
  final String subcategory;
  final double rating;
  final int reviewCount;
  final String? address;
  final String? phone;
  final String? website;
  final String? openingHours;
  final String? closingHours;
  final String? priceRange;
  final String? entranceFee;
  final String? bestTime;
  final int estimatedMinutes;
  final List<String> tags;
  final String city;
  final String district;
  final bool hasParking;
  final bool hasWheelchair;
  final bool hasWifi;
  final bool isIndoor;
  final bool isOutdoor;
  final String? metroStation;
  final List<String> busLines;
  final bool allowsPhotography;
  final String? dressCode;
  final String? cuisine;
  final double? averagePrice;
  final String? wikipediaUrl;

  const MapPlace({
    required this.id,
    required this.name,
    required this.nameTr,
    required this.nameEn,
    required this.description,
    required this.descriptionTr,
    required this.descriptionEn,
    required this.location,
    required this.category,
    this.subcategory = '',
    this.rating = 0,
    this.reviewCount = 0,
    this.address,
    this.phone,
    this.website,
    this.openingHours,
    this.closingHours,
    this.priceRange,
    this.entranceFee,
    this.bestTime,
    this.estimatedMinutes = 60,
    this.tags = const [],
    required this.city,
    this.district = '',
    this.hasParking = false,
    this.hasWheelchair = false,
    this.hasWifi = false,
    this.isIndoor = false,
    this.isOutdoor = false,
    this.metroStation,
    this.busLines = const [],
    this.allowsPhotography = true,
    this.dressCode,
    this.cuisine,
    this.averagePrice,
    this.wikipediaUrl,
  });

  String get localizedName => name;
  String get localizedDescription => description;

  static const categories = [
    'Tout',
    'Monuments Historiques',
    'Mosquées',
    'Musées',
    'Palais',
    'Parcs & Jardins',
    'Points de Vue',
    'Plages',
    'Restaurants',
    'Shopping',
    'Transports',
    'Hébergement',
  ];
}
