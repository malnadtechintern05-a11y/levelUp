import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../screens/settings_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/rankings_screen.dart';
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

  Widget _buildSkillBar(BuildContext context, String icon, String skillName, int totalXp, Color color) {
    final theme = Theme.of(context);
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
                    Text(skillName, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface, fontSize: 15)),
                    Text('Level $level', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Text('$currentXp / 100 XP', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hero Profile', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: theme.colorScheme.onSurface), 
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
          final progress = (profile.totalXP / xpNeeded).clamp(0.0, 1.0);

          return ListView(
            padding: const EdgeInsets.only(bottom: 120.0),
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
                        colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.55), BlendMode.darken),
                      ),
                    ),
                  ),
                  // Avatar
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.scaffoldBackgroundColor,
                      border: Border.all(color: theme.scaffoldBackgroundColor, width: 8),
                    ),
                    child: GestureDetector(
                      onTap: () => _pickImage(context),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFF5B942), width: 4),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFFF5B942).withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 5),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: theme.colorScheme.surfaceContainerHighest,
                              backgroundImage: profile.profileImagePath != null 
                                ? FileImage(File(profile.profileImagePath!)) 
                                : null,
                              child: profile.profileImagePath == null 
                                ? Icon(AvatarHelper.getIconForId(profile.avatarId), size: 60, color: const Color(0xFFF5B942))
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
                                color: const Color(0xFFF5B942),
                                shape: BoxShape.circle,
                                border: Border.all(color: theme.scaffoldBackgroundColor, width: 3),
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
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Level ${profile.level}',
                      style: const TextStyle(fontSize: 18, color: Color(0xFFF5B942), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // XP Progress Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('XP Progress', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
                            Text('${profile.totalXP} / $xpNeeded XP', style: const TextStyle(color: Color(0xFFF5B942), fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            color: const Color(0xFFF5B942),
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
                          child: _buildStatBox(context, 'Total XP', '${profile.totalXP}', const Color(0xFFF5B942)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatBox(context, 'Tasks Done', '${state.completedTasks.length}', isDark ? const Color(0xFF4CAF50) : const Color(0xFF16A34A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatBox(context, 'Current Streak', '${profile.currentStreak} Days', profile.currentStreak == 0 ? Colors.red.shade400 : Colors.green),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Skills', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildSkillBar(context, '💪', 'Strength', profile.skills['Strength'] ?? 0, Colors.redAccent),
                        _buildSkillBar(context, '📚', 'Knowledge', profile.skills['Knowledge'] ?? 0, Colors.blueAccent),
                        _buildSkillBar(context, '🔥', 'Discipline', profile.skills['Discipline'] ?? 0, Colors.orange),
                        _buildSkillBar(context, '🎯', 'Focus', profile.skills['Focus'] ?? 0, Colors.purpleAccent),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFFF5B942),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.leaderboard, color: Colors.black),
                    label: const Text(
                      '🏆 Player Rankings',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RankingsScreen()));
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      foregroundColor: theme.colorScheme.onSurface,
                      side: BorderSide(color: theme.colorScheme.outline),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                    },
                    child: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      await context.read<AppState>().logout();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                      }
                    },
                    child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
