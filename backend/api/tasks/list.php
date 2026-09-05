<?php
/**
 * List Tasks for Authenticated User Endpoint
 * GET: Bearer Token required
 * Optional query params: ?date=YYYY-MM-DD, ?category=Fitness
 */

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../middleware/auth.php';

handleCors();

$db = getDB();
$user = getOptionalAuth($db);

$userId = null;
if ($user) {
    $userId = (int)$user['id'];
} elseif (!empty($_GET['user_id'])) {
    $userId = (int)$_GET['user_id'];
} elseif (!empty($_GET['username'])) {
    $uStmt = $db->prepare("SELECT id FROM users WHERE username = ? LIMIT 1");
    $uStmt->execute([$_GET['username']]);
    $userId = $uStmt->fetchColumn() ? (int)$uStmt->fetchColumn() : null;
}

$date = $_GET['date'] ?? null;
$category = $_GET['category'] ?? null;

$params = [];
if ($userId !== null) {
    $query = "
        SELECT *
        FROM tasks
        WHERE (user_id = ? OR assigned_user_id = ? OR user_id IS NULL) AND is_active = 1
    ";
    $params[] = $userId;
    $params[] = $userId;
} else {
    $query = "
        SELECT *
        FROM tasks
        WHERE is_active = 1
    ";
}

if (!empty($date)) {
    $query .= " AND (scheduled_date = ? OR scheduled_date IS NULL)";
    $params[] = $date;
}
if (!empty($category) && $category !== 'All') {
    $query .= " AND category = ?";
    $params[] = $category;
}

$query .= " ORDER BY scheduled_date ASC, id ASC";

$stmt = $db->prepare($query);
$stmt->execute($params);
$tasks = $stmt->fetchAll();

$formatted = [];
foreach ($tasks as $t) {
    // Check if task is scheduled for future
    $isFuture = strtotime($t['scheduled_date']) > strtotime(date('Y-m-d'));

    $formatted[] = [
        'id' => $t['id'],
        'title' => $t['title'],
        'description' => $t['description'] ?? '',
        'category' => $t['category'] ?? 'Personal',
        'xp_reward' => (int)$t['xp_reward'],
        'is_completed' => (bool)$t['is_completed'],
        'scheduled_date' => $t['scheduled_date'],
        'scheduled_time' => $t['scheduled_time'],
        'duration_minutes' => (int)$t['duration_minutes'],
        'time_spent_seconds' => (int)$t['time_spent_seconds'],
        'timer_status' => $t['timer_status'] ?? 'Not Started',
        'task_type' => $t['task_type'] ?? 'normal',
        'water_goal_ml' => (int)$t['water_goal_ml'],
        'current_water_ml' => (int)$t['current_water_ml'],
        'is_future' => $isFuture,
    ];
}

sendJson(200, [
    'status' => 'success',
    'total' => count($formatted),
    'data' => $formatted
]);
