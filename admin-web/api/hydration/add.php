<?php
/**
 * Add Hydration Log Endpoint
 * POST: amount_ml, task_id (optional)
 * Supports +250, +500, +750, +1000 ml.
 * Awards XP & streak once per day upon reaching goal.
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

$amountMl = (int)($input['amount_ml'] ?? 250);
if ($amountMl <= 0 || $amountMl > 5000) {
    sendJson(422, ['status' => 'error', 'message' => 'Invalid hydration amount.']);
}

$taskId = trim($input['task_id'] ?? '');
$today = date('Y-m-d');
$logId = 'hydro_' . time() . '_' . mt_rand(100, 999);

try {
    $db->beginTransaction();

    // 1. Insert hydration log
    $ins = $db->prepare("
        INSERT INTO hydration_logs (id, user_id, task_id, amount_ml, logged_at)
        VALUES (?, ?, ?, ?, NOW())
    ");
    $ins->execute([$logId, $user['id'], !empty($taskId) ? $taskId : null, $amountMl]);

    // 2. Calculate total water for today
    $totStmt = $db->prepare("
        SELECT COALESCE(SUM(amount_ml), 0)
        FROM hydration_logs
        WHERE user_id = ? AND DATE(logged_at) = CURDATE()
    ");
    $totStmt->execute([$user['id']]);
    $totalTodayMl = (int)$totStmt->fetchColumn();

    // 3. Find or update hydration task for today
    $taskStmt = $db->prepare("
        SELECT *
        FROM tasks
        WHERE (user_id = ? OR assigned_user_id = ?) AND task_type = 'hydration' AND scheduled_date = CURDATE() AND is_active = 1
        LIMIT 1
    ");
    $taskStmt->execute([$user['id'], $user['id']]);
    $hydroTask = $taskStmt->fetch();

    $waterGoalMl = $hydroTask ? (int)$hydroTask['water_goal_ml'] : 2500;
    $goalCompleted = $totalTodayMl >= $waterGoalMl;
    $xpAwarded = 0;
    $didCompleteGoalNow = false;

    if ($hydroTask) {
        $uTask = $db->prepare("
            UPDATE tasks
            SET current_water_ml = ?, is_completed = ?
            WHERE id = ?
        ");
        $uTask->execute([$totalTodayMl, $goalCompleted ? 1 : 0, $hydroTask['id']]);
    }

    // Check if user already got hydration XP today
    $lastHydrationDate = $user['last_hydration_date'];
    $newStreak = (int)$user['hydration_current_streak'];
    $newBestStreak = (int)$user['hydration_best_streak'];
    $newTotalXp = (int)$user['total_xp'];
    $newLevel = (int)$user['level'];

    if ($goalCompleted && $lastHydrationDate !== $today) {
        // First time reaching goal today!
        $didCompleteGoalNow = true;
        $xpAwarded = 50;
        $newTotalXp += $xpAwarded;
        $newLevel = calculateLevelFromXp($newTotalXp);

        $yesterday = date('Y-m-d', strtotime('-1 day'));
        if ($lastHydrationDate === $yesterday) {
            $newStreak++;
        } else {
            $newStreak = 1;
        }

        if ($newStreak > $newBestStreak) {
            $newBestStreak = $newStreak;
        }

        $uUser = $db->prepare("
            UPDATE users
            SET total_xp = ?, level = ?, hydration_current_streak = ?, hydration_best_streak = ?, last_hydration_date = ?
            WHERE id = ?
        ");
        $uUser->execute([$newTotalXp, $newLevel, $newStreak, $newBestStreak, $today, $user['id']]);
    }

    $db->commit();

    sendJson(200, [
        'status' => 'success',
        'message' => 'Logged ' . $amountMl . ' ml of water successfully!',
        'data' => [
            'total_today_ml' => $totalTodayMl,
            'water_goal_ml' => $waterGoalMl,
            'goal_completed' => $goalCompleted,
            'did_complete_goal_now' => $didCompleteGoalNow,
            'xp_awarded' => $xpAwarded,
            'hydration_current_streak' => $newStreak,
            'hydration_best_streak' => $newBestStreak,
            'total_xp' => $newTotalXp,
            'level' => $newLevel,
        ]
    ]);
} catch (Exception $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    sendJson(500, ['status' => 'error', 'message' => 'Hydration logging failed: ' . $e->getMessage()]);
}
