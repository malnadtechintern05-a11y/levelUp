<?php
require_once __DIR__ . '/../config/database.php';

$pdo = getDB();

// Set or create Hero account (matching what the user entered on their screen)
$username = 'Hero';
$email = 'hero@example.com';
$password = 'password123';
$hash = password_hash($password, PASSWORD_BCRYPT);

$stmt = $pdo->prepare("SELECT id FROM users WHERE username = ? OR email = ?");
$stmt->execute([$username, $email]);
$existing = $stmt->fetch();

if ($existing) {
    $update = $pdo->prepare("UPDATE users SET password_hash = ?, is_active = 1 WHERE id = ?");
    $update->execute([$hash, $existing['id']]);
    echo "USER_HERO_UPDATED\n";
} else {
    $insert = $pdo->prepare("
        INSERT INTO users (username, display_name, email, password_hash, avatar_id, level, total_xp, gold, current_streak, best_streak, is_active, show_on_leaderboard)
        VALUES (?, ?, ?, ?, 'hero1', 1, 0, 100, 1, 1, 1, 1)
    ");
    $insert->execute([$username, $username, $email, $hash]);
    echo "USER_HERO_INSERTED\n";
}

// Also ensure harsha_test account is ready
$stmt = $pdo->prepare("UPDATE users SET password_hash = ?, is_active = 1 WHERE username = 'harsha_test'");
$stmt->execute([password_hash('HarshaPass123!', PASSWORD_BCRYPT)]);

echo "ACCOUNTS_READY\n";
