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
$user = requireAuth($db);
$userId = (int)$user['id'];

$date = $_GET['date'] ?? null;
$category = $_GET['category'] ?? null;

$params = [$userId, $userId, $userId];
$query = "
    SELECT t.*,
           CASE 
               WHEN t.assigned_user_id IS NOT NULL OR t.user_id IS NOT NULL THEN t.is_completed
               WHEN tc.id IS NOT NULL THEN 1 
               ELSE t.is_completed 
           END AS user_is_completed,
           CASE 
               WHEN tc.id IS NOT NULL THEN 'Completed'
               ELSE t.timer_status 
           END AS user_timer_status
    FROM tasks t
    LEFT JOIN task_completions tc ON tc.task_id = t.id AND tc.user_id = ?
    WHERE (t.user_id = ? OR t.assigned_user_id = ? OR (t.user_id IS NULL AND t.assigned_user_id IS NULL)) 
      AND t.is_active = 1
";

if (!empty($date)) {
    $query .= " AND (t.scheduled_date = ? OR t.scheduled_date IS NULL)";
    $params[] = $date;
}
if (!empty($category) && $category !== 'All') {
    $query .= " AND t.category = ?";
    $params[] = $category;
}

$query .= " ORDER BY t.scheduled_date ASC, t.id ASC";

$stmt = $db->prepare($query);
$stmt->execute($params);
$tasks = $stmt->fetchAll();

$formatted = [];
foreach ($tasks as $t) {
    // Check if task is scheduled for future
    $isFuture = !empty($t['scheduled_date']) && (strtotime($t['scheduled_date']) > strtotime(date('Y-m-d')));
    $isCompleted = (bool)($t['user_is_completed'] ?? $t['is_completed']);

    $formatted[] = [
        'id' => $t['id'],
        'title' => $t['title'],
        'description' => $t['description'] ?? '',
        'category' => $t['category'] ?? 'Personal',
        'xp_reward' => (int)$t['xp_reward'],
        'is_completed' => $isCompleted,
        'scheduled_date' => $t['scheduled_date'],
        'scheduled_time' => $t['scheduled_time'],
        'duration_minutes' => (int)$t['duration_minutes'],
        'time_spent_seconds' => (int)$t['time_spent_seconds'],
        'timer_status' => $isCompleted ? 'Completed' : ($t['user_timer_status'] ?? $t['timer_status'] ?? 'Not Started'),
        'task_type' => $t['task_type'] ?? 'normal',
        'water_goal_ml' => (int)$t['water_goal_ml'],
        'current_water_ml' => (int)$t['current_water_ml'],
        'is_future' => $isFuture,
        'assigned_user_id' => $t['assigned_user_id'] ? (int)$t['assigned_user_id'] : null,
        'is_global' => ($t['user_id'] === null && $t['assigned_user_id'] === null),
    ];
}

sendJson(200, [
    'status' => 'success',
    'total' => count($formatted),
    'data' => $formatted
]);
