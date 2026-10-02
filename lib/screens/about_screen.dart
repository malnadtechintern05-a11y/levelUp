import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget child,
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5B942).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFFF5B942), size: 20),
              ),
              const SizedBox(width: 12),
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
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildFeatureRow({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required BuildContext context,
    required String stepNumber,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFF5B942),
              shape: BoxShape.circle,
            ),
            child: Text(
              stepNumber,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
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
        title: const Text('About LevelUp', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero Header Card
          Container(
            padding: const EdgeInsets.all(22),
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
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5B942),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_rounded, size: 44, color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'LevelUp',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5B942).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF5B942).withValues(alpha: 0.4)),
                  ),
                  child: const Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF5B942),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Gamify your reality, conquer daily habits, and become the hero of your own life.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // 1. Mission & Philosophy
          _buildCard(
            context: context,
            title: 'Our Mission',
            icon: Icons.flag_outlined,
            child: Text(
              'LevelUp was created with a simple yet powerful idea: self-improvement should feel like an exciting RPG journey rather than a chore.\n\n'
              'By turning your daily habits, study routines, fitness activities, and hydration into interactive quests with XP, leveling, and rewards, LevelUp helps you stay consistent, beat procrastination, and build lifelong momentum.',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),

          // 2. Core Features
          _buildCard(
            context: context,
            title: 'Core Features',
            icon: Icons.star_outline_rounded,
            child: Column(
              children: [
                _buildFeatureRow(
                  context: context,
                  icon: Icons.sports_martial_arts_rounded,
                  iconColor: const Color(0xFFF5B942),
                  title: 'Real-Life Quests & Tasks',
                  description: 'Create custom quests with difficulty tiers (Easy to Epic) and earn instant XP and Gold rewards.',
                ),
                _buildFeatureRow(
                  context: context,
                  icon: Icons.trending_up_rounded,
                  iconColor: Colors.greenAccent,
                  title: 'Hero Attributes (STR, DIS, KNO)',
                  description: 'Boost your Strength, Discipline, and Knowledge stats based on real actions you perform every day.',
                ),
                _buildFeatureRow(
                  context: context,
                  icon: Icons.water_drop_rounded,
                  iconColor: Colors.lightBlueAccent,
                  title: 'Hydration Tracker',
                  description: 'Monitor your daily water intake with visual indicators, milestone goals, and hydration bonuses.',
                ),
                _buildFeatureRow(
                  context: context,
                  icon: Icons.local_fire_department_rounded,
                  iconColor: Colors.orangeAccent,
                  title: 'Daily Streak Counter',
                  description: 'Keep your streak alive with daily consistency and earn bonus multiplier multipliers.',
                ),
                _buildFeatureRow(
                  context: context,
                  icon: Icons.emoji_events_rounded,
                  iconColor: Colors.amber,
                  title: 'Trophies & Achievements',
                  description: 'Unlock milestone badges and showcase your achievements in your trophy room.',
                ),
                _buildFeatureRow(
                  context: context,
                  icon: Icons.lock_outline_rounded,
                  iconColor: Colors.purpleAccent,
                  title: 'Offline & Privacy First',
                  description: 'Your habits, quest history, and progress stay strictly on your device.',
                ),
              ],
            ),
          ),

          // 3. How It Works
          _buildCard(
            context: context,
            title: 'How It Works',
            icon: Icons.lightbulb_outline,
            child: Column(
              children: [
                _buildStepItem(
                  context: context,
                  stepNumber: '1',
                  title: 'Choose or Create Your Quests',
                  description: 'Set your daily goals, tasks, study habits, or workout routines.',
                ),
                _buildStepItem(
                  context: context,
                  stepNumber: '2',
                  title: 'Conquer Them in Real Life',
                  description: 'Take action, track your timer if needed, and check off completed quests.',
                ),
                _buildStepItem(
                  context: context,
                  stepNumber: '3',
                  title: 'Collect XP & Level Up',
                  description: 'Gain experience points, accumulate gold, and watch your hero rank rise.',
                ),
                _buildStepItem(
                  context: context,
                  stepNumber: '4',
                  title: 'Build Consistent Streaks',
                  description: 'Stay committed every day to unlock prestigious trophies and badges.',
                ),
              ],
            ),
          ),

          // 4. App Information & Credits
          _buildCard(
            context: context,
            title: 'App Information',
            icon: Icons.info_outline,
            child: Column(
              children: [
                _buildInfoRow(context, 'App Name', 'LevelUp: Real-Life RPG'),
                _buildInfoRow(context, 'Version', '1.0.0 (Release)'),
                _buildInfoRow(context, 'Platform', 'Flutter Cross-Platform'),
                _buildInfoRow(context, 'Target Audience', 'Self-Improvers & RPG Fans'),
                _buildInfoRow(context, 'Support Email', 'support@levelup-rpg.com'),
                const Divider(height: 20),
                Text(
                  '© 2026 LevelUp Team. All rights reserved.\nCrafted with ❤️ to help you conquer real-life goals.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
