<?php
/**
 * PusherHub Heartbeat Endpoint
 * Updates the last active timestamp of a device.
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../middleware/auth.php';

handleCors();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJson(405, ['status' => 'error', 'message' => 'Method Not Allowed']);
}

$input = getJsonBody();
$token = trim($input['token'] ?? '');
$appKey = trim($input['app_key'] ?? 'LEVELUP');

if (!empty($token)) {
    try {
        $db = getDB();
        $stmt = $db->prepare("UPDATE pusher_devices SET last_active_at = NOW() WHERE token = ?");
        $stmt->execute([$token]);
    } catch (Exception $e) {
        // Silent ignore for heartbeats
    }
}

sendJson(200, [
    'status' => 'success',
    'timestamp' => time()
]);
