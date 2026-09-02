import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_state.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AdminState>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard Overview',
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildSummaryCard('Total Users', state.users.length.toString(), Icons.people, Colors.blue),
              _buildSummaryCard('Active Users', state.activeUsersCount.toString(), Icons.verified_user, Colors.green),
              _buildSummaryCard('Total Tasks', state.tasks.length.toString(), Icons.task, Colors.purple),
              _buildSummaryCard('Completed Tasks', state.totalTaskCompletions.toString(), Icons.check_circle, Colors.teal),
              _buildSummaryCard('Total XP Awarded', state.totalXPAwarded.toString(), Icons.star, Colors.amber),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildRecentList(
                  'Recent Users',
                  state.users.take(5).map((u) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.amber,
                      child: Text(u.username[0].toUpperCase(), style: const TextStyle(color: Colors.black)),
                    ),
                    title: Text(u.username, style: const TextStyle(color: Colors.white)),
                    subtitle: Text('Lvl ${u.level} | ${u.totalXP} XP', style: const TextStyle(color: Colors.grey)),
                  )).toList(),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildRecentList(
                  'Recent Tasks',
                  state.tasks.reversed.take(5).map((t) => ListTile(
                    leading: Icon(
                      t.isCompleted ? Icons.check_circle : Icons.pending,
                      color: t.isCompleted ? Colors.green : Colors.orange,
                    ),
                    title: Text(t.title, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(t.category, style: const TextStyle(color: Colors.grey)),
                    trailing: Text('+${t.xpReward} XP', style: const TextStyle(color: Colors.amber)),
                  )).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // lighter navy
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentList(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (children.isEmpty)
            const Text('No data available', style: TextStyle(color: Colors.grey))
          else
            ...children,
        ],
      ),
    );
  }
}
