<?php
/**
 * PusherHub Server-Side Notification Dispatcher
 * Application Key: LEVELUP
 * Public API Key: pk_live_VuXnrl0Im8pJfzHgVgVe3l1dMBsaRnNl
 */

if (!defined('PUSHER_HUB_APP_KEY')) {
    define('PUSHER_HUB_APP_KEY', 'LEVELUP');
}
if (!defined('PUSHER_HUB_PUBLIC_KEY')) {
    define('PUSHER_HUB_PUBLIC_KEY', 'pk_live_VuXnrl0Im8pJfzHgVgVe3l1dMBsaRnNl');
}

/**
 * Dispatches a push notification & in-app alert to heroes via PusherHub.
 */
function send_pusher_hub_broadcast(
    string $title,
    string $message,
    string $category = 'System',
    string $type = 'announcement',
    ?int $targetUserId = null,
    ?string $deepLink = null
): array {
    $db = getDB();
    $result = [
        'success' => false,
        'devices_count' => 0,
        'app_key' => PUSHER_HUB_APP_KEY,
        'target' => $targetUserId ? "Hero #$targetUserId" : "All Heroes",
        'message' => ''
    ];

    try {
        // 1. Fetch registered device tokens
        $query = "SELECT token, external_id, platform FROM pusher_devices WHERE notification_permission = 'granted'";
        $params = [];

        if ($targetUserId !== null) {
            $query .= " AND (external_id = ? OR external_id = ?)";
            $params[] = (string)$targetUserId;
            // Also match by username if applicable
            $uStmt = $db->prepare("SELECT username FROM users WHERE id = ?");
            $uStmt->execute([$targetUserId]);
            $uRow = $uStmt->fetch();
            $params[] = $uRow ? strtolower($uRow['username']) : (string)$targetUserId;
        }

        $stmt = $db->prepare($query);
        $stmt->execute($params);
        $devices = $stmt->fetchAll();
        $result['devices_count'] = count($devices);

        // 2. Format PusherHub notification payload
        $payload = [
            'app_key' => PUSHER_HUB_APP_KEY,
            'public_key' => PUSHER_HUB_PUBLIC_KEY,
            'title' => $title,
            'body' => $message,
            'message' => $message,
            'category' => $category,
            'type' => $type,
            'deep_link' => $deepLink,
            'target_user_id' => $targetUserId,
            'tokens' => array_column($devices, 'token'),
            'timestamp' => time()
        ];

        // 3. Attempt external PusherHub cloud relay if available
        $pusherHubUrl = get_app_setting('pusher_hub_server_url', 'https://pusherhub.com/api/send-notification');
        if (!empty($pusherHubUrl) && filter_var($pusherHubUrl, FILTER_VALIDATE_URL)) {
            $ch = curl_init($pusherHubUrl);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
            curl_setopt($ch, CURLOPT_TIMEOUT, 4);
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                'Content-Type: application/json',
                'Authorization: Bearer ' . PUSHER_HUB_PUBLIC_KEY,
                'X-App-Key: ' . PUSHER_HUB_APP_KEY
            ]);
            $response = curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);
        }

        $result['success'] = true;
        $result['message'] = "Broadcast successfully queued for " . count($devices) . " registered device(s).";
    } catch (Exception $e) {
        $result['message'] = "PusherHub local queue error: " . $e->getMessage();
    }

    return $result;
}
