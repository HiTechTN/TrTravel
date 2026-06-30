enum QueueAction { create, update, delete }

enum QueueStatus { pending, syncing, failed }

class OfflineQueueItem {
  final String id;
  final Map<String, dynamic> data;
  final QueueAction action;
  final String collection;
  final DateTime timestamp;
  final int retryCount;
  final QueueStatus status;

  OfflineQueueItem({
    required this.id,
    required this.data,
    required this.action,
    required this.collection,
    DateTime? timestamp,
    this.retryCount = 0,
    this.status = QueueStatus.pending,
  }) : timestamp = timestamp ?? DateTime.now();

  OfflineQueueItem copyWith({
    String? id,
    Map<String, dynamic>? data,
    QueueAction? action,
    String? collection,
    DateTime? timestamp,
    int? retryCount,
    QueueStatus? status,
  }) {
    return OfflineQueueItem(
      id: id ?? this.id,
      data: data ?? this.data,
      action: action ?? this.action,
      collection: collection ?? this.collection,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'data': data,
        'action': action.name,
        'collection': collection,
        'timestamp': timestamp.toIso8601String(),
        'retryCount': retryCount,
        'status': status.name,
      };

  factory OfflineQueueItem.fromJson(Map<String, dynamic> json) {
    return OfflineQueueItem(
      id: json['id'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      action: QueueAction.values.firstWhere(
        (e) => e.name == json['action'],
        orElse: () => QueueAction.create,
      ),
      collection: json['collection'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
      status: QueueStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => QueueStatus.pending,
      ),
    );
  }
}

class CacheEntry {
  final String key;
  final Map<String, dynamic> data;
  final DateTime expiry;

  const CacheEntry({
    required this.key,
    required this.data,
    required this.expiry,
  });

  bool get isExpired => DateTime.now().isAfter(expiry);

  Map<String, dynamic> toJson() => {
        'key': key,
        'data': data,
        'expiry': expiry.toIso8601String(),
      };

  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      key: json['key'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      expiry: DateTime.parse(json['expiry'] as String),
    );
  }
}
