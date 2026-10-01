<?php
/**
 * PusherHub In-App Messages Fetch Endpoint
 * Returns recent active announcements / notifications for the device.
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../middleware/auth.php';

handleCors();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJson(405, ['status' => 'error', 'message' => 'Method Not Allowed']);
}

$db = getDB();
$input = getJsonBody();
$token = trim($input['token'] ?? '');
$appKey = trim($input['app_key'] ?? 'LEVELUP');

$externalId = null;
if (!empty($token)) {
    $dStmt = $db->prepare("SELECT external_id FROM pusher_devices WHERE token = ? LIMIT 1");
    $dStmt->execute([$token]);
    $dev = $dStmt->fetch();
    if ($dev) {
        $externalId = $dev['external_id'];
    }
}

// Fetch recent unread or broadcast notifications from the last 7 days
$where = "WHERE n.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)";
$params = [];

if (!empty($externalId) && is_numeric($externalId)) {
    $where .= " AND (n.target_user_id = ? OR n.target_user_id IS NULL)";
    $params[] = (int)$externalId;
} else {
    $where .= " AND n.target_user_id IS NULL";
}

$stmt = $db->prepare("
    SELECT n.*
    FROM notifications n
    $where
    ORDER BY n.created_at DESC
    LIMIT 10
");
$stmt->execute($params);
$notifs = $stmt->fetchAll();

$messages = [];
$counter = 1;

foreach ($notifs as $n) {
    // Generate a consistent integer ID
    $intId = crc32($n['id']) & 0x7FFFFFFF;
    if ($intId === 0) $intId = $counter++;

    $category = $n['category'] ?? 'System';
    $bgColor = ($category === 'Quest' || $category === 'Reward') ? '#1E293B' : '#0F172A';

    $messages[] = [
        'id' => $intId,
        'type' => 'modal',
        'content_mode' => 'simple',
        'heading' => $n['title'],
        'body' => $n['message'],
        'button_text' => 'Acknowledge',
        'button_deep_link' => null,
        'background_color' => $bgColor,
        'text_color' => '#FFFFFF',
        'show_close_button' => true,
        'padding' => 20.0,
        'dismiss_after_seconds' => 15,
        'custom_data' => [
            'notification_id' => $n['id'],
            'category' => $category,
            'type' => $n['type'] ?? 'announcement',
            'created_at' => $n['created_at']
        ]
    ];
}

sendJson(200, [
    'status' => 'success',
    'messages' => $messages
]);
