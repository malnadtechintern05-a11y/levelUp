<?php
/**
 * Delete / Archive Task Endpoint
 * POST: task_id
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

$taskId = trim($input['task_id'] ?? $input['id'] ?? '');

if (empty($taskId)) {
    sendJson(422, ['status' => 'error', 'message' => 'Task ID is required.']);
}

$stmt = $db->prepare("
    UPDATE tasks
    SET is_active = 0
    WHERE id = ? AND (user_id = ? OR assigned_user_id = ?)
");
$stmt->execute([$taskId, $user['id'], $user['id']]);

if ($stmt->rowCount() === 0) {
    sendJson(404, ['status' => 'error', 'message' => 'Task not found or does not belong to you.']);
}

sendJson(200, [
    'status' => 'success',
    'message' => 'Quest removed successfully.'
]);
