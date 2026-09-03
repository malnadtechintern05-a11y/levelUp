import 'package:flutter_test/flutter_test.dart';
import 'package:real_life_rpg/models/ranking_models.dart';
import 'package:real_life_rpg/providers/rankings_provider.dart';

void main() {
  group('Ranking Models Tests', () {
    test('RankingPlayer JSON deserialization and current user check', () {
      final json = {
        'id': 1,
        'rank': 1,
        'username': 'HeroUser',
        'avatar_id': 'hero2',
        'level': 10,
        'total_xp': 5000,
        'completed_tasks': 25,
        'current_streak': 7,
        'best_streak': 14,
        'achievements_count': 5,
        'metric_score': 5000,
        'display_score': '5,000 XP',
        'rank_movement': null,
      };

      final player = RankingPlayer.fromJson(json, currentUsername: 'herouser');
      expect(player.id, 1);
      expect(player.rank, 1);
      expect(player.username, 'HeroUser');
      expect(player.isCurrentUser, true);
      expect(player.level, 10);
      expect(player.totalXP, 5000);
      expect(player.displayScore, '5,000 XP');
      expect(player.rankMovement, isNull);
    });

    test('PlayerPublicProfile JSON deserialization strictly excludes private info', () {
      final json = {
        'id': 42,
        'username': 'Valkyrie',
        'avatar_id': 'hero3',
        'level': 15,
        'total_xp': 7500,
        'current_streak': 10,
        'best_streak': 12,
        'completed_tasks': 40,
        'achievements_count': 8,
        'rank': 3,
        'skills': {
          'Strength': 75,
          'Knowledge': 80,
          'Discipline': 90,
        },
        'joined_date': 'Aug 2026',
        // Attempting to send private data from an external source:
        'email': 'secret@private.com',
        'password': 'hashed_password_123',
      };

      final profile = PlayerPublicProfile.fromJson(json);
      expect(profile.id, 42);
      expect(profile.username, 'Valkyrie');
      expect(profile.rank, 3);
      expect(profile.skills['Strength'], 75);
      expect(profile.joinedDate, 'Aug 2026');
      // Verify PlayerPublicProfile has no email/password properties
    });

    test('RankingType and RankingPeriod mapping test', () {
      expect(RankingType.xp.apiParam, 'xp');
      expect(RankingType.level.apiParam, 'level');
      expect(RankingType.quests.apiParam, 'quests');
      expect(RankingType.streak.apiParam, 'streak');
      expect(RankingType.achievements.apiParam, 'achievements');

      expect(RankingPeriod.allTime.apiParam, 'all');
      expect(RankingPeriod.today.apiParam, 'today');
      expect(RankingPeriod.thisWeek.apiParam, 'week');
      expect(RankingPeriod.thisMonth.apiParam, 'month');
    });
  });

  group('RankingsProvider Podium Logic Tests', () {
    test('Podium returns top 3 and sublist correctly', () {
      final provider = RankingsProvider();
      expect(provider.podiumFirst, isNull);
      expect(provider.podiumSecond, isNull);
      expect(provider.podiumThird, isNull);
      expect(provider.remainingPlayers, isEmpty);
    });
  });
}
