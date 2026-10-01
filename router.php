<?php
/**
 * Universal Dev Server Router for LevelUp Real-Life RPG
 * Strictly separates Mobile App Player Authentication and Browser Web Admin Panel.
 * Properly serves static CSS/JS/Image assets with correct MIME types.
 */

$uri = urldecode(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH));
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
$contentType = $_SERVER['CONTENT_TYPE'] ?? $_SERVER['HTTP_CONTENT_TYPE'] ?? '';
$isJsonRequest = str_contains($contentType, 'application/json') || isset($_SERVER['HTTP_AUTHORIZATION']) || isset($_SERVER['Authorization']);

// Helper function to serve static files with proper MIME types
function serveStaticFile(string $filePath): void {
    $ext = strtolower(pathinfo($filePath, PATHINFO_EXTENSION));
    $mimes = [
        'css'   => 'text/css; charset=UTF-8',
        'js'    => 'application/javascript; charset=UTF-8',
        'json'  => 'application/json; charset=UTF-8',
        'png'   => 'image/png',
        'jpg'   => 'image/jpeg',
        'jpeg'  => 'image/jpeg',
        'gif'   => 'image/gif',
        'svg'   => 'image/svg+xml',
        'ico'   => 'image/x-icon',
        'woff'  => 'font/woff',
        'woff2' => 'font/woff2',
        'ttf'   => 'font/ttf',
        'map'   => 'application/json',
    ];
    if (isset($mimes[$ext])) {
        header('Content-Type: ' . $mimes[$ext]);
    }
    header('Content-Length: ' . filesize($filePath));
    readfile($filePath);
    exit;
}

// 1. Direct Hero Authentication Shortcuts
if ($uri === '/api/login.php' || $uri === '/api/auth/login.php' || $uri === '/auth/login.php') {
    require __DIR__ . '/backend/api/auth/login.php';
    exit;
}

if ($uri === '/api/register.php' || $uri === '/api/auth/register.php' || $uri === '/auth/register.php') {
    require __DIR__ . '/backend/api/auth/register.php';
    exit;
}

if ($uri === '/api/logout.php' || $uri === '/api/auth/logout.php' || $uri === '/auth/logout.php') {
    require __DIR__ . '/backend/api/auth/logout.php';
    exit;
}

if ($uri === '/api/me.php' || $uri === '/api/auth/me.php' || $uri === '/auth/me.php') {
    require __DIR__ . '/backend/api/auth/me.php';
    exit;
}

// If someone sent a JSON POST directly to /login.php, they are an API client!
if ($uri === '/login.php' && ($isJsonRequest || $method === 'POST')) {
    $rawInput = file_get_contents('php://input');
    if (!empty($rawInput)) {
        require __DIR__ . '/backend/api/auth/login.php';
        exit;
    }
}

// 2. PusherHub Direct Root & API Routing
$pusherEndpoints = [
    '/register-device'          => __DIR__ . '/backend/api/register-device.php',
    '/heartbeat'                => __DIR__ . '/backend/api/heartbeat.php',
    '/fetch-in-app-messages'    => __DIR__ . '/backend/api/fetch-in-app-messages.php',
    '/track-open'               => __DIR__ . '/backend/api/track-open.php',
    '/track-click'              => __DIR__ . '/backend/api/track-click.php',
    '/track-in-app-shown'       => __DIR__ . '/backend/api/track-in-app-shown.php',
    '/track-in-app-click'       => __DIR__ . '/backend/api/track-in-app-click.php',
    '/track-in-app-dismiss'     => __DIR__ . '/backend/api/track-in-app-dismiss.php',
    '/api/register-device'      => __DIR__ . '/backend/api/register-device.php',
    '/api/heartbeat'            => __DIR__ . '/backend/api/heartbeat.php',
    '/api/fetch-in-app-messages'=> __DIR__ . '/backend/api/fetch-in-app-messages.php',
    '/api/track-open'           => __DIR__ . '/backend/api/track-open.php',
    '/api/track-click'          => __DIR__ . '/backend/api/track-click.php',
    '/api/track-in-app-shown'   => __DIR__ . '/backend/api/track-in-app-shown.php',
    '/api/track-in-app-click'   => __DIR__ . '/backend/api/track-in-app-click.php',
    '/api/track-in-app-dismiss' => __DIR__ . '/backend/api/track-in-app-dismiss.php',
];

if (isset($pusherEndpoints[$uri]) && file_exists($pusherEndpoints[$uri])) {
    require $pusherEndpoints[$uri];
    exit;
}

// 3. Generic /api/ routing
if (str_starts_with($uri, '/api/')) {
    $subPath = substr($uri, 5); // strip '/api/'
    $target = __DIR__ . '/backend/api/' . $subPath;
    if (file_exists($target . '.php')) {
        require $target . '.php';
        exit;
    }
    if (file_exists($target) && !is_dir($target)) {
        if (str_ends_with($target, '.php')) {
            require $target;
        } else {
            serveStaticFile($target);
        }
        exit;
    }
}

// 4. /backend/api/ routing
if (str_starts_with($uri, '/backend/api/')) {
    $target = __DIR__ . $uri;
    if (file_exists($target . '.php')) {
        require $target . '.php';
        exit;
    }
    if (file_exists($target) && !is_dir($target)) {
        if (str_ends_with($target, '.php')) {
            require $target;
        } else {
            serveStaticFile($target);
        }
        exit;
    }
}

// 5. Web Admin Panel routing
if (str_starts_with($uri, '/admin-web/')) {
    $target = __DIR__ . $uri;
    if (file_exists($target . '.php')) {
        require $target . '.php';
        exit;
    }
    if (file_exists($target) && !is_dir($target)) {
        if (str_ends_with($target, '.php')) {
            require $target;
        } else {
            serveStaticFile($target);
        }
        exit;
    }
}

// 5. Default root navigates to Admin Web Panel in browser
if ($uri === '/' || $uri === '') {
    require __DIR__ . '/admin-web/index.php';
    exit;
}

// 6. Any other existing static file
$target = __DIR__ . $uri;
if (file_exists($target) && !is_dir($target)) {
    if (str_ends_with($target, '.php')) {
        require $target;
    } else {
        serveStaticFile($target);
    }
    exit;
}

http_response_code(404);
header('Content-Type: application/json; charset=utf-8');
echo json_encode(['status' => 'error', 'message' => 'Endpoint not found: ' . $uri]);
