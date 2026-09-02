import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';
import '../../providers/admin_state.dart';

class AdminTaskFormScreen extends StatefulWidget {
  final RPGTask? task; // If null, we are adding a new task

  const AdminTaskFormScreen({Key? key, this.task}) : super(key: key);

  @override
  State<AdminTaskFormScreen> createState() => _AdminTaskFormScreenState();
}

class _AdminTaskFormScreenState extends State<AdminTaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _xpController;
  
  String _selectedCategory = 'Personal';
  int _selectedDuration = 30;
  bool _isActive = true;

  final List<String> _categories = ['Study', 'Fitness', 'Health', 'Work', 'Personal'];
  final List<int> _durations = [1, 5, 10, 20, 30, 40, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(text: widget.task?.description ?? '');
    _xpController = TextEditingController(text: widget.task?.xpReward.toString() ?? '10');
    
    if (widget.task != null) {
      _selectedCategory = widget.task!.category;
      _selectedDuration = widget.task!.durationMinutes;
      if (!_durations.contains(_selectedDuration)) {
        _durations.add(_selectedDuration);
        _durations.sort();
      }
      _isActive = widget.task!.isActive;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _xpController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final task = RPGTask(
        id: widget.task?.id ?? const Uuid().v4(),
        title: _titleController.text,
        description: _descController.text,
        category: _selectedCategory,
        xpReward: int.parse(_xpController.text),
        dueDate: widget.task?.dueDate ?? DateTime.now().add(const Duration(days: 7)),
        durationMinutes: _selectedDuration,
        isActive: _isActive,
      );

      if (widget.task == null) {
        context.read<AdminState>().addTask(task);
      } else {
        context.read<AdminState>().updateTask(task);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1C),
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add New Task' : 'Edit Task'),
        backgroundColor: const Color(0xFF0F172A),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Task Details', style: TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  
                  // Title
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Task Name'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  TextFormField(
                    controller: _descController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: _inputDecoration('Description'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      // Category
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          dropdownColor: const Color(0xFF0F172A),
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Category'),
                          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (v) => setState(() => _selectedCategory = v!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // XP Reward
                      Expanded(
                        child: TextFormField(
                          controller: _xpController,
                          style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('XP Reward'),
                          validator: (v) => v!.isEmpty || int.tryParse(v) == null ? 'Invalid XP' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Duration
                  const Text('Required Duration', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _durations.map((d) {
                      final isSelected = _selectedDuration == d;
                      return ChoiceChip(
                        label: Text('$d min', style: TextStyle(color: isSelected ? Colors.black : Colors.white)),
                        selected: isSelected,
                        selectedColor: Colors.amber,
                        backgroundColor: const Color(0xFF0F172A),
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedDuration = d);
                        },
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 24),
                  // Status
                  Row(
                    children: [
                      const Text('Status:', style: TextStyle(color: Colors.white, fontSize: 16)),
                      const SizedBox(width: 16),
                      Switch(
                        value: _isActive,
                        activeColor: Colors.amber,
                        onChanged: (val) => setState(() => _isActive = val),
                      ),
                      Text(_isActive ? 'Active' : 'Inactive', style: TextStyle(color: _isActive ? Colors.green : Colors.red)),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _saveTask,
                      child: const Text('Save Task', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF0F172A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }
}
