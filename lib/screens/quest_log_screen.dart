import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/task_list_item.dart';

class QuestLogScreen extends StatelessWidget {
  const QuestLogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quest Log'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: Consumer<AppState>(
          builder: (context, state, child) {
            final activeTasks = state.activeTasks;
            final completedTasks = state.completedTasks;

            return TabBarView(
              children: [
                activeTasks.isEmpty
                    ? const Center(child: Text('No active quests.'))
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: activeTasks.length,
                        itemBuilder: (context, index) {
                          return TaskListItem(task: activeTasks[index]);
                        },
                      ),
                completedTasks.isEmpty
                    ? const Center(child: Text('No completed quests yet.'))
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: completedTasks.length,
                        itemBuilder: (context, index) {
                          return TaskListItem(task: completedTasks[index]);
                        },
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}
