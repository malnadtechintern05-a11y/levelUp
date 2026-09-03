<?php
/**
 * LevelUp Web Admin Panel - User Profile & RPG Stats View
 */
require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/functions.php';

require_admin_auth();

$db = getDB();
$userId = (int)($_GET['id'] ?? 0);

if ($userId <= 0) {
    set_flash('danger', 'Invalid Hero ID specified.');
    header('Location: users.php');
    exit;
}

// Fetch user data
$stmt = $db->prepare("SELECT * FROM users WHERE id = ?");
$stmt->execute([$userId]);
$user = $stmt->fetch();

if (!$user) {
    set_flash('danger', 'Hero not found in the realm.');
    header('Location: users.php');
    exit;
}

$pageTitle = "Hero Profile: " . $user['username'];
$currentPage = 'user-view';

// Decode skills JSON
$skills = ['Strength' => 50, 'Knowledge' => 50, 'Discipline' => 50];
if (!empty($user['skills_json'])) {
    $decoded = json_decode($user['skills_json'], true);
    if (is_array($decoded)) {
        $skills = array_merge($skills, $decoded);
    }
}

// Level progress calculation
$progress = calculate_level_progress((int)$user['level'], (int)$user['total_xp']);

// Tasks completed count and list
$tasksStmt = $db->prepare("
    SELECT tc.completed_at, tc.xp_awarded, t.title, t.category, t.task_type
    FROM task_completions tc
    JOIN tasks t ON tc.task_id = t.id
    WHERE tc.user_id = ?
    ORDER BY tc.completed_at DESC
    LIMIT 8
");
$tasksStmt->execute([$userId]);
$recentTasks = $tasksStmt->fetchAll();

// Total completed tasks count
$countCompletedStmt = $db->prepare("SELECT COUNT(*) FROM task_completions WHERE user_id = ?");
$countCompletedStmt->execute([$userId]);
$totalCompletedCount = (int)$countCompletedStmt->fetchColumn();

// Unlocked achievements
$achStmt = $db->prepare("
    SELECT a.*, ua.unlocked_at
    FROM user_achievements ua
    JOIN achievements a ON ua.achievement_id = a.id
    WHERE ua.user_id = ?
    ORDER BY ua.unlocked_at DESC
");
$achStmt->execute([$userId]);
$unlockedAchievements = $achStmt->fetchAll();

// Hydration logs
$hydraStmt = $db->prepare("
    SELECT * FROM hydration_logs 
    WHERE user_id = ? 
    ORDER BY logged_at DESC 
    LIMIT 5
");
$hydraStmt->execute([$userId]);
$hydrationLogs = $hydraStmt->fetchAll();

// Last activity timestamp
$lastActStmt = $db->prepare("SELECT MAX(created_at) FROM activity_logs WHERE user_id = ?");
$lastActStmt->execute([$userId]);
$lastActivity = $lastActStmt->fetchColumn();

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/sidebar.php';
?>

<div class="admin-main">
    <?php require_once __DIR__ . '/includes/navbar.php'; ?>

    <div class="content-body">
        <?php display_flash_messages(); ?>

        <!-- Back Button & Page Header -->
        <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
            <div>
                <a href="users.php" class="btn btn-dark-rpg btn-sm mb-2"><i class="bi bi-arrow-left me-1"></i> Back to Hero Roster</a>
                <h2 class="fw-bold text-white mb-0"><?= e($user['username']) ?> &bull; RPG Character Sheet</h2>
            </div>
            <div class="d-flex gap-2">
                <a href="user-edit.php?id=<?= $user['id'] ?>" class="btn btn-gold">
                    <i class="bi bi-pencil-square me-1"></i> Modify Stats
                </a>
            </div>
        </div>

        <div class="row g-4">
            <!-- Left Hero Identity Card -->
            <div class="col-12 col-lg-4">
                <div class="card-rpg text-center mb-4">
                    <div class="position-relative d-inline-block mx-auto mb-3">
                        <div class="avatar-ring mx-auto" style="width: 86px; height: 86px; font-size: 2.2rem;">
                            <?= strtoupper(substr($user['username'], 0, 1)) ?>
                        </div>
                        <span class="position-absolute bottom-0 end-0 badge rounded-pill <?= $user['is_active'] ? 'bg-success' : 'bg-danger' ?> border border-dark">
                            <?= $user['is_active'] ? 'ACTIVE' : 'INACTIVE' ?>
                        </span>
                    </div>

                    <h4 class="fw-bold text-white mb-1"><?= e($user['username']) ?></h4>
                    <p class="text-secondary small mb-3"><?= e($user['email'] ?? 'No email address registered') ?></p>

                    <div class="level-badge fs-6 py-1 px-3 mb-3">
                        <i class="bi bi-shield-shaded me-1"></i> LEVEL <?= $user['level'] ?> HERO
                    </div>

                    <!-- XP Progression Card -->
                    <div class="card-rpg p-3 text-start bg-dark border-secondary mb-3">
                        <div class="d-flex justify-content-between align-items-center mb-1">
                            <span class="text-secondary small fw-bold">LEVEL EXP PROGRESS</span>
                            <span class="text-warning small fw-bold"><?= $progress['percentage'] ?>%</span>
                        </div>
                        <div class="xp-progress-bar mb-2">
                            <div class="xp-progress-fill" style="width: <?= $progress['percentage'] ?>%;"></div>
                        </div>
                        <div class="d-flex justify-content-between text-muted" style="font-size: 0.75rem;">
                            <span>Total: <?= number_format($user['total_xp']) ?> XP</span>
                            <span>Next: <?= $progress['needed_xp'] ?> XP req</span>
                        </div>
                    </div>

                    <!-- Habit Streaks -->
                    <div class="row g-2 text-start">
                        <div class="col-6">
                            <div class="p-2 rounded bg-dark border border-secondary text-center">
                                <div class="text-danger fw-bold fs-5"><i class="bi bi-fire text-warning me-1"></i><?= $user['current_streak'] ?>d</div>
                                <small class="text-muted" style="font-size: 0.7rem;">CURRENT STREAK</small>
                            </div>
                        </div>
                        <div class="col-6">
                            <div class="p-2 rounded bg-dark border border-secondary text-center">
                                <div class="text-info fw-bold fs-5"><i class="bi bi-trophy text-info me-1"></i><?= $user['best_streak'] ?>d</div>
                                <small class="text-muted" style="font-size: 0.7rem;">BEST STREAK</small>
                            </div>
                        </div>
                    </div>

                    <!-- Meta details -->
                    <div class="mt-4 pt-3 border-top border-secondary text-start small text-secondary">
                        <div class="d-flex justify-content-between py-1">
                            <span>Quests Finished:</span>
                            <strong class="text-white"><?= $totalCompletedCount ?></strong>
                        </div>
                        <div class="d-flex justify-content-between py-1">
                            <span>Gold Balance:</span>
                            <strong class="text-warning"><i class="bi bi-coin me-1"></i><?= $user['gold'] ?></strong>
                        </div>
                        <div class="d-flex justify-content-between py-1">
                            <span>Joined Realm:</span>
                            <span class="text-white"><?= date('M j, Y', strtotime($user['created_at'])) ?></span>
                        </div>
                        <div class="d-flex justify-content-between py-1">
                            <span>Last Recorded Action:</span>
                            <span class="text-white"><?= time_ago($lastActivity) ?></span>
                        </div>
                    </div>
                </div>

                <!-- Skill Attributes Radar/Bars -->
                <div class="card-rpg">
                    <h5 class="fw-bold text-white mb-3"><i class="bi bi-pie-chart-fill text-warning me-2"></i>Attributes & Skills</h5>
                    
                    <?php foreach ($skills as $skillName => $skillValue): ?>
                        <div class="mb-3">
                            <div class="d-flex justify-content-between small mb-1">
                                <span class="text-secondary fw-semibold"><?= e($skillName) ?></span>
                                <span class="text-white fw-bold"><?= $skillValue ?> / 100</span>
                            </div>
                            <div class="progress" style="height: 6px; background-color: #0F172A;">
                                <div class="progress-bar bg-warning" role="progressbar" style="width: <?= min(100, max(0, $skillValue)) ?>%;"></div>
                            </div>
                        </div>
                    <?php endforeach; ?>
                </div>
            </div>

            <!-- Right Column: Recent Quests & Achievements -->
            <div class="col-12 col-lg-8">
                <!-- Recent Completed Quests -->
                <div class="card-rpg mb-4">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold text-white mb-0"><i class="bi bi-check2-circle text-success me-2"></i>Completed Quest History</h5>
                        <span class="badge badge-category"><?= count($recentTasks) ?> logged</span>
                    </div>

                    <?php if (empty($recentTasks)): ?>
                        <div class="text-center py-4 text-muted">
                            <i class="bi bi-journal-x fs-2 d-block mb-2"></i>
                            This hero has not completed any quests yet.
                        </div>
                    <?php else: ?>
                        <div class="table-responsive">
                            <table class="table-rpg">
                                <thead>
                                    <tr>
                                        <th>Quest Name</th>
                                        <th>Category</th>
                                        <th>XP Gained</th>
                                        <th>Completed At</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php foreach ($recentTasks as $task): ?>
                                        <tr>
                                            <td class="fw-bold text-white"><?= e($task['title']) ?></td>
                                            <td><span class="badge badge-category"><?= e($task['category']) ?></span></td>
                                            <td><span class="text-warning fw-bold">+<?= $task['xp_awarded'] ?> XP</span></td>
                                            <td class="text-muted small"><?= time_ago($task['completed_at']) ?></td>
                                        </tr>
                                    <?php endforeach; ?>
                                </tbody>
                            </table>
                        </div>
                    <?php endif; ?>
                </div>

                <!-- Unlocked Achievements -->
                <div class="card-rpg mb-4">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold text-white mb-0"><i class="bi bi-trophy-fill text-warning me-2"></i>Unlocked Trophies (<?= count($unlockedAchievements) ?>)</h5>
                    </div>

                    <?php if (empty($unlockedAchievements)): ?>
                        <div class="text-center py-4 text-muted">
                            <i class="bi bi-trophy fs-2 d-block mb-2"></i>
                            No achievements unlocked yet.
                        </div>
                    <?php else: ?>
                        <div class="row g-3">
                            <?php foreach ($unlockedAchievements as $ach): ?>
                                <div class="col-12 col-md-6">
                                    <div class="p-3 rounded bg-dark border border-secondary d-flex align-items-center gap-3">
                                        <div class="stat-icon-box icon-gold" style="width: 44px; height: 44px; font-size: 1.2rem; flex-shrink: 0;">
                                            <i class="bi bi-<?= e($ach['icon_name']) ?>"></i>
                                        </div>
                                        <div class="overflow-hidden">
                                            <h6 class="fw-bold text-white mb-0 text-truncate"><?= e($ach['name']) ?></h6>
                                            <p class="text-muted small mb-1 text-truncate"><?= e($ach['description']) ?></p>
                                            <span class="badge badge-gold py-0 px-1" style="font-size: 0.7rem;">+<?= $ach['xp_reward'] ?> XP &bull; <?= time_ago($ach['unlocked_at']) ?></span>
                                        </div>
                                    </div>
                                </div>
                            <?php endforeach; ?>
                        </div>
                    <?php endif; ?>
                </div>

                <!-- Hydration Tracking Logs -->
                <div class="card-rpg">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold text-white mb-0"><i class="bi bi-droplet-fill text-info me-2"></i>Hydration Activity</h5>
                        <span class="badge bg-info bg-opacity-25 text-info border border-info">Streak: <?= $user['hydration_current_streak'] ?>d</span>
                    </div>

                    <?php if (empty($hydrationLogs)): ?>
                        <div class="text-center py-3 text-muted">
                            No hydration logs recorded yet for this hero.
                        </div>
                    <?php else: ?>
                        <div class="list-group list-group-flush bg-transparent">
                            <?php foreach ($hydrationLogs as $hl): ?>
                                <div class="list-group-item bg-transparent px-0 py-2 border-bottom border-secondary d-flex justify-content-between align-items-center">
                                    <div>
                                        <i class="bi bi-droplet-half text-info me-2"></i>
                                        <span class="text-white fw-medium">Consumed <?= $hl['amount_ml'] ?> ml</span>
                                    </div>
                                    <small class="text-muted"><?= time_ago($hl['logged_at']) ?></small>
                                </div>
                            <?php endforeach; ?>
                        </div>
                    <?php endif; ?>
                </div>

            </div>
        </div>

    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
