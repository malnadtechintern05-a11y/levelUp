import 'dart:convert';

class WaterLogEntry {
  final String id;
  final int amountMl;
  final DateTime timestamp;

  WaterLogEntry({
    required this.id,
    required this.amountMl,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amountMl': amountMl,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory WaterLogEntry.fromMap(Map<String, dynamic> map) {
    return WaterLogEntry(
      id: map['id'] ?? '',
      amountMl: map['amountMl']?.toInt() ?? 0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch),
    );
  }
}

class UserProfile {
  String username;
  String? email;
  String avatarId;
  String? profileImagePath;
  int level;
  int totalXP;
  int gold;
  int currentStreak;
  int bestStreak;
  Map<String, int> skills; // e.g. 'Strength': 50, 'Knowledge': 80
  bool isActive;
  int hydrationCurrentStreak;
  int hydrationBestStreak;
  String? lastHydrationCompletedDate;
  String? hydrationXpAwardedDate;

  UserProfile({
    required this.username,
    this.email,
    this.avatarId = 'hero1',
    this.profileImagePath,
    this.level = 1,
    this.totalXP = 0,
    this.gold = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.isActive = true,
    this.hydrationCurrentStreak = 0,
    this.hydrationBestStreak = 0,
    this.lastHydrationCompletedDate,
    this.hydrationXpAwardedDate,
    Map<String, int>? skills,
  }) : skills = skills ?? {'Strength': 0, 'Knowledge': 0, 'Discipline': 0};

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'avatarId': avatarId,
      'profileImagePath': profileImagePath,
      'level': level,
      'totalXP': totalXP,
      'gold': gold,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'skills': skills,
      'isActive': isActive,
      'hydrationCurrentStreak': hydrationCurrentStreak,
      'hydrationBestStreak': hydrationBestStreak,
      'lastHydrationCompletedDate': lastHydrationCompletedDate,
      'hydrationXpAwardedDate': hydrationXpAwardedDate,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      username: map['username'] ?? 'Hero',
      email: map['email'],
      avatarId: map['avatarId'] ?? 'hero1',
      profileImagePath: map['profileImagePath'],
      level: map['level']?.toInt() ?? 1,
      totalXP: map['totalXP']?.toInt() ?? 0,
      gold: map['gold']?.toInt() ?? 0,
      currentStreak: map['currentStreak']?.toInt() ?? 0,
      bestStreak: map['bestStreak']?.toInt() ?? 0,
      isActive: map['isActive'] ?? true,
      hydrationCurrentStreak: map['hydrationCurrentStreak']?.toInt() ?? 0,
      hydrationBestStreak: map['hydrationBestStreak']?.toInt() ?? 0,
      lastHydrationCompletedDate: map['lastHydrationCompletedDate'] as String?,
      hydrationXpAwardedDate: map['hydrationXpAwardedDate'] as String?,
      skills: Map<String, int>.from(map['skills'] ?? {'Strength': 0, 'Knowledge': 0, 'Discipline': 0}),
    );
  }

  Map<String, dynamic> toMapSql() {
    return {
      'username': username,
      'email': email,
      'avatarId': avatarId,
      'profileImagePath': profileImagePath,
      'level': level,
      'totalXP': totalXP,
      'gold': gold,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'skills': json.encode(skills), // Store map as JSON string in SQLite
      'isActive': isActive ? 1 : 0,
      'hydrationCurrentStreak': hydrationCurrentStreak,
      'hydrationBestStreak': hydrationBestStreak,
      'lastHydrationCompletedDate': lastHydrationCompletedDate,
      'hydrationXpAwardedDate': hydrationXpAwardedDate,
    };
  }

  factory UserProfile.fromMapSql(Map<String, dynamic> map) {
    return UserProfile(
      username: map['username'] as String,
      email: map['email'] as String?,
      avatarId: map['avatarId'] as String,
      profileImagePath: map['profileImagePath'] as String?,
      level: map['level'] as int,
      totalXP: map['totalXP'] as int,
      gold: map['gold'] as int,
      currentStreak: map['currentStreak'] as int,
      bestStreak: map['bestStreak'] as int,
      isActive: map.containsKey('isActive') ? ((map['isActive'] as int) == 1) : true,
      hydrationCurrentStreak: map.containsKey('hydrationCurrentStreak') ? (map['hydrationCurrentStreak'] as int? ?? 0) : 0,
      hydrationBestStreak: map.containsKey('hydrationBestStreak') ? (map['hydrationBestStreak'] as int? ?? 0) : 0,
      lastHydrationCompletedDate: map['lastHydrationCompletedDate'] as String?,
      hydrationXpAwardedDate: map['hydrationXpAwardedDate'] as String?,
      skills: Map<String, int>.from(json.decode(map['skills'] as String)),
    );
  }

  String toJson() => json.encode(toMap());
  factory UserProfile.fromJson(String source) => UserProfile.fromMap(json.decode(source));
}

