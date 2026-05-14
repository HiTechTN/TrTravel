import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PushNotificationService extends ChangeNotifier {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;
  bool _isInitialized = false;

  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _requestPermissions();
    _fcmToken = await _getToken();
    _configureMessageHandlers();
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
    
    if (kDebugMode) {
      print('Push notification permission status: ${settings.authorizationStatus}');
    }
  }

  Future<String?> _getToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (kDebugMode) print('FCM Token: $token');
      return token;
    } catch (e) {
      if (kDebugMode) print('Error getting FCM token: $e');
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
    if (kDebugMode) {
      print('Received foreground message: ${message.notification?.title}');
    }
    _showNotificationDialog(message);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      print('Message opened from background: ${message.notification?.title}');
    }
    _handleMessageNavigation(message);
  }

  @pragma('vm:entry-point')
  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('Background message handled: ${message.notification?.title}');
    }
  }

  void _showNotificationDialog(RemoteMessage message) {
    // Store notification for display in app
    _storeNotification(message);
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
    
    // Keep only last 20 notifications
    if (notificationList.length > 20) {
      notificationList.removeRange(20, notificationList.length);
    }
    
    await prefs.setString('notifications', jsonEncode(notificationList));
    notifyListeners();
  }

  void _handleMessageNavigation(RemoteMessage message) {
    final data = message.data;
    final screen = data['screen'];
    
    if (kDebugMode) {
      print('Navigating to screen: $screen with data: $data');
    }
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
      if (kDebugMode) print('Subscribed to topic: $topic');
    } catch (e) {
      if (kDebugMode) print('Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      if (kDebugMode) print('Unsubscribed from topic: $topic');
    } catch (e) {
      if (kDebugMode) print('Error unsubscribing from topic: $e');
    }
  }
}