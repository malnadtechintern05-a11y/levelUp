import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:real_life_rpg/models/models.dart';
import 'package:real_life_rpg/providers/admin_state.dart';
import 'package:real_life_rpg/providers/app_state.dart';
import 'package:real_life_rpg/providers/rankings_provider.dart';
import 'package:real_life_rpg/screens/quest_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({'is_logged_in': false});
  });

  group('RPGTask Generic Models & Helper Tests', () {
    test('Difficulty auto-inference works based on XP reward when null', () {
      final easyTask = RPGTask(
        id: 't_easy',
        title: 'Light Stretch',
        description: 'Stretch',
        category: 'Fitness',
        xpReward: 25,
        dueDate: DateTime.now(),
      );
      expect(easyTask.getEffectiveDifficulty(), 'Easy');

      final medTask = RPGTask(
        id: 't_med',
        title: 'Medium Study',
        description: 'Study',
        category: 'Study',
        xpReward: 60,
        dueDate: DateTime.now(),
      );
      expect(medTask.getEffectiveDifficulty(), 'Medium');

      final hardTask = RPGTask(
        id: 't_hard',
        title: 'Hard Code',
        description: 'Code',
        category: 'Coding',
        xpReward: 100,
        dueDate: DateTime.now(),
      );
      expect(hardTask.getEffectiveDifficulty(), 'Hard');

      final epicTask = RPGTask(
        id: 't_epic',
        title: 'Epic Project',
        description: 'Project',
        category: 'Work',
        xpReward: 140,
        dueDate: DateTime.now(),
      );
      expect(epicTask.getEffectiveDifficulty(), 'Epic');

      final legendaryTask = RPGTask(
        id: 't_legend',
        title: 'Marathon Run',
        description: 'Marathon',
        category: 'Fitness',
        xpReward: 200,
        dueDate: DateTime.now(),
      );
      expect(legendaryTask.getEffectiveDifficulty(), 'Legendary');
    });

    test('Effective coins reward defaults to half of XP', () {
      final task = RPGTask(
        id: 't1',
        title: 'Read Book',
        description: 'Pages',
        category: 'Reading',
        xpReward: 50,
        dueDate: DateTime.now(),
      );
      expect(task.getEffectiveCoinReward(), 25);
    });

    test('Category tailored default objectives generate dynamically', () {
      final readingTask = RPGTask(
        id: 't_read',
        title: 'Read 20 Pages',
        description: 'Book reading',
        category: 'Reading',
        xpReward: 40,
        dueDate: DateTime.now(),
      );
      final objs = readingTask.getEffectiveObjectives();
      expect(objs.isNotEmpty, true);
      expect(objs.length, 3);
      expect(objs.first.text.toLowerCase().contains('read'), true);
    });

    test('Category tailored tips generate dynamically', () {
      final codingTask = RPGTask(
        id: 't_code',
        title: 'Complete Login Screen',
        description: 'Coding',
        category: 'Coding',
        xpReward: 100,
        dueDate: DateTime.now(),
      );
      final tips = codingTask.getEffectiveTips();
      expect(tips.isNotEmpty, true);
      expect(tips.any((tip) => tip.toLowerCase().contains('code') || tip.toLowerCase().contains('functions')), true);
    });

    test('Category tailored proof recommendation generates correctly', () {
      final fitnessTask = RPGTask(
        id: 't_fit',
        title: 'Workout',
        description: 'Exercise',
        category: 'Fitness',
        xpReward: 70,
        dueDate: DateTime.now(),
      );
      expect(fitnessTask.getProofRecommendation().toLowerCase().contains('workout'), true);

      final cleaningTask = RPGTask(
        id: 't_clean',
        title: 'Clean Room',
        description: 'Cleaning',
        category: 'Cleaning',
        xpReward: 30,
        dueDate: DateTime.now(),
      );
      expect(cleaningTask.getProofRecommendation().toLowerCase().contains('clean'), true);
    });

    test('SQLite serialization toMapSql & fromMapSql roundtrip preserves generic quest fields', () {
      final task = RPGTask(
        id: 't_roundtrip',
        title: 'Draw for 30 Minutes',
        description: 'Daily artwork study',
        category: 'Creative',
        xpReward: 45,
        coinReward: 22,
        staminaReward: 10,
        difficulty: 'Medium',
        durationMinutes: 30,
        remainingSeconds: 1800,
        streak: 5,
        isHabit: true,
        personalNote: 'Completed portrait study today',
        dueDate: DateTime.now(),
      );
      task.getEffectiveObjectives();

      final sqlMap = task.toMapSql();
      final restored = RPGTask.fromMapSql(sqlMap);

      expect(restored.id, task.id);
      expect(restored.title, task.title);
      expect(restored.difficulty, 'Medium');
      expect(restored.coinReward, 22);
      expect(restored.staminaReward, 10);
      expect(restored.streak, 5);
      expect(restored.isHabit, true);
      expect(restored.personalNote, 'Completed portrait study today');
      expect(restored.objectives.length, task.objectives.length);
    });
  });

  group('QuestDetailsScreen Widget Tests', () {
    testWidgets('Renders Reading Quest with no time limit and category badge', (WidgetTester tester) async {
      final readingTask = RPGTask(
        id: 'test_reading',
        title: 'Read 20 Pages',
        description: 'Read 20 pages from an educational book.',
        category: 'Reading',
        xpReward: 40,
        difficulty: 'Easy',
        durationMinutes: 0,
        remainingSeconds: 0,
        dueDate: DateTime.now(),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppState()),
            ChangeNotifierProvider(create: (_) => AdminState()),
            ChangeNotifierProvider(create: (_) => RankingsProvider()),
          ],
          child: MaterialApp(
            home: QuestDetailsScreen(task: readingTask),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Quest Details'), findsOneWidget);
      expect(find.text('Read 20 Pages'), findsOneWidget);
      expect(find.text('Reading'), findsOneWidget);
      expect(find.text('+40 XP'), findsWidgets);
      expect(find.text('Easy'), findsOneWidget);
      expect(find.text('DESCRIPTION'), findsOneWidget);
      expect(find.text('📋 QUEST OBJECTIVES'), findsOneWidget);
      expect(find.text('QUEST PROGRESS'), findsOneWidget);
      expect(find.text('⏱ No time limit'), findsOneWidget);
      expect(find.text('Complete this quest at your own pace.'), findsOneWidget);
      expect(find.text('🏆 QUEST REWARDS'), findsOneWidget);
      expect(find.text('COMPLETE QUEST'), findsOneWidget);
    });

    testWidgets('Renders Timed Fitness Quest with timer card and controls', (WidgetTester tester) async {
      final fitnessTask = RPGTask(
        id: 'test_fitness',
        title: '30 Minute Workout',
        description: 'Full workout session.',
        category: 'Fitness',
        xpReward: 70,
        difficulty: 'Medium',
        durationMinutes: 30,
        remainingSeconds: 30 * 60,
        dueDate: DateTime.now(),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppState()),
            ChangeNotifierProvider(create: (_) => AdminState()),
            ChangeNotifierProvider(create: (_) => RankingsProvider()),
          ],
          child: MaterialApp(
            home: QuestDetailsScreen(task: fitnessTask),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('30 Minute Workout'), findsOneWidget);
      expect(find.text('Fitness'), findsOneWidget);
      expect(find.text('⏱ QUEST TIMER'), findsOneWidget);
      expect(find.text('START'), findsOneWidget);
      expect(find.text('RESET'), findsOneWidget);
    });

    testWidgets('Renders Habit Quest with Streak Card', (WidgetTester tester) async {
      final habitTask = RPGTask(
        id: 'test_habit',
        title: 'Wake Up Before 7 AM',
        description: 'Rise early and shine.',
        category: 'Habit',
        xpReward: 40,
        difficulty: 'Easy',
        streak: 7,
        isHabit: true,
        dueDate: DateTime.now(),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppState()),
            ChangeNotifierProvider(create: (_) => AdminState()),
            ChangeNotifierProvider(create: (_) => RankingsProvider()),
          ],
          child: MaterialApp(
            home: QuestDetailsScreen(task: habitTask),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Wake Up Before 7 AM'), findsOneWidget);
      expect(find.text('🔥 7 DAY STREAK'), findsOneWidget);
      expect(find.text("Complete today's quest to keep your streak alive."), findsOneWidget);
    });
  });
}
