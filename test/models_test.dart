import 'package:flutter_test/flutter_test.dart';
import 'package:trtravel/features/share/models/share_models.dart';
import 'package:trtravel/features/collaboration/models/collaboration_models.dart';
import 'package:trtravel/features/notifications/models/notification_models.dart';
import 'package:trtravel/features/ar/models/ar_models.dart';
import 'package:trtravel/features/bookings/models/booking_models.dart';
import 'package:trtravel/features/voice_journal/models/voice_journal_models.dart';
import 'package:trtravel/features/offline/models/offline_models.dart';
import 'package:trtravel/features/assistant/models/assistant_models.dart';

void main() {
  group('Share Models', () {
    test('ShareLink toJson/fromJson', () {
      final link = ShareLink(
        id: 'link_1',
        itineraryId: 'itinerary_1',
        code: 'ABC123',
        url: 'https://trtravel.app/share/ABC123',
      );
      final json = link.toJson();
      final restored = ShareLink.fromJson(json);
      expect(restored.code, link.code);
      expect(restored.itineraryId, link.itineraryId);
    });

    test('SharedItinerary toJson/fromJson', () {
      final shared = SharedItinerary(
        id: 'shared_1',
        tripId: 'trip_1',
        ownerId: 'user_1',
        ownerName: 'Alice',
        title: 'Voyage à Istanbul',
        itineraryData: {'days': []},
        shareCode: 'XYZ789',
      );
      final json = shared.toJson();
      final restored = SharedItinerary.fromJson(json);
      expect(restored.id, shared.id);
      expect(restored.title, shared.title);
      expect(restored.shareCode, shared.shareCode);
    });
  });

  group('Collaboration Models', () {
    test('TravelGroup toJson/fromJson', () {
      final group = TravelGroup(
        id: 'group_1',
        name: 'Voyage entre amis',
        ownerId: 'user_1',
        inviteCode: 'INVITE123',
        members: [
          GroupMember(userId: 'user_1', displayName: 'Alice', role: MemberRole.admin),
          GroupMember(userId: 'user_2', displayName: 'Bob', role: MemberRole.editor),
        ],
      );
      final json = group.toJson();
      final restored = TravelGroup.fromJson(json);
      expect(restored.name, group.name);
      expect(restored.inviteCode, group.inviteCode);
      expect(restored.members.length, 2);
      expect(restored.members[0].role, MemberRole.admin);
    });

    test('ChatMessage toJson/fromJson', () {
      final msg = ChatMessage(
        id: 'msg_1',
        groupId: 'group_1',
        userId: 'user_1',
        displayName: 'Alice',
        content: 'Bonjour le groupe!',
      );
      final json = msg.toJson();
      final restored = ChatMessage.fromJson(json);
      expect(restored.content, msg.content);
      expect(restored.displayName, msg.displayName);
    });
  });

  group('Notification Models', () {
    test('NotificationReminder geofence toJson/fromJson', () {
      final reminder = NotificationReminder(
        id: 'reminder_1',
        title: 'Visite Sainte-Sophie',
        body: 'Votre visite commence dans 30 min',
        type: 'geofence',
        placeName: 'Sainte-Sophie',
        latitude: 41.0086,
        longitude: 28.9802,
        radiusMeters: 100,
      );
      final json = reminder.toJson();
      final restored = NotificationReminder.fromJson(json);
      expect(restored.title, reminder.title);
      expect(restored.isGeofence, true);
    });
  });

  group('AR Models', () {
    test('ARLandmark toJson/fromJson', () {
      final landmark = ARLandmark(
        id: 'landmark_1',
        name: 'Sainte-Sophie',
        description: 'Ancienne basilique',
        latitude: 41.0086,
        longitude: 28.9802,
        category: 'history',
        imageUrl: 'https://example.com/hagia.jpg',
      );
      final json = landmark.toJson();
      final restored = ARLandmark.fromJson(json);
      expect(restored.name, landmark.name);
      expect(restored.latitude, landmark.latitude);
      expect(restored.category, landmark.category);
    });
  });

  group('Booking Models', () {
    test('Booking toJson/fromJson', () {
      final booking = Booking(
        id: 'booking_1',
        type: BookingType.hotel,
        title: 'Hotel Istanbul',
        date: DateTime(2026, 7, 15),
        price: 150.0,
        currency: 'EUR',
        confirmationCode: 'CONF123',
        notes: 'Près du centre',
      );
      final json = booking.toJson();
      final restored = Booking.fromJson(json);
      expect(restored.title, booking.title);
      expect(restored.type, BookingType.hotel);
      expect(restored.price, booking.price);
    });
  });

  group('Voice Journal Models', () {
    test('VoiceNote toJson/fromJson', () {
      final note = VoiceNote(
        id: 'voice_1',
        filePath: '/path/to/audio.m4a',
        durationSeconds: 120,
        transcript: 'Journée magnifique à Istanbul',
        isTranscribed: true,
        date: DateTime(2026, 7, 1),
      );
      final json = note.toJson();
      final restored = VoiceNote.fromJson(json);
      expect(restored.filePath, note.filePath);
      expect(restored.durationSeconds, note.durationSeconds);
      expect(restored.isTranscribed, true);
    });

    test('VoiceNote duration formatting', () {
      final note = VoiceNote(
        id: 'voice_2',
        filePath: '/path/to/audio.m4a',
        durationSeconds: 65,
        date: DateTime(2026, 7, 1),
      );
      expect(note.formattedDuration, '01:05');
    });
  });

  group('Offline Models', () {
    test('OfflineQueueItem toJson/fromJson', () {
      final item = OfflineQueueItem(
        id: 'queue_1',
        data: {'name': 'test'},
        action: QueueAction.create,
        collection: 'journal_entries',
      );
      final json = item.toJson();
      final restored = OfflineQueueItem.fromJson(json);
      expect(restored.action, QueueAction.create);
      expect(restored.collection, item.collection);
      expect(restored.status, QueueStatus.pending);
    });
  });

  group('Assistant Models', () {
    test('AIResponse confidence', () {
      final response = AIResponse(
        message: 'Voici un restaurant recommandé',
        confidence: 0.85,
        suggestions: ['Restaurant A', 'Restaurant B'],
      );
      expect(response.message, isNotEmpty);
      expect(response.confidence, greaterThan(0));
      expect(response.suggestions.length, 2);
    });
  });
}
