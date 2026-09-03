<?php
/**
 * Logout Endpoint
 * POST: Bearer Token required
 */

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../middleware/auth.php';

handleCors();

$db = getDB();
$token = getBearerToken();

if ($token) {
    $stmt = $db->prepare("DELETE FROM user_tokens WHERE token = ?");
    $stmt->execute([$token]);
}

sendJson(200, [
    'status' => 'success',
    'message' => 'Successfully logged out.'
]);
