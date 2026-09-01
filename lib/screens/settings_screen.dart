import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _taskReminder = true;
  bool _streakReminder = true;
  bool _soundEffects = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1C),
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('APPEARANCE', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Consumer<AppState>(
              builder: (context, state, child) {
                return SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: state.isDarkMode,
                  onChanged: (val) {
                    state.toggleTheme(val);
                  },
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
          const Text('NOTIFICATIONS', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Daily Task Reminder'),
                  value: _taskReminder,
                  onChanged: (val) => setState(() => _taskReminder = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Streak Reminder'),
                  value: _streakReminder,
                  onChanged: (val) => setState(() => _streakReminder = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text('APP', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Sound Effects'),
                  value: _soundEffects,
                  onChanged: (val) => setState(() => _soundEffects = val),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Reset Progress', style: TextStyle(color: Colors.redAccent)),
                  trailing: const Icon(Icons.warning, color: Colors.redAccent),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Progress reset not available in demo.')));
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text('ABOUT', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('About Real Life RPG'),
                  trailing: const Icon(Icons.info_outline),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Version 1.0.0. Level up in real life!')));
                  },
                ),
                const Divider(height: 1),
                const ListTile(
                  title: Text('App Version'),
                  trailing: Text('1.0.0', style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
