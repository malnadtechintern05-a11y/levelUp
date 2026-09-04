import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../models/alarm_song.dart';
import '../helpers/database_helper.dart';
import '../main.dart'; // Import to use rootScaffoldMessengerKey and rootNavigatorKey
import '../widgets/task_completion_dialog.dart';
import '../services/sound_service.dart';
import '../services/auth_service.dart';
import '../services/online_task_service.dart';
import '../services/online_hydration_service.dart';
import '../services/online_achievement_service.dart';
import '../services/api_client.dart';
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  UserProfile _userProfile = UserProfile(username: 'Hero');
  List<RPGTask> _tasks = [];
  Timer? _globalTimer;
  
  List<AppNotification> _notifications = [];
  NotificationSettings _notificationSettings = NotificationSettings();

  final List<String> _motivationalQuotes = [
    "You're getting stronger every day! 💪",
    "Another quest conquered! ⚔️",
    "Keep going, Hero! 🚀",
    "Progress is progress! ⭐",
    "Your future self will thank you! 🔥",
    "Level up your real life! ⚡",
    "Consistency is your superpower! 🌟",
    "Small daily wins create massive victories! 🏆",
    "Every rep and page counts! 📖",
    "You are unstoppable! 💥",
  ];
  
  // Example achievements matching the redesign
  List<Achievement> _achievements = [
    Achievement(id: 'a1', name: 'First Quest', description: 'Complete your first quest'),
    Achievement(id: 'a2', name: 'On Fire', description: 'Maintain a 7-day streak'),
    Achievement(id: 'a3', name: 'Quest Master', description: 'Complete 50 quests'),
    Achievement(id: 'a4', name: 'Legend', description: 'Reach Level 50'),
  ];
  
  List<Reward> _rewards = [
    Reward(id: 'r1', title: 'Watch 1 Episode of TV', cost: 50),
    Reward(id: 'r2', title: 'Eat a Sweet Treat', cost: 100),
    Reward(id: 'r3', title: 'Buy a New Video Game', cost: 1000),
  ];
  
  Map<String, int> _weeklyXp = {};
  
  bool _isLoading = true;
  bool _isDarkMode = true;
  bool _isLoggedIn = false;
  bool _soundEffectsEnabled = true;
  
  UserProfile get userProfile => _userProfile;
  List<RPGTask> get tasks => _tasks;
  List<Achievement> get achievements => _achievements;
  List<Reward> get rewards => _rewards;
  Map<String, int> get weeklyXp => _weeklyXp;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  bool get isLoggedIn => _isLoggedIn;
  bool get soundEffectsEnabled => _soundEffectsEnabled;
  List<AppNotification> get notifications => _notifications;
  int get unreadNotificationCount => _notifications.where((n) => !n.isRead).length;
  NotificationSettings get notificationSettings => _notificationSettings;
  List<String> get motivationalQuotes => _motivationalQuotes;

  Future<Map<String, dynamic>> loginUser(String identifier, [String? password]) async {
    // If password provided, use online backend
    if (password != null && password.isNotEmpty) {
      final res = await AuthService.instance.login(identifier, password);
      if (res['status'] == 'success') {
        _isLoggedIn = true;
        if (res['user'] != null) {
          _applyUserData(res['user'] as Map<String, dynamic>);
        }
        await refreshAllData();
        notifyListeners();
      }
      return res;
    } else {
      // Local fallback compatibility
      _isLoggedIn = true;
      _userProfile.username = identifier;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('logged_in_username', identifier);
      notifyListeners();
      return {'status': 'success'};
    }
  }

  Future<Map<String, dynamic>> registerHero({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    String avatarId = 'hero1',
    String? displayName,
  }) async {
    final res = await AuthService.instance.register(
      username: username,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      avatarId: avatarId,
      displayName: displayName,
    );
    if (res['status'] == 'success') {
      _isLoggedIn = true;
      if (res['user'] != null) {
        _applyUserData(res['user'] as Map<String, dynamic>);
      }
      await refreshAllData();
      notifyListeners();
    }
    return res;
  }

  void _applyUserData(Map<String, dynamic> data) {
    final displayName = data['display_name']?.toString().trim();
    final rawUsername = data['username']?.toString().trim();
    if (displayName != null && displayName.isNotEmpty) {
      _userProfile.username = displayName;
    } else if (rawUsername != null && rawUsername.isNotEmpty) {
      _userProfile.username = rawUsername;
    }
    _userProfile.email = data['email']?.toString() ?? _userProfile.email;
    _userProfile.avatarId = data['avatar_id']?.toString() ?? _userProfile.avatarId;
    _userProfile.level = int.tryParse(data['level']?.toString() ?? '1') ?? 1;
    _userProfile.totalXP = int.tryParse(data['total_xp']?.toString() ?? '0') ?? 0;
    _userProfile.gold = int.tryParse(data['gold']?.toString() ?? '0') ?? 0;
    _userProfile.currentStreak = int.tryParse(data['current_streak']?.toString() ?? '0') ?? 0;
    _userProfile.bestStreak = int.tryParse(data['best_streak']?.toString() ?? '0') ?? 0;
    if (data['skills'] is Map) {
      _userProfile.skills = Map<String, int>.from(
        (data['skills'] as Map).map((k, v) => MapEntry(k.toString(), int.tryParse(v.toString()) ?? 50))
      );
    }
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('current_username', _userProfile.username);
      prefs.setString('hero_username', _userProfile.username);
      prefs.setString('hero_avatar', _userProfile.avatarId);
    });
    _saveProfile();
  }

  Future<void> refreshAllData() async {
    try {
      final user = await AuthService.instance.getCurrentUser();
      if (user != null) {
        _applyUserData(user);
      }

      final onlineTasks = await OnlineTaskService.instance.fetchTasks();
      if (onlineTasks.isNotEmpty) {
        _tasks = onlineTasks;
        await _saveTasks();
      }

      final onlineAchievements = await OnlineAchievementService.instance.fetchAchievements();
      if (onlineAchievements.isNotEmpty) {
        _achievements = onlineAchievements;
        await _saveAchievements();
      }
    } catch (e) {
      debugPrint("Online sync fallback to local cache: $e");
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthService.instance.logout();
    _isLoggedIn = false;
    _userProfile = UserProfile(username: 'Hero');
    _tasks = [];
    notifyListeners();
  }

  Future<void> toggleSoundEffects(bool val) async {
    _soundEffectsEnabled = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_effects_enabled', val);
    notifyListeners();
  }

  String get selectedAlarmSongId => SoundService.instance.selectedAlarmSongId;
  AlarmSong get currentAlarmSong => SoundService.instance.currentAlarmSong;

  Future<void> setSelectedAlarmSong(String songId) async {
    await SoundService.instance.setSelectedAlarmSong(songId);
    notifyListeners();
  }

  Future<void> previewAlarmSong(String songId) async {
    await SoundService.instance.previewAlarmSong(songId);
  }

  List<RPGTask> get activeTasks => _tasks.where((t) => !t.isCompleted && isTaskToday(t)).toList();
  List<RPGTask> get allActiveTasks => _tasks.where((t) => !t.isCompleted).toList();
  List<RPGTask> get completedTasks => _tasks.where((t) => t.isCompleted).toList();
  
  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  bool isTaskToday(RPGTask task) {
    final now = DateTime.now();
    return _isSameDay(task.dueDate, now);
  }

  bool isTaskFuture(RPGTask task) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
    return taskDate.isAfter(today);
  }

  bool isTaskPast(RPGTask task) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
    return taskDate.isBefore(today);
  }

  String getTaskAvailabilityButtonText(RPGTask task) {
    if (isTaskToday(task)) {
      return 'Start Task';
    }
    if (isTaskFuture(task)) {
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
      final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      if (taskDate == tomorrow) {
        return '🔒 Available Tomorrow';
      }
      return '🔒 Available on ${DateFormat('MMM d').format(task.dueDate)}';
    }
    return task.isCompleted ? 'Completed' : 'Missed Quest';
  }

  String getTaskAvailabilityDateText(RPGTask task) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
    if (taskDate == tomorrow) {
      return 'Tomorrow';
    }
    return DateFormat('MMMM d, yyyy').format(task.dueDate);
  }

  List<RPGTask> getTasksForDate(DateTime date) => _tasks.where((t) => _isSameDay(t.dueDate, date)).toList();
  List<RPGTask> getActiveTasksForDate(DateTime date) => getTasksForDate(date).where((t) => !t.isCompleted).toList();
  List<RPGTask> getCompletedTasksForDate(DateTime date) => getTasksForDate(date).where((t) => t.isCompleted).toList();

  // Calculate today's completed tasks
  int get todayCompletedCount {
    final now = DateTime.now();
    return _tasks.where((t) => t.isCompleted && _isSameDay(t.dueDate, now)).length;
  }

  String get mostActiveCategory {
    if (completedTasks.isEmpty) return 'None';
    final counts = <String, int>{};
    for (var t in completedTasks) {
      counts[t.category] = (counts[t.category] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  AppState() {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('current_username') ?? prefs.getString('hero_username');
      if (savedName != null && savedName.trim().isNotEmpty) {
        _userProfile.username = savedName.trim();
      }
      final savedAvatar = prefs.getString('hero_avatar');
      if (savedAvatar != null && savedAvatar.trim().isNotEmpty) {
        _userProfile.avatarId = savedAvatar.trim();
      }
      final dbHelper = DatabaseHelper.instance;
      
      try {
        final profile = await dbHelper.getProfile();
        if (profile != null) {
          _userProfile = profile;
          if (savedName != null && savedName.trim().isNotEmpty && profile.username == 'Hero') {
            _userProfile.username = savedName.trim();
          }
        }
      } catch (e) {
        debugPrint("Error loading profile from DB: $e");
      }
      
      try {
        final tasksList = await dbHelper.getAllTasks();
        if (tasksList.isNotEmpty) {
          _tasks = tasksList;
        }
        _ensureDailyTasks();
      } catch (e) {
        debugPrint("Error loading tasks from DB: $e");
        _ensureDailyTasks();
      }
      
      try {
        final achievementsList = await dbHelper.getAllAchievements();
        if (achievementsList.isNotEmpty) {
          _achievements = achievementsList;
        }
      } catch (e) {
        debugPrint("Error loading achievements from DB: $e");
      }

      try {
        final notifsList = await dbHelper.getAllNotifications();
        _notifications = notifsList;
      } catch (e) {
        debugPrint("Error loading notifications from DB: $e");
      }

      _notificationSettings = NotificationSettings(
        taskCompletionNotifications: prefs.getBool('notif_task_completion') ?? true,
        taskReminders: prefs.getBool('notif_task_reminders') ?? true,
        dailyReminders: prefs.getBool('notif_daily_reminders') ?? true,
        streakReminders: prefs.getBool('notif_streak_reminders') ?? true,
        achievementNotifications: prefs.getBool('notif_achievements') ?? true,
      );
      
      _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      _soundEffectsEnabled = prefs.getBool('sound_effects_enabled') ?? true;
      _isDarkMode = prefs.getBool('isDarkMode') ?? true;
      _updateStreak();
      
      // For demo purposes, we randomly populate weekly XP if empty
      _weeklyXp = {
        'Mon': 120, 'Tue': 80, 'Wed': 150, 'Thu': 200, 'Fri': 100, 'Sat': 0, 'Sun': 0,
      };
      
    } catch (e) {
      debugPrint("Critical error in _loadData: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _ensureDailyTasks() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final tomorrow = now.add(const Duration(days: 1));

    bool hasYesterday = _tasks.any((t) => _isSameDay(t.dueDate, yesterday));
    bool hasToday = _tasks.any((t) => _isSameDay(t.dueDate, now));
    bool hasTomorrow = _tasks.any((t) => _isSameDay(t.dueDate, tomorrow));

    bool added = false;

    if (!hasYesterday) {
      _tasks.addAll([
        RPGTask(
          id: 'task_yest_water',
          title: 'Daily Drinking Water',
          description: 'Daily hydration goal: 2.5 L',
          category: 'Health',
          xpReward: 50,
          dueDate: yesterday,
          durationMinutes: 0,
          remainingSeconds: 0,
          timerStatus: 'Completed',
          isCompleted: true,
          taskType: 'hydration',
          waterGoalMl: 2500,
          currentWaterMl: 2500,
          waterLogs: [
            WaterLogEntry(id: 'w_y1', amountMl: 500, timestamp: yesterday.add(const Duration(hours: 9))),
            WaterLogEntry(id: 'w_y2', amountMl: 750, timestamp: yesterday.add(const Duration(hours: 12))),
            WaterLogEntry(id: 'w_y3', amountMl: 500, timestamp: yesterday.add(const Duration(hours: 15))),
            WaterLogEntry(id: 'w_y4', amountMl: 750, timestamp: yesterday.add(const Duration(hours: 19))),
          ],
        ),
        RPGTask(
          id: 'task_yest_2',
          title: 'Morning Cardio & Stretch',
          description: '20 minutes of cardio to boost energy',
          category: 'Fitness',
          xpReward: 60,
          dueDate: yesterday,
          durationMinutes: 20,
          remainingSeconds: 0,
          timerStatus: 'Completed',
          isCompleted: true,
        ),
        RPGTask(
          id: 'task_yest_3',
          title: 'Study Flutter Architecture',
          description: 'Provider & SQLite architectural patterns',
          category: 'Study',
          xpReward: 100,
          dueDate: yesterday,
          durationMinutes: 45,
          remainingSeconds: 0,
          timerStatus: 'Completed',
          isCompleted: true,
        ),
        RPGTask(
          id: 'task_yest_4',
          title: 'Read 15 Pages of Book',
          description: 'Atomic Habits chapter reading',
          category: 'Personal',
          xpReward: 40,
          dueDate: yesterday,
          durationMinutes: 20,
          remainingSeconds: 0,
          timerStatus: 'Completed',
          isCompleted: true,
        ),
        RPGTask(
          id: 'task_yest_5',
          title: 'Code Review & Sprint Tasks',
          description: 'Refactor components and optimize code',
          category: 'Work',
          xpReward: 80,
          dueDate: yesterday,
          durationMinutes: 30,
          remainingSeconds: 0,
          timerStatus: 'Completed',
          isCompleted: true,
        ),
      ]);
      added = true;
    }

    if (!hasToday) {
      _tasks.addAll([
        RPGTask(
          id: 'task_today_water',
          title: 'Daily Drinking Water',
          description: 'Daily hydration goal: 2.5 L',
          category: 'Health',
          xpReward: 50,
          dueDate: now,
          durationMinutes: 0,
          remainingSeconds: 0,
          timerStatus: 'Not Started',
          isCompleted: false,
          taskType: 'hydration',
          waterGoalMl: 2500,
          currentWaterMl: 1500,
          waterLogs: [
            WaterLogEntry(id: 'w_t1', amountMl: 500, timestamp: now.subtract(const Duration(hours: 4))),
            WaterLogEntry(id: 'w_t2', amountMl: 500, timestamp: now.subtract(const Duration(hours: 2))),
            WaterLogEntry(id: 'w_t3', amountMl: 500, timestamp: now.subtract(const Duration(minutes: 45))),
          ],
        ),
        RPGTask(
          id: 'task_today_workout',
          title: '30 Minute Workout',
          description: 'Full-body strength training and conditioning routine.',
          category: 'Fitness',
          xpReward: 70,
          coinReward: 35,
          difficulty: 'Medium',
          dueDate: now,
          durationMinutes: 30,
          remainingSeconds: 30 * 60,
          timerStatus: 'Not Started',
          isCompleted: false,
        ),
        RPGTask(
          id: 'task_today_study',
          title: 'Study Mathematics',
          description: 'Practice calculus problems and review key formulas.',
          category: 'Study',
          xpReward: 60,
          coinReward: 30,
          difficulty: 'Medium',
          dueDate: now,
          durationMinutes: 45,
          remainingSeconds: 45 * 60,
          timerStatus: 'Not Started',
          isCompleted: false,
        ),
        RPGTask(
          id: 'task_today_reading',
          title: 'Read 20 Pages',
          description: 'Read at least 20 pages from an educational or personal development book.',
          category: 'Reading',
          xpReward: 40,
          coinReward: 20,
          difficulty: 'Easy',
          dueDate: now,
          durationMinutes: 0,
          remainingSeconds: 0,
          timerStatus: 'Not Started',
          isCompleted: false,
        ),
        RPGTask(
          id: 'task_today_coding',
          title: 'Complete Flutter Login Screen',
          description: 'Implement responsive UI, validation, and error states in Flutter.',
          category: 'Coding',
          xpReward: 100,
          coinReward: 50,
          difficulty: 'Hard',
          dueDate: now,
          durationMinutes: 45,
          remainingSeconds: 45 * 60,
          timerStatus: 'Not Started',
          isCompleted: false,
        ),
        RPGTask(
          id: 'task_today_cleaning',
          title: 'Clean Your Study Desk',
          description: 'Clear clutter, dust desk surfaces, and organize work accessories.',
          category: 'Cleaning',
          xpReward: 30,
          coinReward: 15,
          difficulty: 'Easy',
          dueDate: now,
          durationMinutes: 0,
          remainingSeconds: 0,
          timerStatus: 'Not Started',
          isCompleted: false,
        ),
        RPGTask(
          id: 'task_today_meditation',
          title: '15 Minute Meditation',
          description: 'Mindful breathing practice to reset focus and reduce mental stress.',
          category: 'Meditation',
          xpReward: 35,
          coinReward: 18,
          difficulty: 'Easy',
          dueDate: now,
          durationMinutes: 15,
          remainingSeconds: 15 * 60,
          timerStatus: 'Not Started',
          isCompleted: false,
        ),
        RPGTask(
          id: 'task_today_habit',
          title: 'Wake Up Before 7 AM',
          description: 'Kickstart the morning with discipline and intentional morning routine.',
          category: 'Habit',
          xpReward: 40,
          coinReward: 20,
          difficulty: 'Easy',
          streak: 7,
          isHabit: true,
          dueDate: now,
          durationMinutes: 0,
          remainingSeconds: 0,
          timerStatus: 'Not Started',
          isCompleted: false,
        ),
        RPGTask(
          id: 'task_today_creative',
          title: 'Draw for 30 Minutes',
          description: 'Sketch characters, environment concepts, or daily creative studies.',
          category: 'Creative',
          xpReward: 45,
          coinReward: 22,
          difficulty: 'Medium',
          dueDate: now,
          durationMinutes: 30,
          remainingSeconds: 30 * 60,
          timerStatus: 'Not Started',
          isCompleted: false,
        ),
        RPGTask(
          id: 'task_today_social',
          title: 'Call a Friend',
          description: 'Check in with a close friend or family member for a meaningful chat.',
          category: 'Social',
          xpReward: 25,
          coinReward: 12,
          difficulty: 'Easy',
          dueDate: now,
          durationMinutes: 0,
          remainingSeconds: 0,
          timerStatus: 'Not Started',
          isCompleted: false,
        ),
        RPGTask(
          id: 'task_today_walking',
          title: 'Evening 4000 Steps Walk',
          description: 'Brisk outdoor walk for daily movement and fresh air.',
          category: 'Walking',
          xpReward: 50,
          coinReward: 25,
          difficulty: 'Easy',
          dueDate: now,
          durationMinutes: 25,
          remainingSeconds: 25 * 60,
          timerStatus: 'Not Started',
          isCompleted: false,
        ),
      ]);
      added = true;
    }

    if (!hasTomorrow) {
      _tasks.addAll([
        RPGTask(
          id: 'task_tom_water',
          title: 'Daily Drinking Water',
          description: 'Daily hydration goal: 2.5 L',
          category: 'Health',
          xpReward: 50,
          dueDate: tomorrow,
          durationMinutes: 0,
          remainingSeconds: 0,
          timerStatus: 'Not Started',
          isCompleted: false,
          taskType: 'hydration',
          waterGoalMl: 2500,
          currentWaterMl: 0,
          waterLogs: [],
        ),
        RPGTask(
          id: 'task_tom_2',
          title: 'Gym Strength Training Session',
          description: 'Chest, shoulders, and triceps focus',
          category: 'Fitness',
          xpReward: 90,
          dueDate: tomorrow,
          durationMinutes: 45,
          remainingSeconds: 45 * 60,
          timerStatus: 'Not Started',
          isCompleted: false,
        ),
        RPGTask(
          id: 'task_tom_3',
          title: 'Learn Advanced SQL Queries',
          description: 'Joins, indexing, and query optimization',
          category: 'Study',
          xpReward: 110,
          dueDate: tomorrow,
          durationMinutes: 60,
          remainingSeconds: 60 * 60,
          timerStatus: 'Not Started',
          isCompleted: false,
        ),
        RPGTask(
          id: 'task_tom_4',
          title: 'Team Sprint Review & Planning',
          description: 'Review milestones and track deliverables',
          category: 'Work',
          xpReward: 85,
          dueDate: tomorrow,
          durationMinutes: 40,
          remainingSeconds: 40 * 60,
          timerStatus: 'Not Started',
          isCompleted: false,
        ),
        RPGTask(
          id: 'task_tom_5',
          title: 'Mindfulness & Gratitude Journal',
          description: 'Write 3 accomplishments and 3 reflections',
          category: 'Personal',
          xpReward: 40,
          dueDate: tomorrow,
          durationMinutes: 15,
          remainingSeconds: 15 * 60,
          timerStatus: 'Not Started',
          isCompleted: false,
        ),
      ]);
      added = true;
    }

    // Ensure all hydration tasks have a populated drinking schedule
    for (var t in _tasks) {
      if (t.taskType == 'hydration' && t.reminders.isEmpty) {
        final defReminders = createDefaultDrinkingSchedule(drinkAmountMl: t.drinkAmountMl);
        if (_isSameDay(t.dueDate, now) && t.waterLogs.isNotEmpty) {
          int countToMark = t.waterLogs.length.clamp(0, defReminders.length);
          for (int k = 0; k < countToMark; k++) {
            defReminders[k].isCompleted = true;
            defReminders[k].completedAt = t.waterLogs[k].timestamp;
          }
        }
        t.reminders = defReminders;
        added = true;
      }
    }

    if (added) {
      _saveTasks();
    }
  }

  // --- HYDRATION LOGIC ---

  String _formatDateKey(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  List<HydrationReminder> createDefaultDrinkingSchedule({int drinkAmountMl = 250}) {
    return [
      HydrationReminder(id: 'hr_1', time: '08:00 AM', hour: 8, minute: 0, amountMl: drinkAmountMl, repeat: 'Every Day', isEnabled: true),
      HydrationReminder(id: 'hr_2', time: '10:00 AM', hour: 10, minute: 0, amountMl: drinkAmountMl, repeat: 'Every Day', isEnabled: true),
      HydrationReminder(id: 'hr_3', time: '12:00 PM', hour: 12, minute: 0, amountMl: 300, repeat: 'Every Day', isEnabled: true),
      HydrationReminder(id: 'hr_4', time: '02:00 PM', hour: 14, minute: 0, amountMl: 300, repeat: 'Every Day', isEnabled: true),
      HydrationReminder(id: 'hr_5', time: '04:00 PM', hour: 16, minute: 0, amountMl: drinkAmountMl, repeat: 'Every Day', isEnabled: true),
      HydrationReminder(id: 'hr_6', time: '06:00 PM', hour: 18, minute: 0, amountMl: 300, repeat: 'Every Day', isEnabled: true),
      HydrationReminder(id: 'hr_7', time: '08:00 PM', hour: 20, minute: 0, amountMl: drinkAmountMl, repeat: 'Every Day', isEnabled: true),
    ];
  }

  void addWater(String taskId, int amountMl, [BuildContext? context]) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      if (isTaskFuture(task)) {
        final msg = '🔒 "${task.title}" is scheduled for ${getTaskAvailabilityDateText(task)} and is locked until that day.';
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Colors.orange.shade800,
            ),
          );
        } else {
          rootScaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Colors.orange.shade800,
            ),
          );
        }
        return;
      }

      final newLog = WaterLogEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amountMl: amountMl,
        timestamp: DateTime.now(),
      );

      task.waterLogs.insert(0, newLog);
      task.currentWaterMl += amountMl;

      // Smart Reminder Completion: mark nearest scheduled drink as completed
      if (task.reminders.isNotEmpty) {
        final nowTime = DateTime.now();
        final currentMins = nowTime.hour * 60 + nowTime.minute;
        
        // 1. Check if there are missed reminders (time passed, not completed)
        final missed = task.reminders.where((r) => r.isEnabled && !r.isCompleted && (r.hour * 60 + r.minute <= currentMins)).toList();
        if (missed.isNotEmpty) {
          missed.sort((a, b) => (b.hour * 60 + b.minute).compareTo(a.hour * 60 + a.minute));
          missed.first.isCompleted = true;
          missed.first.completedAt = DateTime.now();
        } else {
          // 2. Otherwise mark the next upcoming reminder
          final upcoming = task.reminders.where((r) => r.isEnabled && !r.isCompleted).toList();
          if (upcoming.isNotEmpty) {
            upcoming.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
            upcoming.first.isCompleted = true;
            upcoming.first.completedAt = DateTime.now();
          }
        }
      }

      final todayStr = _formatDateKey(DateTime.now());
      final yesterdayStr = _formatDateKey(DateTime.now().subtract(const Duration(days: 1)));

      // Check if daily water goal reached
      if (task.currentWaterMl >= task.waterGoalMl) {
        final bool wasAlreadyCompleted = task.isCompleted;
        task.isCompleted = true;
        task.timerStatus = 'Completed';

        // Award XP & streak reward only once per day
        if (_userProfile.hydrationXpAwardedDate != todayStr) {
          final int oldLevel = _userProfile.level;
          _userProfile.hydrationXpAwardedDate = todayStr;
          final int xp = task.xpReward > 0 ? task.xpReward : 50;
          _addXP(xp);
          _userProfile.gold += 25;
          _userProfile.skills['Strength'] = (_userProfile.skills['Strength'] ?? 0) + 10;

          // Hydration streak update
          if (_userProfile.lastHydrationCompletedDate == yesterdayStr) {
            _userProfile.hydrationCurrentStreak += 1;
          } else if (_userProfile.lastHydrationCompletedDate == todayStr) {
            // Already counted streak today
          } else {
            _userProfile.hydrationCurrentStreak = 1;
          }

          if (_userProfile.hydrationCurrentStreak > _userProfile.hydrationBestStreak) {
            _userProfile.hydrationBestStreak = _userProfile.hydrationCurrentStreak;
          }
          _userProfile.lastHydrationCompletedDate = todayStr;

          List<Achievement> newlyUnlocked = _checkAchievements();
          _saveProfile();
          _saveTasks();
          notifyListeners();

          _triggerTaskCompletionFlow(
            task: task,
            xpEarned: xp,
            oldLevel: oldLevel,
            newlyUnlocked: newlyUnlocked,
            context: context,
          );
          return;
        } else if (!wasAlreadyCompleted) {
          _saveProfile();
        }
      }

      _saveTasks();
      notifyListeners();

      // Async online sync for hydration
      OnlineHydrationService.instance.addWater(amountMl, taskId: taskId).catchError((e) {
        debugPrint("Online hydration sync error: $e");
        return <String, dynamic>{};
      });
    }
  }

  void removeWaterLog(String taskId, String logId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      final logIdx = task.waterLogs.indexWhere((l) => l.id == logId);
      if (logIdx != -1) {
        final removed = task.waterLogs.removeAt(logIdx);
        task.currentWaterMl = (task.currentWaterMl - removed.amountMl).clamp(0, 999999);

        // If falls below goal, update completion state
        if (task.currentWaterMl < task.waterGoalMl) {
          task.isCompleted = false;
          task.timerStatus = 'Not Started';
        }

        _saveTasks();
        notifyListeners();
      }
    }
  }

  void updateWaterGoal(String taskId, int newGoalMl) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      task.waterGoalMl = newGoalMl;
      if (task.currentWaterMl >= task.waterGoalMl) {
        task.isCompleted = true;
        task.timerStatus = 'Completed';
      } else {
        task.isCompleted = false;
        task.timerStatus = 'Not Started';
      }
      
      // Save per-user preference in SharedPreferences
      SharedPreferences.getInstance().then((prefs) {
        final uKey = _userProfile.username.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
        prefs.setInt('${uKey}_water_goal', newGoalMl);
      });

      _saveTasks();
      notifyListeners();
    }
  }

  void updateDrinkAmount(String taskId, int newDrinkAmountMl) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      task.drinkAmountMl = newDrinkAmountMl;

      // Save per-user preference in SharedPreferences
      SharedPreferences.getInstance().then((prefs) {
        final uKey = _userProfile.username.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
        prefs.setInt('${uKey}_drink_amount', newDrinkAmountMl);
      });

      _saveTasks();
      notifyListeners();
    }
  }

  void addHydrationReminder(String taskId, HydrationReminder reminder) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      task.reminders.add(reminder);
      task.reminders.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
      _saveTasks();
      notifyListeners();
    }
  }

  void updateHydrationReminder(String taskId, HydrationReminder reminder) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      final remIdx = task.reminders.indexWhere((r) => r.id == reminder.id);
      if (remIdx != -1) {
        task.reminders[remIdx] = reminder;
        task.reminders.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
        _saveTasks();
        notifyListeners();
      }
    }
  }

  void deleteHydrationReminder(String taskId, String reminderId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      task.reminders.removeWhere((r) => r.id == reminderId);
      _saveTasks();
      notifyListeners();
    }
  }

  void toggleHydrationReminder(String taskId, String reminderId, bool isEnabled) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      final remIdx = task.reminders.indexWhere((r) => r.id == reminderId);
      if (remIdx != -1) {
        task.reminders[remIdx].isEnabled = isEnabled;
        _saveTasks();
        notifyListeners();
      }
    }
  }

  void completeHydrationReminder(String taskId, String reminderId, [BuildContext? context]) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      final remIdx = task.reminders.indexWhere((r) => r.id == reminderId);
      if (remIdx != -1) {
        final reminder = task.reminders[remIdx];
        reminder.isCompleted = true;
        reminder.completedAt = DateTime.now();
        addWater(taskId, reminder.amountMl, context);
      }
    }
  }

  void generateHydrationSchedule(
    String taskId, {
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int intervalMinutes,
    required int drinkAmountMl,
  }) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      final startTotalMins = startTime.hour * 60 + startTime.minute;
      final endTotalMins = endTime.hour * 60 + endTime.minute;

      if (endTotalMins > startTotalMins && intervalMinutes > 0) {
        final List<HydrationReminder> newReminders = [];
        int current = startTotalMins;
        int count = 1;

        while (current <= endTotalMins) {
          final h = current ~/ 60;
          final m = current % 60;
          final dt = DateTime(2026, 1, 1, h, m);
          final timeStr = DateFormat('hh:mm a').format(dt);

          newReminders.add(
            HydrationReminder(
              id: 'hr_gen_${DateTime.now().millisecondsSinceEpoch}_$count',
              time: timeStr,
              hour: h,
              minute: m,
              amountMl: drinkAmountMl,
              repeat: 'Every Day',
              isEnabled: true,
            ),
          );
          current += intervalMinutes;
          count++;
        }

        task.reminders = newReminders;
        task.drinkAmountMl = drinkAmountMl;
        task.reminderIntervalMinutes = intervalMinutes;
        final startDt = DateTime(2026, 1, 1, startTime.hour, startTime.minute);
        final endDt = DateTime(2026, 1, 1, endTime.hour, endTime.minute);
        task.reminderStartTime = DateFormat('hh:mm a').format(startDt);
        task.reminderEndTime = DateFormat('hh:mm a').format(endDt);

        // Save per-user preference in SharedPreferences
        SharedPreferences.getInstance().then((prefs) {
          final uKey = _userProfile.username.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
          prefs.setInt('${uKey}_drink_amount', drinkAmountMl);
          prefs.setInt('${uKey}_reminder_interval', intervalMinutes);
          prefs.setString('${uKey}_start_time', task.reminderStartTime!);
          prefs.setString('${uKey}_end_time', task.reminderEndTime!);
        });

        _saveTasks();
        notifyListeners();
      }
    }
  }

  void updateHydrationSettings(
    String taskId, {
    int? dailyGoalMl,
    int? drinkAmountMl,
    bool? notificationsEnabled,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    int? intervalMinutes,
  }) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      if (dailyGoalMl != null) {
        task.waterGoalMl = dailyGoalMl;
      }
      if (drinkAmountMl != null) {
        task.drinkAmountMl = drinkAmountMl;
      }
      if (notificationsEnabled != null) {
        task.notificationsEnabled = notificationsEnabled;
      }
      if (startTime != null) {
        final startDt = DateTime(2026, 1, 1, startTime.hour, startTime.minute);
        task.reminderStartTime = DateFormat('hh:mm a').format(startDt);
      }
      if (endTime != null) {
        final endDt = DateTime(2026, 1, 1, endTime.hour, endTime.minute);
        task.reminderEndTime = DateFormat('hh:mm a').format(endDt);
      }
      if (intervalMinutes != null) {
        task.reminderIntervalMinutes = intervalMinutes;
      }

      // Save per-user preference in SharedPreferences
      SharedPreferences.getInstance().then((prefs) {
        final uKey = _userProfile.username.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
        if (dailyGoalMl != null) prefs.setInt('${uKey}_water_goal', dailyGoalMl);
        if (drinkAmountMl != null) prefs.setInt('${uKey}_drink_amount', drinkAmountMl);
        if (notificationsEnabled != null) prefs.setBool('${uKey}_water_notifs', notificationsEnabled);
        if (task.reminderStartTime != null) prefs.setString('${uKey}_start_time', task.reminderStartTime!);
        if (task.reminderEndTime != null) prefs.setString('${uKey}_end_time', task.reminderEndTime!);
        if (intervalMinutes != null) prefs.setInt('${uKey}_reminder_interval', intervalMinutes);
      });

      _saveTasks();
      notifyListeners();
    }
  }

  Map<String, dynamic> getHydrationStats(RPGTask task) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1. Today
    final todayConsumed = task.currentWaterMl;
    final todayGoal = task.waterGoalMl;

    // 2. Past 7 days (including today)
    int totalLoggedMl7Days = 0;
    int daysGoalCompleted7Days = 0;

    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final dateTasks = _tasks.where((t) => t.taskType == 'hydration' && _isSameDay(t.dueDate, date)).toList();
      if (dateTasks.isNotEmpty) {
        final dayTask = dateTasks.first;
        totalLoggedMl7Days += dayTask.currentWaterMl;
        if (dayTask.currentWaterMl >= dayTask.waterGoalMl && dayTask.waterGoalMl > 0) {
          daysGoalCompleted7Days++;
        }
      } else if (i == 0) {
        totalLoggedMl7Days += todayConsumed;
        if (todayConsumed >= todayGoal && todayGoal > 0) {
          daysGoalCompleted7Days++;
        }
      }
    }

    final double avgLitersPerDay = (totalLoggedMl7Days / 7.0) / 1000.0;
    final int streak = _userProfile.hydrationCurrentStreak;

    return {
      'todayConsumedMl': todayConsumed,
      'todayGoalMl': todayGoal,
      'todayConsumedL': (todayConsumed / 1000).toStringAsFixed(1),
      'todayGoalL': (todayGoal / 1000).toStringAsFixed(1),
      'weeklyAverageL': avgLitersPerDay.toStringAsFixed(1),
      'goalCompletedDays': daysGoalCompleted7Days,
      'streakDays': streak,
      'streak': streak,
    };
  }

  void _updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final completedDates = <DateTime>{};
    for (var t in _tasks) {
      if (t.isCompleted) {
        completedDates.add(DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day));
      }
    }

    int streak = 0;
    DateTime checkDate = today;
    if (!completedDates.contains(today)) {
      checkDate = today.subtract(const Duration(days: 1));
    }

    while (completedDates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    _userProfile.currentStreak = streak;
    if (_userProfile.currentStreak > _userProfile.bestStreak) {
      _userProfile.bestStreak = _userProfile.currentStreak;
    }
    _saveProfile();
  }

  Future<void> _saveProfile() async {
    await DatabaseHelper.instance.saveProfile(_userProfile);
  }

  Future<void> _saveTasks() async {
    await DatabaseHelper.instance.saveAllTasks(_tasks);
  }

  Future<void> _saveAchievements() async {
    await DatabaseHelper.instance.saveAllAchievements(_achievements);
  }

  void addTask(RPGTask task) {
    _tasks.add(task);
    _saveTasks();
    notifyListeners();
  }

  void updateTaskTime(String taskId, int timeSpentSeconds) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _tasks[idx].timeSpentSeconds = timeSpentSeconds;
      _saveTasks();
      notifyListeners();
    }
  }

  // --- TIMER LOGIC ---

  void _startGlobalTimerIfNeeded() {
    if (_globalTimer != null && _globalTimer!.isActive) return;
    _globalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      bool anyRunning = false;
      for (var t in _tasks) {
        if (t.timerStatus == 'Running' && t.timerStartTimeEpoch != null) {
          anyRunning = true;
          final now = DateTime.now().millisecondsSinceEpoch;
          final elapsedSeconds = ((now - t.timerStartTimeEpoch!) / 1000).floor();
          
          if (t.remainingSeconds - elapsedSeconds <= 0) {
            // Timer finished naturally
            t.remainingSeconds = 0;
            completeTask(t.id); // This stops the timer implicitly because status changes to completed
          }
        }
      }
      
      if (anyRunning) {
        notifyListeners();
      } else {
        _globalTimer?.cancel();
        _globalTimer = null;
      }
    });
  }

  int getCalculatedRemainingSeconds(RPGTask task) {
    if (task.timerStatus == 'Running' && task.timerStartTimeEpoch != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsed = ((now - task.timerStartTimeEpoch!) / 1000).floor();
      final currentRemaining = task.remainingSeconds - elapsed;
      return currentRemaining > 0 ? currentRemaining : 0;
    }
    return task.remainingSeconds;
  }

  void startTaskTimer(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];

      if (isTaskFuture(task)) {
        rootScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('🔒 "${task.title}" is scheduled for ${getTaskAvailabilityDateText(task)}. It will unlock on that day!'),
            backgroundColor: Colors.orange.shade800,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      if (isTaskPast(task) && !task.isCompleted) {
        rootScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('⚠️ "${task.title}" was scheduled for a past date and cannot be started.'),
            backgroundColor: Colors.red.shade800,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      // Pause any other running timers
      for (var t in _tasks) {
        if (t.timerStatus == 'Running' && t.id != taskId) {
          _pauseTimerLocally(t);
        }
      }

      if (task.timerStatus != 'Completed') {
        if (task.timerStatus == 'Not Started') {
          task.remainingSeconds = task.durationMinutes * 60;
        }
        task.timerStatus = 'Running';
        task.timerStartTimeEpoch = DateTime.now().millisecondsSinceEpoch;
        _startGlobalTimerIfNeeded();
        _saveTasks();
        notifyListeners();
      }
    }
  }

  void _pauseTimerLocally(RPGTask task) {
    if (task.timerStatus == 'Running' && task.timerStartTimeEpoch != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsed = ((now - task.timerStartTimeEpoch!) / 1000).floor();
      task.remainingSeconds = task.remainingSeconds - elapsed;
      if (task.remainingSeconds < 0) task.remainingSeconds = 0;
      task.timerStatus = 'Paused';
      task.timerStartTimeEpoch = null;
    }
  }

  void resetTaskTimer(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      task.timerStatus = 'Not Started';
      task.timerStartTimeEpoch = null;
      task.remainingSeconds = task.durationMinutes * 60;
      _saveTasks();
      notifyListeners();
    }
  }

  void toggleTaskObjective(String taskId, String objectiveId, bool isCompleted) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      task.getEffectiveObjectives();
      final objIdx = task.objectives.indexWhere((o) => o.id == objectiveId);
      if (objIdx != -1) {
        task.objectives[objIdx].isCompleted = isCompleted;
        _saveTasks();
        notifyListeners();
      }
    }
  }

  void updateTaskNote(String taskId, String note) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _tasks[idx].personalNote = note;
      _saveTasks();
      notifyListeners();
    }
  }

  void updateTaskProof(String taskId, String? imagePath) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _tasks[idx].proofImagePath = imagePath;
      _saveTasks();
      notifyListeners();
    }
  }

  void pauseTaskTimer(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _pauseTimerLocally(_tasks[idx]);
      _saveTasks();
      notifyListeners();
    }
  }

  void finishTaskEarly(String taskId, [BuildContext? context]) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      if (isTaskFuture(task)) {
        rootScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('🔒 "${task.title}" is scheduled for ${getTaskAvailabilityDateText(task)} and is locked.'),
            backgroundColor: Colors.orange.shade800,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
      _pauseTimerLocally(task); // Update elapsed time
      completeTask(taskId, context);
    }
  }

  void completeTask(String taskId, [BuildContext? context, int? xpOverride]) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1 && !_tasks[index].isCompleted) {
      final task = _tasks[index];
      if (isTaskFuture(task)) {
        rootScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('🔒 "${task.title}" is scheduled for ${getTaskAvailabilityDateText(task)} and cannot be completed today.'),
            backgroundColor: Colors.orange.shade800,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      final int oldLevel = _userProfile.level;

      _pauseTimerLocally(task); // Stop timer if running
      task.isCompleted = true;
      task.timerStatus = 'Completed';
      
      int xp = xpOverride ?? task.xpReward;
      int coins = task.getEffectiveCoinReward();
      if (xpOverride != null && task.xpReward > 0) {
        coins = ((coins * xpOverride) / task.xpReward).round();
      }
      _userProfile.gold += coins;
      
      // Update skills based on category
      String category = task.category;
      if (category == 'Fitness' || category == 'Health' || category == 'Walking') {
        _userProfile.skills['Strength'] = (_userProfile.skills['Strength'] ?? 0) + 10;
      } else if (category == 'Study' || category == 'Work' || category == 'Coding' || category == 'Learning' || category == 'Reading') {
        _userProfile.skills['Knowledge'] = (_userProfile.skills['Knowledge'] ?? 0) + 10;
      } else {
        _userProfile.skills['Discipline'] = (_userProfile.skills['Discipline'] ?? 0) + 10;
      }
      
      _addXP(xp);
      _updateStreak();
      List<Achievement> newlyUnlocked = _checkAchievements();
      _saveTasks();
      _saveProfile();
      notifyListeners();

      // Trigger completion flow celebration & dialog
      _triggerTaskCompletionFlow(
        task: task,
        xpEarned: xp,
        oldLevel: oldLevel,
        newlyUnlocked: newlyUnlocked,
        context: context,
      );

      // Online synchronization with backend
      OnlineTaskService.instance.completeTask(taskId).then((res) {
        if (res['status'] == 'success' && res['user'] != null) {
          final u = res['user'];
          _userProfile.totalXP = int.tryParse(u['total_xp']?.toString() ?? '0') ?? _userProfile.totalXP;
          _userProfile.level = int.tryParse(u['level']?.toString() ?? '1') ?? _userProfile.level;
          _userProfile.gold = int.tryParse(u['gold']?.toString() ?? '0') ?? _userProfile.gold;
          _userProfile.currentStreak = int.tryParse(u['current_streak']?.toString() ?? '0') ?? _userProfile.currentStreak;
          _userProfile.bestStreak = int.tryParse(u['best_streak']?.toString() ?? '0') ?? _userProfile.bestStreak;
          _saveProfile();
          notifyListeners();
        }
      }).catchError((e) {
        debugPrint("Online completion sync warning: $e");
      });
    }
  }

  void _triggerTaskCompletionFlow({
    required RPGTask task,
    required int xpEarned,
    required int oldLevel,
    required List<Achievement> newlyUnlocked,
    BuildContext? context,
  }) {
    // 1. Random Motivational Quote
    final quotes = List<String>.from(_motivationalQuotes)..shuffle();
    final quote = quotes.first;

    // 2. Category-Specific Notification Info
    String categoryHeadline = '🎉 QUEST COMPLETE!';
    String categoryBody = 'You completed ${task.title}. +$xpEarned XP earned!';
    switch (task.category) {
      case 'Fitness':
        categoryHeadline = '💪 Workout Complete!';
        categoryBody = 'You finished your fitness quest.\n+$xpEarned XP earned!';
        break;
      case 'Study':
        categoryHeadline = '📚 Knowledge Increased!';
        categoryBody = 'Study task completed successfully.\nKeep learning and earn more XP!';
        break;
      case 'Health':
        categoryHeadline = '💧 Health Quest Complete!';
        categoryBody = 'Great job taking care of yourself.\n+$xpEarned XP earned!';
        break;
      case 'Work':
        categoryHeadline = '🚀 Mission Complete!';
        categoryBody = 'Another step toward your goals.\n+$xpEarned XP earned!';
        break;
      case 'Personal':
      default:
        categoryHeadline = '✨ Personal Quest Complete!';
        categoryBody = 'Small progress every day creates big results.\n+$xpEarned XP earned!';
        break;
    }

    // 3. Task Completion Notification
    final completionNotification = AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: categoryHeadline,
      body: categoryBody,
      category: task.category,
      type: 'taskCompletion',
      timestamp: DateTime.now(),
      xpReward: xpEarned,
      streakDays: _userProfile.currentStreak,
      motivationalQuote: quote,
    );
    _notifications.insert(0, completionNotification);
    DatabaseHelper.instance.saveNotification(completionNotification);

    // 4. Level Up Notification
    bool didLevelUp = _userProfile.level > oldLevel;
    if (didLevelUp) {
      final levelNotification = AppNotification(
        id: 'notif_lvl_${DateTime.now().millisecondsSinceEpoch}',
        title: '🎊 LEVEL UP!',
        body: 'Congratulations, Hero!\nYou reached Level ${_userProfile.level}.\nKeep completing quests to become stronger.',
        category: 'LevelUp',
        type: 'levelUp',
        timestamp: DateTime.now(),
      );
      _notifications.insert(0, levelNotification);
      DatabaseHelper.instance.saveNotification(levelNotification);
    }

    // 5. Achievement Notification
    if (_notificationSettings.achievementNotifications) {
      for (var ach in newlyUnlocked) {
        final achNotif = AppNotification(
          id: 'notif_ach_${ach.id}_${DateTime.now().millisecondsSinceEpoch}',
          title: '🏆 ACHIEVEMENT UNLOCKED!',
          body: '${ach.name}\n${ach.description}',
          category: 'Achievement',
          type: 'achievement',
          timestamp: DateTime.now(),
          xpReward: ach.xpReward,
        );
        _notifications.insert(0, achNotif);
        DatabaseHelper.instance.saveNotification(achNotif);
      }
    }

    // 6. Play Task Completion Alarm Sound & Haptic Vibration
    if (didLevelUp) {
      SoundService.instance.playLevelUpAlarm(isSoundEnabled: _soundEffectsEnabled);
    } else {
      SoundService.instance.playTaskCompletedAlarm(isSoundEnabled: _soundEffectsEnabled);
    }

    // 7. Visual Dialog Feedback
    if (_notificationSettings.taskCompletionNotifications) {
      final targetContext = context ?? rootNavigatorKey.currentContext;
      if (targetContext != null) {
        showDialog(
          context: targetContext,
          barrierDismissible: false,
          builder: (dialogContext) => TaskCompletionCelebrationDialog(
            task: task,
            xpEarned: xpEarned,
            currentStreak: _userProfile.currentStreak,
            motivationalQuote: quote,
            onDismiss: () {
              if (didLevelUp) {
                Future.delayed(const Duration(milliseconds: 250), () {
                  final ctx = rootNavigatorKey.currentContext;
                  if (ctx != null) {
                    showDialog(
                      context: ctx,
                      barrierDismissible: false,
                      builder: (_) => LevelUpCelebrationDialog(
                        newLevel: _userProfile.level,
                        onDismiss: () {
                          if (newlyUnlocked.isNotEmpty && _notificationSettings.achievementNotifications) {
                            Future.delayed(const Duration(milliseconds: 250), () {
                              final c = rootNavigatorKey.currentContext;
                              if (c != null) {
                                showDialog(
                                  context: c,
                                  builder: (_) => AchievementUnlockedCelebrationDialog(
                                    achievement: newlyUnlocked.first,
                                    onDismiss: () {},
                                  ),
                                );
                              }
                            });
                          }
                        },
                      ),
                    );
                  }
                });
              } else if (newlyUnlocked.isNotEmpty && _notificationSettings.achievementNotifications) {
                Future.delayed(const Duration(milliseconds: 250), () {
                  final ctx = rootNavigatorKey.currentContext;
                  if (ctx != null) {
                    showDialog(
                      context: ctx,
                      builder: (_) => AchievementUnlockedCelebrationDialog(
                        achievement: newlyUnlocked.first,
                        onDismiss: () {},
                      ),
                    );
                  }
                });
              }
            },
          ),
        );
      } else {
        rootScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('$categoryHeadline +$xpEarned XP earned!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } else {
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Quest "${task.title}" Completed! +$xpEarned XP earned!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _addXP(int amount) {
    _userProfile.totalXP += amount;
    int xpNeededForNextLevel = _userProfile.level * 100;
    
    if (_userProfile.totalXP >= xpNeededForNextLevel) {
      _userProfile.level++;
      _userProfile.totalXP -= xpNeededForNextLevel;
    }
  }

  List<Achievement> _checkAchievements() {
    List<Achievement> newlyUnlocked = [];
    
    // First Quest
    if (!_achievements[0].isUnlocked && completedTasks.isNotEmpty) {
      _achievements[0].isUnlocked = true;
      newlyUnlocked.add(_achievements[0]);
    }
    // On Fire (7 day streak)
    if (!_achievements[1].isUnlocked && _userProfile.currentStreak >= 7) {
      _achievements[1].isUnlocked = true;
      newlyUnlocked.add(_achievements[1]);
    }
    // Quest Master (50 quests)
    if (!_achievements[2].isUnlocked && completedTasks.length >= 50) {
      _achievements[2].isUnlocked = true;
      newlyUnlocked.add(_achievements[2]);
    }
    // Legend (Level 50)
    if (!_achievements[3].isUnlocked && _userProfile.level >= 50) {
      _achievements[3].isUnlocked = true;
      newlyUnlocked.add(_achievements[3]);
    }
    
    if (newlyUnlocked.isNotEmpty) _saveAchievements();
    return newlyUnlocked;
  }

  Future<void> updateNotificationSettings(NotificationSettings settings) async {
    _notificationSettings = settings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_task_completion', settings.taskCompletionNotifications);
    await prefs.setBool('notif_task_reminders', settings.taskReminders);
    await prefs.setBool('notif_daily_reminders', settings.dailyReminders);
    await prefs.setBool('notif_streak_reminders', settings.streakReminders);
    await prefs.setBool('notif_achievements', settings.achievementNotifications);
    notifyListeners();
  }

  Future<void> markNotificationAsRead(String id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx].isRead = true;
      await DatabaseHelper.instance.markNotificationAsRead(id);
      notifyListeners();
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    for (var n in _notifications) {
      n.isRead = true;
    }
    await DatabaseHelper.instance.markAllNotificationsAsRead();
    notifyListeners();
  }

  Future<void> clearAllNotifications() async {
    _notifications.clear();
    await DatabaseHelper.instance.clearAllNotifications();
    notifyListeners();
  }

  Future<void> updateProfile(String newName, String newAvatarId) async {
    final cleanName = newName.trim();
    if (cleanName.isNotEmpty) {
      _userProfile.username = cleanName;
      _userProfile.avatarId = newAvatarId;
      notifyListeners();

      // 1. Immediately persist to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_username', cleanName);
      await prefs.setString('hero_username', cleanName);
      await prefs.setString('hero_avatar', newAvatarId);

      // 2. Persist to SQLite database
      await _saveProfile();

      // 3. Sync to online backend MySQL database
      try {
        await ApiClient.instance.post('/users/profile.php', body: {
          'username': cleanName,
          'display_name': cleanName,
          'avatar_id': newAvatarId,
        });
      } catch (e) {
        debugPrint("Failed to sync profile update online: $e");
      }
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  void updateProfileImage(String path) {
    _userProfile.profileImagePath = path;
    _saveProfile();
    notifyListeners();
  }

  bool buyReward(String rewardId) {
    final idx = _rewards.indexWhere((r) => r.id == rewardId);
    if (idx != -1) {
      if (_userProfile.gold >= _rewards[idx].cost) {
        _userProfile.gold -= _rewards[idx].cost;
        _saveProfile();
        notifyListeners();
        return true;
      }
    }
    return false;
  }
}
