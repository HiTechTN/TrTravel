class VoiceNote {
  final String id;
  final String filePath;
  final String? transcript;
  final int durationSeconds;
  final DateTime date;
  final String? location;
  final String? journalEntryId;
  final bool isTranscribed;
  final DateTime createdAt;

  VoiceNote({
    required this.id,
    required this.filePath,
    this.transcript,
    this.durationSeconds = 0,
    required this.date,
    this.location,
    this.journalEntryId,
    this.isTranscribed = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  VoiceNote copyWith({
    String? transcript,
    int? durationSeconds,
    String? location,
    String? journalEntryId,
    bool? isTranscribed,
  }) {
    return VoiceNote(
      id: id,
      filePath: filePath,
      transcript: transcript ?? this.transcript,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      date: date,
      location: location ?? this.location,
      journalEntryId: journalEntryId ?? this.journalEntryId,
      isTranscribed: isTranscribed ?? this.isTranscribed,
      createdAt: createdAt,
    );
  }

  String get formattedDuration {
    final min = durationSeconds ~/ 60;
    final sec = durationSeconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'filePath': filePath,
    'transcript': transcript,
    'durationSeconds': durationSeconds,
    'date': date.toIso8601String(),
    'location': location,
    'journalEntryId': journalEntryId,
    'isTranscribed': isTranscribed,
    'createdAt': createdAt.toIso8601String(),
  };

  factory VoiceNote.fromJson(Map<String, dynamic> json) => VoiceNote(
    id: json['id'] as String,
    filePath: json['filePath'] as String,
    transcript: json['transcript'] as String?,
    durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
    date: DateTime.parse(json['date'] as String),
    location: json['location'] as String?,
    journalEntryId: json['journalEntryId'] as String?,
    isTranscribed: json['isTranscribed'] as bool? ?? false,
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
  );
}
