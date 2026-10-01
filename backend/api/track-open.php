<?php
/**
 * PusherHub Event Tracking Endpoint (track-open / track-click)
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../middleware/auth.php';

handleCors();

sendJson(200, [
    'status' => 'success',
    'message' => 'Event tracked successfully.'
]);
