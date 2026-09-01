import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../models/models.dart';
import '../helpers/database_helper.dart';

class AppState extends ChangeNotifier {
  UserProfile _userProfile = UserProfile(username: 'Hero');
  List<RPGTask> _tasks = [];
  Timer? _globalTimer;
  
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
  
  Map<String, int> _weeklyXp = {
    'Mon': 0, 'Tue': 0, 'Wed': 0, 'Thu': 0, 'Fri': 0, 'Sat': 0, 'Sun': 0,
  };
  
  bool _isLoading = true;
  bool _isDarkMode = true;
  
  UserProfile get userProfile => _userProfile;
  List<RPGTask> get tasks => _tasks;
  List<Achievement> get achievements => _achievements;
  List<Reward> get rewards => _rewards;
  Map<String, int> get weeklyXp => _weeklyXp;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;

  List<RPGTask> get activeTasks => _tasks.where((t) => !t.isCompleted).toList();
  List<RPGTask> get completedTasks => _tasks.where((t) => t.isCompleted).toList();
  
  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
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
      final dbHelper = DatabaseHelper.instance;
      
      try {
        final profile = await dbHelper.getProfile();
        if (profile != null) {
          _userProfile = profile;
        }
      } catch (e) {
        debugPrint("Error loading profile from DB: $e");
      }
      
      try {
        final tasksList = await dbHelper.getAllTasks();
        if (tasksList.isNotEmpty) {
          _tasks = tasksList;
        } else {
          _seedTasks();
        }
      } catch (e) {
        debugPrint("Error loading tasks from DB: $e");
        _seedTasks();
      }
      
      try {
        final achievementsList = await dbHelper.getAllAchievements();
        if (achievementsList.isNotEmpty) {
          _achievements = achievementsList;
        }
      } catch (e) {
        debugPrint("Error loading achievements from DB: $e");
      }
      
      _isDarkMode = prefs.getBool('isDarkMode') ?? true;
      
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

  void _seedTasks() {
    _tasks = [
      RPGTask(id: 't1', title: 'Morning Exercise', description: 'Stay fit', category: 'Fitness', xpReward: 50, dueDate: DateTime.now(), isCompleted: true),
      RPGTask(id: 't2', title: 'Study Flutter', description: 'Build cool apps', category: 'Study', xpReward: 100, dueDate: DateTime.now()),
      RPGTask(id: 't3', title: 'Read a Book', description: 'Personal growth', category: 'Personal', xpReward: 30, dueDate: DateTime.now()),
    ];
    _saveTasks();
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
    // Pause any other running timers
    for (var t in _tasks) {
      if (t.timerStatus == 'Running' && t.id != taskId) {
        _pauseTimerLocally(t);
      }
    }

    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1 && _tasks[idx].timerStatus != 'Completed') {
      if (_tasks[idx].timerStatus == 'Not Started') {
        _tasks[idx].remainingSeconds = _tasks[idx].durationMinutes * 60;
      }
      _tasks[idx].timerStatus = 'Running';
      _tasks[idx].timerStartTimeEpoch = DateTime.now().millisecondsSinceEpoch;
      _startGlobalTimerIfNeeded();
      _saveTasks();
      notifyListeners();
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

  void pauseTaskTimer(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _pauseTimerLocally(_tasks[idx]);
      _saveTasks();
      notifyListeners();
    }
  }

  void finishTaskEarly(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _pauseTimerLocally(_tasks[idx]); // Update elapsed time
      completeTask(taskId);
    }
  }

  @override
  void completeTask(String taskId) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1 && !_tasks[index].isCompleted) {
      _pauseTimerLocally(_tasks[index]); // Stop timer if running
      _tasks[index].isCompleted = true;
      _tasks[index].timerStatus = 'Completed';
      
      int xp = _tasks[index].xpReward;
      _userProfile.gold += (xp ~/ 2);
      
      // Update skills based on category
      String category = _tasks[index].category;
      if (category == 'Fitness' || category == 'Health') {
        _userProfile.skills['Strength'] = (_userProfile.skills['Strength'] ?? 0) + 10;
      } else if (category == 'Study' || category == 'Work') {
        _userProfile.skills['Knowledge'] = (_userProfile.skills['Knowledge'] ?? 0) + 10;
      } else {
        _userProfile.skills['Discipline'] = (_userProfile.skills['Discipline'] ?? 0) + 10;
      }
      
      _addXP(xp);
      _checkAchievements();
      _saveTasks();
      _saveProfile();
      notifyListeners();
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

  void _checkAchievements() {
    bool changed = false;
    
    // First Quest
    if (!_achievements[0].isUnlocked && completedTasks.isNotEmpty) {
      _achievements[0].isUnlocked = true; changed = true;
    }
    // On Fire (7 day streak) - simplistic logic for demo
    if (!_achievements[1].isUnlocked && _userProfile.currentStreak >= 7) {
      _achievements[1].isUnlocked = true; changed = true;
    }
    // Quest Master (50 quests)
    if (!_achievements[2].isUnlocked && completedTasks.length >= 50) {
      _achievements[2].isUnlocked = true; changed = true;
    }
    // Legend (Level 50)
    if (!_achievements[3].isUnlocked && _userProfile.level >= 50) {
      _achievements[3].isUnlocked = true; changed = true;
    }
    
    if (changed) _saveAchievements();
  }

  void updateProfile(String newName, String newAvatarId) {
    if (newName.isNotEmpty) {
      _userProfile.username = newName;
      _userProfile.avatarId = newAvatarId;
      _saveProfile();
      notifyListeners();
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
}
