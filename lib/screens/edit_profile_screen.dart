import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/app_state.dart';
import '../widgets/avatar_helper.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _selectedAvatarId = 'hero1';
  bool _showOnLeaderboard = true;

  final List<String> _availableAvatars = [
    'hero1', // Person
    'hero2', // Face
    'hero3', // Star
    'hero4', // Shield
    'hero5', // Bolt
    'hero6', // Pet
  ];

  @override
  void initState() {
    super.initState();
    final profile = context.read<AppState>().userProfile;
    _username = profile.username;
    _selectedAvatarId = profile.avatarId;

    SharedPreferences.getInstance().then((prefs) {
      if (mounted) {
        setState(() {
          _showOnLeaderboard = prefs.getBool('show_on_leaderboard') ?? true;
        });
      }
    });
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await context.read<AppState>().updateProfile(_username, _selectedAvatarId);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('show_on_leaderboard', _showOnLeaderboard);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Avatar', 
                style: TextStyle(
                  color: isDark ? const Color(0xFFF5B942) : const Color(0xFFD97706), 
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: _availableAvatars.map((avatarId) {
                    final isSelected = _selectedAvatarId == avatarId;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatarId = avatarId;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? const Color(0xFFF5B942) : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isSelected ? [BoxShadow(color: const Color(0xFFF5B942).withValues(alpha: 0.4), blurRadius: 8)] : [],
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            AvatarHelper.getIconForId(avatarId), 
                            size: 34, 
                            color: isSelected ? const Color(0xFFF5B942) : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Hero Name', 
                style: TextStyle(
                  color: isDark ? const Color(0xFFF5B942) : const Color(0xFFD97706), 
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _username,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a name' : null,
                onSaved: (value) => _username = value!.trim(),
              ),
              const SizedBox(height: 24),
              Text(
                'Leaderboard Privacy', 
                style: TextStyle(
                  color: isDark ? const Color(0xFFF5B942) : const Color(0xFFD97706), 
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Show me on Leaderboard', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Allow other heroes to view your public rank, level, and trophies', style: TextStyle(fontSize: 12)),
                value: _showOnLeaderboard,
                activeThumbColor: const Color(0xFFF5B942),
                onChanged: (val) {
                  setState(() {
                    _showOnLeaderboard = val;
                  });
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5B942),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _save,
                  child: const Text('SAVE CHANGES', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
