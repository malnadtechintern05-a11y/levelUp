import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_state.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AdminState>();
    final users = state.users.where((u) {
      return u.username.toLowerCase().contains(_searchQuery.toLowerCase()) || 
             (u.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
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
                'Manage Users',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 300,
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
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
                      DataColumn(label: Text('Profile')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Level')),
                      DataColumn(label: Text('XP')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: users.map((user) {
                      return DataRow(cells: [
                        DataCell(CircleAvatar(
                          backgroundColor: Colors.amber,
                          child: Text(user.username[0].toUpperCase(), style: const TextStyle(color: Colors.black)),
                        )),
                        DataCell(Text(user.username)),
                        DataCell(Text(user.email ?? 'N/A')),
                        DataCell(Text(user.level.toString())),
                        DataCell(Text(user.totalXP.toString())),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: user.isActive ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(color: user.isActive ? Colors.green : Colors.red, fontSize: 12),
                            ),
                          ),
                        ),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility, color: Colors.blue),
                              onPressed: () {
                                // View User detail (coming soon)
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('View User Details Coming Soon')));
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.amber),
                              onPressed: () {
                                // Edit User (coming soon)
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit User Coming Soon')));
                              },
                            ),
                            IconButton(
                              icon: Icon(user.isActive ? Icons.block : Icons.check_circle, color: user.isActive ? Colors.red : Colors.green),
                              onPressed: () {
                                context.read<AdminState>().toggleUserStatus(user.username);
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
