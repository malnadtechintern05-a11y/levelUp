import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../config/api_config.dart';
import '../pusher_hub.dart';

/// Singleton service wrapping PusherHub SDK operations
class PusherHubService {
  static final PusherHubService instance = PusherHubService._internal();
  PusherHubService._internal();

  late final PusherHub client = PusherHub(
    appKey: ApiConfig.pusherHubAppKey,
    publicKey: ApiConfig.pusherHubPublicKey,
    baseUrl: ApiConfig.pusherHubBaseUrl,
    onNotificationClick: (deepLink) {
      debugPrint('[PusherHub] Received Deep Link: $deepLink');
    },
  );

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initializes PusherHub device registration and metadata collection safely
  Future<void> initialize({bool resolveLocation = false}) async {
    if (_isInitialized) return;
    try {
      if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
        _isInitialized = true;
        return;
      }

      // Check if Firebase is available
      if (Firebase.apps.isNotEmpty) {
        final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
        await client.registerDevice();
        if (initialMessage != null) {
          client.trackNotificationOpened(initialMessage);
        }
      } else {
        await client.registerDevice();
      }

      // Collect device metadata (optionally with GPS if requested)
      await client.collectDeviceMetadata(resolveLocation: resolveLocation);
      _isInitialized = true;
    } catch (e) {
      debugPrint('[PusherHubService] Initialization notice: $e');
    }
  }

  /// Re-links the device to an authenticated user ID
  Future<void> login(String userId) async {
    try {
      if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;
      await client.login(userId);
    } catch (e) {
      debugPrint('[PusherHubService] Login error: $e');
    }
  }

  /// Reverts the device to an anonymous ID on logout
  Future<void> logout() async {
    try {
      if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;
      await client.logout();
    } catch (e) {
      debugPrint('[PusherHubService] Logout error: $e');
    }
  }

  /// Reports a notification open event
  void trackNotificationOpened(RemoteMessage message) {
    try {
      client.trackNotificationOpened(message);
    } catch (e) {
      debugPrint('[PusherHubService] Track notification open error: $e');
    }
  }
}
