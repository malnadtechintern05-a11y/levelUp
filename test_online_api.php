<?php
/**
 * Automated Verification Script for Online Backend & Two-Account Multi-User Test
 */

$baseUrl = 'http://127.0.0.1:8080/api';

function request($method, $path, $data = null, $token = null) {
    global $baseUrl;
    $url = $baseUrl . $path;
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);

    $headers = ['Content-Type: application/json'];
    if ($token) {
        $headers[] = 'Authorization: Bearer ' . $token;
    }
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);

    if ($data !== null) {
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    }

    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    return [
        'code' => $httpCode,
        'body' => json_decode($response, true),
        'raw' => $response
    ];
}

function assertTest($name, $condition, $extra = '') {
    if ($condition) {
        echo "✅ PASS: $name\n";
    } else {
        echo "❌ FAIL: $name $extra\n";
        exit(1);
    }
}

echo "=== STARTING ONLINE API INTEGRATION & TWO-ACCOUNT TEST ===\n\n";

// 1. Clean up test users if existing
require_once __DIR__ . '/backend/config/database.php';
$db = getDB();
$db->exec("DELETE FROM users WHERE username IN ('harsha_test', 'rahul_test')");

// 2. Register Account A
$regA = request('POST', '/auth/register.php', [
    'username' => 'harsha_test',
    'email' => 'harsha_test@example.com',
    'password' => 'HarshaPass123!',
    'confirm_password' => 'HarshaPass123!',
    'avatar_id' => 'hero2'
]);
assertTest('Register Account A (harsha_test)', $regA['code'] === 201 && isset($regA['body']['token']));
$tokenA = $regA['body']['token'];
$userIdA = $regA['body']['user']['id'];

// 3. Login with wrong password
$badLogin = request('POST', '/auth/login.php', [
    'identifier' => 'harsha_test',
    'password' => 'WrongPass!'
]);
assertTest('Login with invalid credentials rejected (401)', $badLogin['code'] === 401);

// 4. Login Account A with correct password
$loginA = request('POST', '/auth/login.php', [
    'identifier' => 'harsha_test',
    'password' => 'HarshaPass123!'
]);
assertTest('Login Account A successful (200)', $loginA['code'] === 200 && isset($loginA['body']['token']));
$tokenA = $loginA['body']['token'];

// 5. Verify /auth/me.php for Account A
$meA = request('GET', '/auth/me.php', null, $tokenA);
assertTest('Fetch /auth/me for Account A', $meA['code'] === 200 && $meA['body']['user']['username'] === 'harsha_test');
assertTest('Account A initial XP is 0', $meA['body']['user']['total_xp'] === 0);

// 6. Register Account B
$regB = request('POST', '/auth/register.php', [
    'username' => 'rahul_test',
    'email' => 'rahul_test@example.com',
    'password' => 'RahulPass123!',
    'confirm_password' => 'RahulPass123!',
    'avatar_id' => 'hero3'
]);
assertTest('Register Account B (rahul_test)', $regB['code'] === 201 && isset($regB['body']['token']));
$tokenB = $regB['body']['token'];
$userIdB = $regB['body']['user']['id'];

// 7. Verify Account B data isolation
$meB = request('GET', '/auth/me.php', null, $tokenB);
assertTest('Account B has isolated profile', $meB['body']['user']['username'] === 'rahul_test' && $meB['body']['user']['id'] !== $userIdA);

// 8. Create Task for Account A
$taskCreate = request('POST', '/tasks/create.php', [
    'title' => 'Conquer Clean Code Sprint',
    'category' => 'Work',
    'xp_reward' => 50,
    'scheduled_date' => date('Y-m-d'),
    'duration_minutes' => 30
], $tokenA);
assertTest('Create Task for Account A', $taskCreate['code'] === 201);
$taskIdA = $taskCreate['body']['data']['id'];

// 9. Verify Account B cannot see Account A task
$tasksB = request('GET', '/tasks/list.php', null, $tokenB);
$bHasATask = false;
foreach ($tasksB['body']['data'] as $t) {
    if ($t['id'] === $taskIdA) $bHasATask = true;
}
assertTest('Account B cannot see Account A private task', !$bHasATask);

// 10. Future Task Date Rule Enforcement
$futureDate = date('Y-m-d', strtotime('+2 days'));
$futureTask = request('POST', '/tasks/create.php', [
    'title' => 'Future Quest of Valor',
    'category' => 'Personal',
    'xp_reward' => 100,
    'scheduled_date' => $futureDate,
    'duration_minutes' => 20
], $tokenA);
$futureTaskId = $futureTask['body']['data']['id'];

$completeFuture = request('POST', '/tasks/complete.php', ['task_id' => $futureTaskId], $tokenA);
assertTest('Future task completion blocked (403 Forbidden)', $completeFuture['code'] === 403 && str_contains($completeFuture['body']['code'], 'FUTURE_TASK_LOCKED'));

// 11. Complete Today\'s Task on Account A
$completeToday = request('POST', '/tasks/complete.php', ['task_id' => $taskIdA], $tokenA);
assertTest('Complete today task on Account A', $completeToday['code'] === 200 && $completeToday['body']['user']['total_xp'] === 50);

// 12. Prevent duplicate task completion
$completeDup = request('POST', '/tasks/complete.php', ['task_id' => $taskIdA], $tokenA);
assertTest('Duplicate task completion blocked (409 Conflict)', $completeDup['code'] === 409);

// 13. Hydration Logging for Account A
$hydro = request('POST', '/hydration/add.php', ['amount_ml' => 500], $tokenA);
assertTest('Hydration logging succeeds', $hydro['code'] === 200 && $hydro['body']['data']['total_today_ml'] >= 500);

// 14. Real Player Rankings
$rankings = request('GET', '/rankings/leaderboard.php?type=xp&period=all', null, $tokenA);
assertTest('Leaderboard returned real rankings', $rankings['code'] === 200 && $rankings['body']['total'] >= 2);
$foundA = false;
$foundB = false;
foreach ($rankings['body']['data'] as $p) {
    if ($p['raw_username'] === 'harsha_test') $foundA = true;
    if ($p['raw_username'] === 'rahul_test') $foundB = true;
}
assertTest('Leaderboard contains both real test accounts', $foundA && $foundB);

// 15. Public Profile Security (strictly excludes private data)
$pubA = request('GET', '/users/public_profile.php?id=' . $userIdA);
assertTest('Public profile accessible', $pubA['code'] === 200 && $pubA['body']['data']['username'] === 'harsha_test');
assertTest('Public profile excludes password_hash', !isset($pubA['body']['data']['password_hash']));
assertTest('Public profile excludes email', !isset($pubA['body']['data']['email']));

// 16. Logout Account A
$logout = request('POST', '/auth/logout.php', null, $tokenA);
assertTest('Logout succeeds', $logout['code'] === 200);

$meAfterLogout = request('GET', '/auth/me.php', null, $tokenA);
assertTest('Token invalidated after logout (401 Unauthorized)', $meAfterLogout['code'] === 401);

echo "\n🎉 ALL 16 ONLINE BACKEND & MULTI-USER INTEGRATION TESTS PASSED!\n";
