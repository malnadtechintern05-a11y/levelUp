import 'package:flutter/material.dart';

/// Represents an alarm song / audio fanfare available for quests and alerts
class AlarmSong {
  final String id;
  final String name;
  final String category;
  final String description;
  final String assetPath;
  final IconData icon;
  final String durationText;

  const AlarmSong({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.assetPath,
    required this.icon,
    required this.durationText,
  });

  static const List<AlarmSong> allSongs = [
    AlarmSong(
      id: 'fanfare_victory',
      name: '🎺 Victory Fanfare',
      category: 'Heroic Fanfare',
      description: 'Triumphant royal trumpet melody for conquered quests',
      assetPath: 'sounds/fanfare_victory.wav',
      icon: Icons.campaign,
      durationText: '2.1s',
    ),
    AlarmSong(
      id: 'battle_horn',
      name: '⚔️ Battle Warhorn',
      category: 'Epic Brass',
      description: 'Resonant warrior horn calling heroes to victory',
      assetPath: 'sounds/battle_horn.wav',
      icon: Icons.shield,
      durationText: '1.9s',
    ),
    AlarmSong(
      id: 'crystal_chimes',
      name: '🔔 Crystal Chimes',
      category: 'Fantasy Magic',
      description: 'Enchanted sparkling fairy chimes with crystalline tones',
      assetPath: 'sounds/crystal_chimes.wav',
      icon: Icons.auto_awesome,
      durationText: '1.8s',
    ),
    AlarmSong(
      id: 'retro_powerup',
      name: '⚡ 8-Bit Power-Up',
      category: 'Arcade Synth',
      description: 'Classic retro synth arpeggio for rapid level-ups',
      assetPath: 'sounds/retro_powerup.wav',
      icon: Icons.sports_esports,
      durationText: '0.9s',
    ),
    AlarmSong(
      id: 'hero_awakening',
      name: '🌅 Hero Awakening',
      category: 'Dawn Call',
      description: 'Inspiring morning anthem to conquer the day',
      assetPath: 'sounds/hero_awakening.wav',
      icon: Icons.wb_sunny,
      durationText: '2.1s',
    ),
    AlarmSong(
      id: 'dungeon_march',
      name: '🥁 Dungeon March',
      category: 'War Drum',
      description: 'Triumphant war drum cadence with resounding finale',
      assetPath: 'sounds/dungeon_march.wav',
      icon: Icons.fitness_center,
      durationText: '1.9s',
    ),
    AlarmSong(
      id: 'classic_alarm',
      name: '🔔 Classic Quest Bell',
      category: 'Original',
      description: 'The original LevelUp quest completion chime',
      assetPath: 'sounds/task_alarm.wav',
      icon: Icons.notifications_active,
      durationText: '1.5s',
    ),
  ];

  static AlarmSong getById(String id) {
    return allSongs.firstWhere(
      (song) => song.id == id,
      orElse: () => allSongs.first,
    );
  }
}
