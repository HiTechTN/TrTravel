enum MemberRole { admin, editor, viewer }

class GroupMember {
  final String userId;
  final String displayName;
  final String? photoUrl;
  final MemberRole role;
  final DateTime joinedAt;

  GroupMember({
    required this.userId,
    required this.displayName,
    this.photoUrl,
    this.role = MemberRole.viewer,
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now();

  String get roleLabel {
    switch (role) {
      case MemberRole.admin:
        return 'Admin';
      case MemberRole.editor:
        return 'Éditeur';
      case MemberRole.viewer:
        return 'Lecteur';
    }
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'role': role.name,
    'joinedAt': joinedAt.toIso8601String(),
  };

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      role: MemberRole.values.firstWhere((r) => r.name == json['role'], orElse: () => MemberRole.viewer),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }
}

class ChatMessage {
  final String id;
  final String groupId;
  final String userId;
  final String displayName;
  final String? photoUrl;
  final String content;
  final DateTime timestamp;
  final String type;

  ChatMessage({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.displayName,
    this.photoUrl,
    required this.content,
    DateTime? timestamp,
    this.type = 'text',
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'groupId': groupId,
    'userId': userId,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'type': type,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: json['type'] as String? ?? 'text',
    );
  }
}

class TravelGroup {
  final String id;
  final String name;
  final String? description;
  final String ownerId;
  final String inviteCode;
  final List<GroupMember> members;
  final String? linkedTripId;
  final DateTime createdAt;
  final DateTime updatedAt;

  TravelGroup({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    required this.inviteCode,
    this.members = const [],
    this.linkedTripId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  int get memberCount => members.length;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'ownerId': ownerId,
    'inviteCode': inviteCode,
    'members': members.map((m) => m.toJson()).toList(),
    'linkedTripId': linkedTripId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory TravelGroup.fromJson(Map<String, dynamic> json) {
    return TravelGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      ownerId: json['ownerId'] as String,
      inviteCode: json['inviteCode'] as String,
      members: (json['members'] as List?)?.map((m) => GroupMember.fromJson(m as Map<String, dynamic>)).toList() ?? [],
      linkedTripId: json['linkedTripId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
