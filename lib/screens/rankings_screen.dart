import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ranking_models.dart';
import '../providers/app_state.dart';
import '../providers/rankings_provider.dart';
import '../screens/player_profile_screen.dart';
import '../widgets/avatar_helper.dart';

class RankingsScreen extends StatefulWidget {
  const RankingsScreen({super.key});

  @override
  State<RankingsScreen> createState() => _RankingsScreenState();
}

class _RankingsScreenState extends State<RankingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      final rankingsProvider = Provider.of<RankingsProvider>(context, listen: false);
      rankingsProvider.loadRankings(currentUsername: appState.userProfile.username);
    });
  }

  void _openPlayerProfile(RankingPlayer player) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerProfileScreen(
          playerId: player.id,
          fallbackUsername: player.username,
          fallbackRank: player.rank,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appState = Provider.of<AppState>(context);
    final rankings = Provider.of<RankingsProvider>(context);

    final currentUsername = appState.userProfile.username;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 Player Rankings', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Rankings',
            onPressed: () => rankings.refreshRankings(currentUsername: currentUsername),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFFF5B942),
        backgroundColor: isDark ? const Color(0xFF162033) : Colors.white,
        onRefresh: () => rankings.refreshRankings(currentUsername: currentUsername),
        child: rankings.isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFF5B942)),
                    SizedBox(height: 16),
                    Text('Summoning hero leaderboard...', style: TextStyle(color: Color(0xFFAAB4C2))),
                  ],
                ),
              )
            : rankings.errorMessage != null
                ? _buildErrorState(context, rankings.errorMessage!)
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    children: [
                      // Subtitle
                      Text(
                        'See how you rank among other LevelUp players.',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 1. Current User Ranking Summary Card
                      _buildCurrentUserPositionCard(context, rankings.currentUserRank, appState),
                      const SizedBox(height: 16),

                      // 2. Ranking Category Tabs
                      _buildCategorySelector(context, rankings),
                      const SizedBox(height: 12),

                      // 3. Time Filter Row
                      _buildTimeFilterRow(context, rankings),
                      const SizedBox(height: 16),

                      // 4. Podium or Empty State
                      if (rankings.players.isEmpty)
                        _buildEmptyState(context)
                      else ...[
                        // Top 3 Podium
                        if (rankings.players.length >= 2) ...[
                          _buildPodiumSection(context, rankings),
                          const SizedBox(height: 20),
                        ],

                        // Full Leaderboard Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              rankings.players.length >= 3 ? 'Hero Leaderboard' : 'Rankings List',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${rankings.players.length} Heroes',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Full Roster List
                        _buildFullRankingsList(context, rankings),
                      ],

                      const SizedBox(height: 32),
                    ],
                  ),
      ),
    );
  }

  // 1. Current User Position Summary Card
  Widget _buildCurrentUserPositionCard(
    BuildContext context,
    RankingPlayer? userRank,
    AppState appState,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profile = appState.userProfile;

    final rankNum = userRank?.rank ?? 1;
    final levelNum = userRank?.level ?? profile.level;
    final xpNum = userRank?.totalXP ?? profile.totalXP;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162033) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF5B942),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF5B942).withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF5B942), Color(0xFFD97706)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF5B942).withValues(alpha: 0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'RANK',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '#$rankNum',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // User Avatar
          AvatarHelper.buildAvatar(
            avatarId: profile.avatarId,
            profileImagePath: profile.profileImagePath,
            radius: 22,
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        profile.username,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5B942),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'YOU',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Level $levelNum • ${userRank?.displayScore ?? '$xpNum XP'}',
                  style: const TextStyle(
                    color: Color(0xFFF5B942),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Show real rank movement only if available
                if (userRank?.rankMovement != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        userRank!.rankMovement! > 0
                            ? Icons.arrow_upward
                            : userRank.rankMovement! < 0
                                ? Icons.arrow_downward
                                : Icons.remove,
                        color: userRank.rankMovement! > 0
                            ? const Color(0xFF10B981)
                            : userRank.rankMovement! < 0
                                ? const Color(0xFFEF4444)
                                : const Color(0xFFAAB4C2),
                        size: 13,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        userRank.rankMovement! > 0
                            ? 'Moved up ${userRank.rankMovement} places'
                            : userRank.rankMovement! < 0
                                ? 'Dropped ${userRank.rankMovement!.abs()} places'
                                : 'No change in rank',
                        style: TextStyle(
                          color: userRank.rankMovement! > 0
                              ? const Color(0xFF10B981)
                              : userRank.rankMovement! < 0
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFFAAB4C2),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Ranking Category Selector (Tabs)
  Widget _buildCategorySelector(BuildContext context, RankingsProvider rankings) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: RankingType.values.map((type) {
          final isSelected = rankings.selectedType == type;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(type.tabLabel),
              selected: isSelected,
              selectedColor: const Color(0xFFF5B942),
              backgroundColor: isDark ? const Color(0xFF162033) : Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFFF5B942)
                    : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              ),
              onSelected: (selected) {
                if (selected) {
                  final appState = Provider.of<AppState>(context, listen: false);
                  rankings.selectType(type, currentUsername: appState.userProfile.username);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // 3. Time Filter Row
  Widget _buildTimeFilterRow(BuildContext context, RankingsProvider rankings) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.schedule, size: 16, color: Color(0xFFF5B942)),
            const SizedBox(width: 6),
            Text(
              'Timeframe:',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF162033) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<RankingPeriod>(
              value: rankings.selectedPeriod,
              dropdownColor: isDark ? const Color(0xFF162033) : Colors.white,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFF5B942)),
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              items: RankingPeriod.values.map((period) {
                return DropdownMenuItem<RankingPeriod>(
                  value: period,
                  child: Text(period.label),
                );
              }).toList(),
              onChanged: (newPeriod) {
                if (newPeriod != null) {
                  final appState = Provider.of<AppState>(context, listen: false);
                  rankings.selectPeriod(newPeriod, currentUsername: appState.userProfile.username);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // 4. Top 3 Podium Section
  Widget _buildPodiumSection(BuildContext context, RankingsProvider rankings) {
    final p1 = rankings.podiumFirst;
    final p2 = rankings.podiumSecond;
    final p3 = rankings.podiumThird;

    if (p1 == null) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // #2 Silver
        if (p2 != null)
          Expanded(
            flex: 3,
            child: _buildPodiumStep(
              context,
              player: p2,
              rank: 2,
              podiumHeight: 110,
              accentColor: const Color(0xFF94A3B8), // Silver
              label: '🥈 #2',
              avatarRadius: 26,
            ),
          )
        else
          const Spacer(flex: 3),

        const SizedBox(width: 8),

        // #1 Gold Champion
        Expanded(
          flex: 4,
          child: _buildPodiumStep(
            context,
            player: p1,
            rank: 1,
            podiumHeight: 140,
            accentColor: const Color(0xFFF5B942), // Gold
            label: '🥇 #1 CHAMPION',
            avatarRadius: 34,
            isProminent: true,
          ),
        ),

        const SizedBox(width: 8),

        // #3 Bronze
        if (p3 != null)
          Expanded(
            flex: 3,
            child: _buildPodiumStep(
              context,
              player: p3,
              rank: 3,
              podiumHeight: 90,
              accentColor: const Color(0xFFCD7F32), // Bronze
              label: '🥉 #3',
              avatarRadius: 24,
            ),
          )
        else
          const Spacer(flex: 3),
      ],
    );
  }

  Widget _buildPodiumStep(
    BuildContext context, {
    required RankingPlayer player,
    required int rank,
    required double podiumHeight,
    required Color accentColor,
    required String label,
    required double avatarRadius,
    bool isProminent = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _openPlayerProfile(player),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Crown on #1
          if (isProminent)
            const Text('👑', style: TextStyle(fontSize: 22))
          else
            const SizedBox(height: 12),

          // Avatar Ring
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accentColor, width: isProminent ? 3 : 2),
              boxShadow: [
                if (isProminent)
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: AvatarHelper.buildAvatar(
              avatarId: player.avatarId,
              profileImagePath: player.profileImagePath,
              radius: avatarRadius,
            ),
          ),
          const SizedBox(height: 6),

          // Username
          Text(
            player.username,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: isProminent ? 13 : 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Score
          Text(
            player.displayScore,
            style: TextStyle(
              color: isProminent ? const Color(0xFFF5B942) : accentColor,
              fontWeight: FontWeight.w700,
              fontSize: isProminent ? 12 : 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),

          // Podium Pedestal Block
          Container(
            height: podiumHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        accentColor.withValues(alpha: isProminent ? 0.35 : 0.2),
                        const Color(0xFF162033),
                      ]
                    : [
                        accentColor.withValues(alpha: isProminent ? 0.25 : 0.15),
                        Colors.white,
                      ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border.all(color: accentColor.withValues(alpha: 0.6), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isProminent ? Colors.white : accentColor,
                    fontWeight: FontWeight.w900,
                    fontSize: isProminent ? 12 : 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'LVL ${player.level}',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 5. Full Leaderboard List (#4 onwards or all)
  Widget _buildFullRankingsList(BuildContext context, RankingsProvider rankings) {
    // Show remaining players (or all if < 3)
    final list = rankings.players.length >= 3
        ? rankings.remainingPlayers
        : rankings.players;

    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: Text('No further contenders in this ranking category.'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final player = list[index];
        return _buildPlayerRowCard(context, player);
      },
    );
  }

  Widget _buildPlayerRowCard(BuildContext context, RankingPlayer player) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMe = player.isCurrentUser;

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: isMe
            ? (isDark ? const Color(0xFF1A263D) : const Color(0xFFFFFBEB))
            : (isDark ? const Color(0xFF162033) : Colors.white),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMe
              ? const Color(0xFFF5B942)
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          width: isMe ? 1.5 : 1,
        ),
        boxShadow: [
          if (isMe)
            BoxShadow(
              color: const Color(0xFFF5B942).withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        onTap: () => _openPlayerProfile(player),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rank Number
            SizedBox(
              width: 32,
              child: Text(
                '#${player.rank}',
                style: TextStyle(
                  color: isMe ? const Color(0xFFF5B942) : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 8),

            // Avatar
            AvatarHelper.buildAvatar(
              avatarId: player.avatarId,
              profileImagePath: player.profileImagePath,
              radius: 18,
            ),
          ],
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                player.username,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: isMe ? FontWeight.w900 : FontWeight.bold,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isMe) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5B942),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'YOU',
                  style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          'Level ${player.level} • ${player.completedTasks} Quests',
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              player.displayScore,
              style: TextStyle(
                color: isMe ? const Color(0xFFF5B942) : theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            if (player.currentStreak > 0)
              Text(
                '🔥 ${player.currentStreak}d',
                style: const TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Empty State
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.military_tech_outlined, size: 56, color: Color(0xFFAAB4C2)),
            const SizedBox(height: 12),
            Text(
              'No players available yet.',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Complete your quests to become the very first ranked hero!',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Error State with [ Retry ]
  Widget _buildErrorState(BuildContext context, String message) {
    final appState = Provider.of<AppState>(context, listen: false);
    final rankings = Provider.of<RankingsProvider>(context, listen: false);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
            const SizedBox(height: 14),
            Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5B942),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () => rankings.loadRankings(currentUsername: appState.userProfile.username),
            ),
          ],
        ),
      ),
    );
  }
}
