import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Consumer<AppState>(
          builder: (context, state, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Welcome, ${state.userProfile.username}!', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Turn your daily life into an adventure. Complete real-world quests, earn XP, and level up.',
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/main'),
                  child: const Text('Start Your Journey'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
