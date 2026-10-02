<?php
/**
 * LevelUp Web Admin Panel & Backend - Database Configuration & PDO Connection
 */

// Configure your Database settings below:
if (!defined('DB_HOST')) define('DB_HOST', getenv('DB_HOST') ?: '127.0.0.1');
if (!defined('DB_NAME')) define('DB_NAME', getenv('DB_NAME') ?: 'levelup_rpg');
if (!defined('DB_USER')) define('DB_USER', getenv('DB_USER') ?: 'root');
if (!defined('DB_PASS')) define('DB_PASS', getenv('DB_PASS') !== false ? getenv('DB_PASS') : '');
if (!defined('DB_CHARSET')) define('DB_CHARSET', 'utf8mb4');

/**
 * Get the singleton PDO database connection.
 *
 * @return PDO
 * @throws PDOException
 */
if (!function_exists('getDB')) {
    function getDB(): PDO {
        static $pdo = null;

        if ($pdo === null) {
            $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET;
            $options = [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false,
                PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES " . DB_CHARSET,
            ];

            try {
                $pdo = new PDO($dsn, DB_USER, DB_PASS, $options);
            } catch (PDOException $e) {
                error_log("Database connection error: " . $e->getMessage());

                // If running an API endpoint request, return clean JSON
                if (str_contains($_SERVER['REQUEST_URI'] ?? '', '/api/')) {
                    header('Content-Type: application/json; charset=utf-8');
                    http_response_code(500);
                    echo json_encode([
                        'status' => 'error',
                        'message' => 'Database connection failed: ' . $e->getMessage(),
                        'hint' => 'Please configure config/database.php with your InfinityFree MySQL host, user, password, and database name.'
                    ]);
                    exit;
                }

                // If loading web browser page, render styled troubleshooting helper
                http_response_code(500);
                $host = htmlspecialchars(DB_HOST);
                $dbname = htmlspecialchars(DB_NAME);
                $user = htmlspecialchars(DB_USER);
                $errorMsg = htmlspecialchars($e->getMessage());

                echo <<<HTML
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Database Connection Error - LevelUp</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #0A0F1C; color: #E2E8F0; font-family: system-ui, -apple-system, sans-serif; }
        .card-custom { background: #162033; border: 1px solid #1E293B; border-radius: 16px; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
        .badge-gold { background: rgba(245, 185, 66, 0.2); color: #F5B942; border: 1px solid rgba(245, 185, 66, 0.4); }
        code { color: #38BDF8; }
    </style>
</head>
<body class="d-flex align-items-center justify-content-center min-vh-100 p-3">
    <div class="card card-custom p-4 p-md-5" style="max-width: 680px; width: 100%;">
        <div class="d-flex align-items-center gap-3 mb-4">
            <div style="font-size: 38px;">⚠️</div>
            <div>
                <h3 class="fw-bold mb-0 text-white">Database Connection Error</h3>
                <span class="badge badge-gold px-3 py-1 mt-1">LevelUp Server Setup</span>
            </div>
        </div>

        <div class="alert alert-danger bg-danger bg-opacity-10 border-danger text-danger-emphasis mb-4">
            <strong>Error Details:</strong><br>
            <code>{$errorMsg}</code>
        </div>

        <div class="mb-4">
            <h6 class="text-warning fw-bold mb-2">Current Configuration in <code>config/database.php</code>:</h6>
            <ul class="list-group bg-dark border-secondary">
                <li class="list-group-item bg-dark text-light border-secondary d-flex justify-content-between">
                    <span>Host (DB_HOST):</span> <strong class="text-info">{$host}</strong>
                </li>
                <li class="list-group-item bg-dark text-light border-secondary d-flex justify-content-between">
                    <span>Database (DB_NAME):</span> <strong class="text-info">{$dbname}</strong>
                </li>
                <li class="list-group-item bg-dark text-light border-secondary d-flex justify-content-between">
                    <span>User (DB_USER):</span> <strong class="text-info">{$user}</strong>
                </li>
            </ul>
        </div>

        <div class="card bg-black bg-opacity-25 border-secondary p-3 mb-4">
            <h6 class="text-white fw-bold mb-2">🌐 How to Fix for InfinityFree:</h6>
            <ol class="text-muted small ps-3 mb-0" style="line-height: 1.8;">
                <li>Log in to your <strong>InfinityFree Client Area</strong> and open your hosting account.</li>
                <li>Go to <strong>MySQL Databases</strong> (or Control Panel -> MySQL Databases).</li>
                <li>Copy your <strong>MySQL Hostname</strong> (e.g. <code>sql105.infinityfree.com</code> or <code>sql200.epizy.com</code>). <strong class="text-warning">Never use localhost on InfinityFree!</strong></li>
                <li>Ensure you created a database (e.g. <code>epiz_XXXXXXX_levelup_rpg</code>) and imported <code>levelup_rpg.sql</code> in phpMyAdmin.</li>
                <li>Edit <strong><code>config/database.php</code></strong> via InfinityFree File Manager with your exact credentials.</li>
            </ol>
        </div>

        <div class="text-center">
            <a href="login.php" class="btn btn-warning px-4 fw-bold">🔄 Test Connection Again</a>
        </div>
    </div>
</body>
</html>
HTML;
                exit;
            }
        }

        return $pdo;
    }
}
