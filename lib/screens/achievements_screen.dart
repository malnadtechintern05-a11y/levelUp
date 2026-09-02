import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Achievements', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
      ),
      body: Consumer<AppState>(
        builder: (context, state, child) {
          final achievements = state.achievements;
          final unlockedCount = achievements.where((a) => a.isUnlocked).length;
          final totalCount = achievements.length;
          final progress = totalCount > 0 ? unlockedCount / totalCount : 0.0;
          
          final nextAchievement = achievements.firstWhere((a) => !a.isUnlocked, orElse: () => achievements.last);

          return Column(
            children: [
              // Progress Banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4527A0), Color(0xFF283593)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Achievements Unlocked', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                        Text('$unlockedCount / $totalCount', style: const TextStyle(color: Color(0xFFF5B942), fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.black38,
                        color: const Color(0xFFF5B942),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Achievement List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    final achievement = achievements[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: achievement.isUnlocked
                              ? const Color(0xFFF5B942).withValues(alpha: 0.5)
                              : theme.colorScheme.outline,
                          width: achievement.isUnlocked ? 1.5 : 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Icon Left
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: achievement.isUnlocked 
                                    ? const Color(0xFFF5B942).withValues(alpha: 0.15) 
                                    : theme.colorScheme.surfaceContainerHighest,
                                border: Border.all(
                                  color: achievement.isUnlocked 
                                      ? const Color(0xFFF5B942) 
                                      : theme.colorScheme.outline,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                achievement.isUnlocked ? Icons.emoji_events : Icons.lock,
                                color: achievement.isUnlocked 
                                    ? const Color(0xFFF5B942) 
                                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Center Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    achievement.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    achievement.description,
                                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            
                            // Status Right
                            Text(
                              achievement.isUnlocked ? 'UNLOCKED' : 'LOCKED',
                              style: TextStyle(
                                color: achievement.isUnlocked 
                                    ? const Color(0xFFF5B942) 
                                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Next Achievement Section
              if (unlockedCount < totalCount)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text("Next Achievement", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface)),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: theme.colorScheme.outline),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.star_border, color: Color(0xFFF5B942), size: 24),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(nextAchievement.name, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface, fontSize: 15)),
                                        Text(nextAchievement.description, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Level progress', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                                  Text('${state.userProfile.level} / 5', style: const TextStyle(color: Color(0xFFF5B942), fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: (state.userProfile.level / 5).clamp(0.0, 1.0),
                                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                  color: const Color(0xFFF5B942),
                                  minHeight: 4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
