import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/quest_card.dart';
import '../screens/add_quest_screen.dart';
import '../screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';

  Widget _buildCategoryChip(BuildContext context, String label, IconData icon, Color color) {
    bool isSelected = _selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = label;
          });
        },
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isSelected ? Colors.amber : const Color(0xFF162033),
            borderRadius: BorderRadius.circular(16),
            border: isSelected ? null : Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.black : color, size: 28),
              const SizedBox(height: 8),
              Text(
                label, 
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70, 
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1C),
      drawer: Drawer(
        backgroundColor: const Color(0xFF162033),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color(0xFF0A0F1C),
                image: DecorationImage(
                  image: const AssetImage('assets/images/banner_hero.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Real-Life RPG', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Level up your life.', style: TextStyle(color: Colors.amber, fontSize: 14)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text('Settings', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.white),
              title: const Text('About', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF162033),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Row(
                      children: [
                        Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                        SizedBox(width: 8),
                        Text('LevelUp RPG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    content: const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Turn your daily chores and habits into an epic quest! Complete tasks, earn XP, unlock achievements, and become the hero of your own life.',
                          style: TextStyle(color: Colors.white70, height: 1.5),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Keep grinding and leveling up!',
                          style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('CLOSE', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('Hey Hero! ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
                Text('🔥', style: TextStyle(fontSize: 22)),
              ],
            ),
            Text("Let's crush your goals today.", style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white), 
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No new notifications.')));
            }
          ),
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
            padding: const EdgeInsets.only(bottom: 100), // safe padding for FAB
            children: [
              // Hero Banner (Level Card)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                height: 160, // slightly shorter to not be too tall
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: const AssetImage('assets/images/banner_hero.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ]
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
                          value: state.userProfile.totalXP / (state.userProfile.level * 100), 
                          backgroundColor: Colors.white24, 
                          color: Colors.amber,
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
                    const Text('Daily Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('$completedCount / $totalTasks Completed', style: TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold)),
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
                    backgroundColor: const Color(0xFF162033),
                    color: Colors.amber,
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
                    _buildCategoryChip(context, 'All', Icons.dashboard_customize, Colors.amber),
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
                    const Text("Active Tasks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      child: const Text('View all', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
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
                    ? [const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text("No tasks in this category.", style: TextStyle(color: Colors.grey)),
                      )]
                    : filteredTasks.map((task) => QuestCard(
                        task: task,
                        onComplete: () => state.completeTask(task.id),
                      )).toList(),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddQuestScreen()));
        },
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add, size: 24),
        label: const Text('Add Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
