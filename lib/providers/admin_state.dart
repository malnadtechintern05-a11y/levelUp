import 'package:flutter/material.dart';
import '../models/models.dart';
import '../helpers/database_helper.dart';
import '../services/auth_service.dart';

class AdminState extends ChangeNotifier {
  bool _isAdminLoggedIn = false;
  bool get isAdminLoggedIn => _isAdminLoggedIn;

  List<UserProfile> _users = [];
  List<RPGTask> _tasks = [];
  List<Achievement> _achievements = [];

  List<UserProfile> get users => _isAdminLoggedIn ? _users : [];
  List<RPGTask> get tasks => _isAdminLoggedIn ? _tasks : [];
  List<Achievement> get achievements => _isAdminLoggedIn ? _achievements : [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final res = await AuthService.instance.login(email, password);
      _isLoading = false;
      
      if (res['status'] == 'success') {
        final role = await AuthService.instance.getRole();
        final user = res['user'] as Map<String, dynamic>?;
        final isUserAdmin = role.toLowerCase() == 'admin' ||
            (user != null && (user['role'] == 'admin' || user['is_admin'] == 1 || user['is_admin'] == true));

        if (isUserAdmin) {
          _isAdminLoggedIn = true;
          notifyListeners();
          await loadData();
          return true;
        }
      }
    } catch (_) {
      _isLoading = false;
    }
    
    _isAdminLoggedIn = false;
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
    if (!_isAdminLoggedIn) return;
    
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
    if (!_isAdminLoggedIn) throw StateError('Unauthorized admin access');
    final index = _users.indexWhere((u) => u.username == username);
    if (index != -1) {
      _users[index].isActive = !_users[index].isActive;
      await DatabaseHelper.instance.saveProfile(_users[index]);
      notifyListeners();
    }
  }

  // --- Tasks ---
  Future<void> addTask(RPGTask task) async {
    if (!_isAdminLoggedIn) throw StateError('Unauthorized admin access');
    await DatabaseHelper.instance.insertTask(task);
    _tasks.add(task);
    notifyListeners();
  }

  Future<void> updateTask(RPGTask task) async {
    if (!_isAdminLoggedIn) throw StateError('Unauthorized admin access');
    await DatabaseHelper.instance.updateTask(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    if (!_isAdminLoggedIn) throw StateError('Unauthorized admin access');
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index].isActive = false;
      await DatabaseHelper.instance.updateTask(_tasks[index]);
      notifyListeners();
    }
  }
  
  Future<void> toggleTaskStatus(String taskId) async {
    if (!_isAdminLoggedIn) throw StateError('Unauthorized admin access');
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index].isActive = !_tasks[index].isActive;
      await DatabaseHelper.instance.updateTask(_tasks[index]);
      notifyListeners();
    }
  }

  // --- Achievements ---
  Future<void> saveAchievements(List<Achievement> achievementsList) async {
    if (!_isAdminLoggedIn) throw StateError('Unauthorized admin access');
    await DatabaseHelper.instance.saveAllAchievements(achievementsList);
    _achievements = achievementsList;
    notifyListeners();
  }

  // Analytics Helpers
  int get totalTaskCompletions => _isAdminLoggedIn ? _tasks.where((t) => t.isCompleted).length : 0;
  int get totalXPAwarded {
    if (!_isAdminLoggedIn) return 0;
    return _users.fold(0, (sum, user) => sum + user.totalXP);
  }
  int get activeUsersCount => _isAdminLoggedIn ? _users.where((u) => u.isActive).length : 0;
}
