<?php
/**
 * Safe Public Profile Codex Endpoint
 * GET: ?id=123
 * Strictly returns public-safe data. Hides passwords, email, and private tasks.
 */

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../middleware/auth.php';

handleCors();

$db = getDB();

$userId = (int)($_GET['id'] ?? 0);
$username = trim($_GET['username'] ?? '');

if ($userId <= 0 && (empty($username) || $username === 'Hero')) {
    $stmt = $db->query("
        SELECT id, username, display_name, avatar_id, profile_image_path, level, total_xp, gold, current_streak, best_streak, skills_json, created_at, show_on_leaderboard
        FROM users
        WHERE is_active = 1
        ORDER BY id ASC
        LIMIT 1
    ");
    $user = $stmt->fetch();
} elseif ($userId > 0) {
    $stmt = $db->prepare("
        SELECT id, username, display_name, avatar_id, profile_image_path, level, total_xp, gold, current_streak, best_streak, skills_json, created_at, show_on_leaderboard
        FROM users
        WHERE id = ? AND is_active = 1
        LIMIT 1
    ");
    $stmt->execute([$userId]);
    $user = $stmt->fetch();
} else {
    $stmt = $db->prepare("
        SELECT id, username, display_name, avatar_id, profile_image_path, level, total_xp, gold, current_streak, best_streak, skills_json, created_at, show_on_leaderboard
        FROM users
        WHERE username = ? AND is_active = 1
        LIMIT 1
    ");
    $stmt->execute([$username]);
    $user = $stmt->fetch();
}

if (!$user) {
    sendJson(404, ['status' => 'error', 'message' => 'Hero not found or inactive.']);
}

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

$skills = json_decode($user['skills_json'] ?? '{}', true) ?: ['Strength' => 50, 'Knowledge' => 50, 'Discipline' => 50];

sendJson(200, [
    'status' => 'success',
    'data' => [
        'id' => (int)$user['id'],
        'username' => $user['username'],
        'display_name' => $user['display_name'] ?: $user['username'],
        'avatar_id' => $user['avatar_id'] ?: 'hero1',
        'level' => (int)$user['level'],
        'total_xp' => (int)$user['total_xp'],
        'rank' => $rank,
        'completed_tasks' => $completedCount,
        'current_streak' => (int)$user['current_streak'],
        'best_streak' => (int)$user['best_streak'],
        'achievements_count' => $achievementsCount,
        'skills' => $skills,
        'joined_date' => date('M Y', strtotime($user['created_at'])),
        'show_on_leaderboard' => (int)$user['show_on_leaderboard'],
    ]
]);
