import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized API Configuration
/// Automatically detects platform defaults and supports custom server IP for physical devices.
class ApiConfig {
  static const String _customUrlKey = 'custom_api_base_url';

  static String get defaultHost {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2/real-life-rpg/backend/api';
    }
    return 'http://127.0.0.1/real-life-rpg/backend/api';
  }

  static String _currentBaseUrl = '';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_customUrlKey);
    if (saved != null && saved.trim().isNotEmpty) {
      String clean = saved.trim();
      while (clean.endsWith('/')) {
        clean = clean.substring(0, clean.length - 1);
      }
      if (!clean.endsWith('/api') && !clean.endsWith('/backend/api')) {
        clean = '$clean/api';
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
  }

  static Future<void> resetToDefault() async {
    _currentBaseUrl = defaultHost;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_customUrlKey);
  }
}
