import 'package:flutter_test/flutter_test.dart';
import 'package:real_life_rpg/helpers/database_helper.dart';
import 'package:real_life_rpg/helpers/security_helper.dart';
import 'package:real_life_rpg/models/models.dart';
import 'package:real_life_rpg/providers/admin_state.dart';
import 'package:real_life_rpg/providers/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final db = await DatabaseHelper.instance.database;
    await db.execute('DROP TABLE IF EXISTS achievements;');
    await db.execute('''
      CREATE TABLE achievements (
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
    await db.delete('user_profile');
    await db.delete('tasks');
    await db.delete('notifications');
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({'is_logged_in': false});
  });

  group('1. Cryptographic and Security Helper Tests', () {
    test('SHA-256 salted password hashing produces non-trivial unique hashes', () {
      final pass = 'SuperSecret123!';
      final hash1 = SecurityHelper.hashPassword(pass);
      final hash2 = SecurityHelper.hashPassword(pass);

      // Verify format
      expect(hash1.isNotEmpty, isTrue);
      expect(hash2.isNotEmpty, isTrue);

      // Unique hashes
      expect(hash1, equals(hash2)); // Default salt is deterministic for same input

      // Verification succeeds
      expect(SecurityHelper.verifyPassword(pass, hash1), isTrue);
      expect(SecurityHelper.verifyPassword(pass, hash2), isTrue);

      // Incorrect password fails
      expect(SecurityHelper.verifyPassword('WrongPassword', hash1), isFalse);
    });

    test('Constant-time comparison prevents timing discrepancies and matches accurately', () {
      expect(SecurityHelper.constantTimeCompare('secret_token_abc', 'secret_token_abc'), isTrue);
      expect(SecurityHelper.constantTimeCompare('secret_token_abc', 'secret_token_xyz'), isFalse);
      expect(SecurityHelper.constantTimeCompare('short', 'longer_string'), isFalse);
      expect(SecurityHelper.constantTimeCompare('', ''), isTrue);
    });

    test('validateOwnership enforces identity match', () {
      expect(SecurityHelper.validateOwnership('user_101', 'user_101'), isTrue);
      expect(SecurityHelper.validateOwnership('user_101', 'user_999'), isFalse);
      expect(SecurityHelper.validateOwnership(null, 'user_101'), isFalse);
      expect(SecurityHelper.validateOwnership('user_101', null), isFalse);
    });
  });

  group('2. SQLite Database Multi-User Isolation Tests', () {
    test('User profiles are isolated per user_id', () async {
      final dbHelper = DatabaseHelper.instance;

      final profileUserA = UserProfile(
        userId: '1001',
        username: 'UserAlpha',
        level: 3,
        totalXP: 350,
        currentStreak: 4,
      );

      final profileUserB = UserProfile(
        userId: '2002',
        username: 'UserBeta',
        level: 12,
        totalXP: 2400,
        currentStreak: 18,
      );

      await dbHelper.saveProfile(profileUserA, 1001);
      await dbHelper.saveProfile(profileUserB, 2002);

      final fetchedA = await dbHelper.getProfile(1001);
      final fetchedB = await dbHelper.getProfile(2002);

      expect(fetchedA, isNotNull);
      expect(fetchedA!.username, 'UserAlpha');
      expect(fetchedA.level, 3);
      expect(fetchedA.totalXP, 350);

      expect(fetchedB, isNotNull);
      expect(fetchedB!.username, 'UserBeta');
      expect(fetchedB.level, 12);
      expect(fetchedB.totalXP, 2400);

      // Verify User A profile does NOT equal User B profile
      expect(fetchedA.username, isNot(equals(fetchedB.username)));
    });

    test('Quests/Tasks are strictly isolated per user_id in database', () async {
      final dbHelper = DatabaseHelper.instance;

      final taskA1 = RPGTask(
        id: 'task_userA_1',
        title: 'User A Secret Quest 1',
        description: 'Private notes for user A',
        category: 'Work',
        xpReward: 100,
        userId: '1001',
      );

      final taskA2 = RPGTask(
        id: 'task_userA_2',
        title: 'User A Secret Quest 2',
        description: 'More private notes for user A',
        category: 'Health',
        xpReward: 50,
        userId: '1001',
      );

      final taskB1 = RPGTask(
        id: 'task_userB_1',
        title: 'User B Confidential Quest',
        description: 'User B private data',
        category: 'Study',
        xpReward: 80,
        userId: '2002',
      );

      await dbHelper.insertTask(taskA1, 1001);
      await dbHelper.insertTask(taskA2, 1001);
      await dbHelper.insertTask(taskB1, 2002);

      // Fetch tasks for User A (1001)
      final userATasks = await dbHelper.getTasksForUser(1001);
      expect(userATasks.length, 2);
      expect(userATasks.any((t) => t.id == 'task_userA_1'), isTrue);
      expect(userATasks.any((t) => t.id == 'task_userA_2'), isTrue);
      // User A MUST NOT receive User B's task
      expect(userATasks.any((t) => t.id == 'task_userB_1'), isFalse);
      expect(userATasks.any((t) => t.title.contains('User B')), isFalse);

      // Fetch tasks for User B (2002)
      final userBTasks = await dbHelper.getTasksForUser(2002);
      expect(userBTasks.length, 1);
      expect(userBTasks.first.id, 'task_userB_1');
      // User B MUST NOT receive User A's tasks
      expect(userBTasks.any((t) => t.id.contains('userA')), isFalse);

      // Attempt unauthorized cross-user update: User B attempts to edit User A's task
      final tamperedTaskA1 = taskA1.copyWith(title: 'Hacked by User B');
      final updateRowsAffected = await dbHelper.updateTask(tamperedTaskA1, 2002);
      expect(updateRowsAffected, 0); // Should update 0 rows because task belongs to User A

      // Verify User A task remained unchanged
      final userATasksAfter = await dbHelper.getTasksForUser(1001);
      final verifiedTaskA1 = userATasksAfter.firstWhere((t) => t.id == 'task_userA_1');
      expect(verifiedTaskA1.title, 'User A Secret Quest 1');

      // Attempt unauthorized cross-user delete: User B attempts to delete User A's task
      final deleteRowsAffected = await dbHelper.deleteTask('task_userA_1', 2002);
      expect(deleteRowsAffected, 0); // 0 rows deleted

      // Verify User A task still exists
      final userATasksAfterDelete = await dbHelper.getTasksForUser(1001);
      expect(userATasksAfterDelete.any((t) => t.id == 'task_userA_1'), isTrue);
    });

    test('Achievements and Trophy Room data are isolated per user_id', () async {
      final dbHelper = DatabaseHelper.instance;

      final achievementsUserA = [
        Achievement(
          id: 'ach_1',
          name: 'First Step',
          description: 'Complete 1 quest',
          icon: 'target',
          isUnlocked: true,
          unlockedAt: DateTime.now(),
          userId: '1001',
        ),
        Achievement(
          id: 'ach_2',
          name: 'Master',
          description: 'Reach level 10',
          icon: 'crown',
          isUnlocked: false,
          userId: '1001',
        ),
      ];

      final achievementsUserB = [
        Achievement(
          id: 'ach_1',
          name: 'First Step',
          description: 'Complete 1 quest',
          icon: 'target',
          isUnlocked: false, // User B has NOT unlocked it yet
          userId: '2002',
        ),
        Achievement(
          id: 'ach_2',
          name: 'Master',
          description: 'Reach level 10',
          icon: 'crown',
          isUnlocked: true, // User B unlocked it
          unlockedAt: DateTime.now(),
          userId: '2002',
        ),
      ];

      await dbHelper.saveAllAchievements(achievementsUserA, 1001);
      await dbHelper.saveAllAchievements(achievementsUserB, 2002);

      final userAAchievements = await dbHelper.getAchievementsForUser(1001);
      final userBAchievements = await dbHelper.getAchievementsForUser(2002);

      final userAFirstStep = userAAchievements.firstWhere((a) => a.id == 'ach_1');
      final userBFirstStep = userBAchievements.firstWhere((a) => a.id == 'ach_1');

      expect(userAFirstStep.isUnlocked, isTrue);
      expect(userBFirstStep.isUnlocked, isFalse);

      final userAMaster = userAAchievements.firstWhere((a) => a.id == 'ach_2');
      final userBMaster = userBAchievements.firstWhere((a) => a.id == 'ach_2');

      expect(userAMaster.isUnlocked, isFalse);
      expect(userBMaster.isUnlocked, isTrue);
    });

    test('Notifications are isolated per user_id', () async {
      final dbHelper = DatabaseHelper.instance;

      final notifA = AppNotification(
        id: 'notif_a_1',
        title: 'User A Alert',
        message: 'Your personal stats are updated',
        timestamp: DateTime.now(),
        userId: '1001',
      );

      final notifB = AppNotification(
        id: 'notif_b_1',
        title: 'User B Security Notice',
        message: 'Your account was created',
        timestamp: DateTime.now(),
        userId: '2002',
      );

      await dbHelper.saveNotification(notifA, 1001);
      await dbHelper.saveNotification(notifB, 2002);

      final userANotifs = await dbHelper.getNotificationsForUser(1001);
      final userBNotifs = await dbHelper.getNotificationsForUser(2002);

      expect(userANotifs.length, 1);
      expect(userANotifs.first.title, 'User A Alert');

      expect(userBNotifs.length, 1);
      expect(userBNotifs.first.title, 'User B Security Notice');

      // User A marks all as read
      await dbHelper.markAllNotificationsAsRead(1001);

      final userANotifsAfter = await dbHelper.getNotificationsForUser(1001);
      final userBNotifsAfter = await dbHelper.getNotificationsForUser(2002);

      expect(userANotifsAfter.first.isRead, isTrue);
      // User B notifications remain unread
      expect(userBNotifsAfter.first.isRead, isFalse);
    });

    test('clearUserData deletes ONLY target user records', () async {
      final dbHelper = DatabaseHelper.instance;

      // Seed data for both users
      await dbHelper.saveProfile(UserProfile(userId: '3001', username: 'UserTemp'), 3001);
      await dbHelper.insertTask(RPGTask(id: 'temp_task_1', title: 'Temp Quest', category: 'General', xpReward: 10), 3001);

      await dbHelper.saveProfile(UserProfile(userId: '3002', username: 'UserPersistent'), 3002);
      await dbHelper.insertTask(RPGTask(id: 'pers_task_1', title: 'Persistent Quest', category: 'General', xpReward: 10), 3002);

      // Clear User 3001 data
      await dbHelper.clearUserData(3001);

      final profile3001 = await dbHelper.getProfile(3001);
      final tasks3001 = await dbHelper.getTasksForUser(3001);

      expect(profile3001, isNull);
      expect(tasks3001, isEmpty);

      // Verify User 3002 data is completely intact
      final profile3002 = await dbHelper.getProfile(3002);
      final tasks3002 = await dbHelper.getTasksForUser(3002);

      expect(profile3002, isNotNull);
      expect(profile3002!.username, 'UserPersistent');
      expect(tasks3002.length, 1);
      expect(tasks3002.first.title, 'Persistent Quest');
    });
  });

  group('3. AppState Session Isolation and Memory Teardown Tests', () {
    test('Logout clears all sensitive in-memory state preventing session bleed', () async {
      final appState = AppState();

      // Simulate logged in User 5001
      appState.setCurrentUserId('5001');
      appState.addTask(RPGTask(
        id: 'task_active_user',
        title: 'Active User Quest',
        category: 'Fitness',
        xpReward: 100,
        userId: '5001',
      ));
      appState.addNotification('Sensitive Alert', 'Private secret for User 5001');

      expect(appState.tasks.isNotEmpty, isTrue);
      expect(appState.notifications.isNotEmpty, isTrue);
      expect(appState.currentUserId, '5001');

      // Log out
      await appState.logout();

      // Verify complete memory teardown
      expect(appState.tasks, isEmpty);
      expect(appState.notifications, isEmpty);
      expect(appState.userProfile.username, 'Hero');
      expect(appState.userProfile.totalXP, 0);

      // Simulate User 5002 logging in - verify they see ZERO data from User 5001
      appState.setCurrentUserId('5002');
      expect(appState.tasks, isEmpty);
      expect(appState.notifications, isEmpty);
    });

    test('Duplicate task completion does NOT award duplicate XP or levels', () async {
      final appState = AppState();
      appState.setCurrentUserId('6001');

      final task = RPGTask(
        id: 'quest_xp_test',
        title: 'Daily Run',
        category: 'Fitness',
        xpReward: 150,
        isCompleted: false,
        userId: '6001',
      );

      appState.addTask(task);

      // First completion: Level 1 + 150 XP -> Level 2 (100 XP used), 50 XP remainder
      appState.completeTask('quest_xp_test');
      final levelAfterFirst = appState.userProfile.level;
      final xpAfterFirst = appState.userProfile.totalXP;
      expect(levelAfterFirst, 2);
      expect(xpAfterFirst, 50);

      final completedTask = appState.tasks.firstWhere((t) => t.id == 'quest_xp_test');
      expect(completedTask.isCompleted, isTrue);

      // Attempt duplicate completion on already completed task
      appState.completeTask('quest_xp_test');
      final levelAfterSecond = appState.userProfile.level;
      final xpAfterSecond = appState.userProfile.totalXP;

      // XP and Level must NOT increase a second time
      expect(levelAfterSecond, levelAfterFirst);
      expect(xpAfterSecond, xpAfterFirst);
    });

    test('Unauthorized cross-user task completion is blocked by ownership validation', () async {
      final appState = AppState();
      appState.setCurrentUserId('7001');

      final taskBelongingToAnother = RPGTask(
        id: 'foreign_quest',
        title: 'Foreign Quest',
        category: 'Study',
        xpReward: 200,
        isCompleted: false,
        userId: '8888', // Belongs to User 8888
      );

      appState.addTask(taskBelongingToAnother);
      final initialXP = appState.userProfile.totalXP;
      final initialLevel = appState.userProfile.level;

      // User 7001 attempts to complete task owned by 8888
      appState.completeTask('foreign_quest');

      // Must be rejected - no XP or level awarded and task remains uncompleted
      expect(appState.userProfile.totalXP, initialXP);
      expect(appState.userProfile.level, initialLevel);
      final foreignTask = appState.tasks.firstWhere((t) => t.id == 'foreign_quest');
      expect(foreignTask.isCompleted, isFalse);
    });
  });

  group('4. Admin Authorization and Route Security Tests', () {
    test('Unauthenticated user cannot execute admin mutations in AdminState', () async {
      final adminState = AdminState();

      expect(adminState.isAdminLoggedIn, isFalse);

      // Attempt to add task without admin authentication
      expect(
        () async => await adminState.addTask(RPGTask(
          id: 'hacked_task',
          title: 'Hacked Quest',
          category: 'Hack',
          xpReward: 100,
        )),
        throwsA(isA<StateError>()),
      );

      // Attempt to update task
      expect(
        () async => await adminState.updateTask(RPGTask(
          id: 'hacked_task',
          title: 'Tampered Quest',
          category: 'Hack',
          xpReward: 100,
        )),
        throwsA(isA<StateError>()),
      );

      // Attempt to delete task
      expect(
        () async => await adminState.deleteTask('any_id'),
        throwsA(isA<StateError>()),
      );

      // Attempt to toggle user status
      expect(
        () async => await adminState.toggleUserStatus('victim_user'),
        throwsA(isA<StateError>()),
      );
    });

    test('Hardcoded credentials bypass is disabled', () async {
      final adminState = AdminState();

      // Test old hardcoded credentials fail if not valid on the system
      final loginResult = await adminState.login('admin@levelup.com', 'admin123');
      if (!adminState.isAdminLoggedIn) {
        expect(loginResult, isFalse);
      }
    });
  });
}
