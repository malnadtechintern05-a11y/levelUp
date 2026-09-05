import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/app_state.dart';
import '../widgets/quest_card.dart';
import '../screens/add_quest_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/rankings_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().refreshAllData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<AppState>().refreshAllData();
    }
  }

  DecorationImage? _resolveBannerImage(AppState state) {
    if (!state.heroBannerEnabled) return null;
    final adminBanner = (state.heroBannerUrl != null && state.heroBannerUrl!.trim().isNotEmpty)
        ? state.heroBannerUrl!.trim()
        : null;
    final custom = (state.customBannerPath != null && state.customBannerPath!.trim().isNotEmpty)
        ? state.customBannerPath!.trim()
        : null;
    final banner = adminBanner ?? custom;
    if (banner == null || banner.isEmpty) return null;
    if (banner.startsWith('gradient:')) return null;

    if (banner.startsWith('http://') || banner.startsWith('https://')) {
      return DecorationImage(
        image: NetworkImage(banner),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.45), BlendMode.darken),
      );
    }

    try {
      final file = File(banner);
      if (file.existsSync()) {
        return DecorationImage(
          image: FileImage(file),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.45), BlendMode.darken),
        );
      }
    } catch (_) {}

    return null;
  }

  LinearGradient _resolveBannerGradient(AppState state) {
    final path = state.customBannerPath;
    if (path == 'gradient:cyber') {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2E0854), Color(0xFF4A154B), Color(0xFF130924)],
      );
    } else if (path == 'gradient:crimson') {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4A0E17), Color(0xFF2D080A), Color(0xFF150406)],
      );
    } else if (path == 'gradient:ocean') {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0C2461), Color(0xFF1E3799), Color(0xFF0A1430)],
      );
    } else if (path == 'gradient:emerald') {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0B3B24), Color(0xFF1A5336), Color(0xFF081E13)],
      );
    } else if (path == 'gradient:gold') {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3B2F0B), Color(0xFF53410A), Color(0xFF1E1705)],
      );
    }

    // Default clean dark RPG gradient (No photos, sleek & modern)
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF1E293B),
        Color(0xFF131D2F),
        Color(0xFF0B111E),
      ],
    );
  }

  void _showChangeBackgroundSheet(BuildContext context, AppState state) {
    final theme = Theme.of(context);

    final List<Map<String, String>> presets = [
      {
        'title': 'Cosmic Nebula',
        'url': 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=800&q=80',
      },
      {
        'title': 'Cyber City',
        'url': 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800&q=80',
      },
      {
        'title': 'Mystic Peak',
        'url': 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800&q=80',
      },
      {
        'title': 'Ancient Temple',
        'url': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&q=80',
      },
      {
        'title': 'Enchanted Woods',
        'url': 'https://images.unsplash.com/photo-1448375240586-882707db888b?w=800&q=80',
      },
      {
        'title': 'Golden Horizon',
        'url': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80',
      },
    ];

    final List<Map<String, dynamic>> gradients = [
      {'id': 'gradient:obsidian', 'label': 'Obsidian', 'colors': [const Color(0xFF1E293B), const Color(0xFF0B111E)]},
      {'id': 'gradient:cyber', 'label': 'Cyber', 'colors': [const Color(0xFF2E0854), const Color(0xFF130924)]},
      {'id': 'gradient:crimson', 'label': 'Crimson', 'colors': [const Color(0xFF4A0E17), const Color(0xFF150406)]},
      {'id': 'gradient:ocean', 'label': 'Ocean', 'colors': [const Color(0xFF0C2461), const Color(0xFF0A1430)]},
      {'id': 'gradient:emerald', 'label': 'Emerald', 'colors': [const Color(0xFF0B3B24), const Color(0xFF081E13)]},
      {'id': 'gradient:gold', 'label': 'Gold', 'colors': [const Color(0xFF3B2F0B), const Color(0xFF1E1705)]},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          expand: false,
          builder: (_, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Customize Background',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                Text(
                  'Change your Level Card background with custom photos, RPG artworks, or clean gradients.',
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 20),

                // 1. Pick from Gallery
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    try {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                      if (picked != null) {
                        await state.setCustomBanner(picked.path);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✨ Custom background photo applied!'),
                              backgroundColor: Color(0xFFF5B942),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      debugPrint('Error picking image: $e');
                    }
                  },
                  icon: const Icon(Icons.photo_library_rounded, color: Colors.black),
                  label: const Text(
                    'Choose Photo From Gallery',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5B942),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Curated RPG Presets
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 16, color: Color(0xFFF5B942)),
                    const SizedBox(width: 6),
                    Text(
                      'RPG Artworks & Wallpapers',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: presets.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (_, idx) {
                      final item = presets[idx];
                      final isSelected = state.customBannerPath == item['url'];
                      return GestureDetector(
                        onTap: () async {
                          await state.setCustomBanner(item['url']);
                          if (context.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('⚔️ Set "${item['title']}" as background!'),
                                backgroundColor: const Color(0xFF16A34A),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFF5B942) : Colors.white24,
                              width: isSelected ? 2.5 : 1,
                            ),
                            image: DecorationImage(
                              image: NetworkImage(item['url']!),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.35), BlendMode.darken),
                            ),
                          ),
                          alignment: Alignment.bottomLeft,
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item['title']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle, color: Color(0xFFF5B942), size: 16),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Clean Gradient Themes
                Row(
                  children: [
                    const Icon(Icons.palette_rounded, size: 16, color: Color(0xFFF5B942)),
                    const SizedBox(width: 6),
                    Text(
                      'Clean Gradient Themes',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: gradients.map((g) {
                    final isSelected = state.customBannerPath == g['id'] ||
                        (state.customBannerPath == null && g['id'] == 'gradient:obsidian');
                    return GestureDetector(
                      onTap: () async {
                        if (g['id'] == 'gradient:obsidian') {
                          await state.setCustomBanner(null);
                        } else {
                          await state.setCustomBanner(g['id'] as String);
                        }
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('🎨 Applied ${g['label']} gradient!'),
                              backgroundColor: const Color(0xFF1E293B),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(colors: g['colors'] as List<Color>),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFF5B942) : Colors.white24,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              g['label'] as String,
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.check, size: 14, color: Color(0xFFF5B942)),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // 4. Reset Button
                OutlinedButton.icon(
                  onPressed: () async {
                    await state.setCustomBanner(null);
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🔄 Reset to default clean dark theme (no image).'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.restart_alt_rounded, color: Colors.white70),
                  label: const Text(
                    'Reset to Default Theme (No Image)',
                    style: TextStyle(color: Colors.white70),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryChip(BuildContext context, String label, IconData icon, Color color) {
    final theme = Theme.of(context);
    final isSelected = _selectedCategory == label;
    final isDark = theme.brightness == Brightness.dark;

    final unselectedBg = isDark ? const Color(0xFF162033) : Colors.white;
    final unselectedBorder = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final unselectedText = isDark ? const Color(0xFFAAB4C2) : const Color(0xFF475569);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = label;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF5B942) : unselectedBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFFF5B942) : unselectedBorder,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (!isDark && !isSelected)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.black : color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : unselectedText,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appState = context.watch<AppState>();

    return Scaffold(
      drawer: Drawer(
        backgroundColor: theme.colorScheme.surface,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0A0F1C) : const Color(0xFF1E293B),
                gradient: _resolveBannerImage(appState) == null ? _resolveBannerGradient(appState) : null,
                image: _resolveBannerImage(appState),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Real-Life RPG', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Level up your life.', style: TextStyle(color: Color(0xFFF5B942), fontSize: 14)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.leaderboard, color: Color(0xFFF5B942)),
              title: Text('🏆 Player Rankings', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RankingsScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.settings_outlined, color: theme.colorScheme.onSurface),
              title: Text('Settings', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.sync_rounded, color: Color(0xFFF5B942)),
              title: Text('Sync with Server', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
              onTap: () async {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🔄 Syncing with LevelUp server...'),
                    duration: Duration(milliseconds: 800),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                await context.read<AppState>().refreshAllData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✨ Everything is synced with the server!'),
                      backgroundColor: Color(0xFF16A34A),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline, color: theme.colorScheme.onSurface),
              title: Text('About', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: Row(
                      children: [
                        const Icon(Icons.emoji_events, color: Color(0xFFF5B942), size: 28),
                        const SizedBox(width: 8),
                        Text('LevelUp RPG', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Version 1.0.0',
                          style: TextStyle(color: Color(0xFFF5B942), fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Turn your daily chores and habits into an epic quest! Complete tasks, earn XP, unlock achievements, and become the hero of your own life.',
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Keep grinding and leveling up!',
                          style: TextStyle(color: theme.colorScheme.onSurface, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('CLOSE', style: TextStyle(color: Color(0xFFF5B942), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            ),
            Divider(color: theme.colorScheme.outline),
            ListTile(
              leading: Icon(Icons.share_outlined, color: theme.colorScheme.onSurface),
              title: Text('Share App', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
              onTap: () async {
                Navigator.pop(context);
                const shareText = "🔥 I'm leveling up my real life with LevelUp! 🎮⚡\n"
                    "Complete real-life quests, earn XP, build streaks, and become the best version of yourself.\n"
                    "Try LevelUp!\n"
                    "https://play.google.com/store/apps/details?id=com.levelup.realliferpg";
                try {
                  await Share.share(shareText, subject: 'LevelUp - Real Life RPG');
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sharing LevelUp invitation...')),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.star_rate_outlined, color: Color(0xFFF5B942)),
              title: Text('Rate App', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
              onTap: () async {
                Navigator.pop(context);
                const playStoreUrl = 'https://play.google.com/store/apps/details?id=com.levelup.realliferpg';
                final uri = Uri.parse(playStoreUrl);
                bool launched = false;
                try {
                  if (await canLaunchUrl(uri)) {
                    launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                } catch (_) {}

                if (!launched && context.mounted) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: Row(
                        children: [
                          const Icon(Icons.star, color: Color(0xFFF5B942), size: 28),
                          const SizedBox(width: 8),
                          Text('Love LevelUp?', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      content: Text(
                        'Your feedback helps us improve and make the app even better!',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, height: 1.4),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text('Maybe Later', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF5B942),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Rate Later', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.privacy_tip_outlined, color: theme.colorScheme.onSurface),
              title: Text('Privacy Policy', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                );
              },
            ),
            Divider(color: theme.colorScheme.outline),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              onTap: () async {
                Navigator.pop(context); // close drawer
                await context.read<AppState>().logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                }
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: theme.colorScheme.onSurface),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/logo.png',
                width: 34,
                height: 34,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'Hey Hero! ',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Text('🔥', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Text(
                    "Let's crush your goals today.",
                    style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Consumer<AppState>(
            builder: (context, state, child) {
              final unreadCount = state.unreadNotificationCount;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      unreadCount > 0 ? Icons.notifications_active : Icons.notifications_none,
                      color: unreadCount > 0 ? const Color(0xFFF5B942) : theme.colorScheme.onSurface,
                    ),
                    tooltip: 'Notifications',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Sync button only shows for Admin users, not other/regular users
          Consumer<AppState>(
            builder: (context, state, child) {
              if (!state.isAdmin) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.sync_rounded, color: Color(0xFFF5B942)),
                tooltip: 'Sync with Server',
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🔄 Syncing with LevelUp server...'),
                      duration: Duration(milliseconds: 800),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  await state.refreshAllData();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✨ Level, Quests & Banner synced with Server!'),
                        backgroundColor: Color(0xFF16A34A),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, state, child) {
          final activeTasks = state.activeTasks;
          final todayCompletedTasks = state.getCompletedTasksForDate(DateTime.now());
          final totalTasks = activeTasks.length + todayCompletedTasks.length;
          final completedCount = todayCompletedTasks.length;
          final progress = totalTasks > 0 ? completedCount / totalTasks : 0.0;

          final filteredTasks = _selectedCategory == 'All'
              ? activeTasks
              : activeTasks.where((t) => t.category == _selectedCategory).toList();

          return RefreshIndicator(
            onRefresh: () async {
              await state.refreshAllData();
            },
            color: const Color(0xFFF5B942),
            backgroundColor: const Color(0xFF162033),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
              if (state.isMaintenanceMode)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7F1D1D),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEF4444), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFFCA5A5), size: 26),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'REALM MAINTENANCE ACTIVE',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              state.maintenanceMessage,
                              style: const TextStyle(color: Color(0xFFFEE2E2), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Hero Banner (Level Card)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                height: 165,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: _resolveBannerImage(state) == null ? _resolveBannerGradient(state) : null,
                  image: _resolveBannerImage(state),
                  border: Border.all(
                    color: const Color(0xFFF5B942).withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.heroBannerTitle ?? 'Level ${state.userProfile.level}',
                                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.1),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  state.heroBannerSubtitle ?? 'Hero Rank: ${state.userProfile.username}',
                                  style: const TextStyle(color: Color(0xFFF5B942), fontSize: 12, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Option to change background
                          InkWell(
                            onTap: () => _showChangeBackgroundSheet(context, state),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFF5B942).withValues(alpha: 0.4), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.palette_outlined, size: 14, color: Color(0xFFF5B942)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Background',
                                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('XP Progress', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text('${state.userProfile.totalXP} / ${state.userProfile.level * 100} XP', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (state.userProfile.totalXP / (state.userProfile.level * 100)).clamp(0.0, 1.0),
                          backgroundColor: Colors.white24,
                          color: const Color(0xFFF5B942),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Daily Progress Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Daily Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                    Text('$completedCount / $totalTasks Completed', style: const TextStyle(color: Color(0xFFF5B942), fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    color: const Color(0xFFF5B942),
                    minHeight: 8,
                  ),
                ),
              ),
              if (state.quoteOfTheDay != null && state.quoteOfTheDay!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF5B942).withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Color(0xFFF5B942), size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            state.quoteOfTheDay!,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Categories Horizontal Scroll
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    _buildCategoryChip(context, 'All', Icons.dashboard_customize, const Color(0xFFF5B942)),
                    _buildCategoryChip(context, 'Study', Icons.menu_book, Colors.blueAccent),
                    _buildCategoryChip(context, 'Fitness', Icons.fitness_center, Colors.redAccent),
                    _buildCategoryChip(context, 'Health', Icons.favorite, Colors.green),
                    _buildCategoryChip(context, 'Work', Icons.work, Colors.purpleAccent),
                    _buildCategoryChip(context, 'Personal', Icons.person, Colors.orangeAccent),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Today's Tasks Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Active Tasks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                    Text(
                      '${filteredTasks.length} pending',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Task List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: filteredTasks.isEmpty
                      ? [
                          Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.check_circle_outline, size: 48, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                                  const SizedBox(height: 12),
                                  Text("No active tasks in this category.", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14)),
                                ],
                              ),
                            ),
                          )
                        ]
                      : filteredTasks.map((task) => QuestCard(
                            task: task,
                            onComplete: () => state.completeTask(task.id),
                          )).toList(),
                ),
              ),

              if (todayCompletedTasks.isNotEmpty) ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Completed Today", 
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold, 
                          color: isDark ? const Color(0xFF4CAF50) : const Color(0xFF16A34A),
                        ),
                      ),
                      Text(
                        '${todayCompletedTasks.length} done',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF4CAF50) : const Color(0xFF16A34A), 
                          fontSize: 13, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: todayCompletedTasks.map((task) => QuestCard(
                          task: task,
                          onComplete: () {},
                        )).toList(),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    ),
    floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddQuestScreen()));
        },
        backgroundColor: const Color(0xFFF5B942),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add, size: 24),
        label: const Text('Add Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
