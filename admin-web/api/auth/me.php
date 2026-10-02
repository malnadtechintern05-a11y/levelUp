<?php
/**
 * Get Authenticated User Profile & Stats Endpoint
 * GET: Bearer Token required
 */

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../middleware/auth.php';

handleCors();

$db = getDB();
$user = requireAuth($db);

$sStmt = $db->prepare("SELECT * FROM user_settings WHERE user_id = ? LIMIT 1");
$sStmt->execute([$user['id']]);
$settings = $sStmt->fetch() ?: [
    'dark_mode' => 1,
    'sound_effects' => 1,
    'selected_alarm_song' => 'fanfare_victory',
];

$skills = json_decode($user['skills_json'] ?? '{}', true) ?: ['Strength' => 50, 'Knowledge' => 50, 'Discipline' => 50];

// Count completed tasks and trophies
$tStmt = $db->prepare("SELECT COUNT(*) FROM task_completions WHERE user_id = ?");
$tStmt->execute([$user['id']]);
$completedCount = (int)$tStmt->fetchColumn();

$aStmt = $db->prepare("SELECT COUNT(*) FROM user_achievements WHERE user_id = ?");
$aStmt->execute([$user['id']]);
$achievementsCount = (int)$aStmt->fetchColumn();

// Determine XP rank
$rStmt = $db->prepare("SELECT COUNT(*) + 1 FROM users WHERE is_active = 1 AND total_xp > ?");
$rStmt->execute([$user['total_xp']]);
$rank = (int)$rStmt->fetchColumn();

sendJson(200, [
    'status' => 'success',
    'user' => [
        'id' => (int)$user['id'],
        'username' => $user['username'],
        'display_name' => $user['display_name'] ?: $user['username'],
        'email' => $user['email'],
        'avatar_id' => $user['avatar_id'] ?: 'hero1',
        'profile_image_path' => $user['profile_image_path'],
        'level' => (int)$user['level'],
        'total_xp' => (int)$user['total_xp'],
        'gold' => (int)$user['gold'],
        'current_streak' => (int)$user['current_streak'],
        'best_streak' => (int)$user['best_streak'],
        'completed_tasks_count' => $completedCount,
        'achievements_count' => $achievementsCount,
        'rank' => $rank,
        'skills' => $skills,
        'show_on_leaderboard' => (int)$user['show_on_leaderboard'],
        'hydration_current_streak' => (int)$user['hydration_current_streak'],
        'hydration_best_streak' => (int)$user['hydration_best_streak'],
        'last_hydration_date' => $user['last_hydration_date'],
    ],
    'settings' => [
        'dark_mode' => (bool)$settings['dark_mode'],
        'sound_effects' => (bool)$settings['sound_effects'],
        'selected_alarm_song' => $settings['selected_alarm_song'] ?? 'fanfare_victory',
    ]
]);
