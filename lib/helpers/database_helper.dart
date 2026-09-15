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
      version: 6,
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
    if (oldVersion < 5) {
      try {
        await db.execute('ALTER TABLE tasks ADD COLUMN extraDataJson TEXT NOT NULL DEFAULT "{}";');
      } catch (_) {}
    }
    if (oldVersion < 6) {
      // Version 6: Complete User Data Isolation schema additions
      try {
        await db.execute('ALTER TABLE user_profile ADD COLUMN user_id TEXT;');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE tasks ADD COLUMN user_id TEXT;');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE notifications ADD COLUMN user_id TEXT;');
      } catch (_) {}

      // Recreate achievements with composite primary key (id, user_id)
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS achievements_new (
            id TEXT NOT NULL,
            user_id TEXT NOT NULL,
            name TEXT NOT NULL,
            description TEXT NOT NULL,
            isUnlocked INTEGER NOT NULL,
            xpReward INTEGER NOT NULL DEFAULT 0,
            unlockRequirement TEXT NOT NULL DEFAULT '',
            iconPath TEXT,
            isActive INTEGER NOT NULL DEFAULT 1,
            PRIMARY KEY (id, user_id)
          )
        ''');
        await db.execute('''
          INSERT OR IGNORE INTO achievements_new (id, user_id, name, description, isUnlocked, xpReward, unlockRequirement, iconPath, isActive)
          SELECT id, 'hero', name, description, isUnlocked, COALESCE(xpReward, 0), COALESCE(unlockRequirement, ''), iconPath, COALESCE(isActive, 1)
          FROM achievements
        ''');
        await db.execute('DROP TABLE achievements;');
        await db.execute('ALTER TABLE achievements_new RENAME TO achievements;');
      } catch (_) {}

      try {
        await db.execute('CREATE INDEX IF NOT EXISTS idx_user_profile_user_id ON user_profile (user_id);');
      } catch (_) {}
      try {
        await db.execute('CREATE INDEX IF NOT EXISTS idx_tasks_user_id ON tasks (user_id);');
      } catch (_) {}
      try {
        await db.execute('CREATE INDEX IF NOT EXISTS idx_achievements_user_id ON achievements (user_id);');
      } catch (_) {}
      try {
        await db.execute('CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications (user_id);');
      } catch (_) {}

      // Backfill default user_id if null on existing records
      try {
        await db.execute("UPDATE user_profile SET user_id = LOWER(username) WHERE user_id IS NULL OR user_id = '';");
      } catch (_) {}
      try {
        await db.execute("UPDATE tasks SET user_id = 'hero' WHERE user_id IS NULL OR user_id = '';");
      } catch (_) {}
      try {
        await db.execute("UPDATE achievements SET user_id = 'hero' WHERE user_id IS NULL OR user_id = '';");
      } catch (_) {}
      try {
        await db.execute("UPDATE notifications SET user_id = 'hero' WHERE user_id IS NULL OR user_id = '';");
      } catch (_) {}
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL UNIQUE,
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
        user_id TEXT NOT NULL,
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
        waterLogsJson TEXT NOT NULL DEFAULT "[]",
        extraDataJson TEXT NOT NULL DEFAULT "{}"
      )
    ''');

    await db.execute('''
      CREATE TABLE achievements (
        id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        isUnlocked INTEGER NOT NULL,
        xpReward INTEGER NOT NULL DEFAULT 0,
        unlockRequirement TEXT NOT NULL DEFAULT "",
        iconPath TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        PRIMARY KEY (id, user_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
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

    await db.execute('CREATE INDEX IF NOT EXISTS idx_user_profile_user_id ON user_profile (user_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_tasks_user_id ON tasks (user_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_achievements_user_id ON achievements (user_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications (user_id);');
  }

  // --- Profile CRUD with User ID Isolation ---
  Future<void> saveProfile(UserProfile profile, [dynamic userId]) async {
    final db = await instance.database;
    final uStr = userId?.toString();
    final effectiveUserId = (uStr ?? profile.userId ?? profile.username).trim().toLowerCase();
    final data = profile.toMapSql(effectiveUserId);
    
    final existing = await db.query(
      'user_profile',
      where: 'user_id = ? OR LOWER(username) = ?',
      whereArgs: [effectiveUserId, profile.username.toLowerCase()],
      limit: 1,
    );
    
    if (existing.isEmpty) {
      await db.insert('user_profile', data, conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await db.update(
        'user_profile',
        data,
        where: 'user_id = ? OR id = ?',
        whereArgs: [effectiveUserId, existing.first['id']],
      );
    }
  }

  Future<UserProfile?> getProfile([dynamic userId]) async {
    final db = await instance.database;
    final uStr = userId?.toString();
    List<Map<String, dynamic>> maps;
    if (uStr != null && uStr.trim().isNotEmpty) {
      final cleanId = uStr.trim().toLowerCase();
      maps = await db.query(
        'user_profile',
        where: 'user_id = ? OR LOWER(username) = ?',
        whereArgs: [cleanId, cleanId],
        limit: 1,
      );
    } else {
      maps = await db.query('user_profile', limit: 1);
    }
    
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

  // --- Tasks CRUD with User ID Scoping ---
  Future<void> insertTask(RPGTask task, [dynamic userId]) async {
    final db = await instance.database;
    final uStr = userId?.toString();
    final effectiveUserId = (uStr ?? task.userId ?? task.username ?? 'hero').trim().toLowerCase();
    await db.insert(
      'tasks',
      task.toMapSql(effectiveUserId),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateTask(RPGTask task, [dynamic userId]) async {
    final db = await instance.database;
    final uStr = userId?.toString() ?? task.userId;
    if (uStr != null && uStr.trim().isNotEmpty) {
      return await db.update(
        'tasks',
        task.toMapSql(uStr.trim().toLowerCase()),
        where: 'id = ? AND (user_id = ? OR user_id IS NULL)',
        whereArgs: [task.id, uStr.trim().toLowerCase()],
      );
    } else {
      return await db.update(
        'tasks',
        task.toMapSql(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
    }
  }

  Future<int> deleteTask(String taskId, [dynamic userId]) async {
    final db = await instance.database;
    final uStr = userId?.toString();
    if (uStr != null && uStr.trim().isNotEmpty) {
      return await db.delete(
        'tasks',
        where: 'id = ? AND user_id = ?',
        whereArgs: [taskId, uStr.trim().toLowerCase()],
      );
    } else {
      return await db.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: [taskId],
      );
    }
  }

  Future<void> saveAllTasks(List<RPGTask> tasks, [dynamic userId]) async {
    final db = await instance.database;
    final uStr = userId?.toString();
    Batch batch = db.batch();
    for (var task in tasks) {
      final effectiveUserId = (uStr ?? task.userId ?? task.username ?? 'hero').trim().toLowerCase();
      batch.insert(
        'tasks',
        task.toMapSql(effectiveUserId),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<RPGTask>> getTasksForUser(dynamic userId) async {
    final db = await instance.database;
    final cleanId = userId.toString().trim().toLowerCase();
    final result = await db.query(
      'tasks',
      where: 'user_id = ?',
      whereArgs: [cleanId],
    );
    return result.map((json) => RPGTask.fromMapSql(json)).toList();
  }

  Future<List<RPGTask>> getAllTasks([dynamic userId]) async {
    final uStr = userId?.toString();
    if (uStr != null && uStr.trim().isNotEmpty) {
      return getTasksForUser(uStr);
    }
    final db = await instance.database;
    final result = await db.query('tasks');
    return result.map((json) => RPGTask.fromMapSql(json)).toList();
  }

  // --- Achievements CRUD with User ID Scoping ---
  Future<void> saveAllAchievements(List<Achievement> achievements, [dynamic userId]) async {
    final db = await instance.database;
    final uStr = userId?.toString();
    Batch batch = db.batch();
    for (var a in achievements) {
      final effectiveUserId = (uStr ?? a.userId ?? 'hero').trim().toLowerCase();
      batch.insert(
        'achievements',
        {
          'id': a.id,
          'user_id': effectiveUserId,
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

  Future<List<Achievement>> getAchievementsForUser(dynamic userId) async {
    final db = await instance.database;
    final cleanId = userId.toString().trim().toLowerCase();
    final result = await db.query(
      'achievements',
      where: 'user_id = ?',
      whereArgs: [cleanId],
    );
    
    return result.map((json) {
      return Achievement(
        id: json['id'] as String,
        userId: json['user_id'] as String?,
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

  Future<List<Achievement>> getAllAchievements([dynamic userId]) async {
    final uStr = userId?.toString();
    if (uStr != null && uStr.trim().isNotEmpty) {
      return getAchievementsForUser(uStr);
    }
    final db = await instance.database;
    final result = await db.query('achievements');
    
    return result.map((json) {
      return Achievement(
        id: json['id'] as String,
        userId: json['user_id'] as String?,
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

  // --- Notifications CRUD with User ID Scoping ---
  Future<void> saveNotification(AppNotification notification, [dynamic userId]) async {
    final db = await instance.database;
    final uStr = userId?.toString();
    final effectiveUserId = (uStr ?? notification.userId ?? 'hero').trim().toLowerCase();
    await db.insert(
      'notifications',
      notification.toMapSql(effectiveUserId),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AppNotification>> getNotificationsForUser(dynamic userId) async {
    final db = await instance.database;
    final cleanId = userId.toString().trim().toLowerCase();
    final result = await db.query(
      'notifications',
      where: 'user_id = ?',
      whereArgs: [cleanId],
      orderBy: 'timestamp DESC',
    );
    return result.map((json) => AppNotification.fromMapSql(json)).toList();
  }

  Future<List<AppNotification>> getAllNotifications([dynamic userId]) async {
    final uStr = userId?.toString();
    if (uStr != null && uStr.trim().isNotEmpty) {
      return getNotificationsForUser(uStr);
    }
    final db = await instance.database;
    final result = await db.query('notifications', orderBy: 'timestamp DESC');
    return result.map((json) => AppNotification.fromMapSql(json)).toList();
  }

  Future<void> markNotificationAsRead(String id, [dynamic userId]) async {
    final db = await instance.database;
    final uStr = userId?.toString();
    if (uStr != null && uStr.trim().isNotEmpty) {
      await db.update(
        'notifications',
        {'isRead': 1},
        where: 'id = ? AND user_id = ?',
        whereArgs: [id, uStr.trim().toLowerCase()],
      );
    } else {
      await db.update('notifications', {'isRead': 1}, where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<void> markAllNotificationsAsRead([dynamic userId]) async {
    final db = await instance.database;
    final uStr = userId?.toString();
    if (uStr != null && uStr.trim().isNotEmpty) {
      await db.update(
        'notifications',
        {'isRead': 1},
        where: 'user_id = ?',
        whereArgs: [uStr.trim().toLowerCase()],
      );
    } else {
      await db.update('notifications', {'isRead': 1});
    }
  }

  Future<void> clearAllNotifications([dynamic userId]) async {
    final db = await instance.database;
    final uStr = userId?.toString();
    if (uStr != null && uStr.trim().isNotEmpty) {
      await db.delete(
        'notifications',
        where: 'user_id = ?',
        whereArgs: [uStr.trim().toLowerCase()],
      );
    } else {
      await db.delete('notifications');
    }
  }

  Future<void> clearUserData(dynamic userId) async {
    final db = await instance.database;
    final cleanId = userId.toString().trim().toLowerCase();
    await db.delete('tasks', where: 'user_id = ?', whereArgs: [cleanId]);
    await db.delete('achievements', where: 'user_id = ?', whereArgs: [cleanId]);
    await db.delete('notifications', where: 'user_id = ?', whereArgs: [cleanId]);
    await db.delete('user_profile', where: 'user_id = ?', whereArgs: [cleanId]);
  }
}
