import 'package:flutter/material.dart';

/// Categories for ranking players in LevelUp
enum RankingType {
  xp,
  level,
  quests,
  streak,
  achievements,
}

extension RankingTypeExtension on RankingType {
  String get title {
    switch (this) {
      case RankingType.xp:
        return 'XP';
      case RankingType.level:
        return 'Level';
      case RankingType.quests:
        return 'Quests';
      case RankingType.streak:
        return 'Streak';
      case RankingType.achievements:
        return 'Achievements';
    }
  }

  String get tabLabel {
    switch (this) {
      case RankingType.xp:
        return '🏆 XP';
      case RankingType.level:
        return '🎮 Level';
      case RankingType.quests:
        return '⚔ Quests';
      case RankingType.streak:
        return '🔥 Streak';
      case RankingType.achievements:
        return '🏅 Achievements';
    }
  }

  IconData get icon {
    switch (this) {
      case RankingType.xp:
        return Icons.bolt;
      case RankingType.level:
        return Icons.shield;
      case RankingType.quests:
        return Icons.check_circle_outline;
      case RankingType.streak:
        return Icons.local_fire_department;
      case RankingType.achievements:
        return Icons.military_tech;
    }
  }

  String get apiParam {
    switch (this) {
      case RankingType.xp:
        return 'xp';
      case RankingType.level:
        return 'level';
      case RankingType.quests:
        return 'quests';
      case RankingType.streak:
        return 'streak';
      case RankingType.achievements:
        return 'achievements';
    }
  }
}

/// Time period filter for leaderboard calculations
enum RankingPeriod {
  allTime,
  today,
  thisWeek,
  thisMonth,
}

extension RankingPeriodExtension on RankingPeriod {
  String get label {
    switch (this) {
      case RankingPeriod.allTime:
        return 'All Time';
      case RankingPeriod.today:
        return 'Today';
      case RankingPeriod.thisWeek:
        return 'This Week';
      case RankingPeriod.thisMonth:
        return 'This Month';
    }
  }

  String get apiParam {
    switch (this) {
      case RankingPeriod.allTime:
        return 'all';
      case RankingPeriod.today:
        return 'today';
      case RankingPeriod.thisWeek:
        return 'week';
      case RankingPeriod.thisMonth:
        return 'month';
    }
  }
}

/// Public leaderboard player entry
class RankingPlayer {
  final dynamic id;
  final int rank;
  final String username;
  final String avatarId;
  final String? profileImagePath;
  final int level;
  final int totalXP;
  final int completedTasks;
  final int currentStreak;
  final int bestStreak;
  final int achievementsCount;
  final num metricScore;
  final String displayScore;
  final int? rankMovement; // Null when historical movement is unavailable
  final bool isCurrentUser;

  RankingPlayer({
    required this.id,
    required this.rank,
    required this.username,
    this.avatarId = 'hero1',
    this.profileImagePath,
    required this.level,
    required this.totalXP,
    this.completedTasks = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.achievementsCount = 0,
    required this.metricScore,
    required this.displayScore,
    this.rankMovement,
    this.isCurrentUser = false,
  });

