<?php
/**
 * LevelUp Web Admin Panel - General Helper Functions
 */

require_once __DIR__ . '/../config/database.php';

/**
 * Escape string for HTML output (XSS protection).
 */
function e(?string $string): string {
    return htmlspecialchars($string ?? '', ENT_QUOTES, 'UTF-8');
}

/**
 * Set a session flash message (success, danger, warning, info).
 */
function set_flash(string $type, string $message): void {
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }
    $_SESSION['flash_' . $type] = $message;
}

/**
 * Display any pending session flash messages as Bootstrap alerts.
 */
function display_flash_messages(): void {
    $types = ['success', 'danger', 'warning', 'info', 'error'];
    foreach ($types as $type) {
        $sessionKey = 'flash_' . $type;
        if (isset($_SESSION[$sessionKey])) {
            $alertClass = ($type === 'error') ? 'danger' : $type;
            $icon = match($type) {
                'success' => 'bi-check-circle-fill',
                'danger', 'error' => 'bi-exclamation-triangle-fill',
                'warning' => 'bi-exclamation-circle-fill',
                default => 'bi-info-circle-fill',
            };
            echo '<div class="alert alert-' . $alertClass . ' alert-dismissible fade show shadow-sm" role="alert">';
            echo '  <i class="bi ' . $icon . ' me-2"></i>';
            echo e($_SESSION[$sessionKey]);
            echo '  <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>';
            echo '</div>';
            unset($_SESSION[$sessionKey]);
        }
    }
}

/**
 * Insert an activity log into the database.
 */
function log_activity(?int $userId, ?int $adminId, string $activityType, string $description): bool {
    try {
        $db = getDB();
        $stmt = $db->prepare("INSERT INTO activity_logs (user_id, admin_id, activity_type, description, created_at) VALUES (?, ?, ?, ?, NOW())");
        return $stmt->execute([$userId, $adminId, $activityType, $description]);
    } catch (Exception $e) {
        error_log("Failed to log activity: " . $e->getMessage());
        return false;
    }
}

/**
 * Calculate XP required for next level in LevelUp.
 * LevelUp formula: Next level requirement is level * 200 XP.
 */
function xp_for_level(int $level): int {
    return max(1, $level) * 200;
}

/**
 * Calculate percentage progress towards next level.
 */
function calculate_level_progress(int $level, int $totalXp): array {
    $needed = xp_for_level($level);
    // Approximate progress within current tier:
    $currentTierXp = $totalXp % $needed;
    $percent = min(100, max(0, round(($currentTierXp / $needed) * 100)));
    return [
        'needed_xp' => $needed,
        'current_in_tier' => $currentTierXp,
        'percentage' => $percent,
    ];
}

/**
 * Convert datetime string to human friendly "time ago".
 */
function time_ago(?string $datetime): string {
    if (empty($datetime)) return 'Never';
    $time = strtotime($datetime);
    if (!$time) return 'N/A';

    $diff = time() - $time;
    if ($diff < 60) return 'Just now';
    if ($diff < 3600) {
        $m = floor($diff / 60);
        return $m . 'm ago';
    }
    if ($diff < 86400) {
        $h = floor($diff / 3600);
        return $h . 'h ago';
    }
    if ($diff < 2592000) {
        $d = floor($diff / 86400);
        return $d . 'd ago';
    }
    return date('M j, Y', $time);
}

/**
 * Fetch all application settings as key-value pairs.
 */
function get_app_settings(): array {
    try {
        $db = getDB();
        $stmt = $db->query("SELECT setting_key, setting_value FROM app_settings");
        $results = $stmt->fetchAll(PDO::FETCH_KEY_PAIR);
        return $results ?: [];
    } catch (Exception $e) {
        return [];
    }
}

/**
 * Fetch a single application setting.
 */
function get_app_setting(string $key, $default = null) {
    $settings = get_app_settings();
    return $settings[$key] ?? $default;
}

/**
 * Create a new notification.
 */
function create_notification(string $title, string $message, string $category = 'System', string $type = 'announcement', ?int $targetUserId = null): bool {
    try {
        $db = getDB();
        $id = 'notif_' . bin2hex(random_bytes(8));
        $stmt = $db->prepare("INSERT INTO notifications (id, title, message, category, type, target_user_id, is_read, created_at) VALUES (?, ?, ?, ?, ?, ?, 0, NOW())");
        return $stmt->execute([$id, $title, $message, $category, $type, $targetUserId]);
    } catch (Exception $e) {
        error_log("Failed to create notification: " . $e->getMessage());
        return false;
    }
}
