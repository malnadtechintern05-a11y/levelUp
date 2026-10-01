<?php
require_once __DIR__ . '/../middleware/auth.php';
handleCors();
sendJson(200, ['status' => 'success']);
