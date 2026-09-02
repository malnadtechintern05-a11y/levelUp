import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_state.dart';
import '../../models/models.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AdminState>();

    // Calculate "Most completed tasks" (simulated by just looking at task data)
    final topTasks = List<RPGTask>.from(state.tasks)
      ..sort((a, b) => b.xpReward.compareTo(a.xpReward)); // Simulating top tasks by XP for now

    // Calculate top users
    final topUsers = List<UserProfile>.from(state.users)
      ..sort((a, b) => b.totalXP.compareTo(a.totalXP));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Analytics',
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          // Stats Row
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildStatCard('Total Completions', state.totalTaskCompletions.toString(), Icons.done_all, Colors.green),
              _buildStatCard('Total XP Earned', state.totalXPAwarded.toString(), Icons.star, Colors.amber),
              _buildStatCard('Active Users', state.activeUsersCount.toString(), Icons.people, Colors.blue),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Top Lists Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildListCard(
                  'Most Active Users', 
                  topUsers.take(5).map((u) => ListTile(
                    leading: const Icon(Icons.person, color: Colors.blue),
                    title: Text(u.username, style: const TextStyle(color: Colors.white)),
                    trailing: Text('${u.totalXP} XP', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                  )).toList()
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildListCard(
                  'Most Rewarding Tasks', 
                  topTasks.take(5).map((t) => ListTile(
                    leading: const Icon(Icons.task, color: Colors.purple),
                    title: Text(t.title, style: const TextStyle(color: Colors.white)),
                    trailing: Text('${t.xpReward} XP', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                  )).toList()
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Daily Stats (Simulated Bar Chart using Containers)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daily Task Completions (Last 7 Days)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBar('Mon', 40),
                      _buildBar('Tue', 65),
                      _buildBar('Wed', 80),
                      _buildBar('Thu', 45),
                      _buildBar('Fri', 90),
                      _buildBar('Sat', 120),
                      _buildBar('Sun', 75),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListCard(String title, List<Widget> children) {
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

  Widget _buildBar(String label, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: height,
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
