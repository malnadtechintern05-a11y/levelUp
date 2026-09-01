import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';

class TaskListItem extends StatelessWidget {
  final RPGTask task;

  const TaskListItem({Key? key, required this.task}) : super(key: key);

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _showEarlyFinishDialog(BuildContext context, AppState state) {
    int elapsed = (task.durationMinutes * 60) - state.getCalculatedRemainingSeconds(task);
    int elapsedMins = elapsed ~/ 60;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF162033),
        title: const Text('Finish task early?', style: TextStyle(color: Colors.white)),
        content: Text('You have completed $elapsedMins of ${task.durationMinutes} minutes.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (task.timerStatus == 'Paused') {
                state.startTaskTimer(task.id);
              }
            },
            child: const Text('Continue Timer', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
            onPressed: () {
              Navigator.pop(context);
              state.finishTaskEarly(task.id);
            },
            child: const Text('Finish Task'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    int remaining = state.getCalculatedRemainingSeconds(task);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getCategoryIcon(task.category),
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(task.description),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${task.xpReward} XP',
                            style: TextStyle(color: Colors.amber[800], fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ⏱ ${task.durationMinutes} min',
                            style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (task.isCompleted)
                  const Icon(Icons.check_circle, color: Colors.green, size: 32),
              ],
            ),
            if (!task.isCompleted) ...[
              const SizedBox(height: 16),
              if (task.timerStatus == 'Not Started')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Start Task'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A3042),
                      foregroundColor: Colors.amber,
                    ),
                    onPressed: () => state.startTaskTimer(task.id),
                  ),
                )
              else ...[
                Text(
                  '⏱ ${_formatTime(remaining)} remaining',
                  style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2A3042), foregroundColor: Colors.white),
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
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
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
