import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('realliferpg.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add email and isActive to user_profile
      await db.execute('ALTER TABLE user_profile ADD COLUMN email TEXT;');
      await db.execute('ALTER TABLE user_profile ADD COLUMN isActive INTEGER NOT NULL DEFAULT 1;');
      
      // Add isActive to tasks
      await db.execute('ALTER TABLE tasks ADD COLUMN isActive INTEGER NOT NULL DEFAULT 1;');
      
      // Add new fields to achievements
      await db.execute('ALTER TABLE achievements ADD COLUMN xpReward INTEGER NOT NULL DEFAULT 0;');
      await db.execute('ALTER TABLE achievements ADD COLUMN unlockRequirement TEXT NOT NULL DEFAULT "";');
      await db.execute('ALTER TABLE achievements ADD COLUMN iconPath TEXT;');
      await db.execute('ALTER TABLE achievements ADD COLUMN isActive INTEGER NOT NULL DEFAULT 1;');
    }
    if (oldVersion < 3) {
      // Hydration fields for tasks
      await db.execute('ALTER TABLE tasks ADD COLUMN taskType TEXT NOT NULL DEFAULT "normal";');
      await db.execute('ALTER TABLE tasks ADD COLUMN waterGoalMl INTEGER NOT NULL DEFAULT 2000;');
      await db.execute('ALTER TABLE tasks ADD COLUMN currentWaterMl INTEGER NOT NULL DEFAULT 0;');
      await db.execute('ALTER TABLE tasks ADD COLUMN waterLogsJson TEXT NOT NULL DEFAULT "[]";');
      
      // Hydration fields for user_profile
      await db.execute('ALTER TABLE user_profile ADD COLUMN hydrationCurrentStreak INTEGER NOT NULL DEFAULT 0;');
      await db.execute('ALTER TABLE user_profile ADD COLUMN hydrationBestStreak INTEGER NOT NULL DEFAULT 0;');
      await db.execute('ALTER TABLE user_profile ADD COLUMN lastHydrationCompletedDate TEXT;');
      await db.execute('ALTER TABLE user_profile ADD COLUMN hydrationXpAwardedDate TEXT;');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS notifications (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          body TEXT NOT NULL,
          category TEXT NOT NULL,
          type TEXT NOT NULL,
          timestamp INTEGER NOT NULL,
          xpReward INTEGER,
          streakDays INTEGER,
          motivationalQuote TEXT,
          isRead INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        avatarId TEXT NOT NULL,
        profileImagePath TEXT,
        level INTEGER NOT NULL,
        totalXP INTEGER NOT NULL,
        gold INTEGER NOT NULL,
        currentStreak INTEGER NOT NULL,
        bestStreak INTEGER NOT NULL,
        skills TEXT NOT NULL,
        email TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        hydrationCurrentStreak INTEGER NOT NULL DEFAULT 0,
        hydrationBestStreak INTEGER NOT NULL DEFAULT 0,
        lastHydrationCompletedDate TEXT,
        hydrationXpAwardedDate TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        xpReward INTEGER NOT NULL,
        isCompleted INTEGER NOT NULL,
        dueDate INTEGER NOT NULL,
        time TEXT,
        timeSpentSeconds INTEGER NOT NULL,
        durationMinutes INTEGER NOT NULL,
        remainingSeconds INTEGER NOT NULL,
        timerStatus TEXT NOT NULL,
        timerStartTimeEpoch INTEGER,
        isActive INTEGER NOT NULL DEFAULT 1,
        taskType TEXT NOT NULL DEFAULT "normal",
        waterGoalMl INTEGER NOT NULL DEFAULT 2000,
        currentWaterMl INTEGER NOT NULL DEFAULT 0,
        waterLogsJson TEXT NOT NULL DEFAULT "[]"
      )
    ''');

    await db.execute('''
      CREATE TABLE achievements (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        isUnlocked INTEGER NOT NULL,
        xpReward INTEGER NOT NULL DEFAULT 0,
        unlockRequirement TEXT NOT NULL DEFAULT "",
        iconPath TEXT,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        category TEXT NOT NULL,
        type TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        xpReward INTEGER,
        streakDays INTEGER,
        motivationalQuote TEXT,
        isRead INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // --- Profile CRUD ---
  Future<void> saveProfile(UserProfile profile) async {
    final db = await instance.database;
    final data = profile.toMapSql();
    data['id'] = 1; // Enforce single row
    
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM user_profile'));
    if (count == 0 || count == null) {
      await db.insert('user_profile', data);
    } else {
      await db.update('user_profile', data, where: 'id = 1');
    }
  }

  Future<UserProfile?> getProfile() async {
    final db = await instance.database;
    final maps = await db.query('user_profile', limit: 1);
    
    if (maps.isNotEmpty) {
      return UserProfile.fromMapSql(maps.first);
    }
    return null;
  }

  Future<List<UserProfile>> getAllProfiles() async {
    final db = await instance.database;
    final maps = await db.query('user_profile');
    return maps.map((map) => UserProfile.fromMapSql(map)).toList();
  }

  // --- Tasks CRUD ---
  Future<void> insertTask(RPGTask task) async {
    final db = await instance.database;
    await db.insert(
      'tasks',
      task.toMapSql(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTask(RPGTask task) async {
    final db = await instance.database;
    await db.update(
      'tasks',
      task.toMapSql(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> saveAllTasks(List<RPGTask> tasks) async {
    final db = await instance.database;
    Batch batch = db.batch();
    for (var task in tasks) {
      batch.insert(
        'tasks',
        task.toMapSql(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<RPGTask>> getAllTasks() async {
    final db = await instance.database;
    final result = await db.query('tasks');
    return result.map((json) => RPGTask.fromMapSql(json)).toList();
  }

  // --- Achievements CRUD ---
  Future<void> saveAllAchievements(List<Achievement> achievements) async {
    final db = await instance.database;
    Batch batch = db.batch();
    for (var a in achievements) {
      batch.insert(
        'achievements',
        {
          'id': a.id,
          'name': a.name,
          'description': a.description,
          'xpReward': a.xpReward,
          'unlockRequirement': a.unlockRequirement,
          'iconPath': a.iconPath,
          'isUnlocked': a.isUnlocked ? 1 : 0,
          'isActive': a.isActive ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Achievement>> getAllAchievements() async {
    final db = await instance.database;
    final result = await db.query('achievements');
    
    return result.map((json) {
      return Achievement(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        xpReward: json['xpReward'] as int? ?? 0,
        unlockRequirement: json['unlockRequirement'] as String? ?? '',
        iconPath: json['iconPath'] as String?,
        isUnlocked: (json['isUnlocked'] as int) == 1,
        isActive: json.containsKey('isActive') ? ((json['isActive'] as int) == 1) : true,
      );
    }).toList();
  }

  // --- Notifications CRUD ---
  Future<void> saveNotification(AppNotification notification) async {
    final db = await instance.database;
    await db.insert(
      'notifications',
      notification.toMapSql(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AppNotification>> getAllNotifications() async {
    final db = await instance.database;
    final result = await db.query('notifications', orderBy: 'timestamp DESC');
    return result.map((json) => AppNotification.fromMapSql(json)).toList();
  }

  Future<void> markNotificationAsRead(String id) async {
    final db = await instance.database;
    await db.update('notifications', {'isRead': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markAllNotificationsAsRead() async {
    final db = await instance.database;
    await db.update('notifications', {'isRead': 1});
  }

  Future<void> clearAllNotifications() async {
    final db = await instance.database;
    await db.delete('notifications');
  }
}
