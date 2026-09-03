import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:real_life_rpg/models/alarm_song.dart';
import 'package:real_life_rpg/services/sound_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Alarm Songs Catalog Tests', () {
    test('All 7 alarm songs are registered with valid assets and metadata', () {
      expect(AlarmSong.allSongs.length, 7);

      final expectedIds = [
        'fanfare_victory',
        'battle_horn',
        'crystal_chimes',
        'retro_powerup',
        'hero_awakening',
        'dungeon_march',
        'classic_alarm',
      ];

      for (var id in expectedIds) {
        final song = AlarmSong.getById(id);
        expect(song.id, id);
        expect(song.name.isNotEmpty, true);
        expect(song.category.isNotEmpty, true);
        expect(song.description.isNotEmpty, true);
        expect(song.assetPath.startsWith('sounds/'), true);
        expect(song.assetPath.endsWith('.wav'), true);
        expect(song.durationText.isNotEmpty, true);
      }
    });

    test('getById returns default song when given unknown id', () {
      final song = AlarmSong.getById('non_existent_fanfare_999');
      expect(song.id, 'fanfare_victory');
    });
  });

  group('SoundService Alarm Song Management Tests', () {
    test('SoundService switches and persists selected alarm song', () async {
      final service = SoundService.instance;
      expect(service.selectedAlarmSongId, isNotEmpty);

      await service.setSelectedAlarmSong('battle_horn');
      expect(service.selectedAlarmSongId, 'battle_horn');
      expect(service.currentAlarmSong.name, '⚔️ Battle Warhorn');

      await service.setSelectedAlarmSong('crystal_chimes');
      expect(service.selectedAlarmSongId, 'crystal_chimes');
      expect(service.currentAlarmSong.name, '🔔 Crystal Chimes');
    });
  });
}