class RPGTask {
  String id;
  String title;
  String description;
  String category; // Study, Fitness, Health, Work, Personal
  int xpReward;
  bool isCompleted;
  DateTime dueDate;
  String? time;
  int timeSpentSeconds;
  
  // Timer specific fields
  int durationMinutes;
  int remainingSeconds;
  String timerStatus; // "Not Started", "Running", "Paused", "Completed"
  int? timerStartTimeEpoch;
  bool isActive;

  // Hydration / Progress Quest fields
  String taskType; // "normal" (timer-based) or "hydration" (progress-based)
  int waterGoalMl; // e.g. 2000, 2500
  int currentWaterMl; // e.g. 1500
  List<WaterLogEntry> waterLogs;

  RPGTask({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.xpReward,
    this.isCompleted = false,
    required this.dueDate,
    this.time,
    this.timeSpentSeconds = 0,
    this.durationMinutes = 0,
    this.remainingSeconds = 0,
    this.timerStatus = "Not Started",
    this.timerStartTimeEpoch,
    this.isActive = true,
    this.taskType = "normal",
    this.waterGoalMl = 2000,
    this.currentWaterMl = 0,
    List<WaterLogEntry>? waterLogs,
  }) : waterLogs = waterLogs ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'xpReward': xpReward,
      'isCompleted': isCompleted,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'time': time,
      'timeSpentSeconds': timeSpentSeconds,
      'durationMinutes': durationMinutes,
      'remainingSeconds': remainingSeconds,
      'timerStatus': timerStatus,
      'timerStartTimeEpoch': timerStartTimeEpoch,
      'isActive': isActive,
      'taskType': taskType,
      'waterGoalMl': waterGoalMl,
      'currentWaterMl': currentWaterMl,
      'waterLogs': waterLogs.map((e) => e.toMap()).toList(),
    };
  }

  factory RPGTask.fromMap(Map<String, dynamic> map) {
    List<WaterLogEntry> logs = [];
    if (map['waterLogs'] != null) {
      logs = (map['waterLogs'] as List).map((e) => WaterLogEntry.fromMap(Map<String, dynamic>.from(e))).toList();
    }
    return RPGTask(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Personal',
      xpReward: map['xpReward']?.toInt() ?? 10,
      isCompleted: map['isCompleted'] ?? false,
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['dueDate'] ?? DateTime.now().millisecondsSinceEpoch),
      time: map['time'],
      timeSpentSeconds: map['timeSpentSeconds']?.toInt() ?? 0,
      durationMinutes: map['durationMinutes']?.toInt() ?? 0,
      remainingSeconds: map['remainingSeconds']?.toInt() ?? 0,
      timerStatus: map['timerStatus'] ?? 'Not Started',
      timerStartTimeEpoch: map['timerStartTimeEpoch']?.toInt(),
      isActive: map['isActive'] ?? true,
      taskType: map['taskType'] ?? 'normal',
      waterGoalMl: map['waterGoalMl']?.toInt() ?? 2000,
      currentWaterMl: map['currentWaterMl']?.toInt() ?? 0,
      waterLogs: logs,
    );
  }

  Map<String, dynamic> toMapSql() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'xpReward': xpReward,
      'isCompleted': isCompleted ? 1 : 0, // Boolean to int
      'dueDate': dueDate.millisecondsSinceEpoch,
      'time': time,
      'timeSpentSeconds': timeSpentSeconds,
      'durationMinutes': durationMinutes,
      'remainingSeconds': remainingSeconds,
      'timerStatus': timerStatus,
      'timerStartTimeEpoch': timerStartTimeEpoch,
      'isActive': isActive ? 1 : 0,
      'taskType': taskType,
      'waterGoalMl': waterGoalMl,
      'currentWaterMl': currentWaterMl,
      'waterLogsJson': json.encode(waterLogs.map((e) => e.toMap()).toList()),
    };
  }

  factory RPGTask.fromMapSql(Map<String, dynamic> map) {
    List<WaterLogEntry> logs = [];
    if (map['waterLogsJson'] != null && (map['waterLogsJson'] as String).isNotEmpty) {
      try {
        final decoded = json.decode(map['waterLogsJson'] as String) as List;
        logs = decoded.map((e) => WaterLogEntry.fromMap(Map<String, dynamic>.from(e))).toList();
      } catch (_) {}
    }
    return RPGTask(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      xpReward: map['xpReward'] as int,
      isCompleted: (map['isCompleted'] as int) == 1,
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['dueDate'] as int),
      time: map['time'] as String?,
      timeSpentSeconds: map['timeSpentSeconds'] as int,
      durationMinutes: map['durationMinutes'] as int,
      remainingSeconds: map['remainingSeconds'] as int,
      timerStatus: map['timerStatus'] as String,
      timerStartTimeEpoch: map['timerStartTimeEpoch'] as int?,
      isActive: map.containsKey('isActive') ? ((map['isActive'] as int) == 1) : true,
      taskType: map['taskType'] as String? ?? 'normal',
      waterGoalMl: map['waterGoalMl'] as int? ?? 2000,
      currentWaterMl: map['currentWaterMl'] as int? ?? 0,
      waterLogs: logs,
    );
  }

  String toJson() => json.encode(toMap());
  factory RPGTask.fromJson(String source) => RPGTask.fromMap(json.decode(source));
}

