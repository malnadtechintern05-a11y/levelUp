<?php
/**
 * LevelUp Web Admin Panel - Database Configuration & PDO Connection
 */

define('DB_HOST', '127.0.0.1');
define('DB_NAME', 'levelup_rpg');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_CHARSET', 'utf8mb4');

/**
 * Get the singleton PDO database connection.
 *
 * @return PDO
 * @throws PDOException
 */
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
            // In production, log error message instead of exposing details
            error_log("Database connection error: " . $e->getMessage());
            die("Database Connection Error. Please ensure MySQL service is running and credentials in config/database.php are correct.");
        }
    }

    return $pdo;
}
