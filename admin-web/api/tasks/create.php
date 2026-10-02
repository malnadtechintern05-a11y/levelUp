<?php
/**
 * Create Task Endpoint
 * POST: title, description, category, xp_reward, scheduled_date, scheduled_time, duration_minutes, task_type, water_goal_ml
 */

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../middleware/auth.php';

handleCors();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJson(405, ['status' => 'error', 'message' => 'Method Not Allowed']);
}

$db = getDB();
$user = requireAuth($db);
$input = getJsonBody();

$title = trim($input['title'] ?? '');
$description = trim($input['description'] ?? '');
$category = trim($input['category'] ?? 'Personal');
$xpReward = max(5, min(500, (int)($input['xp_reward'] ?? 50)));
$scheduledDate = trim($input['scheduled_date'] ?? date('Y-m-d'));
$scheduledTime = trim($input['scheduled_time'] ?? date('H:i'));
$durationMinutes = max(0, (int)($input['duration_minutes'] ?? 30));
$taskType = ($input['task_type'] ?? '') === 'hydration' ? 'hydration' : 'normal';
$waterGoalMl = max(500, (int)($input['water_goal_ml'] ?? 2000));

if (empty($title)) {
    sendJson(422, ['status' => 'error', 'message' => 'Quest title is required.']);
}

// Generate unique ID
$taskId = 'task_' . time() . '_' . mt_rand(1000, 9999);

$stmt = $db->prepare("
    INSERT INTO tasks (id, user_id, assigned_user_id, title, description, category, xp_reward, is_completed, scheduled_date, scheduled_time, duration_minutes, timer_status, task_type, water_goal_ml, current_water_ml, is_active)
    VALUES (?, ?, ?, ?, ?, ?, ?, 0, ?, ?, ?, 'Not Started', ?, ?, 0, 1)
");
$stmt->execute([
    $taskId,
    $user['id'],
    $user['id'],
    $title,
    $description,
    $category,
    $xpReward,
    $scheduledDate,
    $scheduledTime,
    $durationMinutes,
    $taskType,
    $waterGoalMl
]);

sendJson(201, [
    'status' => 'success',
    'message' => 'Quest created successfully!',
    'data' => [
        'id' => $taskId,
        'title' => $title,
        'description' => $description,
        'category' => $category,
        'xp_reward' => $xpReward,
        'is_completed' => false,
        'scheduled_date' => $scheduledDate,
        'scheduled_time' => $scheduledTime,
        'duration_minutes' => $durationMinutes,
        'time_spent_seconds' => 0,
        'timer_status' => 'Not Started',
        'task_type' => $taskType,
        'water_goal_ml' => $waterGoalMl,
        'current_water_ml' => 0,
    ]
]);
