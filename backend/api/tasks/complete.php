<?php
/**
 * Complete Task Endpoint
 * POST: task_id
 * Strict enforcement of future date rule, duplicate protection, XP awarding, streak updating, and achievement checks.
 */

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../middleware/auth.php';

handleCors();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJson(405, ['status' => 'error', 'message' => 'Method Not Allowed']);
}

$db = getDB();
$user = requireAuth($db);
$input = getJsonBody();

$taskId = trim($input['task_id'] ?? $input['id'] ?? '');

if (empty($taskId)) {
    sendJson(422, ['status' => 'error', 'message' => 'Task ID is required.']);
}

// 1. Fetch task and check ownership
$stmt = $db->prepare("
    SELECT *
    FROM tasks
    WHERE id = ? AND (user_id = ? OR assigned_user_id = ?) AND is_active = 1
    LIMIT 1
");
$stmt->execute([$taskId, $user['id'], $user['id']]);
$task = $stmt->fetch();

if (!$task) {
    sendJson(404, ['status' => 'error', 'message' => 'Task not found or does not belong to you.']);
}

// 2. ENFORCE FUTURE TASK DATE RULE
$today = date('Y-m-d');
if ($task['scheduled_date'] > $today) {
    sendJson(403, [
        'status' => 'error',
        'code' => 'FUTURE_TASK_LOCKED',
        'message' => '🔒 This quest is scheduled for ' . date('M j, Y', strtotime($task['scheduled_date'])) . ' and cannot be completed before that date.'
    ]);
}

// 3. PREVENT DUPLICATE COMPLETION
if ((int)$task['is_completed'] === 1) {
    sendJson(409, [
        'status' => 'error',
        'code' => 'ALREADY_COMPLETED',
        'message' => 'This quest has already been conquered today!'
    ]);
}

try {
    $db->beginTransaction();

    $xpAwarded = (int)$task['xp_reward'];
    $duration = (int)$task['duration_minutes'];

    // Mark task completed
    $uTaskStmt = $db->prepare("
        UPDATE tasks
        SET is_completed = 1, timer_status = 'Completed', time_spent_seconds = ?
        WHERE id = ?
    ");
    $uTaskStmt->execute([$duration * 60, $taskId]);

    // Record in task_completions
    $tcStmt = $db->prepare("
        INSERT INTO task_completions (task_id, user_id, xp_awarded, completed_at)
        VALUES (?, ?, ?, NOW())
    ");
    $tcStmt->execute([$taskId, $user['id'], $xpAwarded]);

    // Update User XP & Gold
    $newTotalXp = (int)$user['total_xp'] + $xpAwarded;
    $newGold = (int)$user['gold'] + (int)floor($xpAwarded / 2);
    $newLevel = calculateLevelFromXp($newTotalXp);

    // Calculate Streak
    // Count distinct completion dates
    $streakStmt = $db->prepare("
        SELECT DISTINCT DATE(completed_at) as cdate
        FROM task_completions
        WHERE user_id = ?
        ORDER BY cdate DESC
    ");
    $streakStmt->execute([$user['id']]);
    $dates = $streakStmt->fetchAll(PDO::FETCH_COLUMN);

    $currentStreak = 0;
    $checkDate = new DateTime('today');
    
    // If completed today
    $todayStr = $checkDate->format('Y-m-d');
    if (!empty($dates) && $dates[0] === $todayStr) {
        $currentStreak = 1;
        $checkDate->modify('-1 day');
        for ($i = 1; $i < count($dates); $i++) {
            if ($dates[$i] === $checkDate->format('Y-m-d')) {
                $currentStreak++;
                $checkDate->modify('-1 day');
            } else {
                break;
            }
        }
    }

    $bestStreak = max((int)$user['best_streak'], $currentStreak);

    // Update skills based on category
    $skills = json_decode($user['skills_json'] ?? '{}', true) ?: ['Strength' => 50, 'Knowledge' => 50, 'Discipline' => 50];
    if (in_array($task['category'], ['Fitness', 'Health'])) {
        $skills['Strength'] = ($skills['Strength'] ?? 50) + 10;
    } elseif (in_array($task['category'], ['Study', 'Work'])) {
        $skills['Knowledge'] = ($skills['Knowledge'] ?? 50) + 10;
    } else {
        $skills['Discipline'] = ($skills['Discipline'] ?? 50) + 10;
    }

    // Save user updates
    $userUpdate = $db->prepare("
        UPDATE users
        SET total_xp = ?, level = ?, gold = ?, current_streak = ?, best_streak = ?, skills_json = ?
        WHERE id = ?
    ");
    $userUpdate->execute([$newTotalXp, $newLevel, $newGold, $currentStreak, $bestStreak, json_encode($skills), $user['id']]);

    // Check Achievements
    $tCountStmt = $db->prepare("SELECT COUNT(*) FROM task_completions WHERE user_id = ?");
    $tCountStmt->execute([$user['id']]);
    $totalCompleted = (int)$tCountStmt->fetchColumn();

    $newlyUnlocked = [];

    // Helper to unlock achievement
    $unlock = function($code) use ($db, $user, &$newlyUnlocked) {
        // Find achievement id
        $aStmt = $db->prepare("SELECT id, name, description, xp_reward FROM achievements WHERE id = ? LIMIT 1");
        $aStmt->execute([$code]);
        $ach = $aStmt->fetch();
        if ($ach) {
            $check = $db->prepare("SELECT id FROM user_achievements WHERE user_id = ? AND achievement_id = ?");
            $check->execute([$user['id'], $ach['id']]);
            if (!$check->fetch()) {
                $ins = $db->prepare("INSERT INTO user_achievements (user_id, achievement_id) VALUES (?, ?)");
                $ins->execute([$user['id'], $ach['id']]);
                $newlyUnlocked[] = $ach;
            }
        }
    };

    // Rule a1: First Quest
    if ($totalCompleted >= 1) $unlock('a1');
    // Rule a2: 7-day streak
    if ($currentStreak >= 7) $unlock('a2');
    // Rule a3: 50 quests
    if ($totalCompleted >= 50) $unlock('a3');
    // Rule a4: Level 50
    if ($newLevel >= 50) $unlock('a4');

    $db->commit();

    sendJson(200, [
        'status' => 'success',
        'message' => 'Quest conquered successfully! +' . $xpAwarded . ' XP earned!',
        'task' => [
            'id' => $taskId,
            'is_completed' => true,
            'timer_status' => 'Completed',
        ],
        'user' => [
            'total_xp' => $newTotalXp,
            'level' => $newLevel,
            'gold' => $newGold,
            'current_streak' => $currentStreak,
            'best_streak' => $bestStreak,
            'skills' => $skills,
            'xp_earned' => $xpAwarded,
            'did_level_up' => $newLevel > (int)$user['level'],
        ],
        'newly_unlocked_achievements' => $newlyUnlocked
    ]);
} catch (Exception $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    sendJson(500, ['status' => 'error', 'message' => 'Task completion failed: ' . $e->getMessage()]);
}
