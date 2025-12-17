import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔔 Background message received: ${message.notification?.title}');
}

/// Service for handling push notifications
/// 
/// Current Mode: FOREGROUND-ONLY (FREE)
/// - Shows notifications when app is OPEN
/// - Uses Firestore listeners + Local notifications
/// 
/// For background notifications, deploy Cloud Functions in `functions/` folder
/// (requires Firebase Blaze plan)
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final StreamController<String> _notificationStreamController = StreamController<String>.broadcast();
  Stream<String> get notificationStream => _notificationStreamController.stream;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  /// Initialize the notification service
  Future<void> initialize() async {
    await _requestPermission();
    await _initializeLocalNotifications();
    _setupFCMHandlers();
    await _saveTokenToFirestore();
    _fcm.onTokenRefresh.listen(_onTokenRefresh);
    print('✅ NotificationService initialized (Foreground-Only Mode)');
  }

  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    print('🔔 Notification permission: ${settings.authorizationStatus}');
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channel);
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      _notificationStreamController.add(response.payload!);
    }
  }

  void _setupFCMHandlers() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    _fcm.getInitialMessage().then((message) {
      if (message != null) _handleMessageOpenedApp(message);
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      // Encode data payload for local notification
      final payload = Uri(queryParameters: message.data.map((key, value) => MapEntry(key, value.toString()))).query;
      
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: '@mipmap/ic_launcher',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload,
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    // Standardize payload format -> simple URL query string for parsing ease
    final payload = Uri(queryParameters: message.data.map((key, value) => MapEntry(key, value.toString()))).query;
    if (payload.isNotEmpty) {
      _notificationStreamController.add(payload);
    }
  }

  Future<void> _saveTokenToFirestore() async {
    try {
      final token = await _fcm.getToken();
      if (token != null) await _saveToken(token);
    } catch (e) {
      print('❌ Error getting FCM token: $e');
    }
  }

  void _onTokenRefresh(String token) => _saveToken(token);

  Future<void> _saveToken(String token) async {
    final user = AuthService().currentUser;
    if (user != null) {
      try {
        // Multi-device token storage
        await _db.collection('users').doc(user.uid)
            .collection('fcmTokens').doc(token)
            .set({'createdAt': FieldValue.serverTimestamp(), 'platform': 'android'});
        
        await _db.collection('users').doc(user.uid).update({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        });
        print('✅ FCM Token saved');
      } catch (e) {
        print('❌ Error saving FCM token: $e');
      }
    }
  }

  Future<void> removeToken() async {
    final user = AuthService().currentUser;
    if (user != null) {
      try {
        final token = await _fcm.getToken();
        if (token != null) {
          await _db.collection('users').doc(user.uid)
              .collection('fcmTokens').doc(token).delete();
        }
      } catch (e) {
        print('❌ Error removing FCM token: $e');
      }
    }
  }

  /// Show a local notification (for in-app alerts)
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  void dispose() {
    _notificationStreamController.close();
  }
}
