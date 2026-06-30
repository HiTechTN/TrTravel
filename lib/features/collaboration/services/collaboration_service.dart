import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trtravel/core/services/auth_service.dart';
import 'package:trtravel/core/services/logger.dart';
import 'package:trtravel/features/collaboration/models/collaboration_models.dart';

class CollaborationService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService;
  List<TravelGroup> _groups = [];
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  StreamSubscription? _groupsSubscription;
  StreamSubscription? _messagesSubscription;
  String? _activeGroupId;

  List<TravelGroup> get groups => List.unmodifiable(_groups);
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get activeGroupId => _activeGroupId;

  CollaborationService(this._authService) {
    if (_authService.isAuthenticated) {
      _listenToGroups();
    }
    _authService.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    if (_authService.isAuthenticated) {
      _listenToGroups();
    } else {
      _groupsSubscription?.cancel();
      _groups.clear();
      notifyListeners();
    }
  }

  void _listenToGroups() {
    final userId = _authService.userId;
    if (userId == null) return;

    _groupsSubscription?.cancel();
    _groupsSubscription = _firestore
        .collection('travel_groups')
        .where('members', arrayContains: {'userId': userId})
        .snapshots()
        .listen((snapshot) {
      _groups = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return TravelGroup.fromJson(data);
      }).toList();
      notifyListeners();
    });
  }

  void listenToGroupMessages(String groupId) {
    _activeGroupId = groupId;
    _messagesSubscription?.cancel();
    _messagesSubscription = _firestore
        .collection('travel_groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
      _messages = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ChatMessage.fromJson(data);
      }).toList();
      notifyListeners();
    });
  }

  void stopListeningToMessages() {
    _messagesSubscription?.cancel();
    _messages.clear();
    _activeGroupId = null;
    notifyListeners();
  }

  Future<TravelGroup?> createGroup({
    required String name,
    String? description,
    String? linkedTripId,
  }) async {
    final userId = _authService.userId;
    final displayName = _authService.displayName ?? 'Voyageur';
    if (userId == null) return null;

    try {
      final inviteCode = _generateInviteCode();
      final group = TravelGroup(
        id: '',
        name: name,
        description: description,
        ownerId: userId,
        inviteCode: inviteCode,
        linkedTripId: linkedTripId,
        members: [
          GroupMember(
            userId: userId,
            displayName: displayName,
            photoUrl: _authService.photoUrl,
            role: MemberRole.admin,
          ),
        ],
      );

      final docRef = await _firestore.collection('travel_groups').add(group.toJson());
      final created = TravelGroup(
        id: docRef.id,
        name: group.name,
        description: group.description,
        ownerId: group.ownerId,
        inviteCode: group.inviteCode,
        linkedTripId: group.linkedTripId,
        members: group.members,
        createdAt: group.createdAt,
        updatedAt: group.updatedAt,
      );

      _groups.add(created);
      notifyListeners();
      return created;
    } catch (e) {
      LogService.error('Collab', 'Échec de création du groupe', e);
      return null;
    }
  }

  Future<bool> joinGroup(String inviteCode) async {
    final userId = _authService.userId;
    final displayName = _authService.displayName ?? 'Voyageur';
    if (userId == null) return false;

    try {
      final snapshot = await _firestore
          .collection('travel_groups')
          .where('inviteCode', isEqualTo: inviteCode)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return false;

      final doc = snapshot.docs.first;
      final group = TravelGroup.fromJson(doc.data()..['id'] = doc.id);

      if (group.members.any((m) => m.userId == userId)) return true;

      final updatedMembers = [
        ...group.members,
        GroupMember(
          userId: userId,
          displayName: displayName,
          photoUrl: _authService.photoUrl,
          role: MemberRole.viewer,
        ),
      ];

      await doc.reference.update({
        'members': updatedMembers.map((m) => m.toJson()).toList(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      LogService.error('Collab', 'Échec pour rejoindre le groupe', e);
      return false;
    }
  }

  Future<bool> leaveGroup(String groupId) async {
    final userId = _authService.userId;
    if (userId == null) return false;

    try {
      final doc = await _firestore.collection('travel_groups').doc(groupId).get();
      if (!doc.exists) return false;

      final group = TravelGroup.fromJson(doc.data()!..['id'] = doc.id);
      final updatedMembers = group.members.where((m) => m.userId != userId).toList();

      if (updatedMembers.isEmpty) {
        await _firestore.collection('travel_groups').doc(groupId).delete();
      } else {
        await doc.reference.update({
          'members': updatedMembers.map((m) => m.toJson()).toList(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }

      _groups.removeWhere((g) => g.id == groupId);
      notifyListeners();
      return true;
    } catch (e) {
      LogService.error('Collab', 'Échec pour quitter le groupe', e);
      return false;
    }
  }

  Future<bool> updateMemberRole(String groupId, String userId, MemberRole role) async {
    try {
      final doc = await _firestore.collection('travel_groups').doc(groupId).get();
      if (!doc.exists) return false;

      final group = TravelGroup.fromJson(doc.data()!..['id'] = doc.id);
      final members = group.members.map((m) {
        if (m.userId == userId) {
          return GroupMember(
            userId: m.userId,
            displayName: m.displayName,
            photoUrl: m.photoUrl,
            role: role,
            joinedAt: m.joinedAt,
          );
        }
        return m;
      }).toList();

      await doc.reference.update({
        'members': members.map((m) => m.toJson()).toList(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      LogService.error('Collab', 'Échec mise à jour rôle', e);
      return false;
    }
  }

  Future<bool> deleteGroup(String groupId) async {
    final userId = _authService.userId;
    if (userId == null) return false;

    try {
      final doc = await _firestore.collection('travel_groups').doc(groupId).get();
      if (!doc.exists) return false;

      final group = TravelGroup.fromJson(doc.data()!..['id'] = doc.id);
      if (group.ownerId != userId) return false;

      await _firestore.collection('travel_groups').doc(groupId).delete();
      _groups.removeWhere((g) => g.id == groupId);
      notifyListeners();
      return true;
    } catch (e) {
      LogService.error('Collab', 'Échec suppression groupe', e);
      return false;
    }
  }

  Future<void> sendMessage(String groupId, String content) async {
    final userId = _authService.userId;
    final displayName = _authService.displayName ?? 'Voyageur';
    if (userId == null || content.trim().isEmpty) return;

    try {
      final message = ChatMessage(
        id: '',
        groupId: groupId,
        userId: userId,
        displayName: displayName,
        photoUrl: _authService.photoUrl,
        content: content.trim(),
      );

      await _firestore
          .collection('travel_groups')
          .doc(groupId)
          .collection('messages')
          .add(message.toJson());

      await _firestore.collection('travel_groups').doc(groupId).update({
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      LogService.error('Collab', 'Échec envoi message', e);
    }
  }

  Future<void> syncItineraryToGroup(String groupId, String tripId, Map<String, dynamic> itineraryData) async {
    try {
      await _firestore
          .collection('travel_groups')
          .doc(groupId)
          .collection('itinerary_sync')
          .doc('current')
          .set({
        'tripId': tripId,
        'data': itineraryData,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _authService.userId,
      });
    } catch (e) {
      LogService.error('Collab', 'Échec synchro itinéraire', e);
    }
  }

  Stream<DocumentSnapshot> getItinerarySyncStream(String groupId) {
    return _firestore
        .collection('travel_groups')
        .doc(groupId)
        .collection('itinerary_sync')
        .doc('current')
        .snapshots();
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  @override
  void dispose() {
    _groupsSubscription?.cancel();
    _messagesSubscription?.cancel();
    super.dispose();
  }
}
