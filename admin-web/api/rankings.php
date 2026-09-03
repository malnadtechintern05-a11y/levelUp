<?php
/**
 * LevelUp (Real-Life RPG) - Public Rankings & Leaderboard REST API
 * Exposes safe, public leaderboard endpoints for Flutter Mobile & Web clients.
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . '/../config/database.php';

try {
    $db = getDB();
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Database connection failed']);
    exit;
}

$action = $_GET['action'] ?? 'rankings';
$type = $_GET['type'] ?? 'xp'; // xp, level, quests, streak, achievements
$period = $_GET['period'] ?? 'all'; // all, today, week, month
$limit = min(100, max(1, (int)($_GET['limit'] ?? 50)));
$offset = max(0, (int)($_GET['offset'] ?? 0));

// 1. Single Player Public Profile Endpoint
if ($action === 'public-profile') {
    $userId = (int)($_GET['id'] ?? 0);
    if ($userId <= 0) {
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'Invalid user ID']);
        exit;
    }

    $stmt = $db->prepare("
        SELECT id, username, avatar_id, level, total_xp, gold, current_streak, best_streak, skills_json, created_at
        FROM users 
        WHERE id = ? AND is_active = 1
    ");
    $stmt->execute([$userId]);
    $user = $stmt->fetch();

    if (!$user) {
        http_response_code(404);
        echo json_encode(['status' => 'error', 'message' => 'Hero not found or inactive']);
        exit;
    }

    // Count completed tasks and trophies
    $tStmt = $db->prepare("SELECT COUNT(*) FROM task_completions WHERE user_id = ?");
    $tStmt->execute([$userId]);
    $completedTasks = (int)$tStmt->fetchColumn();

    $aStmt = $db->prepare("SELECT COUNT(*) FROM user_achievements WHERE user_id = ?");
    $aStmt->execute([$userId]);
    $achievementsCount = (int)$aStmt->fetchColumn();

    // Determine XP Rank
    $rStmt = $db->prepare("SELECT COUNT(*) + 1 FROM users WHERE is_active = 1 AND total_xp > ?");
    $rStmt->execute([$user['total_xp']]);
    $rank = (int)$rStmt->fetchColumn();

    $skills = json_decode($user['skills_json'] ?? '{}', true) ?: ['Strength' => 50, 'Knowledge' => 50, 'Discipline' => 50];

    echo json_encode([
        'status' => 'success',
        'data' => [
            'id' => (int)$user['id'],
            'username' => $user['username'],
            'avatar_id' => $user['avatar_id'],
            'level' => (int)$user['level'],
            'total_xp' => (int)$user['total_xp'],
            'current_streak' => (int)$user['current_streak'],
            'best_streak' => (int)$user['best_streak'],
            'completed_tasks' => $completedTasks,
            'achievements_count' => $achievementsCount,
            'rank' => $rank,
            'skills' => $skills,
            'joined_date' => date('M Y', strtotime($user['created_at']))
        ]
    ]);
    exit;
}

// 2. Rankings List Endpoint
$dateCondition = '';
if ($period === 'today') {
    $dateCondition = "AND tc.completed_at >= CURDATE()";
} elseif ($period === 'week') {
    $dateCondition = "AND tc.completed_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)";
} elseif ($period === 'month') {
    $dateCondition = "AND tc.completed_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)";
}

// Build query based on ranking type
if ($type === 'quests') {
    $query = "
        SELECT u.id, u.username, u.avatar_id, u.level, u.total_xp, u.current_streak,
               COUNT(tc.id) as metric_score,
               (SELECT COUNT(*) FROM user_achievements ua WHERE ua.user_id = u.id) as achievements_count,
               COUNT(tc.id) as completed_tasks
        FROM users u
        LEFT JOIN task_completions tc ON u.id = tc.user_id $dateCondition
        WHERE u.is_active = 1
        GROUP BY u.id
        ORDER BY metric_score DESC, u.total_xp DESC
        LIMIT $limit OFFSET $offset
    ";
} elseif ($type === 'level') {
    $query = "
        SELECT u.id, u.username, u.avatar_id, u.level, u.total_xp, u.current_streak,
               u.level as metric_score,
               (SELECT COUNT(*) FROM task_completions tc WHERE tc.user_id = u.id) as completed_tasks,
               (SELECT COUNT(*) FROM user_achievements ua WHERE ua.user_id = u.id) as achievements_count
        FROM users u
        WHERE u.is_active = 1
        ORDER BY u.level DESC, u.total_xp DESC
        LIMIT $limit OFFSET $offset
    ";
} elseif ($type === 'streak') {
    $query = "
        SELECT u.id, u.username, u.avatar_id, u.level, u.total_xp, u.current_streak,
               u.current_streak as metric_score,
               (SELECT COUNT(*) FROM task_completions tc WHERE tc.user_id = u.id) as completed_tasks,
               (SELECT COUNT(*) FROM user_achievements ua WHERE ua.user_id = u.id) as achievements_count
        FROM users u
        WHERE u.is_active = 1
        ORDER BY u.current_streak DESC, u.total_xp DESC
        LIMIT $limit OFFSET $offset
    ";
} elseif ($type === 'achievements') {
    $query = "
        SELECT u.id, u.username, u.avatar_id, u.level, u.total_xp, u.current_streak,
               COUNT(ua.id) as metric_score,
               (SELECT COUNT(*) FROM task_completions tc WHERE tc.user_id = u.id) as completed_tasks,
               COUNT(ua.id) as achievements_count
        FROM users u
        LEFT JOIN user_achievements ua ON u.id = ua.user_id
        WHERE u.is_active = 1
        GROUP BY u.id
        ORDER BY metric_score DESC, u.total_xp DESC
        LIMIT $limit OFFSET $offset
    ";
} else {
    // Default XP Ranking
    if (!empty($dateCondition)) {
        // Range XP earned
        $query = "
            SELECT u.id, u.username, u.avatar_id, u.level, u.total_xp, u.current_streak,
                   COALESCE(SUM(tc.xp_awarded), 0) as metric_score,
                   (SELECT COUNT(*) FROM task_completions tc2 WHERE tc2.user_id = u.id) as completed_tasks,
                   (SELECT COUNT(*) FROM user_achievements ua WHERE ua.user_id = u.id) as achievements_count
            FROM users u
            LEFT JOIN task_completions tc ON u.id = tc.user_id $dateCondition
            WHERE u.is_active = 1
            GROUP BY u.id
            ORDER BY metric_score DESC, u.total_xp DESC
            LIMIT $limit OFFSET $offset
        ";
    } else {
        $query = "
            SELECT u.id, u.username, u.avatar_id, u.level, u.total_xp, u.current_streak,
                   u.total_xp as metric_score,
                   (SELECT COUNT(*) FROM task_completions tc WHERE tc.user_id = u.id) as completed_tasks,
                   (SELECT COUNT(*) FROM user_achievements ua WHERE ua.user_id = u.id) as achievements_count
            FROM users u
            WHERE u.is_active = 1
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

    $players[] = [
        'id' => (int)$row['id'],
        'rank' => $rank++,
        'username' => $row['username'],
        'avatar_id' => $row['avatar_id'] ?: 'hero1',
        'level' => (int)$row['level'],
        'total_xp' => (int)$row['total_xp'],
        'completed_tasks' => (int)$row['completed_tasks'],
        'current_streak' => (int)$row['current_streak'],
        'achievements_count' => (int)$row['achievements_count'],
        'metric_score' => (int)$row['metric_score'],
        'display_score' => $displayScore,
        'rank_movement' => null // Real historical rank movement (null = hide)
    ];
}

echo json_encode([
    'status' => 'success',
    'type' => $type,
    'period' => $period,
    'total_returned' => count($players),
    'data' => $players
]);
