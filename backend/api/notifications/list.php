<?php
/**
 * Notifications Endpoint
 * GET: Returns notifications for current user and global realm broadcasts
 * POST: Mark single or all notifications read
 */

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../middleware/auth.php';

handleCors();

$db = getDB();
$user = getOptionalAuth($db);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = getJsonBody();
    $notifId = trim($input['id'] ?? '');
    $userId = $user['id'] ?? null;

    if (!empty($notifId)) {
        if ($userId) {
            $uStmt = $db->prepare("UPDATE notifications SET is_read = 1 WHERE id = ? AND (target_user_id = ? OR target_user_id IS NULL OR target_user_id = 0)");
            $uStmt->execute([$notifId, $userId]);
        } else {
            $uStmt = $db->prepare("UPDATE notifications SET is_read = 1 WHERE id = ?");
            $uStmt->execute([$notifId]);
        }
    } else {
        // Mark all read
        if ($userId) {
            $uStmt = $db->prepare("UPDATE notifications SET is_read = 1 WHERE (target_user_id = ? OR target_user_id IS NULL OR target_user_id = 0)");
            $uStmt->execute([$userId]);
        } else {
            $uStmt = $db->prepare("UPDATE notifications SET is_read = 1 WHERE target_user_id IS NULL OR target_user_id = 0");
            $uStmt->execute();
        }
    }
    sendJson(200, ['status' => 'success', 'message' => 'Notifications updated.']);
}

if ($user) {
    $stmt = $db->prepare("
        SELECT id, title, message, category, type, is_read, created_at
        FROM notifications
        WHERE target_user_id = ? OR target_user_id IS NULL OR target_user_id = 0
        ORDER BY created_at DESC
        LIMIT 50
    ");
    $stmt->execute([$user['id']]);
} else {
    $stmt = $db->prepare("
        SELECT id, title, message, category, type, is_read, created_at
        FROM notifications
        WHERE target_user_id IS NULL OR target_user_id = 0
        ORDER BY created_at DESC
        LIMIT 50
    ");
    $stmt->execute();
}

$notifications = $stmt->fetchAll();

sendJson(200, [
    'status' => 'success',
    'total' => count($notifications),
    'unread_count' => count(array_filter($notifications, fn($n) => (int)$n['is_read'] === 0)),
    'data' => $notifications
]);

