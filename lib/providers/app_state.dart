import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../models/alarm_song.dart';
import '../helpers/database_helper.dart';
import '../helpers/security_helper.dart';
import '../main.dart'; // Import to use rootScaffoldMessengerKey and rootNavigatorKey
import '../widgets/task_completion_dialog.dart';
import '../services/sound_service.dart';
import '../services/auth_service.dart';
import '../services/online_task_service.dart';
import '../services/online_hydration_service.dart';
import '../services/online_achievement_service.dart';
import '../services/online_notification_service.dart';
import '../services/api_client.dart';
import '../services/analytics_service.dart';
import '../services/notification_service.dart';
import '../services/pusher_hub_service.dart';
import '../config/api_config.dart';
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  UserProfile _userProfile = UserProfile(username: 'Hero');
  List<RPGTask> _tasks = [];
  Timer? _globalTimer;
  
  List<AppNotification> _notifications = [];
  NotificationSettings _notificationSettings = NotificationSettings();

  final List<String> _motivationalQuotes = [
    "You're getting stronger every day! 💪",
    "Another quest conquered! ⚔️",
    "Keep going, Hero! 🚀",
    "Progress is progress! ⭐",
    "Your future self will thank you! 🔥",
    "Level up your real life! ⚡",
    "Consistency is your superpower! 🌟",
    "Small daily wins create massive victories! 🏆",
    "Every rep and page counts! 📖",
    "You are unstoppable! 💥",
  ];
  
  // Example achievements matching the redesign
  List<Achievement> _achievements = [
    Achievement(id: 'a1', name: 'First Quest', description: 'Complete your first quest'),
    Achievement(id: 'a2', name: 'On Fire', description: 'Maintain a 7-day streak'),
    Achievement(id: 'a3', name: 'Quest Master', description: 'Complete 50 quests'),
    Achievement(id: 'a4', name: 'Legend', description: 'Reach Level 50'),
  ];
  
  final List<Reward> _rewards = [
    Reward(id: 'r1', title: 'Watch 1 Episode of TV', cost: 50),
    Reward(id: 'r2', title: 'Eat a Sweet Treat', cost: 100),
    Reward(id: 'r3', title: 'Buy a New Video Game', cost: 1000),
  ];
  
  Map<String, int> _weeklyXp = {};
  
  bool _isLoading = true;
  bool _isDarkMode = true;
  bool _isLoggedIn = false;
  bool _soundEffectsEnabled = true;
  String? _heroBannerUrl;
  String? _rawHeroBannerImage;
  String? _customBannerPath;
  String? _heroBannerTitle;
  String? _heroBannerSubtitle;
  bool _heroBannerEnabled = true;
  bool _isMaintenanceMode = false;
  String _maintenanceMessage = '';
  String? _quoteOfTheDay;
  int _dailyWaterGoalMl = 2500;

  UserProfile get userProfile => _userProfile;
  List<RPGTask> get tasks => _tasks;
  List<Achievement> get achievements => _achievements;
  List<Reward> get rewards => _rewards;
  Map<String, int> get weeklyXp => _weeklyXp;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  bool get isLoggedIn => _isLoggedIn;
  bool get soundEffectsEnabled => _soundEffectsEnabled;
  String? get heroBannerUrl {
    if (_heroBannerUrl == null || _heroBannerUrl!.trim().isEmpty) return null;
    return ApiConfig.resolveUrl(_heroBannerUrl!);
  }
  String? get customBannerPath => _customBannerPath;
  String? get heroBannerTitle => _heroBannerTitle;
  String? get heroBannerSubtitle => _heroBannerSubtitle;
  bool get heroBannerEnabled => _heroBannerEnabled;
  bool get isMaintenanceMode => _isMaintenanceMode;
  String get maintenanceMessage => _maintenanceMessage;
  String? get quoteOfTheDay => _quoteOfTheDay;
  String? _userRole;
  String get currentUserId => (_userProfile.userId ?? _userProfile.username).trim().toLowerCase();
  bool get isAdmin =>
      _userProfile.email?.toLowerCase() == 'admin@levelup.com' ||
      _userRole == 'admin';

  void setCurrentUserId(String? id) {
    _userProfile.userId = id;
    if (id != null && id.isNotEmpty) {
      _userProfile.username = id;
    }
    notifyListeners();
  }

  void addNotification(String title, String message, {String category = 'System'}) {
    final notif = AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: currentUserId,
      title: title,
      body: message,
      category: category,
      type: 'system',
      timestamp: DateTime.now(),
    );
    _notifications.insert(0, notif);
    DatabaseHelper.instance.saveNotification(notif, currentUserId);
    NotificationService.instance.showLocalNotification(
      title: title,
      body: message,
    );
    notifyListeners();
  }

  Future<void> setCustomBanner(String? path) async {
    final clean = (path != null && path.trim().isNotEmpty) ? path.trim() : null;
    _customBannerPath = clean;
    final prefs = await SharedPreferences.getInstance();
    if (clean != null) {
      await prefs.setString('custom_banner_path', clean);
    } else {
      await prefs.remove('custom_banner_path');
    }
    notifyListeners();
  }

  List<AppNotification> get notifications => _notifications;
  int get unreadNotificationCount => _notifications.where((n) => !n.isRead).length;
  NotificationSettings get notificationSettings => _notificationSettings;
  List<String> get motivationalQuotes => _motivationalQuotes;

  List<Achievement> _getDefaultAchievements([String? userId]) {
    final uid = userId ?? currentUserId;
    return [
      Achievement(id: 'a1', userId: uid, name: 'First Quest', description: 'Complete your first quest'),
      Achievement(id: 'a2', userId: uid, name: 'On Fire', description: 'Maintain a 7-day streak'),
      Achievement(id: 'a3', userId: uid, name: 'Quest Master', description: 'Complete 50 quests'),
      Achievement(id: 'a4', userId: uid, name: 'Legend', description: 'Reach Level 50'),
    ];
  }

  List<RPGTask> _getDefaultTasks([String? userId, DateTime? date]) {
    final uid = (userId ?? currentUserId).trim().toLowerCase();
    final now = date ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      RPGTask(
        id: 'task_hydro_${today.year}_${today.month}_${today.day}',
        userId: uid,
        title: 'Daily Drinking Water',
        description: 'Stay hydrated throughout the day! Daily target: 2.5 L',
        category: 'Hydration',
        xpReward: 50,
        coinReward: 25,
        dueDate: today,
        time: '08:00 AM',
        durationMinutes: 0,
        remainingSeconds: 0,
        timerStatus: 'Not Started',
        isCompleted: false,
        taskType: 'hydration',
        waterGoalMl: _dailyWaterGoalMl,
        currentWaterMl: 0,
        waterLogs: [],
        reminders: createDefaultDrinkingSchedule(drinkAmountMl: 250),
        difficulty: 'Easy',
        tips: [
          'Drink a full glass of water right after waking up.',
          'Keep a refillable water bottle at your study/work desk.',
          'Log each glass you drink to maintain your hydration streak!'
        ],
      ),
      RPGTask(
        id: 'task_study_${today.year}_${today.month}_${today.day}',
        userId: uid,
        title: 'Deep Focus Study Session',
        description: 'Study core subjects, review notes, and solve challenging practice problems.',
        category: 'Study',
        xpReward: 60,
        coinReward: 30,
        dueDate: today,
        time: '10:00 AM',
        durationMinutes: 45,
        remainingSeconds: 45 * 60,
        timerStatus: 'Not Started',
        isCompleted: false,
        difficulty: 'Medium',
        objectives: [
          QuestObjective(id: 'obj_std_1', text: 'Set up quiet study desk and remove phone distractions', isCompleted: false),
          QuestObjective(id: 'obj_std_2', text: 'Execute 45-min active recall & problem solving', isCompleted: false),
          QuestObjective(id: 'obj_std_3', text: 'Synthesize key insights and review formula notes', isCompleted: false),
        ],
        tips: [
          'Use the countdown timer mode for uninterrupted focus.',
          'Test yourself with active recall rather than passive re-reading.',
        ],
      ),
      RPGTask(
        id: 'task_fitness_${today.year}_${today.month}_${today.day}',
        userId: uid,
        title: 'Full Body Strength Workout',
        description: 'Complete 30-min bodyweight and core strength fitness routine.',
        category: 'Fitness',
        xpReward: 75,
        coinReward: 35,
        dueDate: today,
        time: '07:30 AM',
        durationMinutes: 30,
        remainingSeconds: 30 * 60,
        timerStatus: 'Not Started',
        isCompleted: false,
        difficulty: 'Medium',
        objectives: [
          QuestObjective(id: 'obj_fit_1', text: 'Dynamic warm-up & joint mobility', isCompleted: false),
          QuestObjective(id: 'obj_fit_2', text: 'Complete 4 sets of push-ups, squats, and planks', isCompleted: false),
          QuestObjective(id: 'obj_fit_3', text: 'Full body cool-down stretching & hydration', isCompleted: false),
        ],
        tips: [
          'Focus on controlled reps and proper form over speed.',
          'Breathe rhythmically during each exercise set.',
        ],
      ),
      RPGTask(
        id: 'task_health_${today.year}_${today.month}_${today.day}',
        userId: uid,
        title: 'Posture & Spine Mobility Routine',
        description: 'Perform posture alignment, neck & shoulder stretches, and deep breathing.',
        category: 'Health',
        xpReward: 40,
        coinReward: 20,
        dueDate: today,
        time: '09:00 AM',
        durationMinutes: 15,
        remainingSeconds: 15 * 60,
        timerStatus: 'Not Started',
        isCompleted: false,
        difficulty: 'Easy',
        objectives: [
          QuestObjective(id: 'obj_hlth_1', text: 'Perform shoulder rolls, chin tucks & spine twists', isCompleted: false),
          QuestObjective(id: 'obj_hlth_2', text: 'Cat-cow pose and lower back decompression', isCompleted: false),
          QuestObjective(id: 'obj_hlth_3', text: 'Adjust chair and monitor to ergonomic height', isCompleted: false),
        ],
        tips: [
          'Keep eyes level with the top third of your display screen.',
          'Take standing micro-breaks every 45 minutes.',
        ],
      ),
      RPGTask(
        id: 'task_learning_${today.year}_${today.month}_${today.day}',
        userId: uid,
        title: 'Learn a New Skill or Framework',
        description: 'Watch a masterclass, read technical documentation, and practice new concepts.',
        category: 'Learning',
        xpReward: 55,
        coinReward: 25,
        dueDate: today,
        time: '02:00 PM',
        durationMinutes: 30,
        remainingSeconds: 30 * 60,
        timerStatus: 'Not Started',
        isCompleted: false,
        difficulty: 'Medium',
        objectives: [
          QuestObjective(id: 'obj_lrn_1', text: 'Pick a high-value skill or technology topic', isCompleted: false),
          QuestObjective(id: 'obj_lrn_2', text: 'Complete tutorial or documentation chapter', isCompleted: false),
          QuestObjective(id: 'obj_lrn_3', text: 'Apply concepts in a practical hands-on test', isCompleted: false),
        ],
        tips: [
          'Teach or write down what you learned to solidify mastery.',
        ],
      ),
      RPGTask(
        id: 'task_work_${today.year}_${today.month}_${today.day}',
        userId: uid,
        title: 'Sprint Priority Deliverables',
        description: 'Focus deeply on your highest priority work item and sprint objectives.',
        category: 'Work',
        xpReward: 70,
        coinReward: 35,
        dueDate: today,
        time: '11:00 AM',
        durationMinutes: 45,
        remainingSeconds: 45 * 60,
        timerStatus: 'Not Started',
        isCompleted: false,
        difficulty: 'Hard',
        objectives: [
          QuestObjective(id: 'obj_wrk_1', text: 'Define top work milestone for today', isCompleted: false),
          QuestObjective(id: 'obj_wrk_2', text: 'Execute uninterrupted focus block', isCompleted: false),
          QuestObjective(id: 'obj_wrk_3', text: 'Review deliverable, commit changes & update status', isCompleted: false),
        ],
        tips: [
          'Tackle the most important task first when energy is highest.',
        ],
      ),
      RPGTask(
        id: 'task_coding_${today.year}_${today.month}_${today.day}',
        userId: uid,
        title: 'Clean Code & Architecture Sprint',
        description: 'Implement new features, refactor components, and test application logic.',
        category: 'Coding',
        xpReward: 80,
        coinReward: 40,
        dueDate: today,
        time: '03:30 PM',
        durationMinutes: 45,
        remainingSeconds: 45 * 60,
        timerStatus: 'Not Started',
        isCompleted: false,
        difficulty: 'Hard',
        objectives: [
          QuestObjective(id: 'obj_code_1', text: 'Review architecture & module interfaces', isCompleted: false),
          QuestObjective(id: 'obj_code_2', text: 'Write clean, modular code with error handling', isCompleted: false),
          QuestObjective(id: 'obj_code_3', text: 'Run unit tests and verify behavior', isCompleted: false),
        ],
        tips: [
          'Write self-documenting code with descriptive names.',
          'Keep functions concise with single responsibilities.',
        ],
      ),
      RPGTask(
        id: 'task_reading_${today.year}_${today.month}_${today.day}',
        userId: uid,
        title: 'Read 20 Pages of a Book',
        description: 'Read non-fiction, personal growth, or architectural book chapters.',
        category: 'Reading',
        xpReward: 45,
        coinReward: 20,
        dueDate: today,
        time: '08:30 PM',
        durationMinutes: 25,
        remainingSeconds: 25 * 60,
        timerStatus: 'Not Started',
        isCompleted: false,
        difficulty: 'Easy',
        objectives: [
          QuestObjective(id: 'obj_read_1', text: 'Open book and settle into comfortable reading spot', isCompleted: false),
          QuestObjective(id: 'obj_read_2', text: 'Read 20 pages with active comprehension', isCompleted: false),
          QuestObjective(id: 'obj_read_3', text: 'Highlight 3 actionable ideas or quotes', isCompleted: false),
        ],
        tips: [
          'Reading 20 pages a day adds up to 30 books a year!',
        ],
      ),
      RPGTask(
        id: 'task_meditation_${today.year}_${today.month}_${today.day}',
        userId: uid,
        title: 'Mindfulness & Breathwork Session',
        description: '15 minutes of mindful meditation to reset focus and reduce mental stress.',
        category: 'Meditation',
        xpReward: 35,
        coinReward: 15,
        dueDate: today,
        time: '07:00 AM',
        durationMinutes: 15,
        remainingSeconds: 15 * 60,
        timerStatus: 'Not Started',
        isCompleted: false,
        difficulty: 'Easy',
        objectives: [
          QuestObjective(id: 'obj_med_1', text: 'Sit upright in quiet space with eyes closed', isCompleted: false),
          QuestObjective(id: 'obj_med_2', text: 'Follow steady box-breathing or diaphragmatic rhythm', isCompleted: false),
          QuestObjective(id: 'obj_med_3', text: 'Acknowledge thoughts without judgment and return to breath', isCompleted: false),
        ],
        tips: [
          'Even 10 minutes of daily meditation strengthens prefrontal cortex focus.',
        ],
      ),
      RPGTask(
        id: 'task_walking_${today.year}_${today.month}_${today.day}',
        userId: uid,
        title: 'Evening 5,000 Steps Walk',
        description: 'Brisk outdoor walk for daily movement, cardiovascular health, and fresh air.',
        category: 'Walking',
        xpReward: 50,
        coinReward: 25,
        dueDate: today,
        time: '06:00 PM',
        durationMinutes: 30,
        remainingSeconds: 30 * 60,
        timerStatus: 'Not Started',
        isCompleted: false,
        difficulty: 'Easy',
        objectives: [
          QuestObjective(id: 'obj_wlk_1', text: 'Put on walking shoes & head outdoors', isCompleted: false),
          QuestObjective(id: 'obj_wlk_2', text: 'Walk at brisk cadence for 30 minutes', isCompleted: false),
          QuestObjective(id: 'obj_wlk_3', text: 'Log step count and cool down', isCompleted: false),
        ],
        tips: [
          'Walking outdoors in nature significantly lowers cortisol and stress levels.',
        ],
      ),
      RPGTask(
        id: 'task_social_${today.year}_${today.month}_${today.day}',
        userId: uid,
        title: 'Connect with a Friend or Family',
        description: 'Reach out to a close friend, colleague, or loved one for a meaningful chat.',
        category: 'Social',
        xpReward: 30,
        coinReward: 15,
        dueDate: today,
        time: '07:30 PM',
        durationMinutes: 15,
        remainingSeconds: 15 * 60,
        timerStatus: 'Not Started',
        isCompleted: false,
        difficulty: 'Easy',
        objectives: [
          QuestObjective(id: 'obj_soc_1', text: 'Message or call a friend or family member', isCompleted: false),
          QuestObjective(id: 'obj_soc_2', text: 'Ask how they are doing and listen actively', isCompleted: false),
          QuestObjective(id: 'obj_soc_3', text: 'Share positive encouragement', isCompleted: false),
        ],
        tips: [
          'Strong social connections are key predictors of long-term happiness.',
        ],
      ),
      RPGTask(
        id: 'task_creative_${today.year}_${today.month}_${today.day}',
        userId: uid,
        title: 'Creative Design & Sketching',
        description: 'Brainstorm creative concepts, sketch UI designs, or produce artistic work.',
        category: 'Creative',
        xpReward: 45,
        coinReward: 20,
        dueDate: today,
        time: '05:00 PM',
        durationMinutes: 30,
        remainingSeconds: 30 * 60,
        timerStatus: 'Not Started',
        isCompleted: false,
        difficulty: 'Medium',
        objectives: [
          QuestObjective(id: 'obj_crt_1', text: 'Brainstorm creative visual ideas & references', isCompleted: false),
          QuestObjective(id: 'obj_crt_2', text: 'Draft sketches, UI wireframes, or artwork', isCompleted: false),
          QuestObjective(id: 'obj_crt_3', text: 'Refine composition, typography, and colors', isCompleted: false),
        ],
        tips: [
          'Allow yourself to explore wild ideas before filtering.',
        ],
      ),
      RPGTask(
        id: 'task_cleaning_${today.year}_${today.month}_${today.day}',
        userId: uid,
        title: 'Clean & Declutter Workspace',
        description: 'Clear desk clutter, organize study accessories, and wipe surfaces clean.',
        category: 'Cleaning',
        xpReward: 30,
        coinReward: 15,
        dueDate: today,
        time: '06:30 PM',
        durationMinutes: 15,
        remainingSeconds: 15 * 60,
        timerStatus: 'Not Started',
        isCompleted: false,
        difficulty: 'Easy',
        objectives: [
          QuestObjective(id: 'obj_cln_1', text: 'Clear loose papers, mugs, and trash from desk', isCompleted: false),
          QuestObjective(id: 'obj_cln_2', text: 'Wipe down desktop, keyboard, and screen', isCompleted: false),
          QuestObjective(id: 'obj_cln_3', text: 'Organize charging cables and stationery', isCompleted: false),
        ],
        tips: [
          'A clean physical workspace directly reduces mental fatigue.',
        ],
      ),
      RPGTask(
        id: 'task_chores_${today.year}_${today.month}_${today.day}',
        userId: uid,
        title: 'Complete Household Chores',
        description: 'Organize living area, wash dishes, and complete daily household chores.',
        category: 'Chores',
        xpReward: 35,
        coinReward: 15,
        dueDate: today,
        time: '01:00 PM',
        durationMinutes: 20,
        remainingSeconds: 20 * 60,
        timerStatus: 'Not Started',
        isCompleted: false,
        difficulty: 'Easy',
        objectives: [
          QuestObjective(id: 'obj_chr_1', text: 'Wash dishes and clear kitchen counter', isCompleted: false),
          QuestObjective(id: 'obj_chr_2', text: 'Fold laundry or organize wardrobe', isCompleted: false),
          QuestObjective(id: 'obj_chr_3', text: 'Tidy common living room areas', isCompleted: false),
        ],
        tips: [
          'Put on an energetic soundtrack or podcast while doing chores.',
        ],
      ),
      RPGTask(
        id: 'task_habit_${today.year}_${today.month}_${today.day}',
        userId: uid,
        title: 'Morning Discipline Routine',
        description: 'Wake up on schedule, make your bed, hydrate, and prepare for an epic day.',
        category: 'Habit',
        xpReward: 40,
        coinReward: 20,
        dueDate: today,
        time: '06:45 AM',
        durationMinutes: 15,
        remainingSeconds: 15 * 60,
        timerStatus: 'Not Started',
        isCompleted: false,
        difficulty: 'Easy',
        objectives: [
          QuestObjective(id: 'obj_hbt_1', text: 'Get out of bed at first alarm (no snooze)', isCompleted: false),
          QuestObjective(id: 'obj_hbt_2', text: 'Make bed neatly to win your first task of the day', isCompleted: false),
          QuestObjective(id: 'obj_hbt_3', text: 'Drink 500ml water and do 5 deep breaths', isCompleted: false),
        ],
        tips: [
          'Winning the morning sets a winning momentum for the entire day.',
        ],
      ),
      RPGTask(
        id: 'task_daily_${today.year}_${today.month}_${today.day}',
        userId: uid,
        title: 'Daily Goal Review & Planning',
        description: 'Review today’s achievements, log XP, and set top 3 priorities for tomorrow.',
        category: 'Daily',
        xpReward: 35,
        coinReward: 15,
        dueDate: today,
        time: '09:30 PM',
        durationMinutes: 15,
        remainingSeconds: 15 * 60,
        timerStatus: 'Not Started',
        isCompleted: false,
        difficulty: 'Easy',
        objectives: [
          QuestObjective(id: 'obj_dly_1', text: 'Review today’s completed quests and XP gained', isCompleted: false),
          QuestObjective(id: 'obj_dly_2', text: 'Note key accomplishments and reflections', isCompleted: false),
          QuestObjective(id: 'obj_dly_3', text: 'Plan top 3 quests for tomorrow morning', isCompleted: false),
        ],
        tips: [
          'Planning tomorrow the night before reduces morning decision fatigue.',
        ],
      ),
      RPGTask(
        id: 'task_hobbies_${today.year}_${today.month}_${today.day}',
        userId: uid,
        title: 'Dedicated Hobby & Gaming Time',
        description: 'Spend dedicated time practicing your musical instrument, hobby, or game.',
        category: 'Hobbies',
        xpReward: 40,
        coinReward: 20,
        dueDate: today,
        time: '08:00 PM',
        durationMinutes: 30,
        remainingSeconds: 30 * 60,
        timerStatus: 'Not Started',
        isCompleted: false,
        difficulty: 'Easy',
        objectives: [
          QuestObjective(id: 'obj_hob_1', text: 'Set up instrument, gaming setup, or craft tools', isCompleted: false),
          QuestObjective(id: 'obj_hob_2', text: 'Immerse in joyful hobby practice for 30 minutes', isCompleted: false),
          QuestObjective(id: 'obj_hob_3', text: 'Pack up setup neatly when done', isCompleted: false),
        ],
        tips: [
          'Scheduled play and creative leisure prevent burnout.',
        ],
      ),
      RPGTask(
        id: 'task_personal_${today.year}_${today.month}_${today.day}',
        userId: uid,
        title: 'Self-Reflection & Gratitude Journaling',
        description: 'Write 3 accomplishments and 3 reflections in your personal growth journal.',
        category: 'Personal',
        xpReward: 35,
        coinReward: 15,
        dueDate: today,
        time: '09:00 PM',
        durationMinutes: 15,
        remainingSeconds: 15 * 60,
        timerStatus: 'Not Started',
        isCompleted: false,
        difficulty: 'Easy',
        objectives: [
          QuestObjective(id: 'obj_prs_1', text: 'Open notebook or digital notes', isCompleted: false),
          QuestObjective(id: 'obj_prs_2', text: 'Write down 3 things you are genuinely grateful for', isCompleted: false),
          QuestObjective(id: 'obj_prs_3', text: 'Write 1 key personal growth reflection for today', isCompleted: false),
        ],
        tips: [
          'Gratitude journaling shifts focus toward abundance and resilience.',
        ],
      ),
      RPGTask(
        id: 'task_other_${today.year}_${today.month}_${today.day}',
        userId: uid,
        title: 'Custom Adventure Challenge',
        description: 'Step outside your comfort zone and accomplish a spontaneous mini-quest.',
        category: 'Other',
        xpReward: 40,
        coinReward: 20,
        dueDate: today,
        time: '04:00 PM',
        durationMinutes: 20,
        remainingSeconds: 20 * 60,
        timerStatus: 'Not Started',
        isCompleted: false,
        difficulty: 'Medium',
        objectives: [
          QuestObjective(id: 'obj_oth_1', text: 'Define your spontaneous challenge or task', isCompleted: false),
          QuestObjective(id: 'obj_oth_2', text: 'Execute with full energy and focus', isCompleted: false),
          QuestObjective(id: 'obj_oth_3', text: 'Celebrate completing your custom quest', isCompleted: false),
        ],
        tips: [
          'Variety and spontaneity keep your real-life RPG adventure exciting!',
        ],
      ),
    ];
  }

  Future<Map<String, dynamic>> loginUser(String identifier, [String? password]) async {
    // If password provided, use online backend / local auth
    if (password != null && password.isNotEmpty) {
      final res = await AuthService.instance.login(identifier, password);
      if (res['status'] == 'success') {
        _isLoggedIn = true;
        final cleanId = (res['user'] != null && res['user']['id'] != null)
            ? res['user']['id'].toString()
            : identifier.trim().toLowerCase();
        
        // Reset in-memory state completely before loading new user data to prevent cross-contamination
        _tasks = [];
        _achievements = _getDefaultAchievements(cleanId);
        _notifications = [];
        _userProfile = UserProfile(username: identifier.trim(), userId: cleanId);

        if (res['user'] != null) {
          _applyUserData(res['user'] as Map<String, dynamic>);
        }
        await _loadUserDataFromDb(cleanId);
        await refreshAllData();
        AnalyticsService.instance.logLogin(loginMethod: 'online_auth');
        AnalyticsService.instance.setUserProperties(userId: cleanId, level: _userProfile.level);
        PusherHubService.instance.login(cleanId);
        notifyListeners();
      }
      return res;
    } else {
      // Local fallback with isolated user ID
      final cleanId = identifier.trim().toLowerCase();
      _isLoggedIn = true;
      _tasks = [];
      _achievements = _getDefaultAchievements(cleanId);
      _notifications = [];
      _userProfile = UserProfile(username: identifier.trim(), userId: cleanId);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('logged_in_username', identifier.trim());
      await prefs.setString('current_username', identifier.trim());
      await _loadUserDataFromDb(cleanId);
      AnalyticsService.instance.logLogin(loginMethod: 'local_storage');
      AnalyticsService.instance.setUserProperties(userId: cleanId, level: _userProfile.level);
      PusherHubService.instance.login(cleanId);
      notifyListeners();
      return {'status': 'success'};
    }
  }

  Future<Map<String, dynamic>> loginSocial({
    required String provider,
    required String username,
    String? email,
    String? displayName,
    String avatarId = 'hero1',
  }) async {
    final res = await AuthService.instance.socialLogin(
      provider: provider,
      username: username,
      email: email,
      displayName: displayName,
      avatarId: avatarId,
    );

    if (res['status'] == 'success') {
      _isLoggedIn = true;
      final cleanId = (res['user'] != null && res['user']['id'] != null)
          ? res['user']['id'].toString()
          : username.trim().toLowerCase();

      final actualUsername = (res['user'] != null && res['user']['username'] != null)
          ? res['user']['username'].toString()
          : username.trim();

      // Reset in-memory state completely before loading new user data to prevent cross-contamination
      _tasks = [];
      _achievements = _getDefaultAchievements(cleanId);
      _notifications = [];
      _userProfile = UserProfile(
        username: actualUsername,
        userId: cleanId,
        email: email ?? '',
        avatarId: avatarId,
      );

      if (res['user'] != null && res['user'] is Map) {
        _applyUserData(res['user'] as Map<String, dynamic>);
      }
      await _loadUserDataFromDb(cleanId);
      await refreshAllData();
      AnalyticsService.instance.logLogin(loginMethod: provider.toLowerCase());
      AnalyticsService.instance.setUserProperties(userId: cleanId, level: _userProfile.level);
      PusherHubService.instance.login(cleanId);
      notifyListeners();
    }
    return res;
  }

  Future<Map<String, dynamic>> registerHero({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    String avatarId = 'hero1',
    String? displayName,
  }) async {
    final res = await AuthService.instance.register(
      username: username,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      avatarId: avatarId,
      displayName: displayName,
    );
    if (res['status'] == 'success') {
      _isLoggedIn = true;
      final cleanId = (res['user'] != null && res['user']['id'] != null)
          ? res['user']['id'].toString()
          : username.trim().toLowerCase();
      
      _tasks = [];
      _achievements = _getDefaultAchievements(cleanId);
      _notifications = [];
      _userProfile = UserProfile(username: username.trim(), email: email, avatarId: avatarId, userId: cleanId);

      if (res['user'] != null) {
        _applyUserData(res['user'] as Map<String, dynamic>);
      }
      AnalyticsService.instance.logSignUp(signUpMethod: 'email_password');
      AnalyticsService.instance.setUserProperties(userId: cleanId, level: _userProfile.level);
      await _saveProfile();
      _ensureDailyTasks(cleanId);
      await refreshAllData();
      notifyListeners();
    }
    return res;
  }

  void _applyUserData(Map<String, dynamic> data) {
    if (data['id'] != null) {
      _userProfile.userId = data['id'].toString();
    }
    if (data['role'] != null) {
      _userRole = data['role'].toString();
    }
    final displayName = data['display_name']?.toString().trim();
    final rawUsername = data['username']?.toString().trim();
    if (displayName != null && displayName.isNotEmpty) {
      _userProfile.username = displayName;
    } else if (rawUsername != null && rawUsername.isNotEmpty) {
      _userProfile.username = rawUsername;
    }
    _userProfile.email = data['email']?.toString() ?? _userProfile.email;
    _userProfile.avatarId = data['avatar_id']?.toString() ?? _userProfile.avatarId;
    _userProfile.level = int.tryParse(data['level']?.toString() ?? '1') ?? 1;
    _userProfile.totalXP = int.tryParse(data['total_xp']?.toString() ?? '0') ?? 0;
    _userProfile.gold = int.tryParse(data['gold']?.toString() ?? '0') ?? 0;
    _userProfile.currentStreak = int.tryParse(data['current_streak']?.toString() ?? '0') ?? 0;
    _userProfile.bestStreak = int.tryParse(data['best_streak']?.toString() ?? '0') ?? 0;
    if (data['skills'] is Map) {
      _userProfile.skills = Map<String, int>.from(
        (data['skills'] as Map).map((k, v) => MapEntry(k.toString(), int.tryParse(v.toString()) ?? 50))
      );
    }
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('current_username', _userProfile.username);
      prefs.setString('hero_username', _userProfile.username);
      prefs.setString('hero_avatar', _userProfile.avatarId);
    });
    _saveProfile();
  }

  Future<void> refreshAllData() async {
    try {
      final user = await AuthService.instance.getCurrentUser();
      if (user != null) {
        _applyUserData(user);
      } else {
        // Fallback: sync public stats by username or primary active hero from server
        try {
          final queryParams = <String, String>{};
          if (_userProfile.username.isNotEmpty && _userProfile.username != 'Hero') {
            queryParams['username'] = _userProfile.username;
          }
          final pubRes = await ApiClient.instance.get('/users/public_profile.php', queryParams: queryParams.isNotEmpty ? queryParams : null);
          if (pubRes['status'] == 'success' && pubRes['data'] is Map) {
            _applyUserData(pubRes['data'] as Map<String, dynamic>);
          }
        } catch (_) {}
      }

      try {
        final onlineTasks = await OnlineTaskService.instance.fetchTasks();
        if (onlineTasks.isNotEmpty) {
          final taskMap = {for (var t in _tasks) t.id: t};
          for (var ot in onlineTasks) {
            ot.userId ??= currentUserId;
            if (taskMap.containsKey(ot.id)) {
              final existing = taskMap[ot.id]!;
              if (ot.taskType == 'hydration' && existing.waterLogs.isNotEmpty && ot.waterLogs.isEmpty) {
                ot.waterLogs = existing.waterLogs;
                ot.reminders = existing.reminders;
                ot.currentWaterMl = existing.currentWaterMl;
              }
              if (existing.objectives.isNotEmpty && ot.objectives.isEmpty) {
                ot.objectives = existing.objectives;
              }
              if (existing.personalNote != null && ot.personalNote == null) {
                ot.personalNote = existing.personalNote;
              }
            }
            taskMap[ot.id] = ot;
          }
          _tasks = taskMap.values.toList();
          _ensureDailyTasks(currentUserId);
          await _saveTasks();
        }
      } catch (e) {
        debugPrint("Online tasks sync fallback to local cache: $e");
      }

      try {
        final onlineAchievements = await OnlineAchievementService.instance.fetchAchievements();
        if (onlineAchievements.isNotEmpty) {
          _achievements = onlineAchievements;
          await _saveAchievements();
        }
      } catch (e) {
        debugPrint("Online achievements sync fallback: $e");
      }

      try {
        await fetchAppSettings();
      } catch (e) {
        debugPrint("Online settings sync fallback: $e");
      }
    } catch (e) {
      debugPrint("Online sync error: $e");
    }
    notifyListeners();
  }

  Future<void> fetchAppSettings() async {
    try {
      final res = await ApiClient.instance.get('/settings/get.php');
      if (res['status'] == 'success' && res['settings'] is Map) {
        final settings = res['settings'] as Map<String, dynamic>;
        final fullBannerFromApi = settings['hero_banner_url']?.toString().trim();
        final rawBanner = settings['hero_banner_image']?.toString().trim();

        String? resolvedUrl;
        if (fullBannerFromApi != null && fullBannerFromApi.isNotEmpty) {
          resolvedUrl = ApiConfig.resolveUrl(fullBannerFromApi);
        } else if (rawBanner != null && rawBanner.isNotEmpty) {
          resolvedUrl = ApiConfig.resolveUrl(rawBanner);
        } else {
          resolvedUrl = null;
        }

        _rawHeroBannerImage = (rawBanner != null && rawBanner.isNotEmpty) ? rawBanner : null;
        _heroBannerUrl = resolvedUrl;

        final title = settings['hero_banner_title']?.toString().trim();
        _heroBannerTitle = (title != null && title.isNotEmpty) ? title : null;

        final subtitle = settings['hero_banner_subtitle']?.toString().trim();
        _heroBannerSubtitle = (subtitle != null && subtitle.isNotEmpty) ? subtitle : null;

        _heroBannerEnabled = settings['hero_banner_enabled'] != false && settings['hero_banner_enabled'] != '0';
        _isMaintenanceMode = settings['maintenance_mode'] == true || settings['maintenance_mode'] == '1';
        _maintenanceMessage = settings['maintenance_message']?.toString() ?? 'LevelUp realm is currently undergoing maintenance.';

        final quote = settings['quote_of_the_day']?.toString().trim();
        if (quote != null && quote.isNotEmpty) {
          _quoteOfTheDay = quote;
          if (!_motivationalQuotes.contains(quote)) {
            _motivationalQuotes.insert(0, quote);
          }
        }

        if (settings['default_water_goal_ml'] != null) {
          _dailyWaterGoalMl = int.tryParse(settings['default_water_goal_ml'].toString()) ?? 2500;
        }

        final prefs = await SharedPreferences.getInstance();
        if (_heroBannerUrl != null && _heroBannerUrl!.isNotEmpty) {
          await prefs.setString('cached_hero_banner_url', _heroBannerUrl!);
        } else {
          await prefs.remove('cached_hero_banner_url');
        }
        if (_rawHeroBannerImage != null && _rawHeroBannerImage!.isNotEmpty) {
          await prefs.setString('cached_raw_banner_image', _rawHeroBannerImage!);
        } else {
          await prefs.remove('cached_raw_banner_image');
        }
        if (_heroBannerTitle != null) {
          await prefs.setString('cached_hero_banner_title', _heroBannerTitle!);
        } else {
          await prefs.remove('cached_hero_banner_title');
        }
        if (_heroBannerSubtitle != null) {
          await prefs.setString('cached_hero_banner_subtitle', _heroBannerSubtitle!);
        } else {
          await prefs.remove('cached_hero_banner_subtitle');
        }
        await prefs.setBool('cached_hero_banner_enabled', _heroBannerEnabled);
        await prefs.setBool('cached_maintenance_mode', _isMaintenanceMode);
        await prefs.setString('cached_maintenance_message', _maintenanceMessage);
        if (_quoteOfTheDay != null) {
          await prefs.setString('cached_quote_of_the_day', _quoteOfTheDay!);
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Failed to fetch app settings: $e");
    }
  }

  Future<void> logout() async {
    await AuthService.instance.logout();
    PusherHubService.instance.logout();
    _isLoggedIn = false;
    _userRole = null;
    _userProfile = UserProfile(username: 'Hero', userId: 'hero');
    _tasks = _getDefaultTasks('hero');
    _achievements = _getDefaultAchievements('hero');
    _notifications = [];
    _weeklyXp = {};
    _customBannerPath = null;
    _globalTimer?.cancel();
    _globalTimer = null;
    notifyListeners();
  }

  Future<void> toggleSoundEffects(bool val) async {
    _soundEffectsEnabled = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_effects_enabled', val);
    notifyListeners();
  }

  String get selectedAlarmSongId => SoundService.instance.selectedAlarmSongId;
  AlarmSong get currentAlarmSong => SoundService.instance.currentAlarmSong;

  Future<void> setSelectedAlarmSong(String songId) async {
    await SoundService.instance.setSelectedAlarmSong(songId);
    notifyListeners();
  }

  Future<void> previewAlarmSong(String songId) async {
    await SoundService.instance.previewAlarmSong(songId);
  }

  List<RPGTask> get activeTasks => _tasks.where((t) => !t.isCompleted).toList();
  List<RPGTask> get allActiveTasks => _tasks.where((t) => !t.isCompleted).toList();
  List<RPGTask> get todayActiveTasks => _tasks.where((t) => !t.isCompleted && !isTaskFuture(t)).toList();
  List<RPGTask> get completedTasks => _tasks.where((t) => t.isCompleted).toList();
  
  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  bool isTaskToday(RPGTask task) {
    final now = DateTime.now();
    return _isSameDay(task.dueDate, now);
  }

  bool isTaskFuture(RPGTask task) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
    return taskDate.isAfter(today);
  }

  bool isTaskPast(RPGTask task) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
    return taskDate.isBefore(today);
  }

  String getTaskAvailabilityButtonText(RPGTask task) {
    if (isTaskToday(task)) {
      return 'Start Task';
    }
    if (isTaskFuture(task)) {
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
      final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      if (taskDate == tomorrow) {
        return '🔒 Available Tomorrow';
      }
      return '🔒 Available on ${DateFormat('MMM d').format(task.dueDate)}';
    }
    return task.isCompleted ? 'Completed' : 'Missed Quest';
  }

  String getTaskAvailabilityDateText(RPGTask task) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
    if (taskDate == tomorrow) {
      return 'Tomorrow';
    }
    return DateFormat('MMMM d, yyyy').format(task.dueDate);
  }

  List<RPGTask> getTasksForDate(DateTime date) => _tasks.where((t) => _isSameDay(t.dueDate, date)).toList();
  List<RPGTask> getActiveTasksForDate(DateTime date) => getTasksForDate(date).where((t) => !t.isCompleted).toList();
  List<RPGTask> getCompletedTasksForDate(DateTime date) => getTasksForDate(date).where((t) => t.isCompleted).toList();

  // Calculate today's completed tasks
  int get todayCompletedCount {
    final now = DateTime.now();
    return _tasks.where((t) => t.isCompleted && _isSameDay(t.dueDate, now)).length;
  }

  String get mostActiveCategory {
    if (completedTasks.isEmpty) return 'None';
    final counts = <String, int>{};
    for (var t in completedTasks) {
      counts[t.category] = (counts[t.category] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  AppState() {
    ApiConfig.addListener(_onApiConfigChanged);
    _loadData();
  }

  void _onApiConfigChanged() {
    if (_heroBannerUrl != null && _heroBannerUrl!.isNotEmpty) {
      _heroBannerUrl = ApiConfig.resolveUrl(_rawHeroBannerImage ?? _heroBannerUrl!);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    ApiConfig.removeListener(_onApiConfigChanged);
    _globalTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserDataFromDb(String userId) async {
    final cleanId = userId.trim().toLowerCase();
    final dbHelper = DatabaseHelper.instance;

    try {
      final profile = await dbHelper.getProfile(cleanId);
      if (profile != null) {
        _userProfile = profile;
        _userProfile.userId = cleanId;
      }
    } catch (e) {
      debugPrint("Error loading profile from DB: $e");
    }

    try {
      final tasksList = await dbHelper.getTasksForUser(cleanId, _userProfile.username);
      if (tasksList.isNotEmpty) {
        _tasks = tasksList;
      } else {
        _tasks = _getDefaultTasks(cleanId);
        await dbHelper.saveAllTasks(_tasks, cleanId);
      }
      _ensureDailyTasks(cleanId);
    } catch (e) {
      debugPrint("Error loading tasks from DB: $e");
      _tasks = _getDefaultTasks(cleanId);
      _ensureDailyTasks(cleanId);
    }

    try {
      final achievementsList = await dbHelper.getAchievementsForUser(cleanId);
      if (achievementsList.isNotEmpty) {
        _achievements = achievementsList;
      } else {
        _achievements = _getDefaultAchievements(cleanId);
        await dbHelper.saveAllAchievements(_achievements, cleanId);
      }
    } catch (e) {
      debugPrint("Error loading achievements from DB: $e");
    }

    try {
      final notifsList = await dbHelper.getNotificationsForUser(cleanId);
      _notifications = notifsList;
    } catch (e) {
      debugPrint("Error loading notifications from DB: $e");
    }
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      _userRole = prefs.getString('auth_role');
      final savedName = prefs.getString('current_username') ?? prefs.getString('hero_username');
      final savedId = prefs.getInt('auth_user_id')?.toString() ??
          (savedName != null && savedName.isNotEmpty ? savedName.toLowerCase() : 'hero');

      if (savedName != null && savedName.trim().isNotEmpty) {
        _userProfile.username = savedName.trim();
      }
      _userProfile.userId = savedId;

      final savedAvatar = prefs.getString('hero_avatar');
      if (savedAvatar != null && savedAvatar.trim().isNotEmpty) {
        _userProfile.avatarId = savedAvatar.trim();
      }

      await _loadUserDataFromDb(savedId);
      if (_isLoggedIn) {
        PusherHubService.instance.login(savedId);
      }

      _notificationSettings = NotificationSettings(
        taskCompletionNotifications: prefs.getBool('notif_task_completion') ?? true,
        taskReminders: prefs.getBool('notif_task_reminders') ?? true,
        dailyReminders: prefs.getBool('notif_daily_reminders') ?? true,
        streakReminders: prefs.getBool('notif_streak_reminders') ?? true,
        achievementNotifications: prefs.getBool('notif_achievements') ?? true,
      );

      _soundEffectsEnabled = prefs.getBool('sound_effects_enabled') ?? true;
      _isDarkMode = prefs.getBool('isDarkMode') ?? true;

      final cachedBanner = prefs.getString('cached_hero_banner_url');
      if (cachedBanner != null && cachedBanner.trim().isNotEmpty) {
        _heroBannerUrl = ApiConfig.resolveUrl(cachedBanner.trim());
      }

      final cachedRawBanner = prefs.getString('cached_raw_banner_image');
      if (cachedRawBanner != null && cachedRawBanner.trim().isNotEmpty) {
        _rawHeroBannerImage = cachedRawBanner.trim();
        _heroBannerUrl ??= ApiConfig.resolveUrl(cachedRawBanner.trim());
      }

      _heroBannerTitle = prefs.getString('cached_hero_banner_title');
      _heroBannerSubtitle = prefs.getString('cached_hero_banner_subtitle');
      if (prefs.containsKey('cached_hero_banner_enabled')) {
        _heroBannerEnabled = prefs.getBool('cached_hero_banner_enabled') ?? true;
      }
      _quoteOfTheDay = prefs.getString('cached_quote_of_the_day') ?? _quoteOfTheDay;
      if (prefs.containsKey('cached_maintenance_mode')) {
        _isMaintenanceMode = prefs.getBool('cached_maintenance_mode') ?? false;
      }
      _maintenanceMessage = prefs.getString('cached_maintenance_message') ?? _maintenanceMessage;

      final savedCustomBanner = prefs.getString('custom_banner_path');
      if (savedCustomBanner != null && savedCustomBanner.trim().isNotEmpty) {
        _customBannerPath = savedCustomBanner.trim();
      }

      _updateStreak();

      _weeklyXp = {
        'Mon': 120, 'Tue': 80, 'Wed': 150, 'Thu': 200, 'Fri': 100, 'Sat': 0, 'Sun': 0,
      };

      // Asynchronously fetch latest realm settings & notifications from online backend
      fetchAppSettings();
      fetchOnlineNotifications();
    } catch (e) {
      debugPrint("Critical error in _loadData: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _ensureDailyTasks([String? userId]) {
    final effectiveUserId = (userId ?? currentUserId).trim().toLowerCase();
    final now = DateTime.now();
    bool added = false;

    // Check existing tasks for today
    final todayTasks = _tasks.where((t) => _isSameDay(t.dueDate, now)).toList();
    if (_tasks.isEmpty || todayTasks.isEmpty) {
      final defaults = _getDefaultTasks(effectiveUserId, now);
      for (final def in defaults) {
        if (!_tasks.any((t) => t.id == def.id || (t.title == def.title && _isSameDay(t.dueDate, now)))) {
          _tasks.add(def);
          added = true;
        }
      }
    } else {
      // Ensure hydration exists for today
      bool hasHydrationToday = _tasks.any((t) => t.taskType == 'hydration' && _isSameDay(t.dueDate, now));
      if (!hasHydrationToday) {
        _tasks.add(
          RPGTask(
            id: 'task_hydro_${now.year}_${now.month}_${now.day}',
            title: 'Daily Drinking Water',
            description: 'Stay hydrated! Daily goal: 2.5 L',
            category: 'Hydration',
            xpReward: 50,
            coinReward: 25,
            dueDate: now,
            durationMinutes: 0,
            remainingSeconds: 0,
            timerStatus: 'Not Started',
            isCompleted: false,
            taskType: 'hydration',
            waterGoalMl: _dailyWaterGoalMl,
            currentWaterMl: 0,
            waterLogs: [],
            userId: effectiveUserId,
            reminders: createDefaultDrinkingSchedule(),
          ),
        );
        added = true;
      }

      // Check each default category and ensure at least one active/completed quest exists for today so no category is blank
      final defaults = _getDefaultTasks(effectiveUserId, now);
      for (final def in defaults) {
        final hasCategoryToday = _tasks.any((t) =>
            t.category.trim().toLowerCase() == def.category.trim().toLowerCase() && _isSameDay(t.dueDate, now));
        if (!hasCategoryToday) {
          _tasks.add(def);
          added = true;
        }
      }
    }

    // Ensure all hydration tasks have a populated drinking schedule
    for (var t in _tasks) {
      if (t.taskType == 'hydration' && t.reminders.isEmpty) {
        t.reminders = createDefaultDrinkingSchedule(drinkAmountMl: t.drinkAmountMl);
        added = true;
      }
    }

    if (added) {
      _saveTasks();
    }
  }

  // --- HYDRATION LOGIC ---

  String _formatDateKey(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  List<HydrationReminder> createDefaultDrinkingSchedule({int drinkAmountMl = 250}) {
    return [
      HydrationReminder(id: 'hr_1', time: '08:00 AM', hour: 8, minute: 0, amountMl: drinkAmountMl, repeat: 'Every Day', isEnabled: true),
      HydrationReminder(id: 'hr_2', time: '10:00 AM', hour: 10, minute: 0, amountMl: drinkAmountMl, repeat: 'Every Day', isEnabled: true),
      HydrationReminder(id: 'hr_3', time: '12:00 PM', hour: 12, minute: 0, amountMl: 300, repeat: 'Every Day', isEnabled: true),
      HydrationReminder(id: 'hr_4', time: '02:00 PM', hour: 14, minute: 0, amountMl: 300, repeat: 'Every Day', isEnabled: true),
      HydrationReminder(id: 'hr_5', time: '04:00 PM', hour: 16, minute: 0, amountMl: drinkAmountMl, repeat: 'Every Day', isEnabled: true),
      HydrationReminder(id: 'hr_6', time: '06:00 PM', hour: 18, minute: 0, amountMl: 300, repeat: 'Every Day', isEnabled: true),
      HydrationReminder(id: 'hr_7', time: '08:00 PM', hour: 20, minute: 0, amountMl: drinkAmountMl, repeat: 'Every Day', isEnabled: true),
    ];
  }

  void addWater(String taskId, int amountMl, [BuildContext? context, bool autoMarkReminder = true]) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      if (isTaskFuture(task)) {
        final msg = '🔒 "${task.title}" is scheduled for ${getTaskAvailabilityDateText(task)} and is locked until that day.';
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Colors.orange.shade800,
            ),
          );
        } else {
          rootScaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Colors.orange.shade800,
            ),
          );
        }
        return;
      }

      final newLog = WaterLogEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amountMl: amountMl,
        timestamp: DateTime.now(),
      );

      task.waterLogs.insert(0, newLog);
      task.currentWaterMl += amountMl;

      // Smart Reminder Completion: mark nearest scheduled drink as completed only if not triggered for a specific reminder
      if (autoMarkReminder && task.reminders.isNotEmpty) {
        final nowTime = DateTime.now();
        final currentMins = nowTime.hour * 60 + nowTime.minute;
        
        // 1. Check if there are missed reminders (time passed, not completed)
        final missed = task.reminders.where((r) => r.isEnabled && !r.isCompleted && (r.hour * 60 + r.minute <= currentMins)).toList();
        if (missed.isNotEmpty) {
          missed.sort((a, b) => (b.hour * 60 + b.minute).compareTo(a.hour * 60 + a.minute));
          missed.first.isCompleted = true;
          missed.first.completedAt = DateTime.now();
        } else {
          // 2. Otherwise mark the next upcoming reminder
          final upcoming = task.reminders.where((r) => r.isEnabled && !r.isCompleted).toList();
          if (upcoming.isNotEmpty) {
            upcoming.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
            upcoming.first.isCompleted = true;
            upcoming.first.completedAt = DateTime.now();
          }
        }
      }

      final todayStr = _formatDateKey(DateTime.now());
      final yesterdayStr = _formatDateKey(DateTime.now().subtract(const Duration(days: 1)));

      // Check if daily water goal reached
      if (task.currentWaterMl >= task.waterGoalMl) {
        final bool wasAlreadyCompleted = task.isCompleted;
        task.isCompleted = true;
        task.timerStatus = 'Completed';

        // Award XP & streak reward only once per day
        if (_userProfile.hydrationXpAwardedDate != todayStr) {
          final int oldLevel = _userProfile.level;
          _userProfile.hydrationXpAwardedDate = todayStr;
          final int xp = task.xpReward > 0 ? task.xpReward : 50;
          _addXP(xp);
          _userProfile.gold += 25;
          _userProfile.skills['Strength'] = (_userProfile.skills['Strength'] ?? 0) + 10;

          // Hydration streak update
          if (_userProfile.lastHydrationCompletedDate == yesterdayStr) {
            _userProfile.hydrationCurrentStreak += 1;
          } else if (_userProfile.lastHydrationCompletedDate == todayStr) {
            // Already counted streak today
          } else {
            _userProfile.hydrationCurrentStreak = 1;
          }

          if (_userProfile.hydrationCurrentStreak > _userProfile.hydrationBestStreak) {
            _userProfile.hydrationBestStreak = _userProfile.hydrationCurrentStreak;
          }
          _userProfile.lastHydrationCompletedDate = todayStr;

          List<Achievement> newlyUnlocked = _checkAchievements();
          _saveProfile();
          _saveTasks();
          notifyListeners();

          _triggerTaskCompletionFlow(
            task: task,
            xpEarned: xp,
            oldLevel: oldLevel,
            newlyUnlocked: newlyUnlocked,
            context: context,
          );
          return;
        } else if (!wasAlreadyCompleted) {
          _saveProfile();
        }
      }

      _saveTasks();
      notifyListeners();

      // Async online sync for hydration
      OnlineHydrationService.instance.addWater(amountMl, taskId: taskId).catchError((e) {
        debugPrint("Online hydration sync error: $e");
        return <String, dynamic>{};
      });
    }
  }

  void removeWaterLog(String taskId, String logId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      final logIdx = task.waterLogs.indexWhere((l) => l.id == logId);
      if (logIdx != -1) {
        final removed = task.waterLogs.removeAt(logIdx);
        task.currentWaterMl = (task.currentWaterMl - removed.amountMl).clamp(0, 999999);

        // If falls below goal, update completion state
        if (task.currentWaterMl < task.waterGoalMl) {
          task.isCompleted = false;
          task.timerStatus = 'Not Started';
        }

        _saveTasks();
        notifyListeners();
      }
    }
  }

  void updateWaterGoal(String taskId, int newGoalMl) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      task.waterGoalMl = newGoalMl;
      if (task.currentWaterMl >= task.waterGoalMl) {
        task.isCompleted = true;
        task.timerStatus = 'Completed';
      } else {
        task.isCompleted = false;
        task.timerStatus = 'Not Started';
      }
      
      // Save per-user preference in SharedPreferences
      SharedPreferences.getInstance().then((prefs) {
        final uKey = _userProfile.username.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
        prefs.setInt('${uKey}_water_goal', newGoalMl);
      });

      _saveTasks();
      notifyListeners();
    }
  }

  void updateDrinkAmount(String taskId, int newDrinkAmountMl) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      task.drinkAmountMl = newDrinkAmountMl;

      // Save per-user preference in SharedPreferences
      SharedPreferences.getInstance().then((prefs) {
        final uKey = _userProfile.username.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
        prefs.setInt('${uKey}_drink_amount', newDrinkAmountMl);
      });

      _saveTasks();
      notifyListeners();
    }
  }

  void addHydrationReminder(String taskId, HydrationReminder reminder) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      task.reminders.add(reminder);
      task.reminders.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
      _saveTasks();
      notifyListeners();
    }
  }

  void updateHydrationReminder(String taskId, HydrationReminder reminder) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      final remIdx = task.reminders.indexWhere((r) => r.id == reminder.id);
      if (remIdx != -1) {
        task.reminders[remIdx] = reminder;
        task.reminders.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
        _saveTasks();
        notifyListeners();
      }
    }
  }

  void deleteHydrationReminder(String taskId, String reminderId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      task.reminders.removeWhere((r) => r.id == reminderId);
      _saveTasks();
      notifyListeners();
    }
  }

  void toggleHydrationReminder(String taskId, String reminderId, bool isEnabled) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      final remIdx = task.reminders.indexWhere((r) => r.id == reminderId);
      if (remIdx != -1) {
        task.reminders[remIdx].isEnabled = isEnabled;
        _saveTasks();
        notifyListeners();
      }
    }
  }

  void completeHydrationReminder(String taskId, String reminderId, [BuildContext? context]) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      final remIdx = task.reminders.indexWhere((r) => r.id == reminderId);
      if (remIdx != -1) {
        final reminder = task.reminders[remIdx];
        if (!reminder.isCompleted) {
          reminder.isCompleted = true;
          reminder.completedAt = DateTime.now();
          addWater(taskId, reminder.amountMl, context, false);
        }
      }
    }
  }

  void generateHydrationSchedule(
    String taskId, {
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int intervalMinutes,
    required int drinkAmountMl,
  }) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      final startTotalMins = startTime.hour * 60 + startTime.minute;
      final endTotalMins = endTime.hour * 60 + endTime.minute;

      if (endTotalMins > startTotalMins && intervalMinutes > 0) {
        final List<HydrationReminder> newReminders = [];
        int current = startTotalMins;
        int count = 1;

        while (current <= endTotalMins) {
          final h = current ~/ 60;
          final m = current % 60;
          final dt = DateTime(2026, 1, 1, h, m);
          final timeStr = DateFormat('hh:mm a').format(dt);

          newReminders.add(
            HydrationReminder(
              id: 'hr_gen_${DateTime.now().millisecondsSinceEpoch}_$count',
              time: timeStr,
              hour: h,
              minute: m,
              amountMl: drinkAmountMl,
              repeat: 'Every Day',
              isEnabled: true,
            ),
          );
          current += intervalMinutes;
          count++;
        }

        task.reminders = newReminders;
        task.drinkAmountMl = drinkAmountMl;
        task.reminderIntervalMinutes = intervalMinutes;
        final startDt = DateTime(2026, 1, 1, startTime.hour, startTime.minute);
        final endDt = DateTime(2026, 1, 1, endTime.hour, endTime.minute);
        task.reminderStartTime = DateFormat('hh:mm a').format(startDt);
        task.reminderEndTime = DateFormat('hh:mm a').format(endDt);

        // Save per-user preference in SharedPreferences
        SharedPreferences.getInstance().then((prefs) {
          final uKey = _userProfile.username.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
          prefs.setInt('${uKey}_drink_amount', drinkAmountMl);
          prefs.setInt('${uKey}_reminder_interval', intervalMinutes);
          prefs.setString('${uKey}_start_time', task.reminderStartTime!);
          prefs.setString('${uKey}_end_time', task.reminderEndTime!);
        });

        _saveTasks();
        notifyListeners();
      }
    }
  }

  void updateHydrationSettings(
    String taskId, {
    int? dailyGoalMl,
    int? drinkAmountMl,
    bool? notificationsEnabled,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    int? intervalMinutes,
  }) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      if (dailyGoalMl != null) {
        task.waterGoalMl = dailyGoalMl;
      }
      if (drinkAmountMl != null) {
        task.drinkAmountMl = drinkAmountMl;
      }
      if (notificationsEnabled != null) {
        task.notificationsEnabled = notificationsEnabled;
      }
      if (startTime != null) {
        final startDt = DateTime(2026, 1, 1, startTime.hour, startTime.minute);
        task.reminderStartTime = DateFormat('hh:mm a').format(startDt);
      }
      if (endTime != null) {
        final endDt = DateTime(2026, 1, 1, endTime.hour, endTime.minute);
        task.reminderEndTime = DateFormat('hh:mm a').format(endDt);
      }
      if (intervalMinutes != null) {
        task.reminderIntervalMinutes = intervalMinutes;
      }

      // Save per-user preference in SharedPreferences
      SharedPreferences.getInstance().then((prefs) {
        final uKey = _userProfile.username.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
        if (dailyGoalMl != null) prefs.setInt('${uKey}_water_goal', dailyGoalMl);
        if (drinkAmountMl != null) prefs.setInt('${uKey}_drink_amount', drinkAmountMl);
        if (notificationsEnabled != null) prefs.setBool('${uKey}_water_notifs', notificationsEnabled);
        if (task.reminderStartTime != null) prefs.setString('${uKey}_start_time', task.reminderStartTime!);
        if (task.reminderEndTime != null) prefs.setString('${uKey}_end_time', task.reminderEndTime!);
        if (intervalMinutes != null) prefs.setInt('${uKey}_reminder_interval', intervalMinutes);
      });

      _saveTasks();
      notifyListeners();
    }
  }

  Map<String, dynamic> getHydrationStats(RPGTask task) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1. Today
    final todayConsumed = task.currentWaterMl;
    final todayGoal = task.waterGoalMl;

    // 2. Past 7 days (including today)
    int totalLoggedMl7Days = 0;
    int daysGoalCompleted7Days = 0;

    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final dateTasks = _tasks.where((t) => t.taskType == 'hydration' && _isSameDay(t.dueDate, date)).toList();
      if (dateTasks.isNotEmpty) {
        final dayTask = dateTasks.first;
        totalLoggedMl7Days += dayTask.currentWaterMl;
        if (dayTask.currentWaterMl >= dayTask.waterGoalMl && dayTask.waterGoalMl > 0) {
          daysGoalCompleted7Days++;
        }
      } else if (i == 0) {
        totalLoggedMl7Days += todayConsumed;
        if (todayConsumed >= todayGoal && todayGoal > 0) {
          daysGoalCompleted7Days++;
        }
      }
    }

    final double avgLitersPerDay = (totalLoggedMl7Days / 7.0) / 1000.0;
    final int streak = _userProfile.hydrationCurrentStreak;

    return {
      'todayConsumedMl': todayConsumed,
      'todayGoalMl': todayGoal,
      'todayConsumedL': (todayConsumed / 1000).toStringAsFixed(1),
      'todayGoalL': (todayGoal / 1000).toStringAsFixed(1),
      'weeklyAverageL': avgLitersPerDay.toStringAsFixed(1),
      'goalCompletedDays': daysGoalCompleted7Days,
      'streakDays': streak,
      'streak': streak,
    };
  }

  void _updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final completedDates = <DateTime>{};
    for (var t in _tasks) {
      if (t.isCompleted) {
        completedDates.add(DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day));
      }
    }

    int streak = 0;
    DateTime checkDate = today;
    if (!completedDates.contains(today)) {
      checkDate = today.subtract(const Duration(days: 1));
    }

    while (completedDates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    _userProfile.currentStreak = streak;
    if (_userProfile.currentStreak > _userProfile.bestStreak) {
      _userProfile.bestStreak = _userProfile.currentStreak;
    }
    _saveProfile();
  }

  Future<void> _saveProfile() async {
    await DatabaseHelper.instance.saveProfile(_userProfile, currentUserId);
  }

  Future<void> _saveTasks() async {
    await DatabaseHelper.instance.saveAllTasks(_tasks, currentUserId);
  }

  Future<void> _saveAchievements() async {
    await DatabaseHelper.instance.saveAllAchievements(_achievements, currentUserId);
  }

  void addTask(RPGTask task) {
    task.userId = (task.userId != null && task.userId!.isNotEmpty) ? task.userId : currentUserId;
    _tasks.add(task);
    _saveTasks();
    notifyListeners();

    // Sync task to server so admin and all endpoints are up to date
    OnlineTaskService.instance.createTask(task).then((savedOnline) {
      final idx = _tasks.indexWhere((t) => t.id == task.id);
      if (idx != -1 && savedOnline.id != task.id) {
        savedOnline.userId = currentUserId;
        _tasks[idx] = savedOnline;
        _saveTasks();
        notifyListeners();
      }
    }).catchError((e) {
      debugPrint("Online task create notice: $e");
    });
  }

  void updateTaskTime(String taskId, int timeSpentSeconds) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _tasks[idx].timeSpentSeconds = timeSpentSeconds;
      _saveTasks();
      notifyListeners();
    }
  }

  // --- TIMER LOGIC ---

  void _startGlobalTimerIfNeeded() {
    if (_globalTimer != null && _globalTimer!.isActive) return;
    _globalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      bool anyRunning = false;
      for (var t in _tasks) {
        if (t.timerStatus == 'Running' && t.timerStartTimeEpoch != null) {
          anyRunning = true;
          final now = DateTime.now().millisecondsSinceEpoch;
          final elapsedSeconds = ((now - t.timerStartTimeEpoch!) / 1000).floor();
          
          if (t.remainingSeconds - elapsedSeconds <= 0) {
            // Timer finished naturally
            t.remainingSeconds = 0;
            completeTask(t.id); // This stops the timer implicitly because status changes to completed
          }
        }
      }
      
      if (anyRunning) {
        notifyListeners();
      } else {
        _globalTimer?.cancel();
        _globalTimer = null;
      }
    });
  }

  int getCalculatedRemainingSeconds(RPGTask task) {
    if (task.timerStatus == 'Running' && task.timerStartTimeEpoch != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsed = ((now - task.timerStartTimeEpoch!) / 1000).floor();
      final currentRemaining = task.remainingSeconds - elapsed;
      return currentRemaining > 0 ? currentRemaining : 0;
    }
    return task.remainingSeconds;
  }

  void startTaskTimer(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];

      if (isTaskFuture(task)) {
        rootScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('🔒 "${task.title}" is scheduled for ${getTaskAvailabilityDateText(task)}. It will unlock on that day!'),
            backgroundColor: Colors.orange.shade800,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      if (isTaskPast(task) && !task.isCompleted) {
        rootScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('⚠️ "${task.title}" was scheduled for a past date and cannot be started.'),
            backgroundColor: Colors.red.shade800,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      // Pause any other running timers
      for (var t in _tasks) {
        if (t.timerStatus == 'Running' && t.id != taskId) {
          _pauseTimerLocally(t);
        }
      }

      if (task.timerStatus != 'Completed') {
        if (task.timerStatus == 'Not Started') {
          task.remainingSeconds = task.durationMinutes * 60;
        }
        task.timerStatus = 'Running';
        task.timerStartTimeEpoch = DateTime.now().millisecondsSinceEpoch;
        _startGlobalTimerIfNeeded();
        _saveTasks();
        notifyListeners();
      }
    }
  }

  void _pauseTimerLocally(RPGTask task) {
    if (task.timerStatus == 'Running' && task.timerStartTimeEpoch != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsed = ((now - task.timerStartTimeEpoch!) / 1000).floor();
      task.remainingSeconds = task.remainingSeconds - elapsed;
      if (task.remainingSeconds < 0) task.remainingSeconds = 0;
      task.timerStatus = 'Paused';
      task.timerStartTimeEpoch = null;
    }
  }

  void resetTaskTimer(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      task.timerStatus = 'Not Started';
      task.timerStartTimeEpoch = null;
      task.remainingSeconds = task.durationMinutes * 60;
      _saveTasks();
      notifyListeners();
    }
  }

  void toggleTaskObjective(String taskId, String objectiveId, bool isCompleted) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      task.getEffectiveObjectives();
      final objIdx = task.objectives.indexWhere((o) => o.id == objectiveId);
      if (objIdx != -1) {
        task.objectives[objIdx].isCompleted = isCompleted;
        _saveTasks();
        notifyListeners();
      }
    }
  }

  void updateTaskNote(String taskId, String note) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _tasks[idx].personalNote = note;
      _saveTasks();
      notifyListeners();
    }
  }

  void updateTaskProof(String taskId, String? imagePath) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _tasks[idx].proofImagePath = imagePath;
      _saveTasks();
      notifyListeners();
    }
  }

  void pauseTaskTimer(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _pauseTimerLocally(_tasks[idx]);
      _saveTasks();
      notifyListeners();
    }
  }

  void finishTaskEarly(String taskId, [BuildContext? context]) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      if (isTaskFuture(task)) {
        rootScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('🔒 "${task.title}" is scheduled for ${getTaskAvailabilityDateText(task)} and is locked.'),
            backgroundColor: Colors.orange.shade800,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
      _pauseTimerLocally(task); // Update elapsed time
      completeTask(taskId, context);
    }
  }

  void completeTask(String taskId, [BuildContext? context, int? xpOverride]) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1 && !_tasks[index].isCompleted) {
      final task = _tasks[index];
      if (isTaskFuture(task)) {
        rootScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('🔒 "${task.title}" is scheduled for ${getTaskAvailabilityDateText(task)} and cannot be completed today.'),
            backgroundColor: Colors.orange.shade800,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      // Check ownership
      if (task.userId != null && task.userId!.isNotEmpty) {
        if (!SecurityHelper.validateOwnership(currentUserId, task.userId)) {
          debugPrint("Unauthorized attempt to complete another user's task.");
          return;
        }
      }

      final int oldLevel = _userProfile.level;

      _pauseTimerLocally(task); // Stop timer if running
      task.isCompleted = true;
      task.timerStatus = 'Completed';
      
      int xp = xpOverride ?? task.xpReward;
      int coins = task.getEffectiveCoinReward();
      if (xpOverride != null && task.xpReward > 0) {
        coins = ((coins * xpOverride) / task.xpReward).round();
      }
      _userProfile.gold += coins;
      
      // Update skills based on category
      String category = task.category;
      if (category == 'Fitness' || category == 'Health' || category == 'Walking') {
        _userProfile.skills['Strength'] = (_userProfile.skills['Strength'] ?? 0) + 10;
      } else if (category == 'Study' || category == 'Work' || category == 'Coding' || category == 'Learning' || category == 'Reading') {
        _userProfile.skills['Knowledge'] = (_userProfile.skills['Knowledge'] ?? 0) + 10;
      } else {
        _userProfile.skills['Discipline'] = (_userProfile.skills['Discipline'] ?? 0) + 10;
      }
      
      _addXP(xp);
      _updateStreak();
      List<Achievement> newlyUnlocked = _checkAchievements();
      _saveTasks();
      _saveProfile();
      notifyListeners();

      // Trigger completion flow celebration & dialog
      _triggerTaskCompletionFlow(
        task: task,
        xpEarned: xp,
        oldLevel: oldLevel,
        newlyUnlocked: newlyUnlocked,
        context: context,
      );

      // Online synchronization with backend
      OnlineTaskService.instance.completeTask(taskId).then((res) {
        if (res['status'] == 'success' && res['user'] != null) {
          final u = res['user'];
          _userProfile.totalXP = int.tryParse(u['total_xp']?.toString() ?? '0') ?? _userProfile.totalXP;
          _userProfile.level = int.tryParse(u['level']?.toString() ?? '1') ?? _userProfile.level;
          _userProfile.gold = int.tryParse(u['gold']?.toString() ?? '0') ?? _userProfile.gold;
          _userProfile.currentStreak = int.tryParse(u['current_streak']?.toString() ?? '0') ?? _userProfile.currentStreak;
          _userProfile.bestStreak = int.tryParse(u['best_streak']?.toString() ?? '0') ?? _userProfile.bestStreak;
          _saveProfile();
          notifyListeners();
        }
      }).catchError((e) {
        debugPrint("Online completion sync warning: $e");
      });
    }
  }

  void _triggerTaskCompletionFlow({
    required RPGTask task,
    required int xpEarned,
    required int oldLevel,
    required List<Achievement> newlyUnlocked,
    BuildContext? context,
  }) {
    // 1. Random Motivational Quote
    final quotes = List<String>.from(_motivationalQuotes)..shuffle();
    final quote = quotes.first;

    // 2. Category-Specific Notification Info
    String categoryHeadline = '🎉 QUEST COMPLETE!';
    String categoryBody = 'You completed ${task.title}. +$xpEarned XP earned!';
    switch (task.category) {
      case 'Fitness':
        categoryHeadline = '💪 Workout Complete!';
        categoryBody = 'You finished your fitness quest.\n+$xpEarned XP earned!';
        break;
      case 'Study':
        categoryHeadline = '📚 Knowledge Increased!';
        categoryBody = 'Study task completed successfully.\nKeep learning and earn more XP!';
        break;
      case 'Health':
        categoryHeadline = '💧 Health Quest Complete!';
        categoryBody = 'Great job taking care of yourself.\n+$xpEarned XP earned!';
        break;
      case 'Work':
        categoryHeadline = '🚀 Mission Complete!';
        categoryBody = 'Another step toward your goals.\n+$xpEarned XP earned!';
        break;
      case 'Personal':
      default:
        categoryHeadline = '✨ Personal Quest Complete!';
        categoryBody = 'Small progress every day creates big results.\n+$xpEarned XP earned!';
        break;
    }

    // 3. Task Completion Notification
    final completionNotification = AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: currentUserId,
      title: categoryHeadline,
      body: categoryBody,
      category: task.category,
      type: 'taskCompletion',
      timestamp: DateTime.now(),
      xpReward: xpEarned,
      streakDays: _userProfile.currentStreak,
      motivationalQuote: quote,
    );
    _notifications.insert(0, completionNotification);
    DatabaseHelper.instance.saveNotification(completionNotification, currentUserId);

    // 4. Level Up Notification
    bool didLevelUp = _userProfile.level > oldLevel;
    if (didLevelUp) {
      final levelNotification = AppNotification(
        id: 'notif_lvl_${DateTime.now().millisecondsSinceEpoch}',
        userId: currentUserId,
        title: '🎊 LEVEL UP!',
        body: 'Congratulations, Hero!\nYou reached Level ${_userProfile.level}.\nKeep completing quests to become stronger.',
        category: 'LevelUp',
        type: 'levelUp',
        timestamp: DateTime.now(),
      );
      _notifications.insert(0, levelNotification);
      DatabaseHelper.instance.saveNotification(levelNotification, currentUserId);
    }

    // 5. Achievement Notification
    if (_notificationSettings.achievementNotifications) {
      for (var ach in newlyUnlocked) {
        final achNotif = AppNotification(
          id: 'notif_ach_${ach.id}_${DateTime.now().millisecondsSinceEpoch}',
          userId: currentUserId,
          title: '🏆 ACHIEVEMENT UNLOCKED!',
          body: '${ach.name}\n${ach.description}',
          category: 'Achievement',
          type: 'achievement',
          timestamp: DateTime.now(),
          xpReward: ach.xpReward,
        );
        _notifications.insert(0, achNotif);
        DatabaseHelper.instance.saveNotification(achNotif, currentUserId);
      }
    }

    // 6. Play Task Completion Alarm Sound & Haptic Vibration
    if (didLevelUp) {
      SoundService.instance.playLevelUpAlarm(isSoundEnabled: _soundEffectsEnabled);
    } else {
      SoundService.instance.playTaskCompletedAlarm(isSoundEnabled: _soundEffectsEnabled);
    }

    // 7. Visual Dialog Feedback
    if (_notificationSettings.taskCompletionNotifications) {
      final targetContext = context ?? rootNavigatorKey.currentContext;
      if (targetContext != null) {
        showDialog(
          context: targetContext,
          barrierDismissible: false,
          builder: (dialogContext) => TaskCompletionCelebrationDialog(
            task: task,
            xpEarned: xpEarned,
            currentStreak: _userProfile.currentStreak,
            motivationalQuote: quote,
            onDismiss: () {
              if (didLevelUp) {
                Future.delayed(const Duration(milliseconds: 250), () {
                  _showDelayedLevelUpDialog(_userProfile.level, newlyUnlocked);
                });
              } else if (newlyUnlocked.isNotEmpty && _notificationSettings.achievementNotifications) {
                Future.delayed(const Duration(milliseconds: 250), () {
                  _showDelayedAchievementDialog(newlyUnlocked.first);
                });
              }
            },
          ),
        );
      } else {
        rootScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('$categoryHeadline +$xpEarned XP earned!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } else {
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Quest "${task.title}" Completed! +$xpEarned XP earned!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showDelayedLevelUpDialog(int newLevel, List<Achievement> newlyUnlocked) {
    final navState = rootNavigatorKey.currentState;
    if (navState == null || !navState.mounted) return;
    final ctx = navState.context;
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => LevelUpCelebrationDialog(
        newLevel: newLevel,
        onDismiss: () {
          if (newlyUnlocked.isNotEmpty && _notificationSettings.achievementNotifications) {
            Future.delayed(const Duration(milliseconds: 250), () {
              _showDelayedAchievementDialog(newlyUnlocked.first);
            });
          }
        },
      ),
    );
  }

  void _showDelayedAchievementDialog(Achievement achievement) {
    final navState = rootNavigatorKey.currentState;
    if (navState == null || !navState.mounted) return;
    final ctx = navState.context;
    showDialog(
      context: ctx,
      builder: (_) => AchievementUnlockedCelebrationDialog(
        achievement: achievement,
        onDismiss: () {},
      ),
    );
  }

  void _addXP(int amount) {
    _userProfile.totalXP += amount;
    int xpNeededForNextLevel = _userProfile.level * 100;
    
    if (_userProfile.totalXP >= xpNeededForNextLevel) {
      _userProfile.level++;
      _userProfile.totalXP -= xpNeededForNextLevel;
    }
  }

  List<Achievement> _checkAchievements() {
    List<Achievement> newlyUnlocked = [];
    
    // First Quest
    if (!_achievements[0].isUnlocked && completedTasks.isNotEmpty) {
      _achievements[0].isUnlocked = true;
      newlyUnlocked.add(_achievements[0]);
    }
    // On Fire (7 day streak)
    if (!_achievements[1].isUnlocked && _userProfile.currentStreak >= 7) {
      _achievements[1].isUnlocked = true;
      newlyUnlocked.add(_achievements[1]);
    }
    // Quest Master (50 quests)
    if (!_achievements[2].isUnlocked && completedTasks.length >= 50) {
      _achievements[2].isUnlocked = true;
      newlyUnlocked.add(_achievements[2]);
    }
    // Legend (Level 50)
    if (!_achievements[3].isUnlocked && _userProfile.level >= 50) {
      _achievements[3].isUnlocked = true;
      newlyUnlocked.add(_achievements[3]);
    }
    
    if (newlyUnlocked.isNotEmpty) _saveAchievements();
    return newlyUnlocked;
  }

  Future<void> updateNotificationSettings(NotificationSettings settings) async {
    _notificationSettings = settings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_task_completion', settings.taskCompletionNotifications);
    await prefs.setBool('notif_task_reminders', settings.taskReminders);
    await prefs.setBool('notif_daily_reminders', settings.dailyReminders);
    await prefs.setBool('notif_streak_reminders', settings.streakReminders);
    await prefs.setBool('notif_achievements', settings.achievementNotifications);
    notifyListeners();
  }

  /// Fetch and merge notifications from the online server (Admin Web dispatches & user alerts)
  Future<void> fetchOnlineNotifications() async {
    try {
      final onlineNotifs = await OnlineNotificationService.instance.fetchNotifications();
      if (onlineNotifs.isNotEmpty) {
        final dbHelper = DatabaseHelper.instance;
        bool changed = false;
        for (final n in onlineNotifs) {
          final existingIdx = _notifications.indexWhere((loc) => loc.id == n.id);
          if (existingIdx == -1) {
            _notifications.add(n);
            await dbHelper.saveNotification(n, currentUserId);
            changed = true;
          } else {
            if (_notifications[existingIdx].isRead != n.isRead) {
              _notifications[existingIdx].isRead = n.isRead;
              changed = true;
            }
          }
        }
        if (changed) {
          _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Error syncing online notifications: $e");
    }
  }

  Future<void> markNotificationAsRead(String id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx].isRead = true;
      await DatabaseHelper.instance.markNotificationAsRead(id, currentUserId);
      OnlineNotificationService.instance.markAsRead(id);
      notifyListeners();
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    for (var n in _notifications) {
      n.isRead = true;
    }
    await DatabaseHelper.instance.markAllNotificationsAsRead(currentUserId);
    OnlineNotificationService.instance.markAllAsRead();
    notifyListeners();
  }

  Future<void> clearAllNotifications() async {
    _notifications.clear();
    await DatabaseHelper.instance.clearAllNotifications(currentUserId);
    OnlineNotificationService.instance.markAllAsRead();
    notifyListeners();
  }

  Future<void> updateProfile(String newName, String newAvatarId) async {
    final cleanName = newName.trim();
    if (cleanName.isNotEmpty) {
      _userProfile.username = cleanName;
      _userProfile.avatarId = newAvatarId;
      notifyListeners();

      // 1. Immediately persist to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_username', cleanName);
      await prefs.setString('hero_username', cleanName);
      await prefs.setString('hero_avatar', newAvatarId);

      // 2. Persist to SQLite database
      await _saveProfile();

      // 3. Sync to online backend MySQL database
      try {
        await ApiClient.instance.post('/users/profile.php', body: {
          'username': cleanName,
          'display_name': cleanName,
          'avatar_id': newAvatarId,
        });
      } catch (e) {
        debugPrint("Failed to sync profile update online: $e");
      }
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  void updateProfileImage(String path) {
    _userProfile.profileImagePath = path;
    _saveProfile();
    notifyListeners();
  }

  bool buyReward(String rewardId) {
    final idx = _rewards.indexWhere((r) => r.id == rewardId);
    if (idx != -1) {
      if (_userProfile.gold >= _rewards[idx].cost) {
        _userProfile.gold -= _rewards[idx].cost;
        _saveProfile();
        notifyListeners();
        return true;
      }
    }
    return false;
  }
}
