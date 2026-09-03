<?php
/**
 * LevelUp Web Admin Panel - Main Dashboard
 */
require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/functions.php';

require_admin_auth();

$pageTitle = 'Command Dashboard';
$currentPage = 'dashboard';

$db = getDB();

// 1. KPI Statistics from Database
$totalUsers = (int)$db->query("SELECT COUNT(*) FROM users")->fetchColumn();
$activeUsers = (int)$db->query("SELECT COUNT(*) FROM users WHERE is_active = 1")->fetchColumn();
$totalTasks = (int)$db->query("SELECT COUNT(*) FROM tasks")->fetchColumn();
$completedTasks = (int)$db->query("SELECT COUNT(*) FROM tasks WHERE is_completed = 1")->fetchColumn();
$totalXP = (int)$db->query("SELECT COALESCE(SUM(total_xp), 0) FROM users")->fetchColumn();
$unlockedAchievements = (int)$db->query("SELECT COUNT(*) FROM user_achievements")->fetchColumn();

// Percentages for indicators
$activeUserPercent = $totalUsers > 0 ? round(($activeUsers / $totalUsers) * 100) : 0;
$taskCompletionPercent = $totalTasks > 0 ? round(($completedTasks / $totalTasks) * 100) : 0;

// 2. Chart A: User Registrations Over Time
$userGrowthStmt = $db->query("
    SELECT DATE_FORMAT(created_at, '%b %d') as date_label, COUNT(*) as new_users 
    FROM users 
    GROUP BY DATE(created_at) 
    ORDER BY MIN(created_at) ASC 
    LIMIT 10
");
$userGrowthData = $userGrowthStmt->fetchAll();
$chartUserLabels = array_column($userGrowthData, 'date_label');
$chartUserCounts = array_map('intval', array_column($userGrowthData, 'new_users'));

// 3. Chart B: Task Breakdown by Category (Completed vs Pending)
$taskCatStmt = $db->query("
    SELECT category, 
           SUM(CASE WHEN is_completed = 1 THEN 1 ELSE 0 END) as completed_count,
           SUM(CASE WHEN is_completed = 0 THEN 1 ELSE 0 END) as pending_count
    FROM tasks 
    GROUP BY category
");
$taskCatData = $taskCatStmt->fetchAll();
$chartCatLabels = array_column($taskCatData, 'category');
$chartCatCompleted = array_map('intval', array_column($taskCatData, 'completed_count'));
$chartCatPending = array_map('intval', array_column($taskCatData, 'pending_count'));

// 4. Chart C: XP Earned Distribution Over Time
$xpGrowthStmt = $db->query("
    SELECT DATE_FORMAT(completed_at, '%b %d') as date_label, SUM(xp_awarded) as xp_amount
    FROM task_completions
    GROUP BY DATE(completed_at)
    ORDER BY MIN(completed_at) ASC
    LIMIT 10
");
$xpGrowthData = $xpGrowthStmt->fetchAll();
$chartXpLabels = array_column($xpGrowthData, 'date_label');
$chartXpAmounts = array_map('intval', array_column($xpGrowthData, 'xp_amount'));

// 5. Chart D: Top 5 Active Users by XP
$topUsersStmt = $db->query("
    SELECT username, total_xp, level 
    FROM users 
    WHERE is_active = 1 
    ORDER BY total_xp DESC 
    LIMIT 5
");
$topUsersData = $topUsersStmt->fetchAll();
$chartTopLabels = array_column($topUsersData, 'username');
$chartTopXp = array_map('intval', array_column($topUsersData, 'total_xp'));

// 6. Recent Activity Feed
$activitiesStmt = $db->query("
    SELECT a.*, u.username as hero_name, u.avatar_id, adm.username as admin_name
    FROM activity_logs a
    LEFT JOIN users u ON a.user_id = u.id
    LEFT JOIN admins adm ON a.admin_id = adm.id
    ORDER BY a.created_at DESC
    LIMIT 7
");
$recentActivities = $activitiesStmt->fetchAll();

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/sidebar.php';
?>

<div class="admin-main">
    <?php require_once __DIR__ . '/includes/navbar.php'; ?>

    <div class="content-body">
        <?php display_flash_messages(); ?>

        <!-- Welcome Banner & Quick Actions -->
        <div class="row align-items-center mb-4">
            <div class="col-12 col-md-6 mb-3 mb-md-0">
                <h2 class="fw-bold text-white mb-1">RPG Operations Center</h2>
                <p class="text-secondary mb-0">System status optimal. Real-time metrics aggregated across all active heroes.</p>
            </div>
            <div class="col-12 col-md-6 text-md-end d-flex flex-wrap justify-content-md-end gap-2">
                <a href="task-add.php" class="btn btn-gold">
                    <i class="bi bi-plus-circle-fill"></i> New Quest
                </a>
                <a href="users.php" class="btn btn-dark-rpg">
                    <i class="bi bi-person-plus-fill"></i> Manage Users
                </a>
                <a href="notifications.php" class="btn btn-dark-rpg">
                    <i class="bi bi-broadcast"></i> Broadcast Alert
                </a>
            </div>
        </div>

        <!-- Metric KPI Cards (6 Key Indicators) -->
        <div class="row g-3 mb-4">
            <!-- Total Users -->
            <div class="col-12 col-sm-6 col-xl-4">
                <div class="card-rpg stat-card">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="stat-lbl">Registered Heroes</div>
                            <div class="stat-val"><?= number_format($totalUsers) ?></div>
                        </div>
                        <div class="stat-icon-box icon-blue">
                            <i class="bi bi-people-fill"></i>
                        </div>
                    </div>
                    <div class="mt-3 pt-2 border-top border-secondary d-flex justify-content-between align-items-center">
                        <span class="text-secondary small">Active Roster</span>
                        <span class="stat-badge text-success bg-success bg-opacity-10 border border-success border-opacity-25">
                            <i class="bi bi-dot fs-5"></i><?= $activeUserPercent ?>% Active
                        </span>
                    </div>
                </div>
            </div>

            <!-- Active Users -->
            <div class="col-12 col-sm-6 col-xl-4">
                <div class="card-rpg stat-card">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="stat-lbl">Active Questers</div>
                            <div class="stat-val text-success"><?= number_format($activeUsers) ?></div>
                        </div>
                        <div class="stat-icon-box icon-green">
                            <i class="bi bi-person-check-fill"></i>
                        </div>
                    </div>
                    <div class="mt-3 pt-2 border-top border-secondary d-flex justify-content-between align-items-center">
                        <span class="text-secondary small">Daily Active Rate</span>
                        <span class="badge badge-active"><?= $activeUsers ?> online / ready</span>
                    </div>
                </div>
            </div>

            <!-- Total Tasks -->
            <div class="col-12 col-sm-6 col-xl-4">
                <div class="card-rpg stat-card">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="stat-lbl">Total Quests Catalog</div>
                            <div class="stat-val"><?= number_format($totalTasks) ?></div>
                        </div>
                        <div class="stat-icon-box icon-purple">
                            <i class="bi bi-journal-bookmark-fill"></i>
                        </div>
                    </div>
                    <div class="mt-3 pt-2 border-top border-secondary d-flex justify-content-between align-items-center">
                        <span class="text-secondary small">Completion Rate</span>
                        <span class="badge badge-gold"><?= $taskCompletionPercent ?>% Finished</span>
                    </div>
                </div>
            </div>

            <!-- Completed Tasks -->
            <div class="col-12 col-sm-6 col-xl-4">
                <div class="card-rpg stat-card">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="stat-lbl">Completed Quests</div>
                            <div class="stat-val text-warning"><?= number_format($completedTasks) ?></div>
                        </div>
                        <div class="stat-icon-box icon-gold">
                            <i class="bi bi-check2-circle"></i>
                        </div>
                    </div>
                    <div class="mt-3 pt-2 border-top border-secondary d-flex justify-content-between align-items-center">
                        <span class="text-secondary small">Pending Tasks</span>
                        <span class="text-muted small"><?= ($totalTasks - $completedTasks) ?> remaining</span>
                    </div>
                </div>
            </div>

            <!-- Total XP Earned -->
            <div class="col-12 col-sm-6 col-xl-4">
                <div class="card-rpg stat-card">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="stat-lbl">Total Experience Points (XP)</div>
                            <div class="stat-val" style="color: #F5B942;"><?= number_format($totalXP) ?></div>
                        </div>
                        <div class="stat-icon-box icon-gold">
                            <i class="bi bi-lightning-charge-fill"></i>
                        </div>
                    </div>
                    <div class="mt-3 pt-2 border-top border-secondary d-flex justify-content-between align-items-center">
                        <span class="text-secondary small">Avg XP / Hero</span>
                        <span class="text-warning fw-semibold small"><?= $totalUsers > 0 ? number_format(round($totalXP / $totalUsers)) : 0 ?> XP</span>
                    </div>
                </div>
            </div>

            <!-- Achievements Unlocked -->
            <div class="col-12 col-sm-6 col-xl-4">
                <div class="card-rpg stat-card">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="stat-lbl">Achievements Claimed</div>
                            <div class="stat-val" style="color: #A855F7;"><?= number_format($unlockedAchievements) ?></div>
                        </div>
                        <div class="stat-icon-box icon-purple">
                            <i class="bi bi-trophy-fill"></i>
                        </div>
                    </div>
                    <div class="mt-3 pt-2 border-top border-secondary d-flex justify-content-between align-items-center">
                        <span class="text-secondary small">Trophies System</span>
                        <span class="badge bg-purple bg-opacity-25 text-white border border-purple">Active</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Real Chart.js Row 1: User Growth & Task Completion -->
        <div class="row g-4 mb-4">
            <div class="col-12 col-lg-7">
                <div class="card-rpg">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <div>
                            <h5 class="fw-bold mb-0">Hero Growth Velocity</h5>
                            <small class="text-secondary">New account registrations over recent time periods</small>
                        </div>
                        <span class="badge badge-gold"><i class="bi bi-graph-up me-1"></i>Live Data</span>
                    </div>
                    <div style="position: relative; height: 280px;">
                        <canvas id="userGrowthChart"></canvas>
                    </div>
                </div>
            </div>

            <div class="col-12 col-lg-5">
                <div class="card-rpg">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <div>
                            <h5 class="fw-bold mb-0">Task Completion by Category</h5>
                            <small class="text-secondary">Completed vs pending quest ratios</small>
                        </div>
                        <span class="badge badge-category">Categorical</span>
                    </div>
                    <div style="position: relative; height: 280px;">
                        <canvas id="taskCategoryChart"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <!-- Real Chart.js Row 2 & Recent Activity Feed -->
        <div class="row g-4">
            <!-- XP Earned Distribution Chart -->
            <div class="col-12 col-lg-6">
                <div class="card-rpg">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <div>
                            <h5 class="fw-bold mb-0">XP Distribution Flow</h5>
                            <small class="text-secondary">XP earned by users via task completions</small>
                        </div>
                        <span class="badge badge-gold"><i class="bi bi-lightning-fill me-1"></i>XP Logged</span>
                    </div>
                    <div style="position: relative; height: 280px;">
                        <canvas id="xpDistributionChart"></canvas>
                    </div>
                </div>
            </div>

            <!-- Recent Activity Timeline -->
            <div class="col-12 col-lg-6">
                <div class="card-rpg h-100">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <div>
                            <h5 class="fw-bold mb-0">Recent RPG Activity</h5>
                            <small class="text-secondary">Live events logged across the realm</small>
                        </div>
                        <span class="badge badge-active"><i class="bi bi-activity me-1"></i>Live Stream</span>
                    </div>

                    <?php if (empty($recentActivities)): ?>
                        <div class="text-center py-4 text-muted">
                            <i class="bi bi-inbox fs-2 d-block mb-2"></i>
                            No activity logged yet.
                        </div>
                    <?php else: ?>
                        <div class="list-group list-group-flush bg-transparent">
                            <?php foreach ($recentActivities as $act): ?>
                                <?php
                                $badgeColor = match($act['activity_type']) {
                                    'task_completed' => 'text-success bg-success',
                                    'level_up' => 'text-warning bg-warning',
                                    'achievement_unlocked' => 'text-info bg-info',
                                    'user_registered' => 'text-primary bg-primary',
                                    default => 'text-secondary bg-secondary'
                                };
                                $iconClass = match($act['activity_type']) {
                                    'task_completed' => 'bi-check2-all',
                                    'level_up' => 'bi-arrow-up-circle-fill',
                                    'achievement_unlocked' => 'bi-trophy-fill',
                                    'user_registered' => 'bi-person-plus-fill',
                                    default => 'bi-shield-check'
                                };
                                ?>
                                <div class="list-group-item bg-transparent px-0 py-3 border-bottom border-secondary d-flex align-items-center gap-3">
                                    <div class="stat-icon-box <?= $badgeColor ?> bg-opacity-10 border border-opacity-25" style="width: 40px; height: 40px; font-size: 1.1rem; flex-shrink: 0;">
                                        <i class="bi <?= $iconClass ?>"></i>
                                    </div>
                                    <div class="flex-grow-1 overflow-hidden">
                                        <div class="text-white small text-truncate fw-medium"><?= e($act['description']) ?></div>
                                        <div class="d-flex align-items-center gap-2 mt-1">
                                            <?php if ($act['hero_name']): ?>
                                                <span class="badge badge-category py-0 px-1" style="font-size: 0.7rem;"><?= e($act['hero_name']) ?></span>
                                            <?php endif; ?>
                                            <span class="text-muted" style="font-size: 0.75rem;"><i class="bi bi-clock me-1"></i><?= time_ago($act['created_at']) ?></span>
                                        </div>
                                    </div>
                                </div>
                            <?php endforeach; ?>
                        </div>
                    <?php endif; ?>
                </div>
            </div>
        </div>

    </div> <!-- End .content-body -->

<!-- Chart.js Setup Scripts -->
<script>
document.addEventListener('DOMContentLoaded', () => {
    Chart.defaults.color = '#94A3B8';
    Chart.defaults.borderColor = '#1E293B';
    Chart.defaults.font.family = "'Inter', sans-serif";

    // 1. User Growth Chart
    const ctxUser = document.getElementById('userGrowthChart');
    if (ctxUser) {
        new Chart(ctxUser, {
            type: 'line',
            data: {
                labels: <?= json_encode(!empty($chartUserLabels) ? $chartUserLabels : ['Day 1', 'Day 2', 'Day 3', 'Today']) ?>,
                datasets: [{
                    label: 'New Heroes',
                    data: <?= json_encode(!empty($chartUserCounts) ? $chartUserCounts : [2, 4, 3, 5]) ?>,
                    borderColor: '#38BDF8',
                    backgroundColor: 'rgba(56, 189, 248, 0.1)',
                    borderWidth: 2,
                    tension: 0.35,
                    fill: true,
                    pointBackgroundColor: '#38BDF8',
                    pointRadius: 4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: {
                    y: { beginAtZero: true, grid: { color: 'rgba(30, 41, 59, 0.6)' } },
                    x: { grid: { display: false } }
                }
            }
        });
    }

    // 2. Task Category Doughnut / Bar
    const ctxCat = document.getElementById('taskCategoryChart');
    if (ctxCat) {
        new Chart(ctxCat, {
            type: 'bar',
            data: {
                labels: <?= json_encode(!empty($chartCatLabels) ? $chartCatLabels : ['Fitness', 'Study', 'Hydration']) ?>,
                datasets: [
                    {
                        label: 'Completed',
                        data: <?= json_encode(!empty($chartCatCompleted) ? $chartCatCompleted : [1, 2, 0]) ?>,
                        backgroundColor: '#F5B942',
                        borderRadius: 4
                    },
                    {
                        label: 'Pending',
                        data: <?= json_encode(!empty($chartCatPending) ? $chartCatPending : [1, 1, 1]) ?>,
                        backgroundColor: '#334155',
                        borderRadius: 4
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { position: 'bottom', labels: { boxWidth: 12 } } },
                scales: {
                    x: { stacked: true, grid: { display: false } },
                    y: { stacked: true, beginAtZero: true, grid: { color: 'rgba(30, 41, 59, 0.6)' } }
                }
            }
        });
    }

    // 3. XP Earned Flow Chart
    const ctxXp = document.getElementById('xpDistributionChart');
    if (ctxXp) {
        new Chart(ctxXp, {
            type: 'line',
            data: {
                labels: <?= json_encode(!empty($chartXpLabels) ? $chartXpLabels : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']) ?>,
                datasets: [{
                    label: 'XP Gained',
                    data: <?= json_encode(!empty($chartXpAmounts) ? $chartXpAmounts : [100, 250, 180, 320, 410]) ?>,
                    borderColor: '#F5B942',
                    backgroundColor: 'rgba(245, 185, 66, 0.15)',
                    borderWidth: 2,
                    tension: 0.35,
                    fill: true,
                    pointBackgroundColor: '#F5B942',
                    pointRadius: 4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: {
                    y: { beginAtZero: true, grid: { color: 'rgba(30, 41, 59, 0.6)' } },
                    x: { grid: { display: false } }
                }
            }
        });
    }
});
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
