import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../screens/quest_details_screen.dart';
import '../providers/app_state.dart';

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
      case 'Health':
        return Image.asset('assets/images/workout_quest.jpg', width: 60, height: 60, fit: BoxFit.cover);
      case 'Work':
        return Image.asset('assets/images/study_quest.jpg', width: 60, height: 60, fit: BoxFit.cover);
      case 'Study':
      case 'Personal':
      default:
        return Image.asset('assets/images/book_quest.jpg', width: 60, height: 60, fit: BoxFit.cover);
    }
  }

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
    // We watch AppState here so the timer updates every second.
    final state = context.watch<AppState>();
    int remaining = state.getCalculatedRemainingSeconds(task);

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
                          color: task.isCompleted ? Colors.grey : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(task.category, style: const TextStyle(color: Color(0xFFAAB4C2), fontSize: 12)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '+${task.xpReward} XP', 
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12, 
                              fontWeight: FontWeight.bold
                            )
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ⏱ ${task.durationMinutes} min',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 12,
                              fontWeight: FontWeight.bold
                            )
                          ),
                        ],
                      ),
                      
                      // Timer UI
                      if (!task.isCompleted) ...[
                        const SizedBox(height: 12),
                        if (task.timerStatus == 'Not Started')
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.play_arrow, size: 18),
                              label: const Text('Start Task'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2A3042),
                                foregroundColor: Colors.amber,
                                padding: const EdgeInsets.symmetric(vertical: 8),
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
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2A3042),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.zero,
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
                                    backgroundColor: Colors.amber,
                                    foregroundColor: Colors.black,
                                    padding: EdgeInsets.zero,
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
                        color: Colors.green,
                        border: Border.all(color: Colors.green, width: 2),
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
