import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_state.dart';
import 'admin_dashboard_screen.dart';
import 'admin_users_screen.dart';
import 'admin_tasks_screen.dart';
import 'admin_achievements_screen.dart';
import 'admin_analytics_screen.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({Key? key}) : super(key: key);

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const AdminUsersScreen(),
    const AdminTasksScreen(),
    const AdminAchievementsScreen(),
    const AdminAnalyticsScreen(),
    const Center(child: Text('Settings (Coming Soon)', style: TextStyle(color: Colors.white))),
  ];

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Dashboard', 'icon': Icons.dashboard},
    {'title': 'Users', 'icon': Icons.people},
    {'title': 'Tasks', 'icon': Icons.task},
    {'title': 'Achievements', 'icon': Icons.emoji_events},
    {'title': 'Analytics', 'icon': Icons.analytics},
    {'title': 'Settings', 'icon': Icons.settings},
  ];

  void _logout() {
    Provider.of<AdminState>(context, listen: false).logout();
    Navigator.pushReplacementNamed(context, '/admin');
  }

  @override
  Widget build(BuildContext context) {
    // Basic responsive layout: sidebar for desktop/tablet, drawer for mobile
    final isDesktop = MediaQuery.of(context).size.width > 800;

    final sidebar = Container(
      width: 250,
      color: const Color(0xFF0F172A), // Dark navy
      child: Column(
        children: [
          const SizedBox(height: 32),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.admin_panel_settings, color: Colors.amber, size: 32),
              SizedBox(width: 8),
              Text(
                'Admin Panel',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedIndex == index;
                return ListTile(
                  leading: Icon(
                    _menuItems[index]['icon'],
                    color: isSelected ? Colors.amber : Colors.grey,
                  ),
                  title: Text(
                    _menuItems[index]['title'],
                    style: TextStyle(
                      color: isSelected ? Colors.amber : Colors.grey,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  tileColor: isSelected ? const Color(0xFF1E293B) : Colors.transparent,
                  onTap: () {
                    setState(() => _selectedIndex = index);
                    if (!isDesktop) Navigator.pop(context); // Close drawer on mobile
                  },
                );
              },
            ),
          ),
          const Divider(color: Colors.grey),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
            onTap: _logout,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1C),
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF0F172A),
              title: Text(_menuItems[_selectedIndex]['title'], style: const TextStyle(color: Colors.white)),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
      drawer: isDesktop ? null : Drawer(child: sidebar),
      body: Row(
        children: [
          if (isDesktop) sidebar,
          Expanded(
            child: Consumer<AdminState>(
              builder: (context, state, child) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: Colors.amber));
                }
                return _screens[_selectedIndex];
              },
            ),
          ),
        ],
      ),
    );
  }
}
