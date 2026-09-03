<?php
/**
 * LevelUp Web Admin Panel - Authentication & CSRF Protection
 */

if (session_status() === PHP_SESSION_NONE) {
    // Session hardening parameters
    ini_set('session.cookie_httponly', '1');
    ini_set('session.use_only_cookies', '1');
    session_start();
}

require_once __DIR__ . '/../config/database.php';

/**
 * Check if the admin is currently authenticated.
 */
function is_admin_logged_in(): bool {
    return isset($_SESSION['admin_id']) && !empty($_SESSION['admin_id']);
}

/**
 * Enforce authentication for protected admin pages.
 * Redirects to login.php if not authenticated.
 */
function require_admin_auth(): void {
    if (!is_admin_logged_in()) {
        $_SESSION['flash_error'] = "Please log in to access the LevelUp Admin Panel.";
        header("Location: login.php");
        exit;
    }
}

/**
 * Get current logged in admin data.
 */
function get_logged_in_admin(): ?array {
    if (!is_admin_logged_in()) {
        return null;
    }

    try {
        $db = getDB();
        $stmt = $db->prepare("SELECT id, username, email, role, last_login FROM admins WHERE id = ?");
        $stmt->execute([$_SESSION['admin_id']]);
        $admin = $stmt->fetch();
        return $admin ?: null;
    } catch (Exception $e) {
        return null;
    }
}

/**
 * Generate CSRF Token for forms.
 */
function generate_csrf_token(): string {
    if (empty($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf_token'];
}

/**
 * Verify CSRF Token from POST requests.
 */
function verify_csrf_token(?string $token): bool {
    if (empty($_SESSION['csrf_token']) || empty($token)) {
        return false;
    }
    return hash_equals($_SESSION['csrf_token'], $token);
}

/**
 * Output hidden CSRF token input field.
 */
function csrf_field(): void {
    echo '<input type="hidden" name="csrf_token" value="' . htmlspecialchars(generate_csrf_token(), ENT_QUOTES, 'UTF-8') . '">';
}
