import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/models.dart';

class AddQuestScreen extends StatefulWidget {
  const AddQuestScreen({Key? key}) : super(key: key);

  @override
  State<AddQuestScreen> createState() => _AddQuestScreenState();
}

class _AddQuestScreenState extends State<AddQuestScreen> {
  final _formKey = GlobalKey<FormState>();
  String _taskType = 'normal'; // 'normal' or 'hydration'
  String _title = '';
  String _description = '';
  String _category = 'Study';
  int _xpReward = 50;
  int? _selectedDuration = 30; // Default for 'Study'
  int _selectedWaterGoalMl = 2500; // Default for Hydration
  TimeOfDay? _selectedTime;
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = [
    'Study',
    'Fitness',
    'Health',
    'Learning',
    'Work',
    'Coding',
    'Reading',
    'Meditation',
    'Walking',
    'Social',
    'Creative',
    'Cleaning',
    'Habit',
    'Daily',
    'Hobbies',
    'Personal',
  ];
  final List<int> _xpOptions = [20, 40, 50, 70, 100, 150, 200];
  final List<int> _durations = [0, 10, 15, 20, 30, 45, 60, 90];
  final List<int> _waterGoals = [1500, 2000, 2500, 3000];

  void _onCategoryChanged(String? value) {
    if (value != null) {
      setState(() {
        _category = value;
        // Smart defaults
        switch (value) {
          case 'Study':
          case 'Work':
          case 'Coding':
          case 'Learning':
            _selectedDuration = 30;
            break;
          case 'Fitness':
            _selectedDuration = 30;
            break;
          case 'Meditation':
            _selectedDuration = 15;
            break;
          case 'Creative':
            _selectedDuration = 30;
            break;
          case 'Reading':
          case 'Cleaning':
          case 'Health':
          case 'Social':
          case 'Habit':
          case 'Daily':
            _selectedDuration = 0; // default no timer for reading, cleaning, etc.
            break;
          default:
            _selectedDuration = 20;
            break;
        }
      });
    }
  }

