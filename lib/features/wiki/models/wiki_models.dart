import 'package:flutter/material.dart';

class WikiSection {
  final String id;
  final Map<String, String> title;
  final Map<String, String> content;
  final String? imageUrl;
  final List<WikiSection> subsections;

  const WikiSection({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.subsections = const [],
  });

  String get localizedTitle => title['fr'] ?? title['en'] ?? '';
  String get localizedContent => content['fr'] ?? content['en'] ?? '';
}

class WikiItem {
  final String id;
  final Map<String, String> title;
  final Map<String, String> description;
  final String category;
  final List<String> tags;
  final String city;
  final IconData icon;
  final String? imageUrl;
  final String? price;
  final String? hours;
  final String? website;
  final String? phone;
  final String? address;
  final String? bookingUrl;
  final List<WikiSection> sections;

  const WikiItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.tags = const [],
    required this.city,
    required this.icon,
    this.imageUrl,
    this.price,
    this.hours,
    this.website,
    this.phone,
    this.address,
    this.bookingUrl,
    this.sections = const [],
  });

  String get localizedTitle => title['fr'] ?? title['en'] ?? '';
  String get localizedDescription => description['fr'] ?? description['en'] ?? '';
}

class WikiCategory {
  final String id;
  final Map<String, String> name;
  final IconData icon;
  final List<WikiItem> items;

  const WikiCategory({
    required this.id,
    required this.name,
    required this.icon,
    this.items = const [],
  });

  String get localizedName => name['fr'] ?? name['en'] ?? '';
}
