import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trtravel/core/services/local_storage.dart';
import 'package:trtravel/core/services/auth_service.dart';
import 'package:trtravel/core/services/logger.dart';
import 'package:trtravel/features/notifications/models/notification_models.dart';

class NotificationService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService;
  List<NotificationReminder> _reminders = [];
  List<SmartSuggestion> _suggestions = [];
  bool _isLoading = false;

  List<NotificationReminder> get reminders => List.unmodifiable(_reminders);
  List<SmartSuggestion> get suggestions => List.unmodifiable(_suggestions);
  bool get isLoading => _isLoading;
  int get unreadCount => _reminders.where((r) => !r.isRead).length;

  NotificationService(this._authService) {
    _loadReminders();
    if (_authService.isAuthenticated) {
      _loadFromFirestore();
    }
    _authService.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    if (_authService.isAuthenticated) {
      _loadFromFirestore();
    }
  }

  void _loadReminders() {
    final data = LocalStorage.getJsonList('notification_reminders');
    if (data != null) {
      _reminders = data.map((j) => NotificationReminder.fromJson(j)).toList();
      notifyListeners();
    }
  }

  void _saveReminders() {
    LocalStorage.setJsonList('notification_reminders', _reminders.map((r) => r.toJson()).toList());
  }

  Future<void> _loadFromFirestore() async {
    final userId = _authService.userId;
    if (userId == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notification_reminders')
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        final reminder = NotificationReminder.fromJson(data);
        if (!_reminders.any((r) => r.id == reminder.id)) {
          _reminders.add(reminder);
        }
      }
      _saveReminders();
      notifyListeners();
    } catch (e) {
      LogService.error('Notif', 'Échec du chargement Firestore', e);
    }
  }

  Future<void> addReminder(NotificationReminder reminder) async {
    _reminders.insert(0, reminder);
    _saveReminders();
    notifyListeners();

    final userId = _authService.userId;
    if (userId != null) {
      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('notification_reminders')
            .doc(reminder.id)
            .set(reminder.toJson());
      } catch (e) {
        LogService.error('Notif', 'Échec sauvegarde Firestore', e);
      }
    }
  }

  Future<void> removeReminder(String id) async {
    _reminders.removeWhere((r) => r.id == id);
    _saveReminders();
    notifyListeners();

    final userId = _authService.userId;
    if (userId != null) {
      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('notification_reminders')
            .doc(id)
            .delete();
      } catch (e) {
        LogService.error('Notif', 'Échec suppression Firestore', e);
      }
    }
  }

  Future<void> markAsRead(String id) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index].isRead = true;
      _saveReminders();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    for (final reminder in _reminders) {
      reminder.isRead = true;
    }
    _saveReminders();
    notifyListeners();
  }

  Future<void> createGeofenceReminder({
    required String id,
    required String title,
    required String body,
    required String placeName,
    required double latitude,
    required double longitude,
    double radiusMeters = 500,
    String? itineraryId,
  }) async {
    final reminder = NotificationReminder(
      id: id,
      title: title,
      body: body,
      type: 'geofence',
      placeName: placeName,
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
      itineraryId: itineraryId,
    );
    await addReminder(reminder);
  }

  Future<void> createTimeReminder({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String? itineraryId,
  }) async {
    final reminder = NotificationReminder(
      id: id,
      title: title,
      body: body,
      type: 'time',
      scheduledAt: scheduledAt,
      itineraryId: itineraryId,
    );
    await addReminder(reminder);
  }

  void generateSuggestions() {
    _suggestions.clear();

    final now = DateTime.now();
    final tripsJson = LocalStorage.getJsonList('itinerary_trips');
    if (tripsJson == null) return;

    for (final trip in tripsJson) {
      final startDate = trip['startDate'] as String?;
      final endDate = trip['endDate'] as String?;
      final title = trip['title'] as String? ?? 'Voyage';

      if (startDate != null) {
        final start = DateTime.tryParse(startDate);
        if (start != null) {
          final diff = start.difference(now).inDays;
          if (diff == 1) {
            _suggestions.add(SmartSuggestion(
              id: 'sugg_flight_${trip['id']}',
              title: 'Votre voyage commence demain !',
              message: 'Votre voyage "$title" commence demain. Préparez vos bagages !',
              type: 'flight_reminder',
            ));
          } else if (diff == 7) {
            _suggestions.add(SmartSuggestion(
              id: 'sugg_week_${trip['id']}',
              title: 'Plus qu\'une semaine !',
              message: 'Plus qu\'une semaine avant "$title". Pensez à vérifier vos réservations.',
              type: 'week_reminder',
            ));
          } else if (diff == 0) {
            _suggestions.add(SmartSuggestion(
              id: 'sugg_today_${trip['id']}',
              title: 'C\'est aujourd\'hui !',
              message: 'Votre voyage "$title" commence aujourd\'hui. Bon voyage !',
              type: 'today_trip',
            ));
          }
        }
      }

      if (endDate != null) {
        final end = DateTime.tryParse(endDate);
        if (end != null && end.isBefore(now.add(const Duration(days: 1)))) {
          _suggestions.add(SmartSuggestion(
            id: 'sugg_review_${trip['id']}',
            title: 'Voyage terminé',
            message: 'Votre voyage "$title" est terminé. Ajoutez les souvenirs dans votre journal !',
            type: 'review_prompt',
          ));
        }
      }
    }

    notifyListeners();
  }

  void clearSuggestions() {
    _suggestions.clear();
    notifyListeners();
  }
}
