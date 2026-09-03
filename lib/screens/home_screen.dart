import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/quest_card.dart';
import '../screens/add_quest_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/rankings_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';

  Widget _buildCategoryChip(BuildContext context, String label, IconData icon, Color color) {
    final theme = Theme.of(context);
    final isSelected = _selectedCategory == label;
    final isDark = theme.brightness == Brightness.dark;

    final unselectedBg = isDark ? const Color(0xFF162033) : Colors.white;
    final unselectedBorder = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final unselectedText = isDark ? const Color(0xFFAAB4C2) : const Color(0xFF475569);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = label;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF5B942) : unselectedBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFFF5B942) : unselectedBorder,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (!isDark && !isSelected)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.black : color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : unselectedText,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: Drawer(
        backgroundColor: theme.colorScheme.surface,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0A0F1C) : const Color(0xFF1E293B),
                image: DecorationImage(
                  image: const AssetImage('assets/images/banner_hero.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.5), BlendMode.darken),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Real-Life RPG', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Level up your life.', style: TextStyle(color: Color(0xFFF5B942), fontSize: 14)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.leaderboard, color: Color(0xFFF5B942)),
              title: Text('🏆 Player Rankings', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RankingsScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.settings_outlined, color: theme.colorScheme.onSurface),
              title: Text('Settings', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline, color: theme.colorScheme.onSurface),
              title: Text('About', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: Row(
                      children: [
                        const Icon(Icons.emoji_events, color: Color(0xFFF5B942), size: 28),
                        const SizedBox(width: 8),
                        Text('LevelUp RPG', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Version 1.0.0',
                          style: TextStyle(color: Color(0xFFF5B942), fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Turn your daily chores and habits into an epic quest! Complete tasks, earn XP, unlock achievements, and become the hero of your own life.',
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Keep grinding and leveling up!',
                          style: TextStyle(color: theme.colorScheme.onSurface, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('CLOSE', style: TextStyle(color: Color(0xFFF5B942), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            ),
            Divider(color: theme.colorScheme.outline),
            ListTile(
              leading: Icon(Icons.share_outlined, color: theme.colorScheme.onSurface),
              title: Text('Share App', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
              onTap: () async {
                Navigator.pop(context);
                const shareText = "🔥 I'm leveling up my real life with LevelUp! 🎮⚡\n"
                    "Complete real-life quests, earn XP, build streaks, and become the best version of yourself.\n"
                    "Try LevelUp!\n"
                    "https://play.google.com/store/apps/details?id=com.levelup.realliferpg";
                try {
                  await Share.share(shareText, subject: 'LevelUp - Real Life RPG');
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sharing LevelUp invitation...')),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.star_rate_outlined, color: Color(0xFFF5B942)),
              title: Text('Rate App', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
              onTap: () async {
                Navigator.pop(context);
                const playStoreUrl = 'https://play.google.com/store/apps/details?id=com.levelup.realliferpg';
                final uri = Uri.parse(playStoreUrl);
                bool launched = false;
                try {
                  if (await canLaunchUrl(uri)) {
                    launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                } catch (_) {}

                if (!launched && context.mounted) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: Row(
                        children: [
                          const Icon(Icons.star, color: Color(0xFFF5B942), size: 28),
                          const SizedBox(width: 8),
                          Text('Love LevelUp?', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      content: Text(
                        'Your feedback helps us improve and make the app even better!',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, height: 1.4),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text('Maybe Later', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF5B942),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Rate Later', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.privacy_tip_outlined, color: theme.colorScheme.onSurface),
              title: Text('Privacy Policy', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                );
              },
            ),
            Divider(color: theme.colorScheme.outline),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              onTap: () async {
                Navigator.pop(context); // close drawer
                await context.read<AppState>().logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                }
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: theme.colorScheme.onSurface),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/logo.png',
                width: 36,
                height: 36,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Hey Hero! ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.onSurface)),
                    const Text('🔥', style: TextStyle(fontSize: 18)),
                  ],
                ),
                Text(
                  "Let's crush your goals today.",
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Consumer<AppState>(
            builder: (context, state, child) {
              final unreadCount = state.unreadNotificationCount;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      unreadCount > 0 ? Icons.notifications_active : Icons.notifications_none,
                      color: unreadCount > 0 ? const Color(0xFFF5B942) : theme.colorScheme.onSurface,
                    ),
                    tooltip: 'Notifications',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, state, child) {
          final activeTasks = state.activeTasks;
          final todayCompletedTasks = state.getCompletedTasksForDate(DateTime.now());
          final totalTasks = activeTasks.length + todayCompletedTasks.length;
          final completedCount = todayCompletedTasks.length;
          final progress = totalTasks > 0 ? completedCount / totalTasks : 0.0;

          final filteredTasks = _selectedCategory == 'All'
              ? activeTasks
              : activeTasks.where((t) => t.category == _selectedCategory).toList();

          return ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              // Hero Banner (Level Card)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: const AssetImage('assets/images/banner_hero.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.45), BlendMode.darken),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Level', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('${state.userProfile.level}', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, height: 1.1)),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('XP Progress', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text('${state.userProfile.totalXP} / ${state.userProfile.level * 100} XP', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (state.userProfile.totalXP / (state.userProfile.level * 100)).clamp(0.0, 1.0),
                          backgroundColor: Colors.white24,
                          color: const Color(0xFFF5B942),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Daily Progress Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Daily Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                    Text('$completedCount / $totalTasks Completed', style: const TextStyle(color: Color(0xFFF5B942), fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    color: const Color(0xFFF5B942),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Categories Horizontal Scroll
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    _buildCategoryChip(context, 'All', Icons.dashboard_customize, const Color(0xFFF5B942)),
                    _buildCategoryChip(context, 'Study', Icons.menu_book, Colors.blueAccent),
                    _buildCategoryChip(context, 'Fitness', Icons.fitness_center, Colors.redAccent),
                    _buildCategoryChip(context, 'Health', Icons.favorite, Colors.green),
                    _buildCategoryChip(context, 'Work', Icons.work, Colors.purpleAccent),
                    _buildCategoryChip(context, 'Personal', Icons.person, Colors.orangeAccent),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Today's Tasks Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Active Tasks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                    Text(
                      '${filteredTasks.length} pending',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Task List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: filteredTasks.isEmpty
                      ? [
                          Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.check_circle_outline, size: 48, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                                  const SizedBox(height: 12),
                                  Text("No active tasks in this category.", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14)),
                                ],
                              ),
                            ),
                          )
                        ]
                      : filteredTasks.map((task) => QuestCard(
                            task: task,
                            onComplete: () => state.completeTask(task.id),
                          )).toList(),
                ),
              ),

              if (todayCompletedTasks.isNotEmpty) ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Completed Today", 
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold, 
                          color: isDark ? const Color(0xFF4CAF50) : const Color(0xFF16A34A),
                        ),
                      ),
                      Text(
                        '${todayCompletedTasks.length} done',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF4CAF50) : const Color(0xFF16A34A), 
                          fontSize: 13, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: todayCompletedTasks.map((task) => QuestCard(
                          task: task,
                          onComplete: () {},
                        )).toList(),
                  ),
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddQuestScreen()));
        },
        backgroundColor: const Color(0xFFF5B942),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add, size: 24),
        label: const Text('Add Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
