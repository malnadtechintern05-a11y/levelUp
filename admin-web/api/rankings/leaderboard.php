<?php
/**
 * Real Player Rankings / Leaderboard Endpoint
 * GET: ?type=xp|level|quests|streak|achievements &period=all|today|week|month
 * Only shows real users with show_on_leaderboard = 1 and is_active = 1.
 */

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../middleware/auth.php';

handleCors();

$db = getDB();

$token = getBearerToken();
$currentUserId = null;
if ($token) {
    $tStmt = $db->prepare("SELECT user_id FROM user_tokens WHERE token = ? AND expires_at > NOW() LIMIT 1");
    $tStmt->execute([$token]);
    $currentUserId = (int)$tStmt->fetchColumn() ?: null;
}

$type = $_GET['type'] ?? 'xp';
$period = $_GET['period'] ?? 'all';
$limit = min(100, max(1, (int)($_GET['limit'] ?? 50)));
$offset = max(0, (int)($_GET['offset'] ?? 0));

$dateCondition = '';
if ($period === 'today') {
    $dateCondition = "AND tc.completed_at >= CURDATE()";
} elseif ($period === 'week') {
    $dateCondition = "AND tc.completed_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)";
} elseif ($period === 'month') {
    $dateCondition = "AND tc.completed_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)";
}

if ($type === 'quests') {
    $query = "
        SELECT u.id, u.username, u.display_name, u.avatar_id, u.level, u.total_xp, u.current_streak,
               COUNT(tc.id) as metric_score,
               (SELECT COUNT(*) FROM user_achievements ua WHERE ua.user_id = u.id) as achievements_count,
               COUNT(tc.id) as completed_tasks
        FROM users u
        LEFT JOIN task_completions tc ON u.id = tc.user_id $dateCondition
        WHERE u.is_active = 1 AND u.show_on_leaderboard = 1
        GROUP BY u.id
        ORDER BY metric_score DESC, u.total_xp DESC
        LIMIT $limit OFFSET $offset
    ";
} elseif ($type === 'level') {
    $query = "
        SELECT u.id, u.username, u.display_name, u.avatar_id, u.level, u.total_xp, u.current_streak,
               u.level as metric_score,
               (SELECT COUNT(*) FROM task_completions tc WHERE tc.user_id = u.id) as completed_tasks,
               (SELECT COUNT(*) FROM user_achievements ua WHERE ua.user_id = u.id) as achievements_count
        FROM users u
        WHERE u.is_active = 1 AND u.show_on_leaderboard = 1
        ORDER BY u.level DESC, u.total_xp DESC
        LIMIT $limit OFFSET $offset
    ";
} elseif ($type === 'streak') {
    $query = "
        SELECT u.id, u.username, u.display_name, u.avatar_id, u.level, u.total_xp, u.current_streak,
               u.current_streak as metric_score,
               (SELECT COUNT(*) FROM task_completions tc WHERE tc.user_id = u.id) as completed_tasks,
               (SELECT COUNT(*) FROM user_achievements ua WHERE ua.user_id = u.id) as achievements_count
        FROM users u
        WHERE u.is_active = 1 AND u.show_on_leaderboard = 1
        ORDER BY u.current_streak DESC, u.total_xp DESC
        LIMIT $limit OFFSET $offset
    ";
} elseif ($type === 'achievements') {
    $query = "
        SELECT u.id, u.username, u.display_name, u.avatar_id, u.level, u.total_xp, u.current_streak,
               COUNT(ua.id) as metric_score,
               (SELECT COUNT(*) FROM task_completions tc WHERE tc.user_id = u.id) as completed_tasks,
               COUNT(ua.id) as achievements_count
        FROM users u
        LEFT JOIN user_achievements ua ON u.id = ua.user_id
        WHERE u.is_active = 1 AND u.show_on_leaderboard = 1
        GROUP BY u.id
        ORDER BY metric_score DESC, u.total_xp DESC
        LIMIT $limit OFFSET $offset
    ";
} else {
    // Default XP
    if (!empty($dateCondition)) {
        $query = "
            SELECT u.id, u.username, u.display_name, u.avatar_id, u.level, u.total_xp, u.current_streak,
                   COALESCE(SUM(tc.xp_awarded), 0) as metric_score,
                   (SELECT COUNT(*) FROM task_completions tc2 WHERE tc2.user_id = u.id) as completed_tasks,
                   (SELECT COUNT(*) FROM user_achievements ua WHERE ua.user_id = u.id) as achievements_count
            FROM users u
            LEFT JOIN task_completions tc ON u.id = tc.user_id $dateCondition
            WHERE u.is_active = 1 AND u.show_on_leaderboard = 1
            GROUP BY u.id
            ORDER BY metric_score DESC, u.total_xp DESC
            LIMIT $limit OFFSET $offset
        ";
    } else {
        $query = "
            SELECT u.id, u.username, u.display_name, u.avatar_id, u.level, u.total_xp, u.current_streak,
                   u.total_xp as metric_score,
                   (SELECT COUNT(*) FROM task_completions tc WHERE tc.user_id = u.id) as completed_tasks,
                   (SELECT COUNT(*) FROM user_achievements ua WHERE ua.user_id = u.id) as achievements_count
            FROM users u
            WHERE u.is_active = 1 AND u.show_on_leaderboard = 1
            ORDER BY u.total_xp DESC, u.level DESC
            LIMIT $limit OFFSET $offset
        ";
    }
}

$stmt = $db->query($query);
$results = $stmt->fetchAll();

$players = [];
$rank = $offset + 1;

foreach ($results as $row) {
    $displayScore = match($type) {
        'level' => 'Level ' . $row['level'],
        'quests' => number_format($row['metric_score']) . ' Quests',
        'streak' => $row['current_streak'] . ' Day Streak',
        'achievements' => $row['achievements_count'] . ' Trophies',
        default => number_format($row['metric_score']) . ' XP'
    };

    $isMe = $currentUserId !== null && ((int)$row['id'] === $currentUserId);

    $players[] = [
        'id' => (int)$row['id'],
        'rank' => $rank++,
        'username' => $row['display_name'] ?: $row['username'],
        'raw_username' => $row['username'],
        'avatar_id' => $row['avatar_id'] ?: 'hero1',
        'level' => (int)$row['level'],
        'total_xp' => (int)$row['total_xp'],
        'completed_tasks' => (int)$row['completed_tasks'],
        'current_streak' => (int)$row['current_streak'],
        'achievements_count' => (int)$row['achievements_count'],
        'metric_score' => (int)$row['metric_score'],
        'display_score' => $displayScore,
        'rank_movement' => null,
        'is_current_user' => $isMe,
    ];
}

sendJson(200, [
    'status' => 'success',
    'type' => $type,
    'period' => $period,
    'total' => count($players),
    'data' => $players
]);
