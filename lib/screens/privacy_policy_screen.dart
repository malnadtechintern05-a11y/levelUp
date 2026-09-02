import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required String content,
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162033) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: const Color(0xFFF5B942), size: 20),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [const Color(0xFFF8FAFC), const Color(0xFFEDE9FE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFF5B942).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5B942).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_outlined, color: Color(0xFFF5B942), size: 28),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LevelUp Privacy Policy',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Last Updated: September 2026',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Your privacy and data sovereignty are fundamental to our mission. LevelUp is built with privacy-first architecture.',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // 1. Introduction
          _buildSection(
            context: context,
            title: '1. Introduction',
            icon: Icons.info_outline,
            content:
                'Welcome to LevelUp ("we," "our," or "the app"). LevelUp is designed to turn your daily habits, self-improvement routines, and productivity into an engaging real-life RPG adventure. This Privacy Policy explains how your information is handled when you use the app.',
          ),

          // 2. Information We Collect
          _buildSection(
            context: context,
            title: '2. Information We Collect',
            icon: Icons.folder_open_outlined,
            content:
                'LevelUp collects minimal information strictly necessary to power your RPG experience:\n\n'
                '• Profile Data: Hero username and selected avatar profile.\n'
                '• Quest & Habit Data: Quest titles, categories, completion timestamps, countdown timer durations, and daily drinking water logs.\n'
                '• App Preferences: Theme preference (Light/Dark mode) and notification settings.',
          ),

          // 3. How We Use Your Information
          _buildSection(
            context: context,
            title: '3. How We Use Your Information',
            icon: Icons.psychology_outlined,
            content:
                'We use your data exclusively to:\n\n'
                '• Calculate your level, experience points (XP), gold, and skill statistics (Strength, Knowledge, Discipline).\n'
                '• Track daily streak continuity and unlock earned achievements.\n'
                '• Provide hydration tracking and scheduled quest availability.',
          ),

          // 4. Task and Progress Data
          _buildSection(
            context: context,
            title: '4. Task and Progress Data',
            icon: Icons.check_circle_outline,
            content:
                'All quest records, completion history, XP logs, hydration entries, and personal milestones remain your private data. They are never shared, sold, broadcast, or monetized.',
          ),

          // 5. Notifications
          _buildSection(
            context: context,
            title: '5. Notifications',
            icon: Icons.notifications_none,
            content:
                'LevelUp provides local in-app congratulatory celebrations and reminders (such as task completion alerts, Level Up announcements, and streak maintenance). Notifications are generated locally on your device without tracking your activity.',
          ),

          // 6. Data Storage
          _buildSection(
            context: context,
            title: '6. Data Storage',
            icon: Icons.storage_outlined,
            content:
                'All user profile information, quests, hydration logs, and achievements are stored directly on your physical device using local SQLite database and SharedPreferences storage. You have full offline access at all times.',
          ),

          // 7. Data Security
          _buildSection(
            context: context,
            title: '7. Data Security',
            icon: Icons.lock_outline,
            content:
                'Because your data resides locally on your device, it is safeguarded by your operating system\'s application sandbox security, device passcode, and biometric protections.',
          ),

          // 8. Third-Party Services
          _buildSection(
            context: context,
            title: '8. Third-Party Services',
            icon: Icons.public_outlined,
            content:
                'LevelUp does not embed third-party advertising trackers, data brokers, or analytics tracking SDKs that profile your behavior across apps or websites.',
          ),

          // 9. Children\'s Privacy
          _buildSection(
            context: context,
            title: '9. Children\'s Privacy',
            icon: Icons.child_care_outlined,
            content:
                'LevelUp is safe for users of all ages. We do not knowingly collect personal identifiable information from children under 13.',
          ),

          // 10. Changes to This Privacy Policy
          _buildSection(
            context: context,
            title: '10. Changes to This Privacy Policy',
            icon: Icons.update_outlined,
            content:
                'We may update our Privacy Policy periodically. Any modifications will be reflected immediately within this in-app page with an updated "Last Updated" date.',
          ),

          // 11. Contact Us
          _buildSection(
            context: context,
            title: '11. Contact Us',
            icon: Icons.mail_outline,
            content:
                'If you have any questions, suggestions, or feedback regarding this Privacy Policy or your data in LevelUp, please reach out to our team at:\n\n'
                'Email: support@levelup-rpg.com\n'
                'Website: https://levelup-rpg.com',
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
