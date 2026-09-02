import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../screens/hydration_details_screen.dart';

class HydrationQuestCard extends StatelessWidget {
  final RPGTask task;

  const HydrationQuestCard({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userProfile = state.userProfile;

    final currentLiters = (task.currentWaterMl / 1000).toStringAsFixed(1);
    final goalLiters = (task.waterGoalMl / 1000).toStringAsFixed(1);
    final progress = (task.waterGoalMl > 0 ? (task.currentWaterMl / task.waterGoalMl) : 0.0).clamp(0.0, 1.0);
    final percentInt = (progress * 100).toInt();

    final cardBg = isDark ? const Color(0xFF162033) : Colors.white;
    const brightAqua = Color(0xFF38BDF8);
    const goldColor = Color(0xFFF5B942);

    final btnBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final btnBorder = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: task.isCompleted
              ? const Color(0xFF22C55E).withValues(alpha: 0.5)
              : brightAqua.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      color: cardBg,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HydrationDetailsScreen(taskId: task.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (task.isCompleted ? const Color(0xFF22C55E) : brightAqua).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      task.isCompleted ? Icons.check_circle : Icons.water_drop,
                      color: task.isCompleted ? const Color(0xFF22C55E) : brightAqua,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'HYDRATION QUEST',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                                color: task.isCompleted ? const Color(0xFF22C55E) : brightAqua,
                              ),
                            ),
                            const Spacer(),
                            if (task.isCompleted)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'GOAL MET',
                                  style: TextStyle(
                                    color: Color(0xFF22C55E),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress numbers & percentage
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$currentLiters L',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: task.isCompleted ? const Color(0xFF22C55E) : brightAqua,
                          ),
                        ),
                        TextSpan(
                          text: ' / $goalLiters L',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$percentInt% Complete',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: task.isCompleted ? const Color(0xFF22C55E) : goldColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 12,
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF0284C7),
                                task.isCompleted ? const Color(0xFF22C55E) : brightAqua,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Streak and Reward badges
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${userProfile.hydrationCurrentStreak} Day Streak',
                          style: const TextStyle(
                            color: Colors.orangeAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isDark ? const Color(0xFF4CAF50) : const Color(0xFF16A34A)).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: (isDark ? const Color(0xFF4CAF50) : const Color(0xFF16A34A)).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bolt,
                          color: isDark ? const Color(0xFF4CAF50) : const Color(0xFF16A34A),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${task.xpReward} XP',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF4CAF50) : const Color(0xFF16A34A),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Quick Add Buttons or Locked State
              if (!task.isCompleted && state.isTaskFuture(task)) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: btnBg.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: btnBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outline, size: 16, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 8),
                      Text(
                        state.getTaskAvailabilityButtonText(task),
                        style: TextStyle(
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (!task.isCompleted && state.isTaskPast(task)) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_toggle_off, color: Colors.redAccent, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Missed Hydration Quest',
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ] else if (!task.isCompleted) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickButton(
                        context: context,
                        state: state,
                        amountMl: 250,
                        label: '+250 ml',
                        btnBg: btnBg,
                        btnBorder: btnBorder,
                        textColor: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildQuickButton(
                        context: context,
                        state: state,
                        amountMl: 500,
                        label: '+500 ml',
                        btnBg: btnBg,
                        btnBorder: btnBorder,
                        textColor: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildQuickButton(
                        context: context,
                        state: state,
                        amountMl: 750,
                        label: '+750 ml',
                        btnBg: btnBg,
                        btnBorder: btnBorder,
                        textColor: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildQuickButton(
                        context: context,
                        state: state,
                        amountMl: 1000,
                        label: '+1 L',
                        btnBg: btnBg,
                        btnBorder: btnBorder,
                        textColor: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),

              // View Details Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.show_chart, size: 16),
                  label: const Text('VIEW HYDRATION DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: brightAqua,
                    side: BorderSide(color: brightAqua.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HydrationDetailsScreen(taskId: task.id),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickButton({
    required BuildContext context,
    required AppState state,
    required int amountMl,
    required String label,
    required Color btnBg,
    required Color btnBorder,
    required Color textColor,
  }) {
    return InkWell(
      onTap: () => state.addWater(task.id, amountMl, context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: btnBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: btnBorder),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
