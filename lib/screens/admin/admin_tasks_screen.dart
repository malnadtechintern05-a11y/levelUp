import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_state.dart';
import 'admin_task_form_screen.dart';

class AdminTasksScreen extends StatefulWidget {
  const AdminTasksScreen({Key? key}) : super(key: key);

  @override
  State<AdminTasksScreen> createState() => _AdminTasksScreenState();
}

class _AdminTasksScreenState extends State<AdminTasksScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AdminState>();
    final tasks = state.tasks.where((t) {
      return t.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
             t.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Manage Tasks',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  SizedBox(
                    width: 250,
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search tasks...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF1E293B),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminTaskFormScreen()));
                    },
                    icon: const Icon(Icons.add, color: Colors.black),
                    label: const Text('Add Task', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    headingTextStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    dataTextStyle: const TextStyle(color: Colors.white),
                    columns: const [
                      DataColumn(label: Text('Task Name')),
                      DataColumn(label: Text('Category')),
                      DataColumn(label: Text('XP Reward')),
                      DataColumn(label: Text('Duration (min)')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: tasks.map((task) {
                      return DataRow(cells: [
                        DataCell(Text(task.title)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(task.category, style: const TextStyle(color: Colors.blue, fontSize: 12)),
                          ),
                        ),
                        DataCell(Text(task.xpReward.toString(), style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))),
                        DataCell(Text(task.durationMinutes.toString())),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: task.isActive ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              task.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(color: task.isActive ? Colors.green : Colors.red, fontSize: 12),
                            ),
                          ),
                        ),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.amber),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => AdminTaskFormScreen(task: task)
                                ));
                              },
                            ),
                            IconButton(
                              icon: Icon(task.isActive ? Icons.block : Icons.check_circle, color: task.isActive ? Colors.red : Colors.green),
                              onPressed: () {
                                context.read<AdminState>().toggleTaskStatus(task.id);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                context.read<AdminState>().deleteTask(task.id);
                              },
                            ),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
