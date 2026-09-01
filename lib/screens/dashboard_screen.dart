import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/profile_widget.dart';
import '../widgets/task_list_item.dart';
import '../models/models.dart';
import 'dart:math';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  void _showAddTaskModal(BuildContext context) {
    String title = '';
    String description = '';
    String category = 'Fitness';
    int xpReward = 10;
    TimeOfDay? selectedTime;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Create New Quest', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Quest Title'),
                    onChanged: (val) => title = val,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Description (Optional)'),
                    onChanged: (val) => description = val,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Due Time'),
                    subtitle: Text(selectedTime != null ? selectedTime!.format(context) : 'Not set'),
                    leading: const Icon(Icons.access_time),
                    contentPadding: EdgeInsets.zero,
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() => selectedTime = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: category,
                          decoration: const InputDecoration(labelText: 'Category'),
                          items: ['Fitness', 'Learning', 'Chores', 'Work', 'Health']
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (val) => category = val ?? 'Fitness',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: xpReward,
                          decoration: const InputDecoration(labelText: 'XP Reward'),
                          items: const [
                            DropdownMenuItem(value: 10, child: Text('10 XP (Easy)')),
                            DropdownMenuItem(value: 25, child: Text('25 XP (Medium)')),
                            DropdownMenuItem(value: 50, child: Text('50 XP (Hard)')),
                            DropdownMenuItem(value: 100, child: Text('100 XP (Epic)')),
                          ],
                          onChanged: (val) => xpReward = val ?? 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (title.isNotEmpty) {
                        final task = RPGTask(
                          id: DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(1000).toString(),
                          title: title,
                          description: description,
                          category: category,
                          xpReward: xpReward,
                          dueDate: DateTime.now().add(const Duration(days: 1)),
                          time: selectedTime?.format(context),
                        );
                        context.read<AppState>().addTask(task);
                        Navigator.pop(context);
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Add Quest'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: Consumer<AppState>(
        builder: (context, state, child) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final activeTasks = state.activeTasks;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Image.asset(
                  'assets/logo.png',
                  height: 120,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(height: 0),
                ),
              ),
              const SizedBox(height: 16),
              ProfileWidget(),
              const SizedBox(height: 16),
              // Quick Stats
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Text(
                              '${state.completedTasks.length}',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text('Quests Done', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Text(
                              '${state.activeTasks.length}',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text('Active Quests', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Quests',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddTaskModal(context),
                    icon: const Icon(Icons.add),
                    label: const Text('New'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (activeTasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      'No active quests. Add one to earn XP!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...activeTasks.map((task) => TaskListItem(task: task)).toList(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
