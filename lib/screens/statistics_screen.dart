import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: Consumer<AppState>(
        builder: (context, state, child) {
          final profile = state.userProfile;
          final weeklyXp = state.weeklyXp;
          final maxXP = weeklyXp.values.reduce((a, b) => a > b ? a : b);
          
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const Text('Weekly XP Earned', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              // Simple Bar Chart
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: weeklyXp.entries.map((entry) {
                    final heightRatio = maxXP == 0 ? 0.0 : entry.value / maxXP;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('${entry.value}', style: const TextStyle(fontSize: 10, color: Colors.amber)),
                        const SizedBox(height: 4),
                        Container(
                          width: 24,
                          height: 120 * heightRatio,
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(entry.key, style: const TextStyle(fontSize: 12)),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              
              // Summary Cards
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildSummaryRow(context, 'Total Quests Completed', '${state.completedTasks.length}'),
                      Divider(color: Theme.of(context).colorScheme.outline),
                      _buildSummaryRow(context, 'Total XP', '${profile.totalXP}'),
                      Divider(color: Theme.of(context).colorScheme.outline),
                      _buildSummaryRow(context, 'Current Streak', '${profile.currentStreak} Days'),
                      Divider(color: Theme.of(context).colorScheme.outline),
                      _buildSummaryRow(context, 'Most Active Category', state.mostActiveCategory),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String title, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface)),
        ],
      ),
    );
  }
}
