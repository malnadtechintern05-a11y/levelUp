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

class HydrationReminder {
  final String id;
  String time; // e.g. "08:00 AM"
  int hour; // 0-23
  int minute; // 0-59
  int amountMl; // e.g. 250
  String repeat; // e.g. "Every Day"
  bool isEnabled;
  bool isCompleted;
  DateTime? completedAt;

  HydrationReminder({
    required this.id,
    required this.time,
    required this.hour,
    required this.minute,
    required this.amountMl,
    this.repeat = 'Every Day',
    this.isEnabled = true,
    this.isCompleted = false,
    this.completedAt,
  });

  bool isMissed() {
    if (!isEnabled || isCompleted) return false;
    final now = DateTime.now();
    final reminderToday = DateTime(now.year, now.month, now.day, hour, minute);
    return now.isAfter(reminderToday);
  }

  HydrationReminder copyWith({
    String? id,
    String? time,
    int? hour,
    int? minute,
    int? amountMl,
    String? repeat,
    bool? isEnabled,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return HydrationReminder(
      id: id ?? this.id,
      time: time ?? this.time,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      amountMl: amountMl ?? this.amountMl,
      repeat: repeat ?? this.repeat,
      isEnabled: isEnabled ?? this.isEnabled,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'time': time,
      'hour': hour,
      'minute': minute,
      'amountMl': amountMl,
      'repeat': repeat,
      'isEnabled': isEnabled,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.millisecondsSinceEpoch,
    };
  }

  factory HydrationReminder.fromMap(Map<String, dynamic> map) {
    return HydrationReminder(
      id: map['id'] ?? '',
      time: map['time'] ?? '08:00 AM',
      hour: map['hour']?.toInt() ?? 8,
      minute: map['minute']?.toInt() ?? 0,
      amountMl: map['amountMl']?.toInt() ?? 250,
      repeat: map['repeat'] ?? 'Every Day',
      isEnabled: map['isEnabled'] ?? true,
      isCompleted: map['isCompleted'] ?? false,
      completedAt: map['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'] as int)
          : null,
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

class QuestObjective {
  final String id;
  String text;
  bool isCompleted;

  QuestObjective({
    required this.id,
    required this.text,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'isCompleted': isCompleted,
    };
  }

  factory QuestObjective.fromMap(Map<String, dynamic> map) {
    return QuestObjective(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      isCompleted: map['isCompleted'] == true || map['isCompleted'] == 1,
    );
  }
}

class RPGTask {
  String id;
  String title;
  String description;
  String category; // Study, Fitness, Health, Work, Personal, Coding, Reading, etc.
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
  int drinkAmountMl; // e.g. 250
  List<HydrationReminder> reminders;
  bool notificationsEnabled;
  String? reminderStartTime; // e.g. "08:00 AM"
  String? reminderEndTime; // e.g. "08:00 PM"
  int reminderIntervalMinutes; // e.g. 120
  String? username;

  // Generic Quest Extended Fields
  String? difficulty; // "Easy", "Medium", "Hard", "Epic", "Legendary"
  int? coinReward;
  int? staminaReward;
  List<QuestObjective> objectives;
  List<String> tips;
  bool requiresProof;
  String? proofImagePath;
  String? personalNote;
  int? streak;
  bool isHabit;
  DateTime? createdAt;

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
    this.drinkAmountMl = 250,
    List<HydrationReminder>? reminders,
    this.notificationsEnabled = true,
    this.reminderStartTime = "08:00 AM",
    this.reminderEndTime = "08:00 PM",
    this.reminderIntervalMinutes = 120,
    this.username,
    this.difficulty,
    this.coinReward,
    this.staminaReward,
    List<QuestObjective>? objectives,
    List<String>? tips,
    this.requiresProof = false,
    this.proofImagePath,
    this.personalNote,
    this.streak,
    this.isHabit = false,
    this.createdAt,
  })  : waterLogs = waterLogs ?? [],
        reminders = reminders ?? [],
        objectives = objectives ?? [],
        tips = tips ?? [];

  HydrationReminder? getNextReminder() {
    if (reminders.isEmpty) return null;
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    final future = reminders
        .where((r) => r.isEnabled && !r.isCompleted && (r.hour * 60 + r.minute >= currentMinutes))
        .toList();
    if (future.isNotEmpty) {
      future.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
      return future.first;
    }
    final pending = reminders.where((r) => r.isEnabled && !r.isCompleted).toList();
    if (pending.isNotEmpty) {
      pending.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
      return pending.first;
    }
    return null;
  }

  List<HydrationReminder> getMissedReminders() {
    return reminders.where((r) => r.isEnabled && !r.isCompleted && r.isMissed()).toList();
  }

  String getEffectiveDifficulty() {
    if (difficulty != null && difficulty!.trim().isNotEmpty) {
      return difficulty!;
    }
    if (xpReward <= 30) return 'Easy';
    if (xpReward <= 60) return 'Medium';
    if (xpReward <= 100) return 'Hard';
    if (xpReward <= 150) return 'Epic';
    return 'Legendary';
  }

  int getEffectiveCoinReward() {
    return coinReward ?? (xpReward ~/ 2);
  }

  int getEffectiveStaminaReward() {
    return staminaReward ?? 0;
  }

  List<QuestObjective> getEffectiveObjectives() {
    if (objectives.isNotEmpty) {
      return objectives;
    }
    final normCat = category.trim().toLowerCase();
    List<String> defaults;
    if (normCat.contains('fitness') || normCat.contains('gym') || normCat.contains('workout')) {
      defaults = ['Warm up & light stretching', 'Execute workout routine', 'Cool down and hydrate'];
    } else if (normCat.contains('study') || normCat.contains('learn')) {
      defaults = ['Review key material', 'Complete active study & practice', 'Summarize key takeaways'];
    } else if (normCat.contains('reading') || normCat.contains('read') || normCat.contains('book')) {
      defaults = ['Read first section/pages', 'Complete reading target', 'Reflect and note highlights'];
    } else if (normCat.contains('code') || normCat.contains('coding') || normCat.contains('dev')) {
      defaults = ['Review task requirements', 'Implement code changes', 'Test and verify functionality'];
    } else if (normCat.contains('health') || normCat.contains('water') || normCat.contains('sleep')) {
      defaults = ['Prepare wellness routine', 'Complete health objective', 'Log wellness status'];
    } else if (normCat.contains('clean')) {
      defaults = ['Clear loose clutter', 'Organize items in place', 'Wipe surfaces clean'];
    } else if (normCat.contains('meditat') || normCat.contains('mindful')) {
      defaults = ['Settle into quiet posture', 'Complete focused breathing', 'Observe inner clarity'];
    } else if (normCat.contains('walk')) {
      defaults = ['Start walking route', 'Reach milestone distance/time', 'Cool down and stretch'];
    } else if (normCat.contains('social')) {
      defaults = ['Reach out to friend/contact', 'Have meaningful conversation', 'Share positive thoughts'];
    } else if (normCat.contains('creat') || normCat.contains('draw') || normCat.contains('paint')) {
      defaults = ['Brainstorm creative concept', 'Work on artwork/project', 'Polish and review piece'];
    } else if (normCat.contains('habit')) {
      defaults = ['Initiate habit trigger', 'Execute core activity', 'Maintain habit streak'];
    } else {
      defaults = ['Prepare necessary items', 'Complete primary objective', 'Review and wrap up'];
    }
    objectives = List.generate(
      defaults.length,
      (index) => QuestObjective(id: 'obj_${id}_$index', text: defaults[index], isCompleted: false),
    );
    return objectives;
  }

  List<String> getEffectiveTips() {
    if (tips.isNotEmpty) {
      return tips;
    }
    final normCat = category.trim().toLowerCase();
    if (normCat.contains('fitness') || normCat.contains('gym') || normCat.contains('workout')) {
      return [
        'Warm up before starting to prevent injury',
        'Focus on controlled form and cadence',
        'Stay well hydrated between sets',
        'Cool down and stretch thoroughly after completion',
      ];
    } else if (normCat.contains('study') || normCat.contains('learn')) {
      return [
        'Place phone on do-not-disturb mode',
        'Focus on one clear topic at a time',
        'Take a 5-minute break every 25 minutes',
        'Summarize concepts in your own words',
      ];
    } else if (normCat.contains('reading') || normCat.contains('read') || normCat.contains('book')) {
      return [
        'Find a quiet, comfortable reading spot',
        'Highlight meaningful passages as you go',
        'Reflect on how lessons apply to your goals',
        'Maintain a steady, focused pace',
      ];
    } else if (normCat.contains('code') || normCat.contains('coding') || normCat.contains('dev')) {
      return [
        'Break the problem down into small functions',
        'Test incrementally after every modification',
        'Check edge cases and input validation',
        'Save and commit your progress',
      ];
    } else if (normCat.contains('health') || normCat.contains('water')) {
      return [
        'Listen to your body and honor its rhythm',
        'Sip water steadily rather than all at once',
        'Prioritize deep, uninterrupted sleep',
        'Consistency beats intensity every single day',
      ];
    } else if (normCat.contains('meditat') || normCat.contains('mindful')) {
      return [
        'Sit upright in a comfortable position',
        'Focus gently on the rhythm of your breath',
        'Notice thoughts and let them drift away',
        'Cultivate patience and peace with yourself',
      ];
    } else if (normCat.contains('clean')) {
      return [
        'Tackle one zone or surface at a time',
        'Discard trash and clutter before wiping down',
        'Give every item a dedicated home',
        'Enjoy the mental clarity of an organized space',
      ];
    } else if (normCat.contains('walk')) {
      return [
        'Wear supportive walking shoes',
        'Maintain an active, steady pace',
        'Unplug and observe the sights around you',
        'Rehydrate when you finish',
      ];
    } else if (normCat.contains('social')) {
      return [
        'Practice deep, active listening',
        'Share authentic encouragement and care',
        'Put devices away during conversations',
        'Follow up with a thoughtful message',
      ];
    } else if (normCat.contains('creat') || normCat.contains('draw') || normCat.contains('paint')) {
      return [
        'Embrace curiosity and experiment freely',
        'Do not judge the first draft too harshly',
        'Enjoy entering the creative flow state',
        'Save revisions to trace your progress',
      ];
    } else if (normCat.contains('habit')) {
      return [
        'Anchor this habit to an established routine',
        'Make starting frictionless and immediate',
        'Celebrate every single day completed',
        'Never miss two days in a row',
      ];
    } else {
      return [
        'Clarify what completion looks like first',
        'Eliminate distractions before starting',
        'Take immediate action without delaying',
        'Reward yourself when you cross the finish line',
      ];
    }
  }

  String getProofRecommendation() {
    final normCat = category.trim().toLowerCase();
    if (normCat.contains('fitness') || normCat.contains('gym') || normCat.contains('workout')) {
      return 'Upload a workout photo or tracker screenshot';
    } else if (normCat.contains('study') || normCat.contains('learn')) {
      return 'Upload a photo of your study notes or materials';
    } else if (normCat.contains('reading') || normCat.contains('read') || normCat.contains('book')) {
      return 'Upload a photo of your book or reading session';
    } else if (normCat.contains('code') || normCat.contains('coding') || normCat.contains('dev')) {
      return 'Upload a screenshot of your code or terminal';
    } else if (normCat.contains('clean')) {
      return 'Upload a before/after photo of your clean space';
    } else if (normCat.contains('creat') || normCat.contains('draw')) {
      return 'Upload a photo of your artwork or creation';
    } else if (normCat.contains('health') || normCat.contains('water')) {
      return 'Upload a photo of your hydration or healthy meal';
    } else if (normCat.contains('walk')) {
      return 'Upload a route screenshot or outdoor view';
    } else if (normCat.contains('meditat')) {
      return 'Upload a screenshot of your timer or meditation space';
    } else {
      return 'Upload a photo as proof of completion';
    }
  }

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
      'drinkAmountMl': drinkAmountMl,
      'reminders': reminders.map((e) => e.toMap()).toList(),
      'notificationsEnabled': notificationsEnabled,
      'reminderStartTime': reminderStartTime,
      'reminderEndTime': reminderEndTime,
      'reminderIntervalMinutes': reminderIntervalMinutes,
      'username': username,
      'difficulty': difficulty,
      'coinReward': coinReward,
      'staminaReward': staminaReward,
      'objectives': objectives.map((e) => e.toMap()).toList(),
      'tips': tips,
      'requiresProof': requiresProof,
      'proofImagePath': proofImagePath,
      'personalNote': personalNote,
      'streak': streak,
      'isHabit': isHabit,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  factory RPGTask.fromMap(Map<String, dynamic> map) {
    List<WaterLogEntry> logs = [];
    if (map['waterLogs'] != null) {
      logs = (map['waterLogs'] as List).map((e) => WaterLogEntry.fromMap(Map<String, dynamic>.from(e))).toList();
    }
    List<HydrationReminder> remList = [];
    if (map['reminders'] != null) {
      remList = (map['reminders'] as List)
          .map((e) => HydrationReminder.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    }
    List<QuestObjective> objs = [];
    if (map['objectives'] != null) {
      objs = (map['objectives'] as List).map((e) => QuestObjective.fromMap(Map<String, dynamic>.from(e))).toList();
    }
    List<String> tipList = [];
    if (map['tips'] != null) {
      tipList = List<String>.from(map['tips']);
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
      drinkAmountMl: map['drinkAmountMl']?.toInt() ?? 250,
      reminders: remList,
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      reminderStartTime: map['reminderStartTime'] ?? '08:00 AM',
      reminderEndTime: map['reminderEndTime'] ?? '08:00 PM',
      reminderIntervalMinutes: map['reminderIntervalMinutes']?.toInt() ?? 120,
      username: map['username'],
      difficulty: map['difficulty'],
      coinReward: map['coinReward']?.toInt(),
      staminaReward: map['staminaReward']?.toInt(),
      objectives: objs,
      tips: tipList,
      requiresProof: map['requiresProof'] ?? false,
      proofImagePath: map['proofImagePath'],
      personalNote: map['personalNote'],
      streak: map['streak']?.toInt(),
      isHabit: map['isHabit'] ?? false,
      createdAt: map['createdAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['createdAt']) : null,
    );
  }

  Map<String, dynamic> toMapSql() {
    final extraData = {
      'difficulty': difficulty,
      'coinReward': coinReward,
      'staminaReward': staminaReward,
      'objectives': objectives.map((e) => e.toMap()).toList(),
      'tips': tips,
      'requiresProof': requiresProof,
      'proofImagePath': proofImagePath,
      'personalNote': personalNote,
      'streak': streak,
      'isHabit': isHabit,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'drinkAmountMl': drinkAmountMl,
      'reminders': reminders.map((e) => e.toMap()).toList(),
      'notificationsEnabled': notificationsEnabled,
      'reminderStartTime': reminderStartTime,
      'reminderEndTime': reminderEndTime,
      'reminderIntervalMinutes': reminderIntervalMinutes,
      'username': username,
    };

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
      'extraDataJson': json.encode(extraData),
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

    String? diff;
    int? coins;
    int? stamina;
    List<QuestObjective> objs = [];
    List<String> tipList = [];
    bool reqProof = false;
    String? proofPath;
    String? pNote;
    int? strk;
    bool habit = false;
    DateTime? created;
    List<HydrationReminder> remList = [];
    int? drinkMl;
    bool? notifsOn;
    String? startT;
    String? endT;
    int? intervalMins;
    String? uName;

    if (map['extraDataJson'] != null && (map['extraDataJson'] as String).isNotEmpty) {
      try {
        final extra = json.decode(map['extraDataJson'] as String);
        if (extra is Map<String, dynamic>) {
          diff = extra['difficulty'] as String?;
          coins = extra['coinReward'] as int?;
          stamina = extra['staminaReward'] as int?;
          if (extra['objectives'] is List) {
            objs = (extra['objectives'] as List)
                .map((e) => QuestObjective.fromMap(Map<String, dynamic>.from(e)))
                .toList();
          }
          if (extra['tips'] is List) {
            tipList = List<String>.from(extra['tips']);
          }
          reqProof = extra['requiresProof'] == true || extra['requiresProof'] == 1;
          proofPath = extra['proofImagePath'] as String?;
          pNote = extra['personalNote'] as String?;
          strk = extra['streak'] as int?;
          habit = extra['isHabit'] == true || extra['isHabit'] == 1;
          if (extra['createdAt'] != null) {
            created = DateTime.fromMillisecondsSinceEpoch(extra['createdAt'] as int);
          }
          if (extra['reminders'] is List) {
            remList = (extra['reminders'] as List)
                .map((e) => HydrationReminder.fromMap(Map<String, dynamic>.from(e)))
                .toList();
          }
          drinkMl = extra['drinkAmountMl'] as int?;
          notifsOn = extra['notificationsEnabled'] as bool?;
          startT = extra['reminderStartTime'] as String?;
          endT = extra['reminderEndTime'] as String?;
          intervalMins = extra['reminderIntervalMinutes'] as int?;
          uName = extra['username'] as String?;
        }
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
      drinkAmountMl: drinkMl ?? 250,
      reminders: remList,
      notificationsEnabled: notifsOn ?? true,
      reminderStartTime: startT ?? '08:00 AM',
      reminderEndTime: endT ?? '08:00 PM',
      reminderIntervalMinutes: intervalMins ?? 120,
      username: uName,
      difficulty: diff,
      coinReward: coins,
      staminaReward: stamina,
      objectives: objs,
      tips: tipList,
      requiresProof: reqProof,
      proofImagePath: proofPath,
      personalNote: pNote,
      streak: strk,
      isHabit: habit,
      createdAt: created,
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
