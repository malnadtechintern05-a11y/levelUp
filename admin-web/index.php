<?php
/**
 * LevelUp Web Admin Panel - Entry Point
 */
require_once __DIR__ . '/includes/auth.php';

if (is_admin_logged_in()) {
    header("Location: /admin-web/dashboard.php");
} else {
    header("Location: /admin-web/login.php");
}
exit;
