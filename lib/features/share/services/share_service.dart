import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trtravel/core/services/auth_service.dart';
import 'package:trtravel/core/services/local_storage.dart';
import 'package:trtravel/core/services/logger.dart';
import 'package:trtravel/features/share/models/share_models.dart';

class ShareService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService;
  List<SharedItinerary> _sharedItineraries = [];
  bool _isLoading = false;

  List<SharedItinerary> get sharedItineraries => List.unmodifiable(_sharedItineraries);
  bool get isLoading => _isLoading;

  ShareService(this._authService);

  String _generateShareCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }

  String _generateDeepLink(String shareCode) {
    return 'https://trtravel.app/share/$shareCode';
  }

  String _generateSimpleHash(String input) {
    final bytes = utf8.encode(input);
    int hash = 0;
    for (final byte in bytes) {
      hash = ((hash << 5) - hash) + byte;
      hash = hash & hash;
    }
    return hash.abs().toRadixString(16).padLeft(8, '0');
  }

  Future<String?> shareItinerary({
    required String tripId,
    required String title,
    String description = '',
    required Map<String, dynamic> itineraryData,
  }) async {
    try {
      final userId = _authService.userId ?? 'anonymous';
      final userName = _authService.displayName ?? 'Voyageur';
      final shareCode = _generateShareCode();

      final shared = SharedItinerary(
        id: 'share_${DateTime.now().millisecondsSinceEpoch}',
        tripId: tripId,
        ownerId: userId,
        ownerName: userName,
        title: title,
        description: description,
        shareCode: shareCode,
        itineraryData: itineraryData,
      );

      await _firestore.collection('shared_itineraries').doc(shared.id).set(shared.toJson());

      final deepLink = _generateDeepLink(shareCode);
      final link = ShareLink(
        id: 'link_${shared.id}',
        itineraryId: shared.id,
        code: shareCode,
        url: deepLink,
      );

      await _firestore.collection('share_links').doc(link.id).set(link.toJson());

      _sharedItineraries.insert(0, shared);
      notifyListeners();

      return deepLink;
    } catch (e) {
      LogService.error('Share', 'Échec du partage', e);
      return null;
    }
  }

  Future<void> shareViaSystem(String text) async {
    try {
      await SharePlus.instance.share(ShareParams(text: text));
    } catch (e) {
      LogService.error('Share', 'Échec du partage système', e);
    }
  }

  String generateQRCodeData(String shareCode) {
    final deepLink = _generateDeepLink(shareCode);
    return _generateSimpleHash(deepLink);
  }

  Future<SharedItinerary?> getSharedItinerary(String shareCode) async {
    try {
      final snapshot = await _firestore
          .collection('shared_itineraries')
          .where('shareCode', isEqualTo: shareCode)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      final data = doc.data();
      data['id'] = doc.id;

      await doc.reference.update({'viewCount': FieldValue.increment(1)});

      return SharedItinerary.fromJson(data);
    } catch (e) {
      LogService.error('Share', 'Échec de la récupération', e);
      return null;
    }
  }

  Future<SharedItinerary?> importSharedItinerary(String deepLink) async {
    try {
      final uri = Uri.parse(deepLink);
      final segments = uri.pathSegments;
      if (segments.length < 2 || segments[0] != 'share') return null;

      final shareCode = segments[1];
      final shared = await getSharedItinerary(shareCode);
      if (shared == null) return null;

      if (shared.itineraryData.isNotEmpty) {
        final existing = LocalStorage.getJsonList('itinerary_trips') ?? [];
        existing.add(shared.itineraryData);
        LocalStorage.setJsonList('itinerary_trips', existing);
      }

      return shared;
    } catch (e) {
      LogService.error('Share', 'Échec de l\'importation', e);
      return null;
    }
  }

  Future<void> loadSharedItineraries() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = _authService.userId;
      if (userId == null) return;

      final snapshot = await _firestore
          .collection('shared_itineraries')
          .where('ownerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _sharedItineraries = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return SharedItinerary.fromJson(data);
      }).toList();
    } catch (e) {
      LogService.error('Share', 'Échec du chargement', e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> deleteSharedItinerary(String id) async {
    try {
      await _firestore.collection('shared_itineraries').doc(id).delete();
      _sharedItineraries.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      LogService.error('Share', 'Échec de la suppression', e);
      return false;
    }
  }
}
