import 'package:flutter/material.dart';
import '../models/models.dart';

class TaskCompletionCelebrationDialog extends StatelessWidget {
  final RPGTask task;
  final int xpEarned;
  final int currentStreak;
  final String motivationalQuote;
  final VoidCallback onDismiss;

  const TaskCompletionCelebrationDialog({
    Key? key,
    required this.task,
    required this.xpEarned,
    required this.currentStreak,
    required this.motivationalQuote,
    required this.onDismiss,
  }) : super(key: key);

  String _getCategoryHeadline() {
    switch (task.category) {
      case 'Fitness':
        return '💪 Workout Complete!';
      case 'Study':
        return '📚 Knowledge Increased!';
      case 'Health':
        return '💧 Health Quest Complete!';
      case 'Work':
        return '🚀 Mission Complete!';
      case 'Personal':
      default:
        return '✨ Personal Quest Complete!';
    }
  }

  String _getCategorySubtext() {
    switch (task.category) {
      case 'Fitness':
        return 'You finished your fitness quest. Keep building your strength!';
      case 'Study':
        return 'Study task completed successfully. Keep learning and earn more XP!';
      case 'Health':
        return 'Great job taking care of yourself and maintaining balance.';
      case 'Work':
        return 'Another step toward your goals. High productivity achieved!';
      case 'Personal':
      default:
        return 'Small progress every day creates big results.';
    }
  }

  Color _getCategoryColor() {
    switch (task.category) {
      case 'Fitness':
        return Colors.redAccent;
      case 'Study':
        return Colors.blueAccent;
      case 'Health':
        return Colors.green;
      case 'Work':
        return Colors.purpleAccent;
      case 'Personal':
      default:
        return const Color(0xFFF5B942);
    }
  }

  IconData _getCategoryIcon() {
    switch (task.category) {
      case 'Fitness':
        return Icons.fitness_center;
      case 'Study':
        return Icons.menu_book;
      case 'Health':
        return Icons.favorite;
      case 'Work':
        return Icons.work;
      case 'Personal':
      default:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final catColor = _getCategoryColor();
    final cardBg = isDark ? const Color(0xFF162033) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF5B942), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF5B942).withValues(alpha: isDark ? 0.25 : 0.15),
              blurRadius: 30,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Glowing Category Circle
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: catColor.withValues(alpha: 0.15),
                border: Border.all(color: catColor, width: 2.5),
              ),
              child: Icon(_getCategoryIcon(), color: catColor, size: 36),
            ),
            const SizedBox(height: 16),

            // Dialog Header
            const Text(
              '🎉 QUEST COMPLETE!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Color(0xFFF5B942),
              ),
            ),
            const SizedBox(height: 8),

            // Category Headline
            Text(
              _getCategoryHeadline(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),

            // Task Name
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Text(
                task.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),

            Text(
              _getCategorySubtext(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Rewards Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // XP Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: (isDark ? const Color(0xFF4CAF50) : const Color(0xFF16A34A)).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? const Color(0xFF4CAF50) : const Color(0xFF16A34A)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt, color: isDark ? const Color(0xFF4CAF50) : const Color(0xFF16A34A), size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '+$xpEarned XP',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF4CAF50) : const Color(0xFF16A34A),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Streak Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orangeAccent),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '$currentStreak Day Streak',
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Motivational Quote
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5B942).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF5B942).withValues(alpha: 0.3)),
              ),
              child: Text(
                motivationalQuote,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF5B942),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5B942),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onDismiss();
                },
                child: const Text(
                  'GREAT JOB! KEEP LEVELING UP',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LevelUpCelebrationDialog extends StatelessWidget {
  final int newLevel;
  final VoidCallback onDismiss;

  const LevelUpCelebrationDialog({
    Key? key,
    required this.newLevel,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF162033) : Colors.white;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF5B942), width: 3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF5B942).withValues(alpha: 0.3),
              blurRadius: 36,
              spreadRadius: 4,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Level Badge
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF5B942), Color(0xFFD97706)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF5B942).withValues(alpha: 0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$newLevel',
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              '🎊 LEVEL UP!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF5B942),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'Congratulations, Hero!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),

            Text(
              'You reached Level $newLevel.\nKeep completing quests to become stronger!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5B942),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onDismiss();
                },
                child: const Text(
                  'CLAIM REWARDS & CONTINUE',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AchievementUnlockedCelebrationDialog extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback onDismiss;

  const AchievementUnlockedCelebrationDialog({
    Key? key,
    required this.achievement,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF162033) : Colors.white;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.amber, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.25),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amber.withValues(alpha: 0.2),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: const Icon(Icons.emoji_events, color: Colors.amber, size: 40),
            ),
            const SizedBox(height: 16),

            const Text(
              '🏆 ACHIEVEMENT UNLOCKED!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),

            Text(
              achievement.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),

            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (achievement.xpReward > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  '+${achievement.xpReward} XP Reward',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            ],
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onDismiss();
                },
                child: const Text('AWESOME!', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
