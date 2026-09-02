import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';

class HydrationDetailsScreen extends StatefulWidget {
  final String taskId;

  const HydrationDetailsScreen({
    Key? key,
    required this.taskId,
  }) : super(key: key);

  @override
  State<HydrationDetailsScreen> createState() => _HydrationDetailsScreenState();
}

class _HydrationDetailsScreenState extends State<HydrationDetailsScreen> {
  final List<int> _standardGoals = [1500, 2000, 2500, 3000];

  void _showCustomGoalDialog(BuildContext context, AppState state, RPGTask task) {
    final theme = Theme.of(context);
    final controller = TextEditingController(text: (task.waterGoalMl / 1000).toStringAsFixed(1));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Custom Water Goal', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter daily goal in Liters (e.g. 2.8):', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                suffixText: 'L',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF5B942),
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              final val = double.tryParse(controller.text.trim());
              if (val != null && val > 0) {
                final goalMl = (val * 1000).round();
                state.updateWaterGoal(task.id, goalMl);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save Goal', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCustomAddDialog(BuildContext context, AppState state, RPGTask task) {
    final theme = Theme.of(context);
    final controller = TextEditingController(text: '300');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Custom Water Amount', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter amount in milliliters (ml):', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                suffixText: 'ml',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38BDF8),
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              final val = int.tryParse(controller.text.trim());
              if (val != null && val > 0) {
                state.addWater(task.id, val, context);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add Water', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final taskIndex = state.tasks.indexWhere((t) => t.id == widget.taskId);
    if (taskIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hydration Quest')),
        body: const Center(child: Text('Quest not found.')),
      );
    }

    final task = state.tasks[taskIndex];
    final userProfile = state.userProfile;

    final currentLiters = (task.currentWaterMl / 1000).toStringAsFixed(1);
    final goalLiters = (task.waterGoalMl / 1000).toStringAsFixed(1);
    final progress = (task.waterGoalMl > 0 ? (task.currentWaterMl / task.waterGoalMl) : 0.0).clamp(0.0, 1.0);
    final percentInt = (progress * 100).toInt();

    final cardBg = isDark ? const Color(0xFF162033) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final btnBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final aquaColor = const Color(0xFF0284C7);
    final brightAqua = const Color(0xFF38BDF8);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.water_drop, color: Color(0xFF38BDF8), size: 22),
            SizedBox(width: 8),
            Text('Hydration Quest', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Main Hydration Vessel Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: brightAqua.withValues(alpha: 0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: brightAqua.withValues(alpha: isDark ? 0.08 : 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DAILY WATER PROGRESS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$currentLiters L',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: brightAqua,
                              ),
                            ),
                            Text(
                              ' / $goalLiters L',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: (task.isCompleted ? const Color(0xFF16A34A) : aquaColor).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: task.isCompleted ? const Color(0xFF22C55E) : brightAqua,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            task.isCompleted ? Icons.check_circle : Icons.water_drop,
                            color: task.isCompleted ? const Color(0xFF22C55E) : brightAqua,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            task.isCompleted ? 'Goal Met' : '$percentInt%',
                            style: TextStyle(
                              color: task.isCompleted ? const Color(0xFF22C55E) : brightAqua,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Animated Fluid Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 18,
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
                                  task.isCompleted ? const Color(0xFF22C55E) : const Color(0xFF38BDF8),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${task.currentWaterMl} ml logged',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${task.waterGoalMl} ml target',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Goal Selector Section
          Text(
            'SELECT DAILY WATER GOAL',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ..._standardGoals.map((g) {
                  final isSelected = task.waterGoalMl == g;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text('${(g / 1000).toStringAsFixed(1)} L'),
                      selected: isSelected,
                      selectedColor: const Color(0xFFF5B942),
                      backgroundColor: cardBg,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : theme.colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          state.updateWaterGoal(task.id, g);
                        }
                      },
                    ),
                  );
                }),
                ActionChip(
                  avatar: const Icon(Icons.tune, size: 16, color: Color(0xFF38BDF8)),
                  label: Text(
                    !_standardGoals.contains(task.waterGoalMl)
                        ? '${(task.waterGoalMl / 1000).toStringAsFixed(1)} L (Custom)'
                        : 'Custom',
                  ),
                  backgroundColor: !_standardGoals.contains(task.waterGoalMl)
                      ? const Color(0xFFF5B942).withValues(alpha: 0.2)
                      : cardBg,
                  labelStyle: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  onPressed: () => _showCustomGoalDialog(context, state, task),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Add Water Section
          Text(
            'QUICK ADD WATER',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          if (state.isTaskFuture(task)) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: btnBg.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, color: Color(0xFF94A3B8), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '🔒 This quest is scheduled for ${state.getTaskAvailabilityDateText(task)}. Hydration tracking will unlock on that day.',
                      style: TextStyle(
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (state.isTaskPast(task)) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.history_toggle_off, color: Colors.redAccent, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This Hydration Quest was scheduled for a past date and has expired.',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                _buildQuickAddButton(context, state, task, 250, '+250 ml', Icons.local_drink),
                _buildQuickAddButton(context, state, task, 500, '+500 ml', Icons.water_drop),
                _buildQuickAddButton(context, state, task, 750, '+750 ml', Icons.sports_bar),
                _buildQuickAddButton(context, state, task, 1000, '+1 Liter', Icons.opacity),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.add_circle_outline, color: Color(0xFF38BDF8)),
              label: const Text('+ Custom Amount (ml)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface,
                side: BorderSide(color: borderColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _showCustomAddDialog(context, state, task),
            ),
          ],
          const SizedBox(height: 24),

          // Hydration Streak & Rewards Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 28),
                    const SizedBox(height: 4),
                    Text(
                      '${userProfile.hydrationCurrentStreak} Days',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                    ),
                    Text(
                      'Hydration Streak',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                Container(width: 1, height: 40, color: borderColor),
                Column(
                  children: [
                    const Icon(Icons.emoji_events, color: Color(0xFFF5B942), size: 28),
                    const SizedBox(height: 4),
                    Text(
                      '${userProfile.hydrationBestStreak} Days',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                    ),
                    Text(
                      'Best Streak',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                Container(width: 1, height: 40, color: borderColor),
                Column(
                  children: [
                    const Icon(Icons.bolt, color: Color(0xFFF5B942), size: 28),
                    const SizedBox(height: 4),
                    Text(
                      '+50 XP',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF4CAF50) : const Color(0xFF16A34A),
                      ),
                    ),
                    Text(
                      'Daily Reward',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Today's Water History
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TODAY'S WATER LOG",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              Text(
                '${task.waterLogs.length} entries',
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (task.waterLogs.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.water_drop_outlined, size: 40, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                    const SizedBox(height: 8),
                    Text(
                      'No water logged yet today.',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap a quick-add button above to start hydrating!',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: task.waterLogs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final log = task.waterLogs[index];
                final timeFormatted = DateFormat('h:mm a').format(log.timestamp);

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: brightAqua.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.water_drop, color: Color(0xFF38BDF8), size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '+${log.amountMl} ml',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              timeFormatted,
                              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        tooltip: 'Delete / Undo entry',
                        onPressed: () {
                          state.removeWaterLog(task.id, log.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Removed ${log.amountMl} ml water entry.'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton(
    BuildContext context,
    AppState state,
    RPGTask task,
    int amountMl,
    String label,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final btnBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final btnBorder = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);

    return InkWell(
      onTap: () => state.addWater(task.id, amountMl, context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: btnBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: btnBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF38BDF8), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
