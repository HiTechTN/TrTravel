class JournalEntry {
  final String id;
  final DateTime date;
  String title;
  String content;
  String? location;
  List<String> tags;
  List<String> photoPaths;
  final DateTime createdAt;
  DateTime updatedAt;

  JournalEntry({
    required this.id,
    required this.date,
    required this.title,
    required this.content,
    this.location,
    this.tags = const [],
    this.photoPaths = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'title': title,
    'content': content,
    'location': location,
    'tags': tags,
    'photoPaths': photoPaths,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String,
      content: json['content'] as String,
      location: json['location'] as String?,
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
      photoPaths: (json['photoPaths'] as List?)?.cast<String>() ?? [],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }
}
