import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../screens/settings_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../widgets/avatar_helper.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        Provider.of<AppState>(context, listen: false).updateProfileImage(image.path);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Widget _buildSkillBar(String icon, String skillName, int totalXp, Color color) {
    int level = (totalXp / 100).floor();
    int currentXp = totalXp % 100;
    double progress = currentXp / 100.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(skillName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                    Text('Level $level', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Text('$currentXp / 100 XP', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFF162033),
              color: color,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1C),
      appBar: AppBar(
        title: const Text('Hero Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings), 
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, state, child) {
          final profile = state.userProfile;
          final xpNeeded = profile.level * 100;
          final progress = profile.totalXP / xpNeeded;

          return ListView(
            padding: const EdgeInsets.only(bottom: 120.0), // Safe bottom padding
            children: [
              // Banner & Avatar Stack
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Banner Image
                  Container(
                    height: 180,
                    margin: const EdgeInsets.only(bottom: 60),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                      image: DecorationImage(
                        image: const AssetImage('assets/images/banner_hero.jpg'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
                      ),
                    ),
                  ),
                  // Avatar
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0A0F1C),
                      border: Border.all(color: const Color(0xFF0A0F1C), width: 8),
                    ),
                    child: GestureDetector(
                      onTap: () => _pickImage(context),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.amber, width: 4),
                              boxShadow: [
                                BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 15, spreadRadius: 5),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: const Color(0xFF162033),
                              backgroundImage: profile.profileImagePath != null 
                                ? FileImage(File(profile.profileImagePath!)) 
                                : null,
                              child: profile.profileImagePath == null 
                                ? Icon(AvatarHelper.getIconForId(profile.avatarId), size: 60, color: Colors.white)
                                : null,
                            ),
                          ),
                          // Edit Icon Overlay
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF0A0F1C), width: 3),
                              ),
                              child: const Icon(Icons.edit, size: 18, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Basic Info
              Center(
                child: Column(
                  children: [
                    Text(
                      profile.username,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Level ${profile.level}',
                      style: const TextStyle(fontSize: 18, color: Colors.amber, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // XP Progress
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  color: const Color(0xFF162033),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('XP Progress', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text('${profile.totalXP} / $xpNeeded XP', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.black45,
                            color: Colors.amber,
                            minHeight: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Stats Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatBox(context, 'Total XP', '${profile.totalXP}', Colors.amber),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatBox(context, 'Tasks Done', '${state.completedTasks.length}', Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatBox(context, 'Current Streak', '${profile.currentStreak} Days', profile.currentStreak == 0 ? Colors.red.shade300 : Colors.greenAccent),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatBox(context, 'Best Streak', '${profile.bestStreak} Days', Colors.orangeAccent),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Skills Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Skills', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  color: const Color(0xFF162033),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildSkillBar('💪', 'Strength', profile.skills['Strength'] ?? 0, Colors.redAccent),
                        _buildSkillBar('📚', 'Knowledge', profile.skills['Knowledge'] ?? 0, Colors.blueAccent),
                        _buildSkillBar('🔥', 'Discipline', profile.skills['Discipline'] ?? 0, Colors.orange),
                        _buildSkillBar('🎯', 'Focus', profile.skills['Focus'] ?? 0, Colors.purpleAccent),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF2A3042),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                    },
                    child: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatBox(BuildContext context, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF162033),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
