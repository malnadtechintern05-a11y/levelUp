import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      context.read<AppState>().updateProfile(_username, _selectedAvatarId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Choose Avatar', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
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
                            color: isSelected ? Colors.amber : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isSelected ? [BoxShadow(color: Colors.amber.withOpacity(0.5), blurRadius: 8)] : [],
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: Icon(AvatarHelper.getIconForId(avatarId), size: 36, color: Colors.white),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 40),
              const Text('Hero Name', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _username,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a name' : null,
                onSaved: (value) => _username = value!.trim(),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
