import 'dart:convert';

class UserProfile {
  String username;
  String avatarId;
  String? profileImagePath;
  int level;
  int totalXP;
  int gold;
  int currentStreak;
  int bestStreak;
  Map<String, int> skills; // e.g. 'Strength': 50, 'Knowledge': 80

  UserProfile({
    required this.username,
    this.avatarId = 'hero1',
    this.profileImagePath,
    this.level = 1,
    this.totalXP = 0,
    this.gold = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    Map<String, int>? skills,
  }) : skills = skills ?? {'Strength': 0, 'Knowledge': 0, 'Discipline': 0};

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'avatarId': avatarId,
      'profileImagePath': profileImagePath,
      'level': level,
      'totalXP': totalXP,
      'gold': gold,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'skills': skills,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      username: map['username'] ?? 'Hero',
      avatarId: map['avatarId'] ?? 'hero1',
      profileImagePath: map['profileImagePath'],
      level: map['level']?.toInt() ?? 1,
      totalXP: map['totalXP']?.toInt() ?? 0,
      gold: map['gold']?.toInt() ?? 0,
      currentStreak: map['currentStreak']?.toInt() ?? 0,
      bestStreak: map['bestStreak']?.toInt() ?? 0,
      skills: Map<String, int>.from(map['skills'] ?? {'Strength': 0, 'Knowledge': 0, 'Discipline': 0}),
    );
  }

  Map<String, dynamic> toMapSql() {
    return {
      'username': username,
      'avatarId': avatarId,
      'profileImagePath': profileImagePath,
      'level': level,
      'totalXP': totalXP,
      'gold': gold,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'skills': json.encode(skills), // Store map as JSON string in SQLite
    };
  }

  factory UserProfile.fromMapSql(Map<String, dynamic> map) {
    return UserProfile(
      username: map['username'] as String,
      avatarId: map['avatarId'] as String,
      profileImagePath: map['profileImagePath'] as String?,
      level: map['level'] as int,
      totalXP: map['totalXP'] as int,
      gold: map['gold'] as int,
      currentStreak: map['currentStreak'] as int,
      bestStreak: map['bestStreak'] as int,
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
  int timeSpentSeconds; // Legacy, kept for backwards compatibility if needed
  
  // Timer specific fields
  int durationMinutes;
  int remainingSeconds;
  String timerStatus; // "Not Started", "Running", "Paused", "Completed"
  int? timerStartTimeEpoch;

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
  });

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
    };
  }

  factory RPGTask.fromMap(Map<String, dynamic> map) {
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
    };
  }

  factory RPGTask.fromMapSql(Map<String, dynamic> map) {
    return RPGTask(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      xpReward: map['xpReward'] as int,
      isCompleted: (map['isCompleted'] as int) == 1, // Int to boolean
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['dueDate'] as int),
      time: map['time'] as String?,
      timeSpentSeconds: map['timeSpentSeconds'] as int,
      durationMinutes: map['durationMinutes'] as int,
      remainingSeconds: map['remainingSeconds'] as int,
      timerStatus: map['timerStatus'] as String,
      timerStartTimeEpoch: map['timerStartTimeEpoch'] as int?,
    );
  }

  String toJson() => json.encode(toMap());
  factory RPGTask.fromJson(String source) => RPGTask.fromMap(json.decode(source));
}

class Achievement {
  String id;
  String name;
  String description;
  bool isUnlocked;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    this.isUnlocked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isUnlocked': isUnlocked,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      isUnlocked: map['isUnlocked'] ?? false,
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
