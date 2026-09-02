import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService instance = SoundService._internal();
  SoundService._internal();

  AudioPlayer? _player;

  AudioPlayer get _audioPlayer {
    _player ??= AudioPlayer();
    return _player!;
  }

  Future<void> playTaskCompletedAlarm({bool isSoundEnabled = true}) async {
    // 1. Always trigger physical haptic feedback
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}

    if (!isSoundEnabled) return;

    // 2. Play audio alarm sound
    try {
      final player = _audioPlayer;
      await player.stop();
      await player.play(AssetSource('sounds/task_alarm.wav'), volume: 1.0);
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
