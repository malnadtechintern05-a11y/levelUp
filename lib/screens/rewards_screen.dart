import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({Key? key}) : super(key: key);

  void _buyReward(BuildContext context, String rewardId, String title, int cost) {
    final state = context.read<AppState>();
    
    // Check if user has enough gold
    if (state.userProfile.gold >= cost) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Purchase'),
          content: Text('Buy "$title" for $cost Gold?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                bool success = state.buyReward(rewardId);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Successfully purchased: $title! Enjoy!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Purchase'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough Gold! Complete more quests.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards Store'),
        centerTitle: true,
      ),
      body: Consumer<AppState>(
        builder: (context, state, child) {
          final rewards = state.rewards;
          
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(bottom: BorderSide(color: theme.colorScheme.outline)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Your Gold: ', style: TextStyle(fontSize: 18, color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600)),
                    const Icon(Icons.monetization_on, color: Color(0xFFF5B942), size: 28),
                    const SizedBox(width: 8),
                    Text(
                      '${state.userProfile.gold}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF5B942),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rewards.length,
                  itemBuilder: (context, index) {
                    final reward = rewards[index];
                    final canAfford = state.userProfile.gold >= reward.cost;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: theme.colorScheme.outline),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        leading: const Icon(Icons.card_giftcard, size: 40, color: Colors.pinkAccent),
                        title: Text(
                          reward.title,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface),
                        ),
                        trailing: ElevatedButton.icon(
                          onPressed: () => _buyReward(context, reward.id, reward.title, reward.cost),
                          icon: Icon(Icons.monetization_on, size: 16, color: canAfford ? Colors.black : theme.colorScheme.onSurfaceVariant),
                          label: Text('${reward.cost} Gold'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canAfford ? const Color(0xFFF5B942) : theme.colorScheme.surfaceContainerHighest,
                            foregroundColor: canAfford ? Colors.black : theme.colorScheme.onSurfaceVariant,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
