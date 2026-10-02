<?php
/**
 * PusherHub Device Registration Endpoint
 * Compatible with PusherHub Flutter SDK
 * Registers or updates an FCM token for a device/hero.
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../middleware/auth.php';

handleCors();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJson(405, ['status' => 'error', 'message' => 'Method Not Allowed']);
}

$db = getDB();

// Ensure pusher_devices table exists
$db->exec("
    CREATE TABLE IF NOT EXISTS `pusher_devices` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `app_key` VARCHAR(64) NOT NULL DEFAULT 'LEVELUP',
        `external_id` VARCHAR(100) NOT NULL,
        `token` VARCHAR(255) NOT NULL UNIQUE,
        `platform` VARCHAR(20) DEFAULT 'android',
        `brand` VARCHAR(100) DEFAULT NULL,
        `device` VARCHAR(100) DEFAULT NULL,
        `version` VARCHAR(50) DEFAULT NULL,
        `language` VARCHAR(20) DEFAULT NULL,
        `country` VARCHAR(50) DEFAULT NULL,
        `state` VARCHAR(100) DEFAULT NULL,
        `city` VARCHAR(100) DEFAULT NULL,
        `timezone` VARCHAR(100) DEFAULT NULL,
        `notification_permission` VARCHAR(20) DEFAULT 'granted',
        `last_active_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
        `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX `idx_app_external` (`app_key`, `external_id`),
        INDEX `idx_token` (`token`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
");

$input = getJsonBody();
$appKey = trim($input['app_key'] ?? 'LEVELUP');
$externalId = trim($input['external_id'] ?? 'hero');
$token = trim($input['token'] ?? '');
$previousToken = trim($input['previous_token'] ?? '');
$platform = trim($input['platform'] ?? 'android');
$brand = $input['brand'] ?? null;
$device = $input['device'] ?? null;
$version = $input['version'] ?? null;
$language = $input['language'] ?? null;
$country = $input['country'] ?? null;
$state = $input['state'] ?? null;
$city = $input['city'] ?? null;
$timezone = $input['timezone'] ?? null;
$permission = $input['notification_permission'] ?? 'granted';

if (empty($token)) {
    sendJson(400, ['status' => 'error', 'message' => 'FCM device token is required.']);
}

// If previous token was passed, remove or update it
if (!empty($previousToken) && $previousToken !== $token) {
    $delStmt = $db->prepare("DELETE FROM pusher_devices WHERE token = ?");
    $delStmt->execute([$previousToken]);
}

// Upsert device record
$stmt = $db->prepare("
    INSERT INTO pusher_devices (
        app_key, external_id, token, platform, brand, device, 
        version, language, country, state, city, timezone, 
        notification_permission, last_active_at
    ) VALUES (
        ?, ?, ?, ?, ?, ?, 
        ?, ?, ?, ?, ?, ?, 
        ?, NOW()
    )
    ON DUPLICATE KEY UPDATE 
        app_key = VALUES(app_key),
        external_id = VALUES(external_id),
        platform = VALUES(platform),
        brand = VALUES(brand),
        device = VALUES(device),
        version = VALUES(version),
        language = VALUES(language),
        country = VALUES(country),
        state = VALUES(state),
        city = VALUES(city),
        timezone = VALUES(timezone),
        notification_permission = VALUES(notification_permission),
        last_active_at = NOW()
");

$stmt->execute([
    $appKey,
    $externalId,
    $token,
    $platform,
    $brand,
    $device,
    $version,
    $language,
    $country,
    $state,
    $city,
    $timezone,
    $permission
]);

sendJson(200, [
    'status' => 'success',
    'message' => 'Device registered with PusherHub successfully.',
    'data' => [
        'app_key' => $appKey,
        'external_id' => $externalId,
        'token' => $token,
        'registered_at' => date('Y-m-d H:i:s')
    ]
]);
