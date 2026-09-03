<?php
/**
 * Notifications Endpoint
 * GET: Bearer Token required
 * POST: mark read
 */

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../middleware/auth.php';

handleCors();

$db = getDB();
$user = requireAuth($db);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = getJsonBody();
    $notifId = trim($input['id'] ?? '');
    if (!empty($notifId)) {
        $uStmt = $db->prepare("UPDATE notifications SET is_read = 1 WHERE id = ? AND (target_user_id = ? OR target_user_id IS NULL)");
        $uStmt->execute([$notifId, $user['id']]);
    } else {
        // Mark all read
        $uStmt = $db->prepare("UPDATE notifications SET is_read = 1 WHERE (target_user_id = ? OR target_user_id IS NULL)");
        $uStmt->execute([$user['id']]);
    }
    sendJson(200, ['status' => 'success', 'message' => 'Notifications updated.']);
}

$stmt = $db->prepare("
    SELECT id, title, message, category, type, is_read, created_at
    FROM notifications
    WHERE target_user_id = ? OR target_user_id IS NULL
    ORDER BY created_at DESC
    LIMIT 50
");
$stmt->execute([$user['id']]);
$notifications = $stmt->fetchAll();

sendJson(200, [
    'status' => 'success',
    'total' => count($notifications),
    'unread_count' => count(array_filter($notifications, fn($n) => (int)$n['is_read'] === 0)),
    'data' => $notifications
]);
