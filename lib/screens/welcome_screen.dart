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
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),
                Text('Welcome, ${state.userProfile.username}!', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Turn your daily life into an adventure. Complete real-world quests, earn XP, and level up.',
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/main'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5B942),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Start Your Journey', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