class Achievement {
  String id;
  String name;
  String description;
  int xpReward;
  String unlockRequirement;
  String? iconPath;
  bool isUnlocked;
  bool isActive;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    this.xpReward = 0,
    this.unlockRequirement = '',
    this.iconPath,
    this.isUnlocked = false,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'xpReward': xpReward,
      'unlockRequirement': unlockRequirement,
      'iconPath': iconPath,
      'isUnlocked': isUnlocked,
      'isActive': isActive,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      xpReward: map['xpReward']?.toInt() ?? 0,
      unlockRequirement: map['unlockRequirement'] ?? '',
      iconPath: map['iconPath'],
      isUnlocked: map['isUnlocked'] ?? false,
      isActive: map['isActive'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());
  factory Achievement.fromJson(String source) => Achievement.fromMap(json.decode(source));
}

class Reward {
  String id;
  String title;
  int cost;

  Reward({
    required this.id,
    required this.title,
    required this.cost,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'cost': cost,
    };
  }

  factory Reward.fromMap(Map<String, dynamic> map) {
    return Reward(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      cost: map['cost']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());
  factory Reward.fromJson(String source) => Reward.fromMap(json.decode(source));
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String category; // Fitness, Study, Health, Work, Personal, LevelUp, Achievement, System
  final String type; // taskCompletion, levelUp, achievement, reminder
  final DateTime timestamp;
  final int? xpReward;
  final int? streakDays;
  final String? motivationalQuote;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.type,
    required this.timestamp,
    this.xpReward,
    this.streakDays,
    this.motivationalQuote,
    this.isRead = false,
  });

  Map<String, dynamic> toMapSql() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'category': category,
      'type': type,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'xpReward': xpReward,
      'streakDays': streakDays,
      'motivationalQuote': motivationalQuote,
      'isRead': isRead ? 1 : 0,
    };
  }

  factory AppNotification.fromMapSql(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      category: map['category'] ?? 'Personal',
      type: map['type'] ?? 'taskCompletion',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch),
      xpReward: map['xpReward'] as int?,
      streakDays: map['streakDays'] as int?,
      motivationalQuote: map['motivationalQuote'] as String?,
      isRead: (map['isRead'] ?? 0) == 1,
    );
  }
}

class NotificationSettings {
  bool taskCompletionNotifications;
  bool taskReminders;
  bool dailyReminders;
  bool streakReminders;
  bool achievementNotifications;

  NotificationSettings({
    this.taskCompletionNotifications = true,
    this.taskReminders = true,
    this.dailyReminders = true,
    this.streakReminders = true,
    this.achievementNotifications = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'taskCompletionNotifications': taskCompletionNotifications,
      'taskReminders': taskReminders,
      'dailyReminders': dailyReminders,
      'streakReminders': streakReminders,
      'achievementNotifications': achievementNotifications,
    };
  }

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      taskCompletionNotifications: map['taskCompletionNotifications'] ?? true,
      taskReminders: map['taskReminders'] ?? true,
      dailyReminders: map['dailyReminders'] ?? true,
      streakReminders: map['streakReminders'] ?? true,
      achievementNotifications: map['achievementNotifications'] ?? true,
    );
  }
}
