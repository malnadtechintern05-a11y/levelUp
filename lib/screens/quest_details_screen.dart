import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import 'hydration_details_screen.dart';

class QuestDetailsScreen extends StatefulWidget {
  final RPGTask task;

  const QuestDetailsScreen({super.key, required this.task});

  @override
  State<QuestDetailsScreen> createState() => _QuestDetailsScreenState();
}

class _QuestDetailsScreenState extends State<QuestDetailsScreen> {
  bool _isTipsExpanded = false;

  // --- Dynamic Category Styling & Icons ---
  IconData _getCategoryIcon(String category) {
    final cat = category.trim().toLowerCase();
    if (cat.contains('fitness') || cat.contains('gym') || cat.contains('workout')) {
      return Icons.fitness_center;
    } else if (cat.contains('study')) {
      return Icons.menu_book;
    } else if (cat.contains('health') || cat.contains('water')) {
      return Icons.favorite;
    } else if (cat.contains('learning') || cat.contains('learn')) {
      return Icons.psychology;
    } else if (cat.contains('work')) {
      return Icons.work;
    } else if (cat.contains('coding') || cat.contains('code') || cat.contains('dev')) {
      return Icons.code;
    } else if (cat.contains('reading') || cat.contains('read') || cat.contains('book')) {
      return Icons.auto_stories;
    } else if (cat.contains('meditation') || cat.contains('meditat') || cat.contains('mindful')) {
      return Icons.self_improvement;
    } else if (cat.contains('walking') || cat.contains('walk')) {
      return Icons.directions_walk;
    } else if (cat.contains('social')) {
      return Icons.people;
    } else if (cat.contains('creative') || cat.contains('draw') || cat.contains('paint')) {
      return Icons.palette;
    } else if (cat.contains('cleaning') || cat.contains('clean')) {
      return Icons.cleaning_services;
    } else if (cat.contains('daily')) {
      return Icons.wb_sunny;
    } else if (cat.contains('habit')) {
      return Icons.local_fire_department;
    } else if (cat.contains('hobbies') || cat.contains('hobby')) {
      return Icons.sports_esports;
    } else {
      return Icons.star;
    }
  }

  Color _getCategoryColor(String category) {
    final cat = category.trim().toLowerCase();
    if (cat.contains('fitness') || cat.contains('gym')) {
      return const Color(0xFFF97316); // Vibrant Orange
    } else if (cat.contains('study')) {
      return const Color(0xFF3B82F6); // Royal Blue
    } else if (cat.contains('health')) {
      return const Color(0xFFEF4444); // Crimson / Heart Red
    } else if (cat.contains('learning')) {
      return const Color(0xFF8B5CF6); // Violet
    } else if (cat.contains('work')) {
      return const Color(0xFF0EA5E9); // Cyan / Blue
    } else if (cat.contains('coding') || cat.contains('code')) {
      return const Color(0xFF06B6D4); // Cyan
    } else if (cat.contains('reading') || cat.contains('read')) {
      return const Color(0xFFF59E0B); // Warm Amber
    } else if (cat.contains('meditation') || cat.contains('meditat')) {
      return const Color(0xFF14B8A6); // Teal
    } else if (cat.contains('walking') || cat.contains('walk')) {
      return const Color(0xFF84CC16); // Lime
    } else if (cat.contains('social')) {
      return const Color(0xFFEC4899); // Pink
    } else if (cat.contains('creative')) {
      return const Color(0xFFA855F7); // Purple
    } else if (cat.contains('cleaning')) {
      return const Color(0xFF38BDF8); // Sky
    } else if (cat.contains('daily')) {
      return const Color(0xFFFACC15); // Sun Yellow
    } else if (cat.contains('habit')) {
      return const Color(0xFFFF5722); // Deep Orange / Fire
    } else if (cat.contains('hobbies')) {
      return const Color(0xFF10B981); // Emerald
    } else {
      return const Color(0xFFF5B942); // RPG Gold
    }
  }