  factory RankingPlayer.fromJson(Map<String, dynamic> json, {String? currentUsername}) {
    final uname = json['username']?.toString() ?? 'Hero';
    final rawUname = json['raw_username']?.toString() ?? uname;
    final isMe = (json['is_current_user'] == true || json['is_current_user'] == 1) ||
        (currentUsername != null &&
            (uname.toLowerCase() == currentUsername.toLowerCase() ||
                rawUname.toLowerCase() == currentUsername.toLowerCase()));
    
    return RankingPlayer(
      id: json['id'] ?? 0,
      rank: json['rank'] is int ? json['rank'] : int.tryParse(json['rank']?.toString() ?? '0') ?? 0,
      username: uname,
      avatarId: json['avatar_id']?.toString() ?? 'hero1',
      profileImagePath: json['profile_image_path']?.toString(),
      level: json['level'] is int ? json['level'] : int.tryParse(json['level']?.toString() ?? '1') ?? 1,
      totalXP: json['total_xp'] is int ? json['total_xp'] : int.tryParse(json['total_xp']?.toString() ?? '0') ?? 0,
      completedTasks: json['completed_tasks'] is int ? json['completed_tasks'] : int.tryParse(json['completed_tasks']?.toString() ?? '0') ?? 0,
      currentStreak: json['current_streak'] is int ? json['current_streak'] : int.tryParse(json['current_streak']?.toString() ?? '0') ?? 0,
      bestStreak: json['best_streak'] is int ? json['best_streak'] : int.tryParse(json['best_streak']?.toString() ?? '0') ?? 0,
      achievementsCount: json['achievements_count'] is int ? json['achievements_count'] : int.tryParse(json['achievements_count']?.toString() ?? '0') ?? 0,
      metricScore: json['metric_score'] is num ? json['metric_score'] : num.tryParse(json['metric_score']?.toString() ?? '0') ?? 0,
      displayScore: json['display_score']?.toString() ?? '${json['total_xp'] ?? 0} XP',
      rankMovement: json['rank_movement'] != null ? int.tryParse(json['rank_movement'].toString()) : null,
      isCurrentUser: isMe,
    );
  }

  RankingPlayer copyWith({
    int? rank,
    bool? isCurrentUser,
    int? rankMovement,
  }) {
    return RankingPlayer(
      id: id,
      rank: rank ?? this.rank,
      username: username,
      avatarId: avatarId,
      profileImagePath: profileImagePath,
      level: level,
      totalXP: totalXP,
      completedTasks: completedTasks,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      achievementsCount: achievementsCount,
      metricScore: metricScore,
      displayScore: displayScore,
      rankMovement: rankMovement ?? this.rankMovement,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }
}

/// Safe public player profile without private data
class PlayerPublicProfile {
  final dynamic id;
  final String username;
  final String avatarId;
  final String? profileImagePath;
  final int level;
  final int totalXP;
  final int currentStreak;
  final int bestStreak;
  final int completedTasks;
  final int achievementsCount;
  final int rank;
  final Map<String, int> skills;
  final String? joinedDate;

  PlayerPublicProfile({
    required this.id,
    required this.username,
    this.avatarId = 'hero1',
    this.profileImagePath,
    required this.level,
    required this.totalXP,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.completedTasks = 0,
    this.achievementsCount = 0,
    required this.rank,
    this.skills = const {'Strength': 50, 'Knowledge': 50, 'Discipline': 50},
    this.joinedDate,
  });

  factory PlayerPublicProfile.fromJson(Map<String, dynamic> json) {
    Map<String, int> skillsMap = {'Strength': 50, 'Knowledge': 50, 'Discipline': 50};
    if (json['skills'] is Map) {
      skillsMap = Map<String, int>.from(json['skills'].map((k, v) => MapEntry(k.toString(), int.tryParse(v.toString()) ?? 50)));
    }

    return PlayerPublicProfile(
      id: json['id'] ?? 0,
      username: json['username']?.toString() ?? 'Hero',
      avatarId: json['avatar_id']?.toString() ?? 'hero1',
      profileImagePath: json['profile_image_path']?.toString(),
      level: json['level'] is int ? json['level'] : int.tryParse(json['level']?.toString() ?? '1') ?? 1,
      totalXP: json['total_xp'] is int ? json['total_xp'] : int.tryParse(json['total_xp']?.toString() ?? '0') ?? 0,
      currentStreak: json['current_streak'] is int ? json['current_streak'] : int.tryParse(json['current_streak']?.toString() ?? '0') ?? 0,
      bestStreak: json['best_streak'] is int ? json['best_streak'] : int.tryParse(json['best_streak']?.toString() ?? '0') ?? 0,
      completedTasks: json['completed_tasks'] is int ? json['completed_tasks'] : int.tryParse(json['completed_tasks']?.toString() ?? '0') ?? 0,
      achievementsCount: json['achievements_count'] is int ? json['achievements_count'] : int.tryParse(json['achievements_count']?.toString() ?? '0') ?? 0,
      rank: json['rank'] is int ? json['rank'] : int.tryParse(json['rank']?.toString() ?? '1') ?? 1,
      skills: skillsMap,
      joinedDate: json['joined_date']?.toString(),
    );
  }
}
