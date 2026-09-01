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
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Your Gold: ', style: TextStyle(fontSize: 18)),
                    const Icon(Icons.monetization_on, color: Colors.amber, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      '${state.userProfile.gold}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
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
                      elevation: 4,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        leading: const Icon(Icons.card_giftcard, size: 40, color: Colors.pinkAccent),
                        title: Text(
                          reward.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        trailing: ElevatedButton.icon(
                          onPressed: () => _buyReward(context, reward.id, reward.title, reward.cost),
                          icon: const Icon(Icons.monetization_on, size: 16, color: Colors.amber),
                          label: Text('${reward.cost}'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canAfford ? Colors.black45 : Colors.grey[800],
                            foregroundColor: canAfford ? Colors.white : Colors.grey,
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
