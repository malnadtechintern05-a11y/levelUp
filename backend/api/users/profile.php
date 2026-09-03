<?php
/**
 * Update Profile & Settings Endpoint
 * POST: display_name, avatar_id, skills, show_on_leaderboard, dark_mode, sound_effects, selected_alarm_song
 */

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../middleware/auth.php';

handleCors();

$db = getDB();
$user = requireAuth($db);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = getJsonBody();

    $displayName = isset($input['display_name']) ? trim($input['display_name']) : (isset($input['username']) ? trim($input['username']) : $user['display_name']);
    $username = isset($input['username']) ? trim($input['username']) : (isset($input['display_name']) ? trim($input['display_name']) : $user['username']);
    $avatarId = isset($input['avatar_id']) ? trim($input['avatar_id']) : $user['avatar_id'];
    $showOnLeaderboard = isset($input['show_on_leaderboard']) ? (int)(bool)$input['show_on_leaderboard'] : (int)$user['show_on_leaderboard'];
    $skillsJson = isset($input['skills']) && is_array($input['skills']) ? json_encode($input['skills']) : $user['skills_json'];

    // Update user record
    $uStmt = $db->prepare("
        UPDATE users
        SET username = ?, display_name = ?, avatar_id = ?, show_on_leaderboard = ?, skills_json = ?
        WHERE id = ?
    ");
    $uStmt->execute([$username, $displayName, $avatarId, $showOnLeaderboard, $skillsJson, $user['id']]);

    // Update user settings if provided
    if (isset($input['dark_mode']) || isset($input['sound_effects']) || isset($input['selected_alarm_song'])) {
        $setStmt = $db->prepare("
            INSERT INTO user_settings (user_id, dark_mode, sound_effects, selected_alarm_song)
            VALUES (?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
                dark_mode = VALUES(dark_mode),
                sound_effects = VALUES(sound_effects),
                selected_alarm_song = VALUES(selected_alarm_song)
        ");
        $darkMode = isset($input['dark_mode']) ? (int)(bool)$input['dark_mode'] : 1;
        $soundEffects = isset($input['sound_effects']) ? (int)(bool)$input['sound_effects'] : 1;
        $alarmSong = isset($input['selected_alarm_song']) ? trim($input['selected_alarm_song']) : 'fanfare_victory';
        $setStmt->execute([$user['id'], $darkMode, $soundEffects, $alarmSong]);
    }

    sendJson(200, [
        'status' => 'success',
        'message' => 'Profile updated successfully!'
    ]);
}

// GET profile
$skills = json_decode($user['skills_json'] ?? '{}', true) ?: ['Strength' => 50, 'Knowledge' => 50, 'Discipline' => 50];

sendJson(200, [
    'status' => 'success',
    'data' => [
        'id' => (int)$user['id'],
        'username' => $user['username'],
        'display_name' => $user['display_name'] ?: $user['username'],
        'email' => $user['email'],
        'avatar_id' => $user['avatar_id'],
        'level' => (int)$user['level'],
        'total_xp' => (int)$user['total_xp'],
        'gold' => (int)$user['gold'],
        'current_streak' => (int)$user['current_streak'],
        'best_streak' => (int)$user['best_streak'],
        'skills' => $skills,
        'show_on_leaderboard' => (int)$user['show_on_leaderboard'],
    ]
]);
