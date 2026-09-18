<?php
/**
 * Utility script to reset/set a password for a hero user or admin
 * Usage: php backend/reset_password.php <username_or_email> <new_password>
 */

require_once __DIR__ . '/config/database.php';

$identifier = $argv[1] ?? 'harsha';
$newPassword = $argv[2] ?? 'Harsha123!';

try {
    $db = getDB();
    $hash = password_hash($newPassword, PASSWORD_BCRYPT);

    // Update in users table
    $stmt = $db->prepare("UPDATE users SET password_hash = :hash WHERE username = :id OR email = :id");
    $stmt->execute([':hash' => $hash, ':id' => $identifier]);
    $affectedUsers = $stmt->rowCount();

    // Update in admins table
    $stmtAdmin = $db->prepare("UPDATE admins SET password_hash = :hash WHERE username = :id OR email = :id");
    $stmtAdmin->execute([':hash' => $hash, ':id' => $identifier]);
    $affectedAdmins = $stmtAdmin->rowCount();

    if ($affectedUsers > 0 || $affectedAdmins > 0) {
        echo "SUCCESS: Password for '$identifier' updated to '$newPassword'\n";
    } else {
        echo "NOT FOUND: No user or admin found with username/email '$identifier'\n";
    }
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
