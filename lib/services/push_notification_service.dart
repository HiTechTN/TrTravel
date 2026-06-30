import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trtravel/features/notifications/models/notification_models.dart';

class PushNotificationService extends ChangeNotifier {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;
  bool _isInitialized = false;
  List<NotificationReminder> _reminders = [];
  bool _isMonitoringGeofences = false;

  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;
  List<NotificationReminder> get reminders => List.unmodifiable(_reminders);
  bool get isMonitoringGeofences => _isMonitoringGeofences;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _requestPermissions();
    _fcmToken = await _getToken();
    _configureMessageHandlers();
    await _loadReminders();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _requestPermissions() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      sound: true,
    );

    debugPrint('Push notification permission status: ${settings.authorizationStatus}');
  }

  Future<String?> _getToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> refreshToken() async {
    _fcmToken = await _getToken();
    notifyListeners();
  }

  void _configureMessageHandlers() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.notification?.title}');
    _storeNotification(message);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message opened from background: ${message.notification?.title}');
    _handleMessageNavigation(message);
  }

  @pragma('vm:entry-point')
  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('Background message handled: ${message.notification?.title}');
  }

  Future<void> _storeNotification(RemoteMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = prefs.getString('notifications') ?? '[]';
    final List<dynamic> notificationList = jsonDecode(notifications);

    notificationList.insert(0, {
      'title': message.notification?.title ?? 'Notification',
      'body': message.notification?.body ?? '',
      'data': message.data,
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (notificationList.length > 20) {
      notificationList.removeRange(20, notificationList.length);
    }

    await prefs.setString('notifications', jsonEncode(notificationList));
    notifyListeners();
  }

  void _handleMessageNavigation(RemoteMessage message) {
    final data = message.data;
    final screen = data['screen'];
    debugPrint('Navigating to screen: $screen with data: $data');
  }

  Future<List<Map<String, dynamic>>> getStoredNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = prefs.getString('notifications') ?? '[]';
    return List<Map<String, dynamic>>.from(jsonDecode(notifications));
  }

  Future<void> clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notifications');
    notifyListeners();
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
    }
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('notification_reminders');
    if (data != null) {
      final list = jsonDecode(data) as List;
      _reminders = list.map((e) => NotificationReminder.fromJson(e as Map<String, dynamic>)).toList();
    }
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_reminders.map((r) => r.toJson()).toList());
    await prefs.setString('notification_reminders', data);
  }

  Future<void> addReminder(NotificationReminder reminder) async {
    _reminders.add(reminder);
    await _saveReminders();
    notifyListeners();
  }

  Future<void> removeReminder(String id) async {
    _reminders.removeWhere((r) => r.id == id);
    await _saveReminders();
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index].isRead = true;
      await _saveReminders();
      notifyListeners();
    }
  }

  int get unreadCount => _reminders.where((r) => !r.isRead).length;

  Future<void> startGeofenceMonitoring() async {
    if (_isMonitoringGeofences) return;

    final permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.always && permission != LocationPermission.whileInUse) return;

    _isMonitoringGeofences = true;
    notifyListeners();

    for (final reminder in _reminders.where((r) => r.isGeofence && !r.isTriggered)) {
      _monitorGeofence(reminder);
    }
  }

  void _monitorGeofence(NotificationReminder reminder) {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      ),
    ).listen((position) {
      if (reminder.latitude == null || reminder.longitude == null || reminder.radiusMeters == null) return;

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        reminder.latitude!,
        reminder.longitude!,
      );

      if (distance <= reminder.radiusMeters! && !reminder.isTriggered) {
        reminder.isTriggered = true;
        _storeLocalNotification(reminder.title, reminder.body);
        _saveReminders();
        notifyListeners();
      }
    });
  }

  Future<void> _storeLocalNotification(String title, String body) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = prefs.getString('notifications') ?? '[]';
    final List<dynamic> notificationList = jsonDecode(notifications);

    notificationList.insert(0, {
      'title': title,
      'body': body,
      'data': {},
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (notificationList.length > 20) {
      notificationList.removeRange(20, notificationList.length);
    }

    await prefs.setString('notifications', jsonEncode(notificationList));
    notifyListeners();
  }

  void stopGeofenceMonitoring() {
    _isMonitoringGeofences = false;
    notifyListeners();
  }
}
