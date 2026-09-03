import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/ranking_models.dart';
import '../models/models.dart';
import '../helpers/database_helper.dart';
import '../config/api_config.dart';

/// Abstract contract for fetching leaderboard rankings and public profiles
abstract class RankingRepository {
  Future<List<RankingPlayer>> getRankings({
    required RankingType type,
    required RankingPeriod period,
    String? currentUsername,
  });

  Future<PlayerPublicProfile?> getPublicProfile(dynamic userId);

  Future<RankingPlayer?> getCurrentUserRank({
    required String username,
    required RankingType type,
    required RankingPeriod period,
  });
}

/// Local SQLite implementation of RankingRepository
/// Uses only real local database data and does not generate fake players.
class LocalRankingRepository implements RankingRepository {
  final DatabaseHelper _dbHelper;

  LocalRankingRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<List<RankingPlayer>> getRankings({
    required RankingType type,
    required RankingPeriod period,
    String? currentUsername,
  }) async {
    try {
      final profiles = await _dbHelper.getAllProfiles();
      if (profiles.isEmpty) {
        return [];
      }

      final allTasks = await _dbHelper.getAllTasks();
      final allAchievements = await _dbHelper.getAllAchievements();
      final unlockedAchievementsCount = allAchievements.where((a) => a.isUnlocked).length;

      final now = DateTime.now();

      // Calculate metric for each local profile
      List<RankingPlayer> players = [];

      for (var p in profiles) {
        final isMe = currentUsername != null &&
            p.username.toLowerCase() == currentUsername.toLowerCase();

        // Calculate time-filtered stats for tasks completed
        List<RPGTask> relevantTasks = allTasks.where((t) => t.isCompleted).toList();
        if (period == RankingPeriod.today) {
          relevantTasks = relevantTasks.where((t) {
            final d = t.dueDate;
            return d.year == now.year && d.month == now.month && d.day == now.day;
          }).toList();
        } else if (period == RankingPeriod.thisWeek) {
          final weekAgo = now.subtract(const Duration(days: 7));
          relevantTasks = relevantTasks.where((t) => t.dueDate.isAfter(weekAgo)).toList();
        } else if (period == RankingPeriod.thisMonth) {
          final monthAgo = now.subtract(const Duration(days: 30));
          relevantTasks = relevantTasks.where((t) => t.dueDate.isAfter(monthAgo)).toList();
        }

        final filteredXp = (period == RankingPeriod.allTime)
            ? p.totalXP
            : relevantTasks.fold<int>(0, (sum, t) => sum + t.xpReward);

        final filteredTasksCount = relevantTasks.length;

        num metricScore = 0;
        String displayScore = '';

        switch (type) {
          case RankingType.level:
            metricScore = p.level;
            displayScore = 'Level ${p.level}';
            break;
          case RankingType.quests:
            metricScore = filteredTasksCount;
            displayScore = '$filteredTasksCount Quests';
            break;
          case RankingType.streak:
            metricScore = p.currentStreak;
            displayScore = '${p.currentStreak} Day Streak';
            break;
          case RankingType.achievements:
            metricScore = unlockedAchievementsCount;
            displayScore = '$unlockedAchievementsCount Trophies';
            break;
          case RankingType.xp:
            metricScore = filteredXp;
            displayScore = '$filteredXp XP';
            break;
        }

        players.add(RankingPlayer(
          id: p.username,
          rank: 1, // Calculated after sorting
          username: p.username,
          avatarId: p.avatarId,
          profileImagePath: p.profileImagePath,
          level: p.level,
          totalXP: p.totalXP,
          completedTasks: filteredTasksCount,
          currentStreak: p.currentStreak,
          bestStreak: p.bestStreak,
          achievementsCount: unlockedAchievementsCount,
          metricScore: metricScore,
          displayScore: displayScore,
          rankMovement: null, // No fake movement
          isCurrentUser: isMe,
        ));
      }

      // Sort by metric descending, tie breaker totalXP
      players.sort((a, b) {
        final comp = b.metricScore.compareTo(a.metricScore);
        if (comp != 0) return comp;
        return b.totalXP.compareTo(a.totalXP);
      });

      // Assign sequential ranks
      for (int i = 0; i < players.length; i++) {
        players[i] = players[i].copyWith(rank: i + 1);
      }

      return players;
    } catch (e) {
      debugPrint('LocalRankingRepository error: $e');
      return [];
    }
  }

