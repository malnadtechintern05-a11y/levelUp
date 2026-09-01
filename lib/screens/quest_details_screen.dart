import 'dart:async';
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
  String _formatDuration(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

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
                color: _getCategoryColor().withOpacity(0.2),
                border: Border.all(color: _getCategoryColor(), width: 3),
              ),
              child: Icon(_getCategoryIcon(), size: 60, color: _getCategoryColor()),
            ),
            const SizedBox(height: 24),
            Text(
              widget.task.title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getCategoryColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(widget.task.category, style: TextStyle(color: _getCategoryColor(), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text('+${widget.task.xpReward} XP', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Timer UI
            if (!widget.task.isCompleted) ...[
              Consumer<AppState>(
                builder: (context, state, child) {
                  int remaining = state.getCalculatedRemainingSeconds(widget.task);
                  return Card(
                    color: const Color(0xFF162033),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: widget.task.timerStatus == 'Running' ? Colors.amber : Colors.transparent, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          if (widget.task.timerStatus == 'Not Started')
                            Text(
                              '${widget.task.durationMinutes}:00',
                              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                            )
                          else
                            Text(
                              '${(remaining ~/ 60).toString().padLeft(2, '0')}:${(remaining % 60).toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 48, 
                                fontWeight: FontWeight.bold, 
                                color: widget.task.timerStatus == 'Running' ? Colors.amber : Colors.white
                              ),
                            ),
                          const SizedBox(height: 16),
                          if (widget.task.timerStatus == 'Not Started')
                            ElevatedButton.icon(
                              onPressed: () => state.startTaskTimer(widget.task.id),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('START TIMER', style: TextStyle(fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                                    backgroundColor: widget.task.timerStatus == 'Running' ? Colors.orange : Colors.amber,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                color: Colors.green.withOpacity(0.2),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 48),
                      const SizedBox(height: 8),
                      const Text('Quest Completed!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 4),
                      Text('Duration: ${widget.task.durationMinutes} min', style: const TextStyle(color: Colors.white70)),
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
                        const Text('Description', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(widget.task.description, style: const TextStyle(fontSize: 16, height: 1.5)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!widget.task.isCompleted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('COMPLETE QUEST EARLY', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    context.read<AppState>().finishTaskEarly(widget.task.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('+${widget.task.xpReward} XP Earned!'), backgroundColor: Colors.green),
                    );
                    Navigator.pop(context);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
