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
      version: 1,
      onCreate: _createDB,
    );
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
        skills TEXT NOT NULL
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
        timerStartTimeEpoch INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE achievements (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        isUnlocked INTEGER NOT NULL
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
          'isUnlocked': a.isUnlocked ? 1 : 0,
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
        isUnlocked: (json['isUnlocked'] as int) == 1,
      );
    }).toList();
  }
}