  @override
  Future<PlayerPublicProfile?> getPublicProfile(dynamic userId) async {
    try {
      final profiles = await _dbHelper.getAllProfiles();
      final p = profiles.firstWhere(
        (u) => u.username.toString() == userId.toString(),
        orElse: () => profiles.first,
      );

      final allTasks = await _dbHelper.getAllTasks();
      final allAchievements = await _dbHelper.getAllAchievements();

      return PlayerPublicProfile(
        id: p.username,
        username: p.username,
        avatarId: p.avatarId,
        profileImagePath: p.profileImagePath,
        level: p.level,
        totalXP: p.totalXP,
        currentStreak: p.currentStreak,
        bestStreak: p.bestStreak,
        completedTasks: allTasks.where((t) => t.isCompleted).length,
        achievementsCount: allAchievements.where((a) => a.isUnlocked).length,
        rank: 1,
        skills: p.skills,
        joinedDate: 'Local Realm',
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<RankingPlayer?> getCurrentUserRank({
    required String username,
    required RankingType type,
    required RankingPeriod period,
  }) async {
    final all = await getRankings(type: type, period: period, currentUsername: username);
    try {
      return all.firstWhere((p) => p.isCurrentUser);
    } catch (_) {
      return all.isNotEmpty ? all.first : null;
    }
  }
}

/// Remote API implementation of RankingRepository
/// Communicates with the online PHP backend REST API
class ApiRankingRepository implements RankingRepository {
  final HttpClient _client = HttpClient()..connectionTimeout = const Duration(seconds: 4);

  ApiRankingRepository();

  @override
  Future<List<RankingPlayer>> getRankings({
    required RankingType type,
    required RankingPeriod period,
    String? currentUsername,
  }) async {
    final endpoint = '${ApiConfig.baseUrl}/rankings/leaderboard.php';
    final uri = Uri.parse(endpoint).replace(queryParameters: {
      'type': type.apiParam,
      'period': period.apiParam,
      'limit': '50',
    });

    final request = await _client.getUrl(uri);
    final response = await request.close();

    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> json = jsonDecode(responseBody);
      if (json['status'] == 'success' && json['data'] is List) {
        final list = (json['data'] as List)
            .map((item) => RankingPlayer.fromJson(item, currentUsername: currentUsername))
            .toList();
        return list;
      }
    }
    throw Exception('Failed to fetch rankings from online server (HTTP ${response.statusCode})');
  }

  @override
  Future<PlayerPublicProfile?> getPublicProfile(dynamic userId) async {
    final endpoint = '${ApiConfig.baseUrl}/users/public_profile.php';
    final uri = Uri.parse(endpoint).replace(queryParameters: {
      'id': userId.toString(),
    });

    final request = await _client.getUrl(uri);
    final response = await request.close();

    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> json = jsonDecode(responseBody);
      if (json['status'] == 'success' && json['data'] is Map<String, dynamic>) {
        return PlayerPublicProfile.fromJson(json['data']);
      }
    }
    return null;
  }

  @override
  Future<RankingPlayer?> getCurrentUserRank({
    required String username,
    required RankingType type,
    required RankingPeriod period,
  }) async {
    final list = await getRankings(type: type, period: period, currentUsername: username);
    try {
      return list.firstWhere((p) => p.isCurrentUser);
    } catch (_) {
      return null;
    }
  }
}

/// Unified RankingService orchestrating online and offline local fallback
class RankingService {
  final ApiRankingRepository _apiRepo = ApiRankingRepository();
  final LocalRankingRepository _localRepo = LocalRankingRepository();

  bool _isOnlineMode = false;
  bool get isOnlineMode => _isOnlineMode;

  Future<List<RankingPlayer>> getRankings({
    required RankingType type,
    required RankingPeriod period,
    String? currentUsername,
  }) async {
    try {
      // First attempt online API
      final results = await _apiRepo.getRankings(
        type: type,
        period: period,
        currentUsername: currentUsername,
      );
      _isOnlineMode = true;
      return results;
    } catch (e) {
      // Clean fallback to local SQLite data
      debugPrint('Online ranking API unreachable ($e). Seamlessly falling back to local realm data.');
      _isOnlineMode = false;
      return await _localRepo.getRankings(
        type: type,
        period: period,
        currentUsername: currentUsername,
      );
    }
  }

  Future<PlayerPublicProfile?> getPublicProfile(dynamic userId) async {
    if (_isOnlineMode) {
      try {
        final profile = await _apiRepo.getPublicProfile(userId);
        if (profile != null) return profile;
      } catch (_) {}
    }
    return await _localRepo.getPublicProfile(userId);
  }
}
