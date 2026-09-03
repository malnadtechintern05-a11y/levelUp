<?php
/**
 * Register New Hero Account Endpoint
 * POST: username, email, password, confirm_password, avatar_id (optional)
 */

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../middleware/auth.php';

handleCors();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJson(405, ['status' => 'error', 'message' => 'Method Not Allowed']);
}

$db = getDB();
$input = getJsonBody();

$username = trim($input['username'] ?? '');
$email = trim(strtolower($input['email'] ?? ''));
$password = $input['password'] ?? '';
$confirmPassword = $input['confirm_password'] ?? '';
$avatarId = trim($input['avatar_id'] ?? 'hero1');
$displayName = trim($input['display_name'] ?? $username);

// Validation
$errors = [];
if (empty($username)) {
    $errors[] = 'Username is required.';
} elseif (strlen($username) < 3 || strlen($username) > 50) {
    $errors[] = 'Username must be between 3 and 50 characters.';
} elseif (!preg_match('/^[a-zA-Z0-9_-]+$/', $username)) {
    $errors[] = 'Username can only contain letters, numbers, underscores, and hyphens.';
}

if (empty($email)) {
    $errors[] = 'Email is required.';
} elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    $errors[] = 'Please enter a valid email address.';
}

if (empty($password)) {
    $errors[] = 'Password is required.';
} elseif (strlen($password) < 6) {
    $errors[] = 'Password must be at least 6 characters.';
}

if ($password !== $confirmPassword) {
    $errors[] = 'Password confirmation does not match.';
}

if (!empty($errors)) {
    sendJson(422, [
        'status' => 'error',
        'code' => 'VALIDATION_FAILED',
        'message' => implode(' ', $errors),
        'errors' => $errors
    ]);
}

// Check duplicates
$checkStmt = $db->prepare("SELECT id, username, email FROM users WHERE username = ? OR email = ? LIMIT 1");
$checkStmt->execute([$username, $email]);
$existing = $checkStmt->fetch();

if ($existing) {
    if (strtolower($existing['username']) === strtolower($username)) {
        sendJson(409, [
            'status' => 'error',
            'code' => 'USERNAME_TAKEN',
            'message' => 'This username is already taken. Please choose another.'
        ]);
    } else {
        sendJson(409, [
            'status' => 'error',
            'code' => 'EMAIL_TAKEN',
            'message' => 'An account with this email already exists.'
        ]);
    }
}

// Hash password with bcrypt
$passwordHash = password_hash($password, PASSWORD_BCRYPT);
$defaultSkills = json_encode(['Strength' => 50, 'Knowledge' => 50, 'Discipline' => 50]);

try {
    $db->beginTransaction();

    // 1. Insert user
    $insertStmt = $db->prepare("
        INSERT INTO users (username, display_name, email, password_hash, avatar_id, level, total_xp, gold, current_streak, best_streak, skills_json, is_active, show_on_leaderboard)
        VALUES (?, ?, ?, ?, ?, 1, 0, 100, 0, 0, ?, 1, 1)
    ");
    $insertStmt->execute([$username, $displayName, $email, $passwordHash, $avatarId, $defaultSkills]);
    $userId = (int)$db->lastInsertId();

    // 2. Create default settings
    $settingsStmt = $db->prepare("
        INSERT INTO user_settings (user_id, dark_mode, sound_effects, selected_alarm_song, task_notifications, achievement_notifications, daily_reminders, streak_reminders)
        VALUES (?, 1, 1, 'fanfare_victory', 1, 1, 1, 1)
    ");
    $settingsStmt->execute([$userId]);

    // 3. Issue 30-day authentication token
    $token = bin2hex(random_bytes(32));
    $expiresAt = date('Y-m-d H:i:s', strtotime('+30 days'));

    $tokenStmt = $db->prepare("
        INSERT INTO user_tokens (user_id, token, expires_at)
        VALUES (?, ?, ?)
    ");
    $tokenStmt->execute([$userId, $token, $expiresAt]);

    // 4. Welcome notification
    $notifStmt = $db->prepare("
        INSERT INTO notifications (id, title, message, category, type, target_user_id)
        VALUES (?, 'Welcome to LevelUp, Hero!', 'Your epic real-life RPG adventure begins now. Complete daily quests, earn XP, level up, and conquer your goals!', 'System', 'announcement', ?)
    ");
    $notifId = 'notif_' . time() . '_' . mt_rand(100, 999);
    $notifStmt->execute([$notifId, $userId]);

    $db->commit();

    sendJson(201, [
        'status' => 'success',
        'message' => 'Hero registered successfully!',
        'token' => $token,
        'expires_at' => $expiresAt,
        'user' => [
            'id' => $userId,
            'username' => $username,
            'display_name' => $displayName,
            'email' => $email,
            'avatar_id' => $avatarId,
            'profile_image_path' => null,
            'level' => 1,
            'total_xp' => 0,
            'gold' => 100,
            'current_streak' => 0,
            'best_streak' => 0,
            'skills' => ['Strength' => 50, 'Knowledge' => 50, 'Discipline' => 50],
            'show_on_leaderboard' => 1,
        ]
    ]);
} catch (Exception $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    sendJson(500, [
        'status' => 'error',
        'message' => 'Registration failed: ' . $e->getMessage()
    ]);
}
