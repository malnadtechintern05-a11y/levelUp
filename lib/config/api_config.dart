import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized API Configuration
/// Automatically detects platform defaults and supports custom server IP for physical devices.
class ApiConfig {
  static const String _customUrlKey = 'custom_api_base_url';

  static const String lanHost = 'http://192.168.31.173/real-life-rpg/backend/api';

  static String get defaultHost {
    if (!kIsWeb && Platform.isAndroid) {
      return lanHost;
    }
    return 'http://127.0.0.1/real-life-rpg/backend/api';
  }

  static String _currentBaseUrl = '';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_customUrlKey);
    if (saved != null && saved.trim().isNotEmpty) {
      String clean = saved.trim();
      if (clean.contains('10.0.2.2')) {
        // Automatically migrate away from emulator loopback on real devices
        clean = defaultHost;
        await prefs.remove(_customUrlKey);
      } else {
        while (clean.endsWith('/')) {
          clean = clean.substring(0, clean.length - 1);
        }
        if (!clean.endsWith('/api') && !clean.endsWith('/backend/api')) {
          clean = '$clean/api';
        }
      }
      _currentBaseUrl = clean;
    } else {
      _currentBaseUrl = defaultHost;
    }
  }

  static String get baseUrl {
    if (_currentBaseUrl.isEmpty) {
      return defaultHost;
    }
    return _currentBaseUrl;
  }

  static final List<VoidCallback> _listeners = [];

  static void addListener(VoidCallback listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  static void _notifyListeners() {
    for (final listener in List<VoidCallback>.from(_listeners)) {
      try {
        listener();
      } catch (e) {
        debugPrint("ApiConfig listener error: $e");
      }
    }
  }

  static Future<void> setBaseUrl(String url) async {
    String cleanUrl = url.trim();
    while (cleanUrl.endsWith('/')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
    }
    if (!cleanUrl.endsWith('/api') && !cleanUrl.endsWith('/backend/api')) {
      cleanUrl = '$cleanUrl/api';
    }
    _currentBaseUrl = cleanUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customUrlKey, cleanUrl);
    _notifyListeners();
  }

  static Future<void> resetToDefault() async {
    _currentBaseUrl = defaultHost;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_customUrlKey);
    _notifyListeners();
  }

  /// Resolves any relative or mismatched server URL (such as banners, avatars, uploads)
  /// against the currently active API base URL and platform.
  static String resolveUrl(String rawOrUrl) {
    if (rawOrUrl.trim().isEmpty) return rawOrUrl;
    final trimmed = rawOrUrl.trim();
    if (trimmed.startsWith('gradient:')) return trimmed;

    final apiUri = Uri.tryParse(baseUrl);
    if (apiUri == null) return trimmed;

    final portStr = (apiUri.port == 80 || apiUri.port == 443 || apiUri.port == 0) ? '' : ':${apiUri.port}';
    final serverOrigin = '${apiUri.scheme}://${apiUri.host}$portStr';

    // If it's a relative path:
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      final clean = trimmed.startsWith('/') ? trimmed : '/$trimmed';
      String prefix = '';
      if (!clean.startsWith('/real-life-rpg') &&
          (apiUri.path.contains('/real-life-rpg') ||
              clean.startsWith('/admin-web') ||
              clean.startsWith('/backend') ||
              clean.startsWith('/uploads'))) {
        prefix = '/real-life-rpg';
      }
      return '$serverOrigin$prefix$clean';
    }

    // If it's a full URL, check if host needs alignment with active ApiConfig host
    final uri = Uri.tryParse(trimmed);
    if (uri != null) {
      final isLocalOrLan = uri.host == 'localhost' ||
          uri.host == '127.0.0.1' ||
          uri.host == '10.0.2.2' ||
          uri.host.startsWith('192.168.') ||
          uri.host.startsWith('10.') ||
          uri.host.startsWith('172.') ||
          uri.path.contains('/admin-web/') ||
          uri.path.contains('/real-life-rpg/');

      if (isLocalOrLan) {
        String path = uri.path;
        if (!path.startsWith('/real-life-rpg') &&
            apiUri.path.contains('/real-life-rpg') &&
            (path.startsWith('/admin-web') || path.startsWith('/backend') || path.startsWith('/uploads'))) {
          path = '/real-life-rpg$path';
        }
        return '$serverOrigin$path${uri.hasQuery ? '?${uri.query}' : ''}';
      }
    }

    return trimmed;
  }
}
