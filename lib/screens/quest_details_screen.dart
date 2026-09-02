import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/models.dart';

class QuestDetailsScreen extends StatefulWidget {
  final RPGTask task;
  
  const QuestDetailsScreen({Key? key, required this.task}) : super(key: key);

  @override
  State<QuestDetailsScreen> createState() => _QuestDetailsScreenState();
}

class _QuestDetailsScreenState extends State<QuestDetailsScreen> {
  IconData _getCategoryIcon() {
    switch (widget.task.category) {
      case 'Study': return Icons.menu_book;
      case 'Fitness': return Icons.fitness_center;
      case 'Health': return Icons.favorite;
      case 'Work': return Icons.work;
      case 'Personal': default: return Icons.person;
    }
  }

  Color _getCategoryColor() {
    switch (widget.task.category) {
      case 'Study': return Colors.blueAccent;
      case 'Fitness': return Colors.orangeAccent;
      case 'Health': return Colors.redAccent;
      case 'Work': return Colors.purpleAccent;
      case 'Personal': default: return Colors.tealAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Quest Details')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getCategoryColor().withValues(alpha: 0.15),
                border: Border.all(color: _getCategoryColor(), width: 3),
              ),
              child: Icon(_getCategoryIcon(), size: 60, color: _getCategoryColor()),
            ),
            const SizedBox(height: 24),
            Text(
              widget.task.title,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getCategoryColor().withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(widget.task.category, style: TextStyle(color: _getCategoryColor(), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5B942).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFF5B942), size: 16),
                      const SizedBox(width: 4),
                      Text('+${widget.task.xpReward} XP', style: const TextStyle(color: Color(0xFFF5B942), fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Timer / Availability UI
            if (!widget.task.isCompleted) ...[
              Consumer<AppState>(
                builder: (context, state, child) {
                  if (state.isTaskFuture(widget.task)) {
                    return Card(
                      color: isDark ? const Color(0xFF162033) : const Color(0xFFF1F5F9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: theme.colorScheme.outline),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            const Icon(Icons.lock_outline, size: 48, color: Color(0xFF94A3B8)),
                            const SizedBox(height: 12),
                            Text(
                              'Quest Locked',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'This quest is scheduled for ${state.getTaskAvailabilityDateText(widget.task)} and will automatically unlock on that day.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state.isTaskPast(widget.task)) {
                    return Card(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            const Icon(Icons.history_toggle_off, size: 48, color: Colors.redAccent),
                            const SizedBox(height: 12),
                            const Text(
                              'Missed Quest',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'This quest was scheduled for ${state.getTaskAvailabilityDateText(widget.task)} and has expired.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  int remaining = state.getCalculatedRemainingSeconds(widget.task);
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: widget.task.timerStatus == 'Running' ? const Color(0xFFF5B942) : theme.colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          if (widget.task.timerStatus == 'Not Started')
                            Text(
                              '${widget.task.durationMinutes}:00',
                              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                            )
                          else
                            Text(
                              '${(remaining ~/ 60).toString().padLeft(2, '0')}:${(remaining % 60).toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 48, 
                                fontWeight: FontWeight.bold, 
                                color: widget.task.timerStatus == 'Running' ? const Color(0xFFF5B942) : theme.colorScheme.onSurface,
                              ),
                            ),
                          const SizedBox(height: 16),
                          if (widget.task.timerStatus == 'Not Started')
                            ElevatedButton.icon(
                              onPressed: () => state.startTaskTimer(widget.task.id),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('START TIMER', style: TextStyle(fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF5B942),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            )
                          else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    if (widget.task.timerStatus == 'Running') {
                                      state.pauseTaskTimer(widget.task.id);
                                    } else {
                                      state.startTaskTimer(widget.task.id);
                                    }
                                  },
                                  icon: Icon(widget.task.timerStatus == 'Running' ? Icons.pause : Icons.play_arrow),
                                  label: Text(widget.task.timerStatus == 'Running' ? 'PAUSE' : 'RESUME', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: widget.task.timerStatus == 'Running' ? Colors.orange : const Color(0xFFF5B942),
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                }
              ),
            ],

            if (widget.task.isCompleted)
              Card(
                color: isDark ? const Color(0xFF4CAF50).withValues(alpha: 0.15) : const Color(0xFF16A34A).withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: isDark ? const Color(0xFF4CAF50) : const Color(0xFF16A34A)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle, color: isDark ? const Color(0xFF4CAF50) : const Color(0xFF16A34A), size: 48),
                      const SizedBox(height: 8),
                      Text('Quest Completed!', style: TextStyle(color: isDark ? const Color(0xFF4CAF50) : const Color(0xFF16A34A), fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 4),
                      Text('Duration: ${widget.task.durationMinutes} min', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Description', style: TextStyle(color: isDark ? const Color(0xFFF5B942) : const Color(0xFFD97706), fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(widget.task.description, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16, height: 1.5)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Consumer<AppState>(
              builder: (context, state, child) {
                if (!widget.task.isCompleted && state.isTaskToday(widget.task)) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('COMPLETE QUEST EARLY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: isDark ? const Color(0xFF4CAF50) : const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        context.read<AppState>().finishTaskEarly(widget.task.id);
                        Navigator.pop(context);
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