  void _onTaskTypeChanged(String type) {
    setState(() {
      _taskType = type;
      if (type == 'hydration') {
        _title = 'Daily Drinking Water';
        _category = 'Health';
        _xpReward = 50;
      }
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_taskType == 'normal' && _selectedDuration == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a task duration.')));
        return;
      }
      
      _formKey.currentState!.save();
      String? timeStr;
      if (_selectedTime != null) {
        timeStr = _selectedTime!.format(context);
      }
      
      final newTask = RPGTask(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _title,
        description: _description.isNotEmpty 
            ? _description 
            : (_taskType == 'hydration' ? 'Daily hydration goal: ${(_selectedWaterGoalMl / 1000).toStringAsFixed(1)} L' : ''),
        category: _category,
        xpReward: _xpReward,
        dueDate: _selectedDate,
        time: timeStr,
        durationMinutes: _taskType == 'normal' ? (_selectedDuration ?? 0) : 0,
        remainingSeconds: _taskType == 'normal' ? ((_selectedDuration ?? 0) * 60) : 0,
        taskType: _taskType,
        waterGoalMl: _taskType == 'hydration' ? _selectedWaterGoalMl : 2000,
        currentWaterMl: 0,
        waterLogs: [],
        drinkAmountMl: 250,
        reminders: _taskType == 'hydration'
            ? Provider.of<AppState>(context, listen: false).createDefaultDrinkingSchedule(drinkAmountMl: 250)
            : [],
      );
      
      context.read<AppState>().addTask(newTask);
      Navigator.pop(context);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Task', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Type Switcher
              Text('Task Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _onTaskTypeChanged('normal'),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _taskType == 'normal'
                              ? const Color(0xFFF5B942).withValues(alpha: 0.2)
                              : (isDark ? const Color(0xFF162033) : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _taskType == 'normal' ? const Color(0xFFF5B942) : theme.colorScheme.outline,
                            width: _taskType == 'normal' ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.timer_outlined, color: _taskType == 'normal' ? const Color(0xFFF5B942) : theme.colorScheme.onSurfaceVariant, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Timed Task',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _taskType == 'normal' ? const Color(0xFFF5B942) : theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _onTaskTypeChanged('hydration'),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _taskType == 'hydration'
                              ? const Color(0xFF38BDF8).withValues(alpha: 0.2)
                              : (isDark ? const Color(0xFF162033) : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _taskType == 'hydration' ? const Color(0xFF38BDF8) : theme.colorScheme.outline,
                            width: _taskType == 'hydration' ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.water_drop, color: _taskType == 'hydration' ? const Color(0xFF38BDF8) : theme.colorScheme.onSurfaceVariant, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Hydration Quest',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _taskType == 'hydration' ? const Color(0xFF38BDF8) : theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              TextFormField(
                key: Key(_taskType),
                initialValue: _taskType == 'hydration' ? 'Daily Drinking Water' : _title,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Task Name',
                  prefixIcon: Icon(_taskType == 'hydration' ? Icons.water_drop : Icons.title, color: _taskType == 'hydration' ? const Color(0xFF38BDF8) : null),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 20),
              TextFormField(
                maxLines: 2,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: _taskType == 'hydration' ? 'Hydration Description (Optional)' : 'Description',
                  prefixIcon: const Icon(Icons.description),
                ),
                onSaved: (value) => _description = value ?? '',
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _taskType == 'hydration' ? 'Health' : _category,
                dropdownColor: theme.colorScheme.surface,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: _taskType == 'hydration' ? null : _onCategoryChanged,
              ),
              const SizedBox(height: 24),

              // Task Duration OR Water Goal
              if (_taskType == 'normal') ...[
                Text('Task Duration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _durations.map((duration) {
                    final isSelected = _selectedDuration == duration;
                    return ChoiceChip(
                      label: Text(duration == 0 ? 'No Timer' : '$duration min'),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedDuration = duration);
                      },
                      backgroundColor: isDark ? const Color(0xFF162033) : const Color(0xFFF1F5F9),
                      selectedColor: const Color(0xFFF5B942),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFFF5B942) : theme.colorScheme.outline,
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList(),
                ),
              ] else ...[
                Text('Daily Water Goal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _waterGoals.map((goal) {
                    final isSelected = _selectedWaterGoalMl == goal;
                    return ChoiceChip(
                      avatar: const Icon(Icons.water_drop, size: 16, color: Color(0xFF38BDF8)),
                      label: Text('${(goal / 1000).toStringAsFixed(1)} Liters'),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedWaterGoalMl = goal);
                      },
                      backgroundColor: isDark ? const Color(0xFF162033) : const Color(0xFFF1F5F9),
                      selectedColor: const Color(0xFF38BDF8),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF38BDF8) : theme.colorScheme.outline,
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.outline),
                      ),
                      child: ListTile(
                        title: Text('Due Date', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500, fontSize: 13)),
                        subtitle: Text(DateFormat('MMM d, yyyy').format(_selectedDate), style: const TextStyle(color: Color(0xFFF5B942), fontWeight: FontWeight.bold)),
                        leading: const Icon(Icons.calendar_today, color: Color(0xFFF5B942)),
                        onTap: _pickDate,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.outline),
                      ),
                      child: ListTile(
                        title: Text('Due Time', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500, fontSize: 13)),
                        subtitle: Text(_selectedTime != null ? _selectedTime!.format(context) : 'Not set', style: const TextStyle(color: Color(0xFFF5B942), fontWeight: FontWeight.bold)),
                        leading: const Icon(Icons.access_time, color: Color(0xFFF5B942)),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setState(() => _selectedTime = picked);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              Text('XP Reward', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: _xpOptions.map((xp) {
                  final isSelected = _xpReward == xp;
                  return ChoiceChip(
                    label: Text('+$xp XP'),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _xpReward = xp);
                    },
                    backgroundColor: isDark ? const Color(0xFF162033) : const Color(0xFFF1F5F9),
                    selectedColor: const Color(0xFFF5B942),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFFF5B942) : theme.colorScheme.outline,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _taskType == 'hydration' ? const Color(0xFF38BDF8) : const Color(0xFFF5B942),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                  ),
                  onPressed: _submit,
                  child: Text(
                    _taskType == 'hydration' ? 'START HYDRATION QUEST' : 'CREATE TASK',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
