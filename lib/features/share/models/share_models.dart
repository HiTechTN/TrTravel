class SharedItinerary {
  final String id;
  final String tripId;
  final String ownerId;
  final String ownerName;
  final String title;
  final String description;
  final String? shareCode;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int viewCount;
  final Map<String, dynamic> itineraryData;

  SharedItinerary({
    required this.id,
    required this.tripId,
    required this.ownerId,
    required this.ownerName,
    required this.title,
    this.description = '',
    this.shareCode,
    DateTime? createdAt,
    DateTime? expiresAt,
    this.viewCount = 0,
    required this.itineraryData,
  })  : createdAt = createdAt ?? DateTime.now(),
        expiresAt = expiresAt ?? DateTime.now().add(const Duration(days: 30));

  Map<String, dynamic> toJson() => {
    'id': id,
    'tripId': tripId,
    'ownerId': ownerId,
    'ownerName': ownerName,
    'title': title,
    'description': description,
    'shareCode': shareCode,
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'viewCount': viewCount,
    'itineraryData': itineraryData,
  };

  factory SharedItinerary.fromJson(Map<String, dynamic> json) {
    return SharedItinerary(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      ownerId: json['ownerId'] as String,
      ownerName: json['ownerName'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      shareCode: json['shareCode'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      viewCount: json['viewCount'] as int? ?? 0,
      itineraryData: json['itineraryData'] as Map<String, dynamic>? ?? {},
    );
  }
}

class ShareLink {
  final String id;
  final String itineraryId;
  final String code;
  final String url;
  final DateTime createdAt;
  final bool isActive;

  ShareLink({
    required this.id,
    required this.itineraryId,
    required this.code,
    required this.url,
    DateTime? createdAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'itineraryId': itineraryId,
    'code': code,
    'url': url,
    'createdAt': createdAt.toIso8601String(),
    'isActive': isActive,
  };

  factory ShareLink.fromJson(Map<String, dynamic> json) {
    return ShareLink(
      id: json['id'] as String,
      itineraryId: json['itineraryId'] as String,
      code: json['code'] as String,
      url: json['url'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

enum ShareOption { link, qrCode, social, copy }
