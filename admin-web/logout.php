<?php
/**
 * LevelUp Web Admin Panel - Secure Logout
 */
require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/functions.php';

if (is_admin_logged_in()) {
    $adminId = $_SESSION['admin_id'] ?? null;
    $username = $_SESSION['admin_username'] ?? 'Admin';
    log_activity(null, $adminId, 'admin_logout', "Admin '{$username}' logged out");
}

// Clear all session variables
$_SESSION = [];

// Destroy session cookie if set
if (ini_get("session.use_cookies")) {
    $params = session_get_cookie_params();
    setcookie(session_name(), '', time() - 42000,
        $params["path"], $params["domain"],
        $params["secure"], $params["httponly"]
    );
}

// Destroy session
session_destroy();

// Start new session to flash message
session_start();
set_flash('info', 'You have been successfully logged out.');
header("Location: login.php");
exit;
