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
  String _title = '';
  String _description = '';
  String _category = 'Study';
  int _xpReward = 50;
  int? _selectedDuration = 30; // Default for 'Study'
  TimeOfDay? _selectedTime;
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = ['Study', 'Fitness', 'Health', 'Work', 'Personal'];
  final List<int> _xpOptions = [20, 50, 100, 200];
  final List<int> _durations = [10, 20, 30, 40, 45, 60, 90, 120];

  void _onCategoryChanged(String? value) {
    if (value != null) {
      setState(() {
        _category = value;
        // Smart defaults
        switch (value) {
          case 'Study':
          case 'Work':
            _selectedDuration = 30;
            break;
          case 'Fitness':
            _selectedDuration = 40;
            break;
          case 'Health':
          case 'Personal':
            _selectedDuration = 20;
            break;
        }
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDuration == null) {
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
        description: _description,
        category: _category,
        xpReward: _xpReward,
        dueDate: _selectedDate,
        time: timeStr,
        durationMinutes: _selectedDuration!,
        remainingSeconds: _selectedDuration! * 60,
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
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.amber,
              onPrimary: Colors.black,
              surface: Color(0xFF162033),
              onSurface: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1C),
      appBar: AppBar(
        title: const Text('Create Task', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Task Name',
                  labelStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade700)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade700)),
                  prefixIcon: const Icon(Icons.title, color: Colors.grey),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 20),
              TextFormField(
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade700)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade700)),
                  prefixIcon: const Icon(Icons.description, color: Colors.grey),
                ),
                onSaved: (value) => _description = value ?? '',
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _category,
                dropdownColor: const Color(0xFF162033),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade700)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade700)),
                  prefixIcon: const Icon(Icons.category, color: Colors.grey),
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: _onCategoryChanged,
              ),
              const SizedBox(height: 20),
              const Text('Task Duration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _durations.map((duration) {
                  final isSelected = _selectedDuration == duration;
                  return ChoiceChip(
                    label: Text('$duration min'),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedDuration = duration);
                    },
                    backgroundColor: const Color(0xFF162033),
                    selectedColor: Colors.amber,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Due Date', style: TextStyle(color: Colors.white)),
                      subtitle: Text(DateFormat('MMM d, yyyy').format(_selectedDate), style: const TextStyle(color: Colors.amber)),
                      leading: const Icon(Icons.calendar_today, color: Colors.amber),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide(color: Colors.grey.shade700),
                      ),
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ListTile(
                      title: const Text('Due Time', style: TextStyle(color: Colors.white)),
                      subtitle: Text(_selectedTime != null ? _selectedTime!.format(context) : 'Not set', style: const TextStyle(color: Colors.amber)),
                      leading: const Icon(Icons.access_time, color: Colors.amber),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide(color: Colors.grey.shade700),
                      ),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: Colors.amber,
                                  onPrimary: Colors.black,
                                  surface: Color(0xFF162033),
                                  onSurface: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() => _selectedTime = picked);
                        }
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              const Text('XP Reward', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
                    backgroundColor: const Color(0xFF162033),
                    selectedColor: Colors.amber,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
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
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: _submit,
                  child: const Text('CREATE TASK', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
