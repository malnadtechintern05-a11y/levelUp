import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';

/// Top-level background message handler for FCM
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  debugPrint('[FCM Background] Message received: ${message.messageId}, data: ${message.data}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;

  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  String? _fcmToken;

  bool get isInitialized => _isInitialized;
  String? get fcmToken => _fcmToken;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important game quests, streak alerts, and announcements.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  /// Initialize Push Notifications & Local Notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Setup Background Handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 2. Initialize Flutter Local Notifications for Foreground Presentation
      const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettingsDarwin = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _localNotifications.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _handleNotificationTap(response.payload);
        },
      );

      // Create high-importance Android Notification Channel
      final androidImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(_channel);
      }

      // 3. Setup Listeners for Incoming Messages
      _setupMessageListeners();

      _isInitialized = true;
      debugPrint('[Firebase Notifications] Base notification system ready');

      // 4. Run async setup in background without blocking UI startup
      _runAsyncBackgroundSetup(androidImplementation);
    } catch (e) {
      debugPrint('[Firebase Notifications] Initialization error: $e');
    }
  }

  void _runAsyncBackgroundSetup(AndroidFlutterLocalNotificationsPlugin? androidImplementation) async {
    try {
      // Request permissions
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }

      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Fetch FCM Device Token with timeout
      await _fetchFcmToken();

      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('[Firebase Notifications] FCM Token refreshed: $newToken');
      });

      // Subscribe to default broadcast topics
      subscribeToTopic('all_users');
      subscribeToTopic('announcements');
    } catch (e) {
      debugPrint('[Firebase Notifications] Async setup error: $e');
    }
  }

  Future<void> _fetchFcmToken() async {
    try {
      _fcmToken = await _messaging.getToken().timeout(
        const Duration(seconds: 4),
        onTimeout: () => null,
      );
      if (_fcmToken != null) {
        debugPrint('[Firebase Notifications] FCM Device Token: $_fcmToken');
      }
    } catch (e) {
      debugPrint('[Firebase Notifications] Failed to get FCM Token: $e');
    }
  }

  void _setupMessageListeners() {
    // 1. Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCM Foreground] Message title: ${message.notification?.title}, body: ${message.notification?.body}');
      _showForegroundNotification(message);
    });

    // 2. Message clicked when app in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM OpenedApp] Message clicked: ${message.data}');
      _handleRemoteMessageClick(message);
    });

    // 3. Message clicked when app opened from terminated state
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('[FCM InitialMessage] Opened from terminated state: ${message.data}');
        _handleRemoteMessageClick(message);
      }
    });
  }

  /// Display a local notification banner when a message is received in foreground
  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    final title = notification?.title ?? message.data['title'] ?? 'LevelUp Alert';
    final body = notification?.body ?? message.data['body'] ?? 'New notification received';

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        icon: android?.smallIcon ?? '@mipmap/ic_launcher',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        styleInformation: BigTextStyleInformation(body),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _localNotifications.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: jsonEncode(message.data),
    );
  }

  /// Show a manual local notification (e.g. for quest completed, level up, reminders)
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
  }) async {
    try {
      final notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _localNotifications.show(
        id: id ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000),
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('[Firebase Notifications] showLocalNotification error: $e');
    }
  }

  /// Handle tap on notification
  void _handleNotificationTap(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      try {
        final Map<String, dynamic> data = jsonDecode(payload);
        _navigateBasedOnData(data);
        return;
      } catch (_) {}
    }
    _navigateToNotificationsScreen();
  }

  void _handleRemoteMessageClick(RemoteMessage message) {
    _navigateBasedOnData(message.data);
  }

  void _navigateBasedOnData(Map<String, dynamic> data) {
    final route = data['route'] as String?;
    if (route != null && route.isNotEmpty) {
      rootNavigatorKey.currentState?.pushNamed(route);
    } else {
      _navigateToNotificationsScreen();
    }
  }

  void _navigateToNotificationsScreen() {
    rootNavigatorKey.currentState?.pushNamed('/notifications');
  }

  /// Subscribe to a notification topic (e.g. 'all_users', 'rankings_update', 'daily_quests')
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('[Firebase Notifications] Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('[Firebase Notifications] Subscribe to topic failed: $e');
    }
  }

  /// Unsubscribe from a notification topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('[Firebase Notifications] Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('[Firebase Notifications] Unsubscribe from topic failed: $e');
    }
  }
}
