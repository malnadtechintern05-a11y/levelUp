<?php
/**
 * LevelUp Online Multi-User Backend - Authentication Middleware & Helpers
 */

function handleCors() {
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(200);
        exit;
    }
}

function sendJson(int $statusCode, array $data) {
    http_response_code($statusCode);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($data);
    exit;
}

function getJsonBody(): array {
    $raw = file_get_contents('php://input');
    if (empty($raw)) {
        return $_POST ?: [];
    }
    $decoded = json_decode($raw, true);
    return is_array($decoded) ? $decoded : [];
}

function getBearerToken(): ?string {
    $header = null;
    if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
        $header = trim($_SERVER['HTTP_AUTHORIZATION']);
    } elseif (isset($_SERVER['Authorization'])) {
        $header = trim($_SERVER['Authorization']);
    } elseif (function_exists('apache_request_headers')) {
        $headers = apache_request_headers();
        if (isset($headers['Authorization'])) {
            $header = trim($headers['Authorization']);
        } elseif (isset($headers['authorization'])) {
            $header = trim($headers['authorization']);
        }
    }

    if (!empty($header) && preg_match('/Bearer\s+(\S+)/i', $header, $matches)) {
        return $matches[1];
    }
    return null;
}

function requireAuth(PDO $db): array {
    $token = getBearerToken();
    if (!$token) {
        sendJson(401, [
            'status' => 'error',
            'code' => 'UNAUTHORIZED',
            'message' => 'Authentication token required.'
        ]);
    }

    $stmt = $db->prepare("
        SELECT u.*, ut.id as token_id, ut.expires_at
        FROM user_tokens ut
        JOIN users u ON ut.user_id = u.id
        WHERE ut.token = ? AND ut.expires_at > NOW()
        LIMIT 1
    ");
    $stmt->execute([$token]);
    $user = $stmt->fetch();

    if (!$user) {
        sendJson(401, [
            'status' => 'error',
            'code' => 'SESSION_EXPIRED',
            'message' => 'Your session has expired. Please log in again.'
        ]);
    }

    if ((int)$user['is_active'] !== 1) {
        sendJson(403, [
            'status' => 'error',
            'code' => 'ACCOUNT_DISABLED',
            'message' => 'Your account has been disabled by an administrator.'
        ]);
    }

    return $user;
}

function getOptionalAuth(PDO $db): ?array {
    $token = getBearerToken();
    if (!$token) {
        return null;
    }
    try {
        $stmt = $db->prepare("
            SELECT u.*, ut.id as token_id, ut.expires_at
            FROM user_tokens ut
            JOIN users u ON ut.user_id = u.id
            WHERE ut.token = ? AND ut.expires_at > NOW()
            LIMIT 1
        ");
        $stmt->execute([$token]);
        $user = $stmt->fetch();
        return ($user && (int)$user['is_active'] === 1) ? $user : null;
    } catch (Exception $e) {
        return null;
    }
}

function calculateLevelFromXp(int $totalXp): int {
    // 100 XP per level: Level 1 = 0-99 XP, Level 2 = 100-199 XP, etc.
    return max(1, (int)floor($totalXp / 100) + 1);
}

