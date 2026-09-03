import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alarm_song.dart';
import '../providers/app_state.dart';
import '../services/sound_service.dart';

class AlarmSoundScreen extends StatefulWidget {
  const AlarmSoundScreen({super.key});

  @override
  State<AlarmSoundScreen> createState() => _AlarmSoundScreenState();
}

class _AlarmSoundScreenState extends State<AlarmSoundScreen> {
  String? _currentlyPlayingId;

  @override
  void dispose() {
    SoundService.instance.stopPlayback();
    super.dispose();
  }

  void _previewSong(String songId) {
    setState(() {
      _currentlyPlayingId = songId;
    });

    SoundService.instance.previewAlarmSong(songId);

    // Reset playing status after song duration (~2.5s)
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted && _currentlyPlayingId == songId) {
        setState(() {
          _currentlyPlayingId = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appState = Provider.of<AppState>(context);
    final currentSong = appState.currentAlarmSong;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎵 Alarm Songs', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          // Header description
          Text(
            'Select your signature quest fanfare. This song sounds whenever a task or quest is conquered!',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),

          // Active Song Hero Banner
          Container(
            padding: const EdgeInsets.all(18.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [const Color(0xFFFFFBEB), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFF5B942),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF5B942).withValues(alpha: 0.15),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5B942).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFF5B942).withValues(alpha: 0.5)),
                  ),
                  child: Icon(currentSong.icon, color: const Color(0xFFF5B942), size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5B942),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ACTIVE ALARM',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            currentSong.durationText,
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentSong.name,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        currentSong.category,
                        style: const TextStyle(
                          color: Color(0xFFF5B942),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  style: IconButton.styleFrom(
                    backgroundColor: _currentlyPlayingId == currentSong.id
                        ? const Color(0xFFF5B942)
                        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    foregroundColor: _currentlyPlayingId == currentSong.id ? Colors.black : theme.colorScheme.onSurface,
                  ),
                  icon: Icon(_currentlyPlayingId == currentSong.id ? Icons.volume_up : Icons.play_arrow),
                  onPressed: () => _previewSong(currentSong.id),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Catalog Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available RPG Fanfares',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                '${AlarmSong.allSongs.length} Songs',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Songs List
          ...AlarmSong.allSongs.map((song) {
            final isSelected = song.id == currentSong.id;
            final isPlaying = _currentlyPlayingId == song.id;

            return Container(
              margin: const EdgeInsets.only(bottom: 10.0),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFBEB))
                    : (isDark ? const Color(0xFF162033) : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFF5B942)
                      : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: const Color(0xFFF5B942).withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                onTap: () {
                  appState.setSelectedAlarmSong(song.id);
                  _previewSong(song.id);
                },
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFF5B942).withValues(alpha: 0.2)
                        : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    song.icon,
                    color: isSelected ? const Color(0xFFF5B942) : theme.colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                ),
                title: Row(
                  children: [
                    Flexible(
                      child: Text(
                        song.name,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFF5B942).withValues(alpha: 0.4)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        song.category,
                        style: TextStyle(
                          color: isSelected ? const Color(0xFFF5B942) : theme.colorScheme.onSurfaceVariant,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    '${song.description} • ${song.durationText}',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        isPlaying ? Icons.volume_up : Icons.play_circle_outline,
                        color: isPlaying ? const Color(0xFFF5B942) : theme.colorScheme.onSurfaceVariant,
                        size: 26,
                      ),
                      tooltip: 'Preview song',
                      onPressed: () => _previewSong(song.id),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? const Color(0xFFF5B942) : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFF5B942)
                              : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 16, color: Colors.black)
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // Test completion fanfare button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5B942),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
              icon: const Icon(Icons.celebration, color: Colors.black),
              label: const Text(
                'Test Full Quest Alarm',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              onPressed: () {
                SoundService.instance.playTaskCompletedAlarm(isSoundEnabled: true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🔔 Conquered Quest! Playing "${currentSong.name}"'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: const Color(0xFF162033),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
