import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  static AnalyticsService get instance => _instance;

  AnalyticsService._internal();

  FirebaseAnalytics? _analytics;
  FirebaseAnalyticsObserver? _observer;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  FirebaseAnalytics? get analytics => _analytics;

  FirebaseAnalyticsObserver? get observer {
    if (_observer == null && _analytics != null) {
      _observer = FirebaseAnalyticsObserver(analytics: _analytics!);
    }
    return _observer;
  }

  Future<void> initialize() async {
    try {
      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics!);
      _isInitialized = true;
      debugPrint('[Firebase Analytics] Initialized successfully');
    } catch (e) {
      debugPrint('[Firebase Analytics] Initialization skipped or failed: $e');
    }
  }

  /// Log custom events safely
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (!_isInitialized || _analytics == null) return;
    try {
      // Firebase event names must be alphanumeric and underscores only, max 40 chars
      final sanitizedName = name
          .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')
          .substring(0, name.length > 40 ? 40 : name.length);

      await _analytics!.logEvent(
        name: sanitizedName,
        parameters: parameters,
      );
      debugPrint('[Firebase Analytics] Event logged: $sanitizedName, params: $parameters');
    } catch (e) {
      debugPrint('[Firebase Analytics] Failed to log event $name: $e');
    }
  }

  /// Log screen views
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (!_isInitialized || _analytics == null) return;
    try {
      await _analytics!.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
    } catch (e) {
      debugPrint('[Firebase Analytics] Failed to log screen view: $e');
    }
  }

  /// Log user login
  Future<void> logLogin({String loginMethod = 'email_password'}) async {
    if (!_isInitialized || _analytics == null) return;
    try {
      await _analytics!.logLogin(loginMethod: loginMethod);
    } catch (e) {
      debugPrint('[Firebase Analytics] Failed to log login: $e');
    }
  }

  /// Log user sign up
  Future<void> logSignUp({String signUpMethod = 'email_password'}) async {
    if (!_isInitialized || _analytics == null) return;
    try {
      await _analytics!.logSignUp(signUpMethod: signUpMethod);
    } catch (e) {
      debugPrint('[Firebase Analytics] Failed to log sign up: $e');
    }
  }

  /// Set user ID and custom properties
  Future<void> setUserProperties({
    required String userId,
    String? rank,
    int? level,
  }) async {
    if (!_isInitialized || _analytics == null) return;
    try {
      await _analytics!.setUserId(id: userId);
      if (rank != null) {
        await _analytics!.setUserProperty(name: 'user_rank', value: rank);
      }
      if (level != null) {
        await _analytics!.setUserProperty(name: 'user_level', value: level.toString());
      }
    } catch (e) {
      debugPrint('[Firebase Analytics] Failed to set user properties: $e');
    }
  }

  /// Log quest/task creation
  Future<void> logTaskCreated({
    required String taskType,
    required String difficulty,
    int? xp,
  }) async {
    final params = <String, Object>{
      'task_type': taskType,
      'difficulty': difficulty,
    };
    if (xp != null) params['xp_value'] = xp;
    await logEvent(name: 'task_created', parameters: params);
  }

  /// Log quest/task completion
  Future<void> logTaskCompleted({
    required String taskTitle,
    required int xp,
    int? gold,
    String? category,
  }) async {
    final params = <String, Object>{
      'task_title': taskTitle.substring(0, taskTitle.length > 50 ? 50 : taskTitle.length),
      'xp_earned': xp,
    };
    if (gold != null) params['gold_earned'] = gold;
    if (category != null) params['category'] = category;
    await logEvent(name: 'task_completed', parameters: params);
  }

  /// Log player level up
  Future<void> logLevelUp({
    required int newLevel,
    String? rank,
  }) async {
    final params = <String, Object>{
      'level': newLevel,
    };
    if (rank != null) params['rank'] = rank;
    await logEvent(name: 'level_up', parameters: params);
  }

  /// Log achievement unlock
  Future<void> logAchievementUnlocked({
    required String achievementTitle,
    int? xpReward,
  }) async {
    final params = <String, Object>{
      'achievement_id': achievementTitle.replaceAll(' ', '_').toLowerCase(),
      'achievement_name': achievementTitle,
    };
    if (xpReward != null) params['xp_reward'] = xpReward;
    await logEvent(name: 'unlock_achievement', parameters: params);
  }

  /// Log reward redeemed
  Future<void> logRewardRedeemed({
    required String rewardTitle,
    required int cost,
  }) async {
    await logEvent(
      name: 'reward_redeemed',
      parameters: {
        'reward_title': rewardTitle,
        'cost': cost,
      },
    );
  }
}
