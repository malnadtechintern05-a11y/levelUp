import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm_song.dart';

class SoundService {
  static final SoundService instance = SoundService._internal();
  SoundService._internal() {
    _loadSavedSong();
  }

  AudioPlayer? _player;
  String _selectedAlarmSongId = 'fanfare_victory';

  AudioPlayer get _audioPlayer {
    _player ??= AudioPlayer();
    return _player!;
  }

  String get selectedAlarmSongId => _selectedAlarmSongId;
  AlarmSong get currentAlarmSong => AlarmSong.getById(_selectedAlarmSongId);

  Future<void> _loadSavedSong() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString('selected_alarm_song');
      if (savedId != null && savedId.isNotEmpty) {
        _selectedAlarmSongId = savedId;
      }
    } catch (e) {
      debugPrint("Error loading saved alarm song: $e");
    }
  }

  Future<void> setSelectedAlarmSong(String songId) async {
    _selectedAlarmSongId = songId;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_alarm_song', songId);
    } catch (e) {
      debugPrint("Error saving alarm song: $e");
    }
  }

  Future<void> previewAlarmSong(String songId) async {
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}

    try {
      final song = AlarmSong.getById(songId);
      final player = _audioPlayer;
      await player.stop();
      await player.play(AssetSource(song.assetPath), volume: 1.0);
    } catch (e) {
      debugPrint("AudioPlayer preview exception: $e. Falling back to SystemSound.");
      try {
        await SystemSound.play(SystemSoundType.alert);
      } catch (_) {}
    }
  }

  Future<void> stopPlayback() async {
    try {
      await _player?.stop();
    } catch (_) {}
  }

  Future<void> playTaskCompletedAlarm({bool isSoundEnabled = true}) async {
    // 1. Always trigger physical haptic feedback
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}

    if (!isSoundEnabled) return;

    // 2. Play selected alarm song
    try {
      final song = currentAlarmSong;
      final player = _audioPlayer;
      await player.stop();
      await player.play(AssetSource(song.assetPath), volume: 1.0);
    } catch (e) {
      debugPrint("AudioPlayer playback exception: $e. Falling back to SystemSound.");
      try {
        await SystemSound.play(SystemSoundType.alert);
      } catch (_) {}
    }
  }

  Future<void> playLevelUpAlarm({bool isSoundEnabled = true}) async {
    try {
      HapticFeedback.vibrate();
    } catch (_) {}

    if (!isSoundEnabled) return;

    try {
      final player = _audioPlayer;
      await player.stop();
      await player.play(AssetSource('sounds/level_up.wav'), volume: 1.0);
    } catch (e) {
      debugPrint("AudioPlayer level up exception: $e");
      try {
        await SystemSound.play(SystemSoundType.alert);
      } catch (_) {}
    }
  }

  void dispose() {
    _player?.dispose();
    _player = null;
  }
}
