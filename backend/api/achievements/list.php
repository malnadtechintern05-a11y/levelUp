<?php
/**
 * Achievements List & User Progress Endpoint
 * GET: Bearer Token optional / required for user unlock status
 */

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../middleware/auth.php';

handleCors();

$db = getDB();
$token = getBearerToken();
$userId = null;

if ($token) {
    $tStmt = $db->prepare("SELECT user_id FROM user_tokens WHERE token = ? AND expires_at > NOW() LIMIT 1");
    $tStmt->execute([$token]);
    $userId = $tStmt->fetchColumn() ?: null;
}

$stmt = $db->query("
    SELECT id, name, description, xp_reward, unlock_requirement, icon_name, is_active
    FROM achievements
    WHERE is_active = 1
    ORDER BY id ASC
");
$all = $stmt->fetchAll();

// Get user unlocked ids
$unlockedIds = [];
if ($userId) {
    $uStmt = $db->prepare("SELECT achievement_id, unlocked_at FROM user_achievements WHERE user_id = ?");
    $uStmt->execute([$userId]);
    $unlockedRows = $uStmt->fetchAll();
    foreach ($unlockedRows as $r) {
        $unlockedIds[$r['achievement_id']] = $r['unlocked_at'];
    }
}

$achievements = [];
foreach ($all as $a) {
    $isUnlocked = isset($unlockedIds[$a['id']]);
    $achievements[] = [
        'id' => $a['id'],
        'name' => $a['name'],
        'description' => $a['description'],
        'xp_reward' => (int)$a['xp_reward'],
        'unlock_requirement' => $a['unlock_requirement'],
        'icon_path' => $a['icon_name'],
        'is_unlocked' => $isUnlocked,
        'unlocked_at' => $isUnlocked ? $unlockedIds[$a['id']] : null,
    ];
}

sendJson(200, [
    'status' => 'success',
    'total' => count($achievements),
    'unlocked_count' => count($unlockedIds),
    'data' => $achievements
]);
