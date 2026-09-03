import 'package:flutter_test/flutter_test.dart';
import 'package:real_life_rpg/config/api_config.dart';
import 'package:real_life_rpg/models/ranking_models.dart';
import 'package:real_life_rpg/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ApiConfig Tests', () {
    test('ApiConfig initializes with appropriate default host', () async {
      await ApiConfig.init();
      expect(ApiConfig.baseUrl, isNotEmpty);
      expect(ApiConfig.baseUrl.startsWith('http://'), isTrue);
    });

    test('ApiConfig updates and trims trailing slash correctly', () async {
      await ApiConfig.setBaseUrl('http://192.168.1.50:8080/api/');
      expect(ApiConfig.baseUrl, equals('http://192.168.1.50:8080/api'));
    });

    test('ApiConfig resets to default correctly', () async {
      await ApiConfig.setBaseUrl('http://192.168.1.50:8080/api');
      await ApiConfig.resetToDefault();
      expect(ApiConfig.baseUrl, equals(ApiConfig.defaultHost));
    });
  });

  group('Online Model Deserialization Tests', () {
    test('RankingPlayer handles real online backend payload', () {
      final json = {
        'id': 42,
        'rank': 1,
        'username': 'HarshaWarrior',
        'raw_username': 'harsha_test',
        'avatar_id': 'hero2',
        'level': 5,
        'total_xp': 450,
        'completed_tasks': 12,
        'current_streak': 4,
        'achievements_count': 3,
        'metric_score': 450,
        'display_score': '450 XP',
        'is_current_user': true,
      };

      final player = RankingPlayer.fromJson(json, currentUsername: 'harsha_test');
      expect(player.id, equals(42));
      expect(player.username, equals('HarshaWarrior'));
      expect(player.level, equals(5));
      expect(player.totalXP, equals(450));
      expect(player.isCurrentUser, isTrue);
      expect(player.displayScore, equals('450 XP'));
    });

    test('UserProfile handles online serialization and skill updates', () {
      final profile = UserProfile(
        username: 'harsha_test',
        email: 'harsha@example.com',
        avatarId: 'hero2',
        level: 2,
        totalXP: 150,
        gold: 75,
        currentStreak: 3,
        bestStreak: 5,
      );

      expect(profile.username, equals('harsha_test'));
      expect(profile.level, equals(2));
      expect(profile.skills['Strength'], equals(0));

      final map = profile.toMap();
      expect(map['email'], equals('harsha@example.com'));
      expect(map['totalXP'], equals(150));
    });

    test('RPGTask future date detection works correctly', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final task = RPGTask(
        id: 'task_tom',
        title: 'Tomorrow Quest',
        description: 'Test',
        category: 'Work',
        xpReward: 50,
        dueDate: tomorrow,
      );

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final due = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);

      expect(due.isAfter(today), isTrue);
    });
  });
}
