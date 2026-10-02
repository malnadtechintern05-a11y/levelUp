import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/sound_service.dart';
import '../screens/alarm_sound_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _handleEmailSupport() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@levelup-rpg.com',
      query: 'subject=LevelUp RPG Support & Inquiries',
    );
    bool launched = false;
    try {
      if (await canLaunchUrl(uri)) {
        launched = await launchUrl(uri);
      }
    } catch (_) {}

    if (!launched && mounted) {
      await Clipboard.setData(const ClipboardData(text: 'support@levelup-rpg.com'));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📋 Email copied to clipboard: support@levelup-rpg.com'),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
      }
    }
  }

  void _showFeedbackDialog() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final messageController = TextEditingController();
    String selectedCategory = 'Bug Report';
    final categories = ['Bug Report', 'Feature Request', 'General Feedback', 'Help & Question'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF162033) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            ),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5B942).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.rate_review_rounded, color: Color(0xFFF5B942), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Send Feedback',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        selectedCategory = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),
                Text(
                  'Your Message',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Describe your issue or suggestion...',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5B942),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final message = messageController.text.trim();
                if (message.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Please enter a message before submitting.')),
                  );
                  return;
                }
                Navigator.pop(ctx);

                final emailUri = Uri(
                  scheme: 'mailto',
                  path: 'support@levelup-rpg.com',
                  query: 'subject=LevelUp Feedback: $selectedCategory&body=${Uri.encodeComponent(message)}',
                );

                bool launched = false;
                try {
                  if (await canLaunchUrl(emailUri)) {
                    launched = await launchUrl(emailUri);
                  }
                } catch (_) {}

                if (!launched && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Thank you for your feedback! It helps us level up the app.'),
                      backgroundColor: Color(0xFF16A34A),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text('Submit', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              'APPEARANCE',
              style: TextStyle(
                color: isDark ? const Color(0xFFF5B942) : const Color(0xFFD97706),
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Card(
            child: Consumer<AppState>(
              builder: (context, state, child) {
                return SwitchListTile(
                  secondary: Icon(
                    state.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: isDark ? const Color(0xFFF5B942) : const Color(0xFFD97706),
                  ),
                  title: Text(
                    state.isDarkMode ? 'Dark Mode' : 'Light Mode',
                    style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    state.isDarkMode ? 'Dark navy & gold aesthetic' : 'Clean & bright slate aesthetic',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                  ),
                  value: state.isDarkMode,
                  activeThumbColor: const Color(0xFFF5B942),
                  onChanged: (val) {
                    state.toggleTheme(val);
                  },
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              'NOTIFICATIONS',
              style: TextStyle(
                color: isDark ? const Color(0xFFF5B942) : const Color(0xFFD97706),
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Consumer<AppState>(
            builder: (context, state, child) {
              final notifSettings = state.notificationSettings;
              return Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.celebration_outlined, color: Color(0xFFF5B942)),
                      title: Text('Task Completion Celebrations', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
                      subtitle: Text('Show congratulatory XP dialog & quotes', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                      value: notifSettings.taskCompletionNotifications,
                      activeThumbColor: const Color(0xFFF5B942),
                      onChanged: (val) {
                        notifSettings.taskCompletionNotifications = val;
                        state.updateNotificationSettings(notifSettings);
                      },
                    ),
                    Divider(height: 1, color: theme.colorScheme.outline),
                    SwitchListTile(
                      secondary: const Icon(Icons.emoji_events_outlined, color: Colors.amber),
                      title: Text('Achievement Notifications', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
                      subtitle: Text('Alerts when new trophies are unlocked', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                      value: notifSettings.achievementNotifications,
                      activeThumbColor: const Color(0xFFF5B942),
                      onChanged: (val) {
                        notifSettings.achievementNotifications = val;
                        state.updateNotificationSettings(notifSettings);
                      },
                    ),
                    Divider(height: 1, color: theme.colorScheme.outline),
                    SwitchListTile(
                      secondary: Icon(Icons.timer_outlined, color: theme.colorScheme.onSurface),
                      title: Text('Task Reminders', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
                      subtitle: Text('Reminders for scheduled quest times', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                      value: notifSettings.taskReminders,
                      activeThumbColor: const Color(0xFFF5B942),
                      onChanged: (val) {
                        notifSettings.taskReminders = val;
                        state.updateNotificationSettings(notifSettings);
                      },
                    ),
                    Divider(height: 1, color: theme.colorScheme.outline),
                    SwitchListTile(
                      secondary: Icon(Icons.notifications_active_outlined, color: theme.colorScheme.onSurface),
                      title: Text('Daily Reminders', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
                      subtitle: Text('Daily morning quest check-ins', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                      value: notifSettings.dailyReminders,
                      activeThumbColor: const Color(0xFFF5B942),
                      onChanged: (val) {
                        notifSettings.dailyReminders = val;
                        state.updateNotificationSettings(notifSettings);
                      },
                    ),
                    Divider(height: 1, color: theme.colorScheme.outline),
                    SwitchListTile(
                      secondary: const Icon(Icons.local_fire_department_outlined, color: Colors.orangeAccent),
                      title: Text('Streak Reminders', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
                      subtitle: Text('Keep your streak alive before midnight', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                      value: notifSettings.streakReminders,
                      activeThumbColor: const Color(0xFFF5B942),
                      onChanged: (val) {
                        notifSettings.streakReminders = val;
                        state.updateNotificationSettings(notifSettings);
                      },
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              'APP',
              style: TextStyle(
                color: isDark ? const Color(0xFFF5B942) : const Color(0xFFD97706),
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Consumer<AppState>(
            builder: (context, state, child) {
              return Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: Icon(Icons.volume_up_outlined, color: theme.colorScheme.onSurface),
                      title: Text('Completion Alarm & Sounds', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
                      subtitle: Text('Play victory fanfare alarm & vibration when a task finishes', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                      value: state.soundEffectsEnabled,
                      activeThumbColor: const Color(0xFFF5B942),
                      onChanged: (val) async {
                        await state.toggleSoundEffects(val);
                        if (val) {
                          state.previewAlarmSong(state.selectedAlarmSongId);
                        }
                      },
                    ),
                    Divider(height: 1, color: theme.colorScheme.outline),
                    ListTile(
                      leading: const Icon(Icons.music_note, color: Color(0xFFF5B942)),
                      title: Text('Alarm Song & Fanfare', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
                      subtitle: Text(
                        '${state.currentAlarmSong.name} (${state.currentAlarmSong.category})',
                        style: const TextStyle(color: Color(0xFFF5B942), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AlarmSoundScreen()));
                      },
                    ),
                    Divider(height: 1, color: theme.colorScheme.outline),
                    ListTile(
                      leading: const Icon(Icons.play_circle_outline, color: Color(0xFFF5B942)),
                      title: Text('Test Active Alarm', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
                      subtitle: Text('Preview ${state.currentAlarmSong.name}', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                      trailing: const Icon(Icons.volume_up, color: Color(0xFFF5B942)),
                      onTap: () {
                        SoundService.instance.playTaskCompletedAlarm(isSoundEnabled: true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('🔔 Conquered Quest! Playing "${state.currentAlarmSong.name}"'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    Divider(height: 1, color: theme.colorScheme.outline),
                    ListTile(
                      leading: const Icon(Icons.refresh, color: Colors.redAccent),
                      title: const Text('Reset Progress', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.redAccent),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Progress reset not available in demo.')));
                      },
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              'CONTACT US',
              style: TextStyle(
                color: isDark ? const Color(0xFFF5B942) : const Color(0xFFD97706),
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.mail_outline_rounded, color: Color(0xFFF5B942)),
                  title: Text('Email Support', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
                  subtitle: Text('support@levelup-rpg.com', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _handleEmailSupport,
                ),
                Divider(height: 1, color: theme.colorScheme.outline),
                ListTile(
                  leading: const Icon(Icons.rate_review_outlined, color: Color(0xFFF5B942)),
                  title: Text('Send Feedback & Suggestions', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
                  subtitle: Text('Report issues or request new RPG features', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showFeedbackDialog,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              'ABOUT',
              style: TextStyle(
                color: isDark ? const Color(0xFFF5B942) : const Color(0xFFD97706),
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: Color(0xFFF5B942)),
                  title: Text('Privacy Policy', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
                  subtitle: Text('Review our privacy policy and data security', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                  trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
                  },
                ),
                Divider(height: 1, color: theme.colorScheme.outline),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: Color(0xFFF5B942)),
                  title: Text('About LevelUp', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
                  subtitle: Text('Mission, gameplay mechanics & app info', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                  trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
                  },
                ),
                Divider(height: 1, color: theme.colorScheme.outline),
                ListTile(
                  leading: Icon(Icons.verified_outlined, color: theme.colorScheme.onSurface),
                  title: Text('App Version', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
                  trailing: Text('1.0.0', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
