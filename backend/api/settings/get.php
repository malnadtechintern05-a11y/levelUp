<?php
/**
 * LevelUp API - Get Global Application Settings
 * Includes hero banner image URL, app defaults, and features.
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . '/../../config/database.php';

try {
    $db = getDB();
    $stmt = $db->query("SELECT setting_key, setting_value FROM app_settings");
    $settings = [];
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $settings[$row['setting_key']] = $row['setting_value'];
    }

    $rawBanner = $settings['hero_banner_image'] ?? null;
    $bannerUrl = null;

    if (!empty($rawBanner)) {
        if (str_starts_with($rawBanner, 'http://') || str_starts_with($rawBanner, 'https://')) {
            $bannerUrl = $rawBanner;
        } else {
            // Build full URL based on current host & scheme
            $scheme = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on') ? 'https' : 'http';
            $host = $_SERVER['HTTP_HOST'] ?? '127.0.0.1:8080';
            $cleanedPath = ltrim($rawBanner, '/');
            $bannerUrl = "{$scheme}://{$host}/{$cleanedPath}";
        }
    }

    echo json_encode([
        'status' => 'success',
        'settings' => [
            'app_name' => $settings['app_name'] ?? 'LevelUp - Real-Life RPG',
            'app_description' => $settings['app_description'] ?? '',
            'default_xp' => (int)($settings['default_xp'] ?? 50),
            'default_task_duration' => (int)($settings['default_task_duration'] ?? 30),
            'hero_banner_image' => $rawBanner,
            'hero_banner_url' => $bannerUrl,
            'hero_banner_title' => $settings['hero_banner_title'] ?? '',
            'hero_banner_subtitle' => $settings['hero_banner_subtitle'] ?? '',
            'hero_banner_enabled' => ($settings['hero_banner_enabled'] ?? '1') === '1',
            'maintenance_mode' => ($settings['maintenance_mode'] ?? '0') === '1',
            'maintenance_message' => $settings['maintenance_message'] ?? 'LevelUp realm is currently undergoing scheduled upgrades. Please check back shortly!',
            'default_water_goal_ml' => (int)($settings['default_water_goal_ml'] ?? 2500),
            'quote_of_the_day' => $settings['quote_of_the_day'] ?? "You're getting stronger every day! 💪",
            'daily_reminder' => ($settings['daily_reminder'] ?? '1') === '1',
            'achievement_notifications' => ($settings['achievement_notifications'] ?? '1') === '1',
            'task_completion_notifications' => ($settings['task_completion_notifications'] ?? '1') === '1',
            'streak_notifications' => ($settings['streak_notifications'] ?? '1') === '1',
        ]
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => 'Failed to retrieve settings: ' . $e->getMessage()
    ]);
}
