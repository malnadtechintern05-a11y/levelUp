import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';
import '../../providers/admin_state.dart';

class AdminAchievementsScreen extends StatefulWidget {
  const AdminAchievementsScreen({Key? key}) : super(key: key);

  @override
  State<AdminAchievementsScreen> createState() => _AdminAchievementsScreenState();
}

class _AdminAchievementsScreenState extends State<AdminAchievementsScreen> {
  String _searchQuery = '';

  void _showAchievementForm([Achievement? achievement]) {
    final titleCtrl = TextEditingController(text: achievement?.name ?? '');
    final descCtrl = TextEditingController(text: achievement?.description ?? '');
    final xpCtrl = TextEditingController(text: achievement?.xpReward.toString() ?? '100');
    final reqCtrl = TextEditingController(text: achievement?.unlockRequirement ?? '');
    bool isActive = achievement?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: Text(achievement == null ? 'Add Achievement' : 'Edit Achievement', style: const TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Container(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Achievement Name', labelStyle: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Description', labelStyle: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: reqCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Unlock Requirement (e.g. Reach Level 5)', labelStyle: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: xpCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.amber),
                      decoration: const InputDecoration(labelText: 'XP Reward', labelStyle: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Status:', style: TextStyle(color: Colors.white)),
                        Switch(
                          value: isActive,
                          activeColor: Colors.amber,
                          onChanged: (val) => setState(() => isActive = val),
                        ),
                        Text(isActive ? 'Active' : 'Inactive', style: TextStyle(color: isActive ? Colors.green : Colors.red)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                onPressed: () {
                  final newAchv = Achievement(
                    id: achievement?.id ?? const Uuid().v4(),
                    name: titleCtrl.text,
                    description: descCtrl.text,
                    xpReward: int.tryParse(xpCtrl.text) ?? 0,
                    unlockRequirement: reqCtrl.text,
                    isUnlocked: achievement?.isUnlocked ?? false,
                    isActive: isActive,
                  );
                  
                  final state = context.read<AdminState>();
                  final list = List<Achievement>.from(state.achievements);
                  if (achievement == null) {
                    list.add(newAchv);
                  } else {
                    final index = list.indexWhere((a) => a.id == achievement.id);
                    if (index != -1) list[index] = newAchv;
                  }
                  state.saveAchievements(list);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AdminState>();
    final achievements = state.achievements.where((a) {
      return a.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Manage Achievements',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  SizedBox(
                    width: 250,
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search achievements...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF1E293B),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showAchievementForm(),
                    icon: const Icon(Icons.add, color: Colors.black),
                    label: const Text('Add Achievement', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    headingTextStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    dataTextStyle: const TextStyle(color: Colors.white),
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Description')),
                      DataColumn(label: Text('Requirement')),
                      DataColumn(label: Text('XP Reward')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: achievements.map((achv) {
                      return DataRow(cells: [
                        DataCell(Text(achv.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(achv.description)),
                        DataCell(Text(achv.unlockRequirement)),
                        DataCell(Text(achv.xpReward.toString(), style: const TextStyle(color: Colors.amber))),
                        DataCell(
                          Text(achv.isActive ? 'Active' : 'Inactive', style: TextStyle(color: achv.isActive ? Colors.green : Colors.red)),
                        ),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.amber),
                              onPressed: () => _showAchievementForm(achv),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                final list = List<Achievement>.from(state.achievements);
                                list.removeWhere((a) => a.id == achv.id);
                                state.saveAchievements(list);
                              },
                            ),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
