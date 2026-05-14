import 'package:intl/intl.dart';

class JournalEntry {
  final String id;
  final DateTime date;
  final String title;
  final String content;
  final String? location;
  final List<String> photos; // In a real app, these would be file paths or URLs
  final List<String> tags;

  JournalEntry({
    required this.id,
    required this.date,
    required this.title,
    required this.content,
    this.location,
    this.photos = const [],
    this.tags = const [],
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String,
      content: json['content'] as String,
      location: json['location'] as String?,
      photos: List<String>.from(json['photos'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'title': title,
        'content': content,
        'location': location,
        'photos': photos,
        'tags': tags,
      };

  String get formattedDate =>
      DateFormat('dd MMMM yyyy', 'fr_FR').format(date);
}