<?php
/**
 * Social / Multi-Provider & Guest Login Endpoint
 * POST: provider (google, apple, microsoft, guest), username, email (optional), display_name (optional), avatar_id (optional)
 */

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../middleware/auth.php';

handleCors();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJson(405, ['status' => 'error', 'message' => 'Method Not Allowed']);
}

$db = getDB();
$input = getJsonBody();

$provider = trim(strtolower($input['provider'] ?? 'google'));
$rawUsername = trim($input['username'] ?? '');
$email = trim(strtolower($input['email'] ?? ''));
$displayName = trim($input['display_name'] ?? '');
$avatarId = trim($input['avatar_id'] ?? 'hero1');

// Generate safe fallback values if not provided
if (empty($rawUsername)) {
    $rawUsername = ucfirst($provider) . '_Hero_' . substr(bin2hex(random_bytes(3)), 0, 5);
}

// Clean username characters
$cleanUsername = preg_replace('/[^a-zA-Z0-9_-]/', '_', $rawUsername);
if (strlen($cleanUsername) < 3) {
    $cleanUsername .= '_hero';
}

if (empty($email)) {
    $email = strtolower($cleanUsername) . '@' . $provider . '.levelup.com';
}

if (empty($displayName)) {
    $displayName = ucwords(str_replace(['_', '-'], ' ', $cleanUsername));
}

try {
    $db->beginTransaction();

    // 1. Check if user already exists by email or username
    $checkStmt = $db->prepare("SELECT * FROM users WHERE email = ? OR username = ? LIMIT 1");
    $checkStmt->execute([$email, $cleanUsername]);
    $user = $checkStmt->fetch();

    if (!$user) {
        // Ensure username uniqueness
        $uCheck = $db->prepare("SELECT id FROM users WHERE username = ? LIMIT 1");
        $uCheck->execute([$cleanUsername]);
        if ($uCheck->fetch()) {
            $cleanUsername = $cleanUsername . '_' . rand(100, 999);
        }

        // Dummy hash for social users
        $passwordHash = password_hash(bin2hex(random_bytes(16)), PASSWORD_BCRYPT);
        $defaultSkills = json_encode(['Strength' => 50, 'Knowledge' => 50, 'Discipline' => 50]);

        // Insert user into MySQL users table so they appear in Admin Web Panel immediately
        $insertStmt = $db->prepare("
            INSERT INTO users (
                username, display_name, email, password_hash, avatar_id, 
                level, total_xp, gold, current_streak, best_streak, 
                skills_json, is_active, show_on_leaderboard, created_at, updated_at
            ) VALUES (
                ?, ?, ?, ?, ?, 
                1, 0, 100, 0, 0, 
                ?, 1, 1, NOW(), NOW()
            )
        ");
        $insertStmt->execute([$cleanUsername, $displayName, $email, $passwordHash, $avatarId, $defaultSkills]);
        $userId = (int)$db->lastInsertId();

        // Create default settings
        $settingsStmt = $db->prepare("
            INSERT INTO user_settings (user_id, dark_mode, sound_effects, selected_alarm_song, task_notifications, achievement_notifications, daily_reminders, streak_reminders)
            VALUES (?, 1, 1, 'fanfare_victory', 1, 1, 1, 1)
        ");
        $settingsStmt->execute([$userId]);

        // Create initial notification
        $notifId = 'notif_' . time() . '_' . rand(100, 999);
        $notifStmt = $db->prepare("
            INSERT INTO notifications (id, title, message, category, type, target_user_id, is_read, created_at)
            VALUES (?, 'Welcome to LevelUp, Hero!', 'Your epic real-life RPG adventure begins now. Complete daily quests, earn XP, level up, and conquer your goals!', 'System', 'announcement', ?, 0, NOW())
        ");
        $notifStmt->execute([$notifId, $userId]);

        // Log in activity logs for Admin Panel
        $logStmt = $db->prepare("
            INSERT INTO activity_logs (user_id, activity_type, description, created_at)
            VALUES (?, 'user_registered', ?, NOW())
        ");
        $logStmt->execute([$userId, "Hero '$cleanUsername' joined the realm via " . ucfirst($provider) . "!"]);

        // Fetch newly created user
        $fStmt = $db->prepare("SELECT * FROM users WHERE id = ?");
        $fStmt->execute([$userId]);
        $user = $fStmt->fetch();
    }

    if ((int)$user['is_active'] !== 1) {
        $db->rollBack();
        sendJson(403, [
            'status' => 'error',
            'code' => 'ACCOUNT_DISABLED',
            'message' => 'Your hero account has been deactivated by an administrator.'
        ]);
    }

    // 2. Generate 30-day session token
    $token = bin2hex(random_bytes(32));
    $expiresAt = date('Y-m-d H:i:s', strtotime('+30 days'));

    $tokenStmt = $db->prepare("
        INSERT INTO user_tokens (user_id, token, expires_at)
        VALUES (?, ?, ?)
    ");
    $tokenStmt->execute([$user['id'], $token, $expiresAt]);

    $db->commit();

    $skills = json_decode($user['skills_json'] ?? '{}', true) ?: ['Strength' => 50, 'Knowledge' => 50, 'Discipline' => 50];
    
    // Safe role resolution: verify against database role and admins table
    $role = 'user';
    if (!empty($user['role']) && strtolower($user['role']) === 'admin') {
        $role = 'admin';
    } else {
        $adminCheck = $db->prepare("SELECT id, role FROM admins WHERE email = ? OR username = ? LIMIT 1");
        $adminCheck->execute([$user['email'] ?? '', $user['username']]);
        $adminRow = $adminCheck->fetch();
        if ($adminRow) {
            $role = $adminRow['role'] ?: 'admin';
        }
    }

    sendJson(200, [
        'status' => 'success',
        'message' => 'Authenticated successfully with ' . ucfirst($provider) . '!',
        'token' => $token,
        'expires_at' => $expiresAt,
        'user' => [
            'id' => (int)$user['id'],
            'username' => $user['username'],
            'display_name' => $user['display_name'] ?: $user['username'],
            'email' => $user['email'],
            'avatar_id' => $user['avatar_id'] ?: 'hero1',
            'level' => (int)$user['level'],
            'total_xp' => (int)$user['total_xp'],
            'gold' => (int)$user['gold'],
            'current_streak' => (int)$user['current_streak'],
            'best_streak' => (int)$user['best_streak'],
            'skills' => $skills,
            'role' => $role,
            'is_admin' => $role === 'admin' ? 1 : 0,
        ]
    ]);

} catch (Exception $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    sendJson(500, [
        'status' => 'error',
        'message' => 'Social authentication failed: ' . $e->getMessage()
    ]);
}
