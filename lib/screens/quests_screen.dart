import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../widgets/quest_card.dart';
import '../widgets/smooth_transitions.dart';
import 'add_quest_screen.dart';

class QuestsScreen extends StatefulWidget {
  const QuestsScreen({super.key});

  @override
  State<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends State<QuestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  String _activeFilter = 'All'; // 'All', 'Today', 'Upcoming', 'Overdue', 'Hydration'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFFF5B942),
                  onPrimary: Colors.black,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getDateText() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    if (selected == today) return 'Today';
    if (selected == today.subtract(const Duration(days: 1))) return 'Yesterday';
    if (selected == today.add(const Duration(days: 1))) return 'Tomorrow';

    return DateFormat('EEE, MMM d').format(_selectedDate);
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<AppState>(
      builder: (context, state, child) {
        final allActive = state.activeTasks;
        final completed = state.completedTasks;
        final tasksForDate = state.getTasksForDate(_selectedDate);
        final completedForDate = tasksForDate.where((t) => t.isCompleted).length;
        final totalForDate = tasksForDate.length;
        final progressForDate = totalForDate > 0 ? completedForDate / totalForDate : 0.0;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Quest Catalog',
              style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFFF5B942),
              indicatorWeight: 3,
              labelColor: const Color(0xFFF5B942),
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: [
                Tab(
                  icon: const Icon(Icons.calendar_month_rounded, size: 20),
                  text: 'Calendar',
                ),
                Tab(
                  icon: const Icon(Icons.bolt_rounded, size: 20),
                  text: 'Active (${allActive.length})',
                ),
                Tab(
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                  text: 'Done (${completed.length})',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // TAB 1: Calendar View
              _buildCalendarTab(
                context,
                state,
                tasksForDate,
                completedForDate,
                totalForDate,
                progressForDate,
                theme,
                isDark,
              ),

              // TAB 2: All Active Tasks
              _buildAllActiveTab(context, state, allActive, theme, isDark),

              // TAB 3: Completed Tasks
              _buildCompletedTab(context, state, completed, theme, isDark),
            ],
          ),
          floatingActionButton: BounceTap(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddQuestScreen()));
            },
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddQuestScreen()));
              },
              icon: const Icon(Icons.add_rounded, size: 24),
              label: const Text('Add Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              backgroundColor: const Color(0xFFF5B942),
              foregroundColor: Colors.black,
              elevation: 4,
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  // --- TAB 1: Calendar View ---
  Widget _buildCalendarTab(
    BuildContext context,
    AppState state,
    List<RPGTask> tasksForDate,
    int completedCount,
    int totalTasks,
    double progress,
    ThemeData theme,
    bool isDark,
  ) {
    final isSelectedToday = _isToday(_selectedDate);

    return RefreshIndicator(
      onRefresh: () => state.refreshAllData(),
      color: const Color(0xFFF5B942),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          // Date Selector Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFFF5B942), size: 32),
                  onPressed: () => _changeDate(-1),
                ),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFF5B942).withValues(alpha: 0.4), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_rounded, color: Color(0xFFF5B942), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _getDateText(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.arrow_drop_down_rounded, color: theme.colorScheme.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFFF5B942), size: 32),
                  onPressed: () => _changeDate(1),
                ),
              ],
            ),
          ),

          if (!isSelectedToday)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: TextButton.icon(
                  onPressed: () => setState(() => _selectedDate = DateTime.now()),
                  icon: const Icon(Icons.today_rounded, size: 16),
                  label: const Text('Jump to Today', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFFF5B942)),
                ),
              ),
            ),

          // Daily Progress Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Day Progress',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                      ),
                      Text(
                        '$completedCount / $totalTasks Quests Done',
                        style: const TextStyle(color: Color(0xFFF5B942), fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                      color: const Color(0xFFF5B942),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Task List for Day
          if (tasksForDate.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_available_rounded,
                      size: 54,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'No tasks scheduled for ${_getDateText()}.',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tap below to view all upcoming tasks or create a new one.',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    if (state.activeTasks.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: () => _tabController.animateTo(1),
                        icon: const Icon(Icons.list_alt_rounded, size: 18),
                        label: Text('View All Active Tasks (${state.activeTasks.length})'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF5B942),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: tasksForDate.map((task) {
                  return QuestCard(
                    task: task,
                    onComplete: () => state.completeTask(task.id),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  // --- TAB 2: All Active Tasks ---
  Widget _buildAllActiveTab(
    BuildContext context,
    AppState state,
    List<RPGTask> allActive,
    ThemeData theme,
    bool isDark,
  ) {
    List<RPGTask> filtered = List.from(allActive);
    if (_activeFilter == 'Today') {
      filtered = allActive.where((t) => state.isTaskToday(t)).toList();
    } else if (_activeFilter == 'Upcoming') {
      filtered = allActive.where((t) => state.isTaskFuture(t)).toList();
    } else if (_activeFilter == 'Overdue') {
      filtered = allActive.where((t) => state.isTaskPast(t)).toList();
    } else if (_activeFilter == 'Hydration') {
      filtered = allActive.where((t) => t.taskType == 'hydration' || t.category.trim().toLowerCase() == 'hydration').toList();
    } else if (_activeFilter != 'All') {
      filtered = allActive.where((t) => t.category.trim().toLowerCase() == _activeFilter.trim().toLowerCase()).toList();
    }

    // Sort by scheduled date
    filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final categories = [
      'Study', 'Fitness', 'Health', 'Learning', 'Work', 'Coding', 'Reading',
      'Meditation', 'Walking', 'Social', 'Creative', 'Cleaning', 'Chores',
      'Habit', 'Daily', 'Hobbies', 'Personal', 'Other'
    ];

    return RefreshIndicator(
      onRefresh: () => state.refreshAllData(),
      color: const Color(0xFFF5B942),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          // Filter Chips Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', allActive.length, theme, isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('Today', allActive.where((t) => state.isTaskToday(t)).length, theme, isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('Upcoming', allActive.where((t) => state.isTaskFuture(t)).length, theme, isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('Overdue', allActive.where((t) => state.isTaskPast(t)).length, theme, isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('Hydration', allActive.where((t) => t.taskType == 'hydration' || t.category.trim().toLowerCase() == 'hydration').length, theme, isDark),
                  for (final cat in categories) ...[
                    const SizedBox(width: 8),
                    _buildFilterChip(cat, allActive.where((t) => t.category.trim().toLowerCase() == cat.toLowerCase()).length, theme, isDark),
                  ],
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _activeFilter == 'All' ? 'All Pending Quests' : '$_activeFilter Quests',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                ),
                Text(
                  '${filtered.length} quests',
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 52, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                    const SizedBox(height: 12),
                    Text(
                      'No $_activeFilter active quests.',
                      style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tap "+ Add Task" to create a new quest.',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: filtered.map((task) {
                  return QuestCard(
                    task: task,
                    onComplete: () => state.completeTask(task.id),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int count, ThemeData theme, bool isDark) {
    final isSelected = _activeFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFF5B942)
              : (isDark ? const Color(0xFF162033) : theme.colorScheme.surfaceContainerHighest),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFF5B942) : theme.colorScheme.outline.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black.withValues(alpha: 0.2) : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Colors.black : theme.colorScheme.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 3: Completed Tasks ---
  Widget _buildCompletedTab(
    BuildContext context,
    AppState state,
    List<RPGTask> completed,
    ThemeData theme,
    bool isDark,
  ) {
    // Sort completed by most recent first
    final sortedCompleted = List<RPGTask>.from(completed)..sort((a, b) => b.dueDate.compareTo(a.dueDate));

    return RefreshIndicator(
      onRefresh: () => state.refreshAllData(),
      color: const Color(0xFFF5B942),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF064E3B), const Color(0xFF047857)]
                      : [const Color(0xFFDCFCE7), const Color(0xFFBBF7D0)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.military_tech_rounded, color: Color(0xFFF5B942), size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${completed.length} Quests Conquered!',
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF065F46),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Keep up your legendary momentum!',
                          style: TextStyle(
                            color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF047857),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (sortedCompleted.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 52,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No completed quests yet.',
                      style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Complete your active tasks to fill up your quest trophy log!',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: sortedCompleted.map((task) {
                  return QuestCard(
                    task: task,
                    onComplete: () {},
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
