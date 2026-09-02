import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../screens/quest_details_screen.dart';
import '../providers/app_state.dart';
import 'hydration_quest_card.dart';

class QuestCard extends StatelessWidget {
  final RPGTask task;
  final VoidCallback onComplete;

  const QuestCard({
    Key? key,
    required this.task,
    required this.onComplete,
  }) : super(key: key);

  String _capitalize(String input) {
    if (input.isEmpty) return input;
    return input.split(' ').map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }

  Color _getCategoryColor() {
    switch (task.category) {
      case 'Study': return Colors.blueAccent;
      case 'Fitness': return Colors.redAccent;
      case 'Health': return Colors.green;
      case 'Work': return Colors.purpleAccent;
      case 'Personal': default: return Colors.greenAccent;
    }
  }

  Widget _buildImage() {
    final title = task.title.toLowerCase();
    
    // Keyword overrides
    if (title.contains('run')) {
      return Image.asset('assets/images/run_quest.jpg', width: 60, height: 60, fit: BoxFit.cover);
    }
    if (title.contains('meditat') || title.contains('yoga')) {
      return Image.asset('assets/images/yoga_quest.jpg', width: 60, height: 60, fit: BoxFit.cover);
    }

    // Category fallbacks
    switch (task.category) {
      case 'Fitness':
        return Image.asset('assets/images/workout_quest.jpg', width: 60, height: 60, fit: BoxFit.cover);
      case 'Health':
        return Image.asset('assets/images/health_quest.jpg', width: 60, height: 60, fit: BoxFit.cover);
      case 'Work':
        return Image.asset('assets/images/work_quest.jpg', width: 60, height: 60, fit: BoxFit.cover);
      case 'Study':
        return Image.asset('assets/images/book_quest.jpg', width: 60, height: 60, fit: BoxFit.cover);
      case 'Personal':
      default:
        return Image.asset('assets/images/personal_quest.jpg', width: 60, height: 60, fit: BoxFit.cover);
    }
  }

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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF5B942),
              foregroundColor: Colors.black,
            ),
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
      return HydrationQuestCard(task: task);
    }

    // We watch AppState here so the timer updates every second.
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    int remaining = state.getCalculatedRemainingSeconds(task);

    final actionBtnBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final actionBtnBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final actionBtnText = isDark ? Colors.white : const Color(0xFF0F172A);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => QuestDetailsScreen(task: task)));
        },
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Colored left strip
              Container(
                width: 6,
                color: _getCategoryColor(),
              ),
              const SizedBox(width: 8),
              
              // Image
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildImage(),
                ),
              ),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _capitalize(task.title),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          color: task.isCompleted ? Colors.grey : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.category, 
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant, 
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '+${task.xpReward} XP', 
                            style: TextStyle(
                              color: isDark ? const Color(0xFF4CAF50) : const Color(0xFF16A34A),
                              fontSize: 12, 
                              fontWeight: FontWeight.bold
                            )
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ⏱ ${task.durationMinutes} min',
                            style: const TextStyle(
                              color: Color(0xFFF5B942),
                              fontSize: 12,
                              fontWeight: FontWeight.bold
                            )
                          ),
                        ],
                      ),
                      
                      // Timer / Availability UI
                      if (!task.isCompleted) ...[
                        const SizedBox(height: 12),
                        if (state.isTaskFuture(task))
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.lock_outline, size: 16, color: Color(0xFF94A3B8)),
                              label: Text(
                                state.getTaskAvailabilityButtonText(task),
                                style: TextStyle(
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: actionBtnBg.withValues(alpha: 0.5),
                                side: BorderSide(color: actionBtnBorder),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('🔒 "${task.title}" is scheduled for ${state.getTaskAvailabilityDateText(task)}. It will unlock on that day!'),
                                    backgroundColor: Colors.orange.shade800,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              },
                            ),
                          )
                        else if (state.isTaskPast(task))
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.history_toggle_off, color: Colors.redAccent, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Missed Quest',
                                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                          )
                        else if (task.timerStatus == 'Not Started')
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.play_arrow, size: 18),
                              label: const Text('Start Task'),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: actionBtnBg,
                                foregroundColor: const Color(0xFFF5B942),
                                side: BorderSide(color: actionBtnBorder),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () {
                                    if (task.timerStatus == 'Running') {
                                      state.pauseTaskTimer(task.id);
                                    } else {
                                      state.startTaskTimer(task.id);
                                    }
                                  },
                                  child: Text(task.timerStatus == 'Running' ? 'Pause' : 'Resume', style: const TextStyle(fontWeight: FontWeight.w600)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF5B942),
                                    foregroundColor: Colors.black,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () {
                                    state.pauseTaskTimer(task.id); // Pause while in dialog
                                    _showEarlyFinishDialog(context, state);
                                  },
                                  child: const Text('Finish', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ]
                      ]
                    ],
                  ),
                ),
              ),
              
              // Animated Checkbox (Only for Completed Tasks)
              if (task.isCompleted)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? const Color(0xFF4CAF50) : const Color(0xFF16A34A),
                        border: Border.all(color: isDark ? const Color(0xFF4CAF50) : const Color(0xFF16A34A), width: 2),
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 20),
                    ),
                  ),
                )
              else
                const SizedBox(width: 16), // Padding for incomplete tasks
            ],
          ),
        ),
      ),
    );
  }
}
