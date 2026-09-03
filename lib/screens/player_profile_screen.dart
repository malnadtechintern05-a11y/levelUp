import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ranking_models.dart';
import '../providers/rankings_provider.dart';
import '../widgets/avatar_helper.dart';

class PlayerProfileScreen extends StatefulWidget {
  final dynamic playerId;
  final String fallbackUsername;
  final int? fallbackRank;

  const PlayerProfileScreen({
    super.key,
    required this.playerId,
    required this.fallbackUsername,
    this.fallbackRank,
  });

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  PlayerPublicProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final provider = Provider.of<RankingsProvider>(context, listen: false);
    final data = await provider.fetchPublicProfile(widget.playerId);
    if (mounted) {
      setState(() {
        _profile = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final rankDisplay = _profile?.rank ?? widget.fallbackRank ?? 1;
    final usernameDisplay = _profile?.username ?? widget.fallbackUsername;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hero Codex', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF5B942)))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              children: [
                // Hero Header Card
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF162033) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: rankDisplay == 1
                          ? const Color(0xFFF5B942)
                          : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                      width: rankDisplay == 1 ? 2 : 1,
                    ),
                    boxShadow: [
                      if (rankDisplay == 1)
                        BoxShadow(
                          color: const Color(0xFFF5B942).withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Avatar & Rank Badge
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: rankDisplay == 1
                                    ? const Color(0xFFF5B942)
                                    : const Color(0xFF38BDF8),
                                width: 3,
                              ),
                            ),
                            child: AvatarHelper.buildAvatar(
                              avatarId: _profile?.avatarId ?? 'hero1',
                              profileImagePath: _profile?.profileImagePath,
                              radius: 44,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: rankDisplay == 1
                                  ? const Color(0xFFF5B942)
                                  : const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black26),
                            ),
                            child: Text(
                              '#$rankDisplay',
                              style: TextStyle(
                                color: rankDisplay == 1 ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Text(
                        usernameDisplay,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Level Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5B942).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFF5B942).withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          'LEVEL ${_profile?.level ?? 1} HERO',
                          style: const TextStyle(
                            color: Color(0xFFF5B942),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Public Metric Counters
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        context,
                        icon: Icons.bolt,
                        iconColor: const Color(0xFFF5B942),
                        label: 'Total XP',
                        value: '${_profile?.totalXP ?? 0}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricTile(
                        context,
                        icon: Icons.check_circle_outline,
                        iconColor: const Color(0xFF10B981),
                        label: 'Completed',
                        value: '${_profile?.completedTasks ?? 0}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        context,
                        icon: Icons.local_fire_department,
                        iconColor: const Color(0xFFEF4444),
                        label: 'Habit Streak',
                        value: '${_profile?.currentStreak ?? 0} Days',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricTile(
                        context,
                        icon: Icons.military_tech,
                        iconColor: const Color(0xFFA855F7),
                        label: 'Trophies',
                        value: '${_profile?.achievementsCount ?? 0}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Public RPG Attributes Section
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF162033) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.pie_chart, color: Color(0xFFF5B942), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Public RPG Attributes',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...(_profile?.skills.entries.map((entry) {
                            final val = entry.value.clamp(0, 100);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: TextStyle(
                                          color: theme.colorScheme.onSurfaceVariant,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '$val / 100',
                                        style: TextStyle(
                                          color: theme.colorScheme.onSurface,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: val / 100.0,
                                      minHeight: 6,
                                      backgroundColor: const Color(0xFF0F172A),
                                      color: const Color(0xFFF5B942),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }) ??
                          []),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                // Privacy notice
                Center(
                  child: Text(
                    '🛡️ Only safe, public achievements are displayed here.',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162033) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 11),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
