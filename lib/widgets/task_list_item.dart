import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../screens/quest_details_screen.dart';
import 'hydration_quest_card.dart';

class TaskListItem extends StatelessWidget {
  final RPGTask task;

  const TaskListItem({Key? key, required this.task}) : super(key: key);

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _showEarlyFinishDialog(BuildContext context, AppState state) {
    final theme = Theme.of(context);
    int elapsed = (task.durationMinutes * 60) - state.getCalculatedRemainingSeconds(task);
    int elapsedMins = elapsed ~/ 60;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Finish task early?', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
        content: Text('You have completed $elapsedMins of ${task.durationMinutes} minutes.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (task.timerStatus == 'Paused') {
                state.startTaskTimer(task.id);
              }
            },
            child: Text('Continue Timer', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF5B942), foregroundColor: Colors.black),
            onPressed: () {
              Navigator.pop(context);
              state.finishTaskEarly(task.id);
            },
            child: const Text('Finish Task', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (task.taskType == 'hydration') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: HydrationQuestCard(task: task),
      );
    }

    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    int remaining = state.getCalculatedRemainingSeconds(task);

    final actionBtnBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final actionBtnBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final actionBtnText = isDark ? Colors.white : const Color(0xFF0F172A);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => QuestDetailsScreen(task: task)));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getCategoryIcon(task.category),
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(task.description, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Color(0xFFF5B942)),
                          const SizedBox(width: 4),
                          Text(
                            '${task.xpReward} XP',
                            style: const TextStyle(color: Color(0xFFF5B942), fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ⏱ ${task.durationMinutes} min',
                            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (task.isCompleted)
                  Icon(Icons.check_circle, color: isDark ? const Color(0xFF4CAF50) : const Color(0xFF16A34A), size: 32),
              ],
            ),
            if (!task.isCompleted) ...[
              const SizedBox(height: 16),
              if (task.timerStatus == 'Not Started')
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Start Task'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: actionBtnBg,
                      foregroundColor: const Color(0xFFF5B942),
                      side: BorderSide(color: actionBtnBorder),
                    ),
                    onPressed: () => state.startTaskTimer(task.id),
                  ),
                )
              else ...[
                Text(
                  '⏱ ${_formatTime(remaining)} remaining',
                  style: const TextStyle(color: Color(0xFFF5B942), fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: actionBtnBg,
                          foregroundColor: actionBtnText,
                          side: BorderSide(color: actionBtnBorder),
                        ),
                        onPressed: () {
                          if (task.timerStatus == 'Running') {
                            state.pauseTaskTimer(task.id);
                          } else {
                            state.startTaskTimer(task.id);
                          }
                        },
                        child: Text(task.timerStatus == 'Running' ? 'Pause' : 'Resume'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF5B942),
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          state.pauseTaskTimer(task.id);
                          _showEarlyFinishDialog(context, state);
                        },
                        child: const Text('Finish', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ]
            ],
          ],
        ),
      ),
    ),
  );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'fitness':
        return Icons.fitness_center;
      case 'learning':
        return Icons.menu_book;
      case 'chores':
        return Icons.cleaning_services;
      case 'work':
        return Icons.work;
      case 'health':
        return Icons.favorite;
      default:
        return Icons.task_alt;
    }
  }
}
