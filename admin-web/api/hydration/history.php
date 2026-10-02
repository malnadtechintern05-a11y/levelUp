<?php
/**
 * Hydration History Endpoint
 * GET: Bearer Token required
 */

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../middleware/auth.php';

handleCors();

$db = getDB();
$user = requireAuth($db);

$stmt = $db->prepare("
    SELECT id, amount_ml, logged_at
    FROM hydration_logs
    WHERE user_id = ?
    ORDER BY logged_at DESC
    LIMIT 100
");
$stmt->execute([$user['id']]);
$logs = $stmt->fetchAll();

$todayTotal = 0;
$todayDate = date('Y-m-d');

foreach ($logs as $log) {
    if (str_starts_with($log['logged_at'], $todayDate)) {
        $todayTotal += (int)$log['amount_ml'];
    }
}

sendJson(200, [
    'status' => 'success',
    'today_total_ml' => $todayTotal,
    'hydration_current_streak' => (int)$user['hydration_current_streak'],
    'hydration_best_streak' => (int)$user['hydration_best_streak'],
    'logs' => $logs
]);
