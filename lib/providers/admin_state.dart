import 'package:flutter/material.dart';
import '../models/models.dart';
import '../helpers/database_helper.dart';

class AdminState extends ChangeNotifier {
  bool _isAdminLoggedIn = false;
  bool get isAdminLoggedIn => _isAdminLoggedIn;

  List<UserProfile> _users = [];
  List<RPGTask> _tasks = [];
  List<Achievement> _achievements = [];

  List<UserProfile> get users => _users;
  List<RPGTask> get tasks => _tasks;
  List<Achievement> get achievements => _achievements;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 1)); // Simulate network/DB
    
    _isLoading = false;
    if (email == 'admin@levelup.com' && password == 'admin123') {
      _isAdminLoggedIn = true;
      notifyListeners();
      await loadData();
      return true;
    }
    
    notifyListeners();
    return false;
  }

  void logout() {
    _isAdminLoggedIn = false;
    _users = [];
    _tasks = [];
    _achievements = [];
    notifyListeners();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    
    _users = await DatabaseHelper.instance.getAllProfiles();
    _tasks = await DatabaseHelper.instance.getAllTasks();
    _achievements = await DatabaseHelper.instance.getAllAchievements();
    
    _isLoading = false;
    notifyListeners();
  }

  // --- Users ---
  Future<void> toggleUserStatus(String username) async {
    final index = _users.indexWhere((u) => u.username == username);
    if (index != -1) {
      _users[index].isActive = !_users[index].isActive;
      // Because we only enforce id=1 for the primary user currently, saving is tricky if there were multiple.
      // We'll assume the primary user is the only one right now.
      await DatabaseHelper.instance.saveProfile(_users[index]);
      notifyListeners();
    }
  }

  // --- Tasks ---
  Future<void> addTask(RPGTask task) async {
    await DatabaseHelper.instance.insertTask(task);
    _tasks.add(task);
    notifyListeners();
  }

  Future<void> updateTask(RPGTask task) async {
    await DatabaseHelper.instance.updateTask(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    // We shouldn't actually delete to preserve history, maybe just deactivate
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index].isActive = false;
      await DatabaseHelper.instance.updateTask(_tasks[index]);
      notifyListeners();
    }
  }
  
  Future<void> toggleTaskStatus(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index].isActive = !_tasks[index].isActive;
      await DatabaseHelper.instance.updateTask(_tasks[index]);
      notifyListeners();
    }
  }

  // --- Achievements ---
  Future<void> saveAchievements(List<Achievement> achievementsList) async {
    await DatabaseHelper.instance.saveAllAchievements(achievementsList);
    _achievements = achievementsList;
    notifyListeners();
  }

  // Analytics Helpers
  int get totalTaskCompletions => _tasks.where((t) => t.isCompleted).length;
  int get totalXPAwarded {
    return _users.fold(0, (sum, user) => sum + user.totalXP);
  }
  int get activeUsersCount => _users.where((u) => u.isActive).length;
}