  // --- Dynamic Difficulty Styling ---
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF22C55E); // Green
      case 'medium':
        return const Color(0xFFEAB308); // Yellow
      case 'hard':
        return const Color(0xFFEF4444); // Red
      case 'epic':
        return const Color(0xFFA855F7); // Purple
      case 'legendary':
        return const Color(0xFFF59E0B); // Amber / Gold
      default:
        return const Color(0xFF22C55E);
    }
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Icons.circle;
      case 'medium':
        return Icons.circle;
      case 'hard':
        return Icons.warning_amber_rounded;
      case 'epic':
        return Icons.auto_awesome;
      case 'legendary':
        return Icons.military_tech;
      default:
        return Icons.circle;
    }
  }

  // --- Image Picker Action ---
  Future<void> _pickProofImage(BuildContext context, String taskId) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null && context.mounted) {
        context.read<AppState>().updateTaskProof(taskId, pickedFile.path);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📸 Quest proof photo uploaded successfully!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to open image picker: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // --- Personal Note Dialog ---
  void _showAddNoteDialog(BuildContext context, RPGTask task) {
    final textController = TextEditingController(text: task.personalNote ?? '');
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF162033),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF334155)),
        ),
        title: const Row(
          children: [
            Icon(Icons.edit_note, color: Color(0xFFF5B942)),
            SizedBox(width: 8),
            Text('Personal Note', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: TextField(
          controller: textController,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Write your thoughts, reflections, or notes...',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFF0F172A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF334155)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF5B942)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AppState>().updateTaskNote(task.id, textController.text.trim());
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📝 Note saved!'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF5B942),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save Note', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- Complete Quest Confirmation & Execution ---
  void _handleCompleteQuest(BuildContext context, AppState state, RPGTask task) {
    if (task.isCompleted) return;

    if (state.isTaskFuture(task)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔒 "${task.title}" is scheduled for ${state.getTaskAvailabilityDateText(task)} and cannot be completed today.'),
          backgroundColor: Colors.orange.shade800,
        ),
      );
      return;
    }

    final objectives = task.getEffectiveObjectives();
    final completedCount = objectives.where((o) => o.isCompleted).length;
    final totalCount = objectives.length;
    final hasIncomplete = totalCount > 0 && completedCount < totalCount;

    if (hasIncomplete) {
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          backgroundColor: const Color(0xFF162033),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFEAB308)),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFEAB308), size: 28),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Quest Not Fully Completed',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            'You have completed $completedCount of $totalCount objectives.\n\nDo you want to complete this quest anyway for partial rewards?',
            style: const TextStyle(color: Color(0xFFAAB4C2), fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('CANCEL', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
                // Calculate proportional XP (at least 50% XP when completing anyway)
                int partialXp = ((completedCount / totalCount) * task.xpReward).round();
                if (partialXp < (task.xpReward ~/ 2)) {
                  partialXp = (task.xpReward ~/ 2);
                }
                state.completeTask(task.id, context, partialXp);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEAB308),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('COMPLETE ANYWAY', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      // Full completion
      state.completeTask(task.id, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    // Retrieve live task instance from AppState
    final liveTask = state.tasks.firstWhere(
      (t) => t.id == widget.task.id,
      orElse: () => widget.task,
    );

    // If Hydration Quest, automatically display the dedicated Hydration UI
    if (liveTask.taskType == 'hydration') {
      return HydrationDetailsScreen(taskId: liveTask.id);
    }

    final categoryColor = _getCategoryColor(liveTask.category);
    final categoryIcon = _getCategoryIcon(liveTask.category);
    final difficulty = liveTask.getEffectiveDifficulty();
    final difficultyColor = _getDifficultyColor(difficulty);
    final difficultyIcon = _getDifficultyIcon(difficulty);
    final objectives = liveTask.getEffectiveObjectives();
    final completedObjectives = objectives.where((o) => o.isCompleted).length;
    final totalObjectives = objectives.length;
    final progressRatio = totalObjectives > 0 ? (completedObjectives / totalObjectives) : 0.0;
    final tips = liveTask.getEffectiveTips();
    final coins = liveTask.getEffectiveCoinReward();
    final stamina = liveTask.getEffectiveStaminaReward();
    final hasStreak = (liveTask.streak != null && liveTask.streak! > 0) ||
        liveTask.isHabit ||
        liveTask.category.toLowerCase().contains('habit');
    final streakDays = liveTask.streak ?? (liveTask.isHabit ? 1 : 0);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0F1C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quest Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ==========================================
                    // 1. GENERIC QUEST HEADER
                    // ==========================================
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: categoryColor.withValues(alpha: 0.15),
                              border: Border.all(color: categoryColor, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: categoryColor.withValues(alpha: 0.3),
                                  blurRadius: 18,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(categoryIcon, size: 40, color: categoryColor),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            liveTask.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          // Badges row: Category, XP, Difficulty
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              // Category Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: categoryColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: categoryColor.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  liveTask.category,
                                  style: TextStyle(
                                    color: categoryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              // XP Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5B942).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFF5B942).withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star, color: Color(0xFFF5B942), size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      '+${liveTask.xpReward} XP',
                                      style: const TextStyle(
                                        color: Color(0xFFF5B942),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Difficulty Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: difficultyColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: difficultyColor.withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(difficultyIcon, color: difficultyColor, size: 12),
                                    const SizedBox(width: 5),
                                    Text(
                                      difficulty,
                                      style: TextStyle(
                                        color: difficultyColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Quest Type Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      liveTask.durationMinutes > 0
                                          ? Icons.timer_outlined
                                          : (liveTask.isHabit || liveTask.category.toLowerCase().contains('habit'))
                                              ? Icons.local_fire_department
                                              : (liveTask.time != null && liveTask.time!.isNotEmpty)
                                                  ? Icons.event
                                                  : objectives.isNotEmpty
                                                      ? Icons.checklist
                                                      : Icons.explore,
                                      color: const Color(0xFF38BDF8),
                                      size: 13,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      liveTask.durationMinutes > 0
                                          ? 'Timed Quest'
                                          : (liveTask.isHabit || liveTask.category.toLowerCase().contains('habit'))
                                              ? 'Habit Quest'
                                              : (liveTask.time != null && liveTask.time!.isNotEmpty)
                                                  ? 'Scheduled Quest'
                                                  : objectives.isNotEmpty
                                                      ? 'Objective Quest'
                                                      : 'Normal Quest',
                                      style: const TextStyle(
                                        color: Color(0xFF38BDF8),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ==========================================
                    // 2. QUEST DESCRIPTION
                    // ==========================================
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            icon: Icons.notes,
                            iconColor: const Color(0xFF94A3B8),
                            title: 'DESCRIPTION',
                          ),
                          const SizedBox(height: 10),
                          Text(
                            liveTask.description.isNotEmpty
                                ? liveTask.description
                                : 'No additional description provided for this quest.',
                            style: const TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ==========================================
                    // 3. QUEST OBJECTIVES CHECKLIST
                    // ==========================================
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            icon: Icons.checklist_rounded,
                            iconColor: const Color(0xFF38BDF8),
                            title: '📋 QUEST OBJECTIVES',
                          ),
                          const SizedBox(height: 12),
                          if (objectives.isEmpty)
                            const Text(
                              'No specific objectives required.',
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                            )
                          else
                            ...objectives.map((obj) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: liveTask.isCompleted
                                      ? null
                                      : () {
                                          state.toggleTaskObjective(liveTask.id, obj.id, !obj.isCompleted);
                                        },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: obj.isCompleted
                                          ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                                          : const Color(0xFF0F172A),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: obj.isCompleted
                                            ? const Color(0xFF4CAF50).withValues(alpha: 0.4)
                                            : const Color(0xFF1E293B),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: obj.isCompleted
                                                ? const Color(0xFF4CAF50)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: obj.isCompleted
                                                  ? const Color(0xFF4CAF50)
                                                  : const Color(0xFF64748B),
                                              width: 1.8,
                                            ),
                                          ),
                                          child: obj.isCompleted
                                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            obj.text,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: obj.isCompleted
                                                  ? const Color(0xFF94A3B8)
                                                  : Colors.white,
                                              decoration: obj.isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                              decorationColor: const Color(0xFF94A3B8),
                                              fontWeight: obj.isCompleted
                                                  ? FontWeight.normal
                                                  : FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ==========================================
                    // 4. QUEST PROGRESS
                    // ==========================================
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionHeader(
                                icon: Icons.insights,
                                iconColor: const Color(0xFFF5B942),
                                title: 'QUEST PROGRESS',
                              ),
                              Text(
                                '${(progressRatio * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Color(0xFFF5B942),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progressRatio,
                              minHeight: 10,
                              backgroundColor: const Color(0xFF0F172A),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progressRatio == 1.0 ? const Color(0xFF4CAF50) : const Color(0xFFF5B942),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$completedObjectives / $totalObjectives completed',
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ==========================================
                    // 5. OPTIONAL TIMER
                    // ==========================================
                    if (liveTask.durationMinutes > 0) ...[
                      _buildTimerCard(context, state, liveTask)
                    ] else ...[
                      _buildNoTimeLimitCard()
                    ],
                    const SizedBox(height: 14),

                    // ==========================================
                    // 6. QUEST REWARDS
                    // ==========================================
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            icon: Icons.emoji_events,
                            iconColor: const Color(0xFFF5B942),
                            title: '🏆 QUEST REWARDS',
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: [
                              // XP Reward
                              _buildRewardPill(
                                icon: Icons.star,
                                color: const Color(0xFFF5B942),
                                text: '+${liveTask.xpReward} XP',
                              ),
                              // Coins Reward
                              if (coins > 0)
                                _buildRewardPill(
                                  icon: Icons.monetization_on,
                                  color: const Color(0xFFEAB308),
                                  text: '+$coins Coins',
                                ),
                              // Stamina Reward
                              if (stamina > 0)
                                _buildRewardPill(
                                  icon: Icons.local_fire_department,
                                  color: const Color(0xFFEF4444),
                                  text: '+$stamina Stamina',
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ==========================================
                    // 7. STREAK (Conditional)
                    // ==========================================
                    if (hasStreak) ...[
                      _buildCard(
                        borderColor: const Color(0xFFFF5722).withValues(alpha: 0.5),
                        color: const Color(0xFFFF5722).withValues(alpha: 0.08),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFF5722).withValues(alpha: 0.2),
                              ),
                              child: const Icon(Icons.local_fire_department, color: Color(0xFFFF5722), size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '🔥 ${streakDays > 0 ? streakDays : 1} DAY STREAK',
                                    style: const TextStyle(
                                      color: Color(0xFFFF5722),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Complete today\'s quest to keep your streak alive.',
                                    style: TextStyle(color: Color(0xFFAAB4C2), fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // ==========================================
                    // 8. QUEST PROOF
                    // ==========================================
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            icon: Icons.photo_camera,
                            iconColor: const Color(0xFFA855F7),
                            title: '📸 QUEST PROOF',
                          ),
                          const SizedBox(height: 8),
                          Text(
                            liveTask.getProofRecommendation(),
                            style: const TextStyle(color: Color(0xFFAAB4C2), fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          if (liveTask.proofImagePath != null &&
                              liveTask.proofImagePath!.isNotEmpty &&
                              File(liveTask.proofImagePath!).existsSync()) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                children: [
                                  Image.file(
                                    File(liveTask.proofImagePath!),
                                    height: 160,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black.withValues(alpha: 0.6),
                                      radius: 16,
                                      child: IconButton(
                                        icon: const Icon(Icons.close, size: 16, color: Colors.white),
                                        onPressed: () {
                                          state.updateTaskProof(liveTask.id, null);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: () => _pickProofImage(context, liveTask.id),
                              icon: const Icon(Icons.change_circle, size: 16),
                              label: const Text('Change Proof Photo'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFA855F7),
                                side: const BorderSide(color: Color(0xFFA855F7)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ] else ...[
                            OutlinedButton.icon(
                              onPressed: () => _pickProofImage(context, liveTask.id),
                              icon: const Icon(Icons.add_a_photo, size: 18),
                              label: const Text('+ Upload Proof', style: TextStyle(fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFA855F7),
                                side: const BorderSide(color: Color(0xFFA855F7)),
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ==========================================
                    // 9. PERSONAL NOTES
                    // ==========================================
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionHeader(
                                icon: Icons.edit_note,
                                iconColor: const Color(0xFF10B981),
                                title: '📝 PERSONAL NOTE',
                              ),
                              TextButton.icon(
                                onPressed: () => _showAddNoteDialog(context, liveTask),
                                icon: Icon(
                                  liveTask.personalNote != null && liveTask.personalNote!.isNotEmpty
                                      ? Icons.edit
                                      : Icons.add,
                                  size: 16,
                                  color: const Color(0xFF10B981),
                                ),
                                label: Text(
                                  liveTask.personalNote != null && liveTask.personalNote!.isNotEmpty
                                      ? 'Edit Note'
                                      : '+ Add Note',
                                  style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (liveTask.personalNote != null && liveTask.personalNote!.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFF1E293B)),
                              ),
                              child: Text(
                                liveTask.personalNote!,
                                style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, height: 1.4),
                              ),
                            )
                          else
                            const Text(
                              'No personal notes added yet. Tap "+ Add Note" to record insights.',
                              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ==========================================
                    // 10. TIPS / INSTRUCTIONS (Expandable)
                    // ==========================================
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isTipsExpanded = !_isTipsExpanded;
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildSectionHeader(
                                    icon: Icons.lightbulb_outline,
                                    iconColor: const Color(0xFFF5B942),
                                    title: '💡 QUEST TIPS',
                                  ),
                                  Icon(
                                    _isTipsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_isTipsExpanded) ...[
                            const SizedBox(height: 12),
                            ...tips.map((tip) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 5.0),
                                      child: Icon(Icons.fiber_manual_record, size: 8, color: Color(0xFFF5B942)),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        tip,
                                        style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, height: 1.4),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ==========================================
            // 11. COMPLETE QUEST BOTTOM ACTION
            // ==========================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                border: Border(top: BorderSide(color: Color(0xFF1E293B))),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: liveTask.isCompleted
                    ? Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF4CAF50)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                            SizedBox(width: 8),
                            Text(
                              'QUEST COMPLETED',
                              style: TextStyle(
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline, size: 22),
                        label: const Text(
                          'COMPLETE QUEST',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () => _handleCompleteQuest(context, state, liveTask),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildCard({required Widget child, Color? color, Color? borderColor}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color ?? const Color(0xFF162033),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? const Color(0xFF1E293B)),
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader({required IconData icon, required Color iconColor, required String title}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildRewardPill({required IconData icon, required Color color, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildNoTimeLimitCard() {
    return _buildCard(
      child: const Row(
        children: [
          Icon(Icons.all_inclusive, color: Color(0xFF38BDF8), size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⏱ No time limit',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 2),
                Text(
                  'Complete this quest at your own pace.',
                  style: TextStyle(color: Color(0xFFAAB4C2), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard(BuildContext context, AppState state, RPGTask task) {
    if (state.isTaskFuture(task)) {
      return _buildCard(
        borderColor: Colors.orange.withValues(alpha: 0.3),
        child: Column(
          children: [
            const Icon(Icons.lock_clock, size: 40, color: Colors.orangeAccent),
            const SizedBox(height: 8),
            const Text(
              'Quest Locked',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              'Unlocks on ${state.getTaskAvailabilityDateText(task)}',
              style: const TextStyle(color: Color(0xFFAAB4C2), fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (state.isTaskPast(task) && !task.isCompleted) {
      return _buildCard(
        borderColor: Colors.red.withValues(alpha: 0.3),
        child: Column(
          children: [
            const Icon(Icons.history_toggle_off, size: 40, color: Colors.redAccent),
            const SizedBox(height: 8),
            const Text(
              'Expired Quest',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
            const SizedBox(height: 4),
            Text(
              'Scheduled for ${state.getTaskAvailabilityDateText(task)}',
              style: const TextStyle(color: Color(0xFFAAB4C2), fontSize: 13),
            ),
          ],
        ),
      );
    }

    final remaining = state.getCalculatedRemainingSeconds(task);
    final minutes = (remaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (remaining % 60).toString().padLeft(2, '0');
    final isRunning = task.timerStatus == 'Running';
    final isPaused = task.timerStatus == 'Paused';

    return _buildCard(
      borderColor: isRunning ? const Color(0xFFF5B942) : const Color(0xFF1E293B),
      child: Column(
        children: [
          _buildSectionHeader(
            icon: Icons.timer,
            iconColor: const Color(0xFFF5B942),
            title: '⏱ QUEST TIMER',
          ),
          const SizedBox(height: 12),
          Text(
            task.timerStatus == 'Not Started'
                ? '${task.durationMinutes.toString().padLeft(2, '0')}:00'
                : '$minutes:$seconds',
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: isRunning ? const Color(0xFFF5B942) : Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          // Timer Control Buttons: START, PAUSE, RESET
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              if (!isRunning)
                ElevatedButton.icon(
                  onPressed: task.isCompleted ? null : () => state.startTaskTimer(task.id),
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: Text(isPaused ? 'RESUME' : 'START', style: const TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5B942),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              if (isRunning)
                ElevatedButton.icon(
                  onPressed: () => state.pauseTaskTimer(task.id),
                  icon: const Icon(Icons.pause, size: 18),
                  label: const Text('PAUSE', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              OutlinedButton.icon(
                onPressed: task.isCompleted ? null : () => state.resetTaskTimer(task.id),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('RESET', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF94A3B8),
                  side: const BorderSide(color: Color(0xFF334155)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
