import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'analytics_service.dart';
import 'notification_service.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  static FirebaseService get instance => _instance;

  FirebaseService._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize all Firebase services safely without blocking UI
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Firebase.initializeApp().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('[Firebase Service] Firebase.initializeApp() timed out; continuing app start.');
          return Firebase.app();
        },
      );
      _isInitialized = true;
      debugPrint('[Firebase Service] Firebase App initialized successfully');

      // Initialize Analytics in background
      AnalyticsService.instance.initialize();

      // Initialize Messaging & Notifications in background
      NotificationService.instance.initialize();
    } catch (e) {
      debugPrint('[Firebase Service] Firebase initialization error/timeout: $e');
    }
  }
}
