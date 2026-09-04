import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:real_life_rpg/models/models.dart';
import 'package:real_life_rpg/providers/admin_state.dart';
import 'package:real_life_rpg/providers/app_state.dart';
import 'package:real_life_rpg/providers/rankings_provider.dart';
import 'package:real_life_rpg/screens/hydration_details_screen.dart';
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

  group('HydrationReminder Model Tests', () {
    test('HydrationReminder serializes and deserializes correctly', () {
      final reminder = HydrationReminder(
        id: 'r_test_1',
        time: '09:30 AM',
        hour: 9,
        minute: 30,
        amountMl: 250,
        isEnabled: true,
        isCompleted: false,
      );

      final map = reminder.toMap();
      final restored = HydrationReminder.fromMap(map);

      expect(restored.id, 'r_test_1');
      expect(restored.time, '09:30 AM');
      expect(restored.hour, 9);
      expect(restored.minute, 30);
      expect(restored.amountMl, 250);
      expect(restored.isEnabled, isTrue);
      expect(restored.isCompleted, isFalse);
    });

    test('HydrationReminder isMissed correctly detects past reminders', () {
      final pastReminder = HydrationReminder(
        id: 'r_past',
        time: '00:01 AM',
        hour: 0,
        minute: 1,
        amountMl: 250,
        isEnabled: true,
        isCompleted: false,
      );

      final now = DateTime.now();
      if (now.hour > 0 || now.minute > 5) {
        expect(pastReminder.isMissed(), isTrue);
      }

      // Completed reminder is never considered missed
      final completedPast = pastReminder.copyWith(isCompleted: true);
      expect(completedPast.isMissed(), isFalse);

      // Disabled reminder is never considered missed
      final disabledPast = pastReminder.copyWith(isEnabled: false);
      expect(disabledPast.isMissed(), isFalse);
    });
  });

  group('RPGTask Hydration Schedule Helpers Tests', () {
    test('getNextReminder and getMissedReminders return appropriate items', () {
      final task = RPGTask(
        id: 't_hydro',
        title: 'Daily Water Goal',
        description: 'Drink water',
        category: 'Health',
        xpReward: 50,
        taskType: 'hydration',
        dueDate: DateTime.now(),
        waterGoalMl: 2500,
        currentWaterMl: 500,
        drinkAmountMl: 250,
        reminders: [
          HydrationReminder(id: 'r1', time: '00:05 AM', hour: 0, minute: 5, amountMl: 250, isEnabled: true, isCompleted: true),
          HydrationReminder(id: 'r2', time: '00:10 AM', hour: 0, minute: 10, amountMl: 250, isEnabled: true, isCompleted: false),
          HydrationReminder(id: 'r3', time: '11:55 PM', hour: 23, minute: 55, amountMl: 250, isEnabled: true, isCompleted: false),
        ],
      );

      final missed = task.getMissedReminders();
      final now = DateTime.now();
      if (now.hour > 0 || now.minute > 15) {
        expect(missed.any((r) => r.id == 'r2'), isTrue);
      }

      final next = task.getNextReminder();
      expect(next, isNotNull);
      expect(next!.isCompleted, isFalse);
    });

    test('SQLite serialization preserves hydration extra data', () {
      final task = RPGTask(
        id: 't_hydro_db',
        title: 'Hydration Quest',
        description: 'Drink water',
        category: 'Health',
        xpReward: 50,
        taskType: 'hydration',
        dueDate: DateTime.now(),
        waterGoalMl: 3000,
        currentWaterMl: 1200,
        drinkAmountMl: 300,
        reminderIntervalMinutes: 90,
        notificationsEnabled: false,
        reminders: [
          HydrationReminder(id: 'r_db_1', time: '08:00 AM', hour: 8, minute: 0, amountMl: 300),
          HydrationReminder(id: 'r_db_2', time: '10:00 AM', hour: 10, minute: 0, amountMl: 300),
        ],
      );

      final sqlMap = task.toMapSql();
      expect(sqlMap.containsKey('extraDataJson'), isTrue);

      final restored = RPGTask.fromMapSql(sqlMap);
      expect(restored.waterGoalMl, 3000);
      expect(restored.currentWaterMl, 1200);
      expect(restored.drinkAmountMl, 300);
      expect(restored.reminderIntervalMinutes, 90);
      expect(restored.notificationsEnabled, isFalse);
      expect(restored.reminders.length, 2);
      expect(restored.reminders[0].time, '08:00 AM');
      expect(restored.reminders[1].amountMl, 300);
    });
  });

  group('AppState Hydration Operations Tests', () {
    test('createDefaultDrinkingSchedule creates expected schedule items', () {
      final state = AppState();
      final schedule = state.createDefaultDrinkingSchedule(drinkAmountMl: 300);

      expect(schedule.isNotEmpty, isTrue);
      expect(schedule.length, 7);
      expect(schedule[0].time, '08:00 AM');
      expect(schedule[0].amountMl, 300);
      expect(schedule[1].time, '10:00 AM');
    });

    test('addWater completes nearest reminder and updates progress', () async {
      final state = AppState();

      final hydrationTask = RPGTask(
        id: 't_mock_hydro_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Daily Water Goal',
        description: 'Stay hydrated',
        category: 'Health',
        xpReward: 50,
        taskType: 'hydration',
        dueDate: DateTime.now(),
        waterGoalMl: 2000,
        currentWaterMl: 0,
        drinkAmountMl: 250,
        reminders: [
          HydrationReminder(id: 'r_now_1', time: '08:00 AM', hour: 8, minute: 0, amountMl: 250, isCompleted: false),
          HydrationReminder(id: 'r_now_2', time: '10:00 AM', hour: 10, minute: 0, amountMl: 250, isCompleted: false),
        ],
      );

      state.addTask(hydrationTask);

      final initialWater = state.tasks.firstWhere((t) => t.id == hydrationTask.id).currentWaterMl;
      state.addWater(hydrationTask.id, 250);

      final updatedTask = state.tasks.firstWhere((t) => t.id == hydrationTask.id);
      expect(updatedTask.currentWaterMl, initialWater + 250);
      expect(updatedTask.waterLogs.isNotEmpty, isTrue);
    });

    test('getHydrationStats returns valid summary figures', () {
      final state = AppState();
      final task = RPGTask(
        id: 't_stats',
        title: 'Water',
        description: 'Drink',
        category: 'Health',
        xpReward: 50,
        dueDate: DateTime.now(),
        taskType: 'hydration',
        waterGoalMl: 2500,
        currentWaterMl: 1500,
      );

      final stats = state.getHydrationStats(task);
      expect(stats.containsKey('todayConsumedMl'), isTrue);
      expect(stats.containsKey('todayGoalMl'), isTrue);
      expect(stats.containsKey('todayConsumedL'), isTrue);
      expect(stats.containsKey('todayGoalL'), isTrue);
      expect(stats.containsKey('weeklyAverageL'), isTrue);
      expect(stats.containsKey('goalCompletedDays'), isTrue);
      expect(stats.containsKey('streak'), isTrue);
      expect(stats['todayConsumedL'], '1.5');
      expect(stats['todayGoalL'], '2.5');
    });
  });

  group('Quest Routing Widget Tests', () {
    Widget createTestApp(RPGTask task) {
      final appState = AppState();
      final adminState = AdminState();
      final rankings = RankingsProvider();

      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: appState),
          ChangeNotifierProvider.value(value: adminState),
          ChangeNotifierProvider.value(value: rankings),
        ],
        child: MaterialApp(
          home: QuestDetailsScreen(task: task),
        ),
      );
    }

    testWidgets('Hydration quest redirects to HydrationDetailsScreen', (tester) async {
      final appState = AppState();
      final adminState = AdminState();
      final rankings = RankingsProvider();

      final hydroTask = RPGTask(
        id: 't_hydro_route',
        title: 'Daily Water Goal',
        description: 'Drink plenty of water',
        category: 'Health',
        xpReward: 50,
        taskType: 'hydration',
        dueDate: DateTime.now(),
        waterGoalMl: 2500,
        currentWaterMl: 1500,
        drinkAmountMl: 250,
        reminders: [
          HydrationReminder(id: 'r_route_1', time: '09:00 AM', hour: 9, minute: 0, amountMl: 250),
        ],
      );

      appState.addTask(hydroTask);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: appState),
            ChangeNotifierProvider.value(value: adminState),
            ChangeNotifierProvider.value(value: rankings),
          ],
          child: MaterialApp(
            home: QuestDetailsScreen(task: hydroTask),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Hydration details screen should be rendered
      expect(find.byType(HydrationDetailsScreen), findsOneWidget);
      expect(find.text('Hydration Quest'), findsOneWidget);
      expect(find.text('💧 Health / Hydration'), findsOneWidget);
      expect(find.text('Daily Water Goal'), findsWidgets);
    });
  });
}
