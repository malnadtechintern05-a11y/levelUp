<?php
/**
 * LevelUp Web Admin Panel - Deep Analytics Engine
 */
require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/functions.php';

require_admin_auth();

$pageTitle = 'Realm Analytics & Intelligence';
$currentPage = 'analytics';

$db = getDB();

// 1. Process Date Filter
$filter = $_GET['range'] ?? '30';
$customFrom = $_GET['from'] ?? '';
$customTo = $_GET['to'] ?? '';

$startDate = '';
$endDate = date('Y-m-d 23:59:59');

if ($filter === 'today') {
    $startDate = date('Y-m-d 00:00:00');
} elseif ($filter === '7') {
    $startDate = date('Y-m-d 00:00:00', strtotime('-7 days'));
} elseif ($filter === '30') {
    $startDate = date('Y-m-d 00:00:00', strtotime('-30 days'));
} elseif ($filter === '90') {
    $startDate = date('Y-m-d 00:00:00', strtotime('-90 days'));
} elseif ($filter === 'custom' && !empty($customFrom)) {
    $startDate = date('Y-m-d 00:00:00', strtotime($customFrom));
    if (!empty($customTo)) {
        $endDate = date('Y-m-d 23:59:59', strtotime($customTo));
    }
} else {
    $filter = '30';
    $startDate = date('Y-m-d 00:00:00', strtotime('-30 days'));
}

// 2. Aggregate Key Analytics Metrics
$totalUsers = (int)$db->query("SELECT COUNT(*) FROM users")->fetchColumn();
$activeUsers = (int)$db->query("SELECT COUNT(*) FROM users WHERE is_active = 1")->fetchColumn();

// New users in date range
$newUsersStmt = $db->prepare("SELECT COUNT(*) FROM users WHERE created_at BETWEEN ? AND ?");
$newUsersStmt->execute([$startDate, $endDate]);
$newUsers = (int)$newUsersStmt->fetchColumn();

// Completed tasks in range
$compStmt = $db->prepare("SELECT COUNT(*), COALESCE(SUM(xp_awarded), 0) FROM task_completions WHERE completed_at BETWEEN ? AND ?");
$compStmt->execute([$startDate, $endDate]);
[$rangeCompletedTasks, $rangeXpEarned] = $compStmt->fetch(PDO::FETCH_NUM);
$rangeCompletedTasks = (int)$rangeCompletedTasks;
$rangeXpEarned = (int)$rangeXpEarned;

// Total quests in catalog
$totalTasksCatalog = (int)$db->query("SELECT COUNT(*) FROM tasks")->fetchColumn();
$allCompletedTasks = (int)$db->query("SELECT COUNT(*) FROM tasks WHERE is_completed = 1")->fetchColumn();
$completionRate = $totalTasksCatalog > 0 ? round(($allCompletedTasks / $totalTasksCatalog) * 100, 1) : 0;

$totalRealmXp = (int)$db->query("SELECT COALESCE(SUM(total_xp), 0) FROM users")->fetchColumn();
$avgXpPerUser = $totalUsers > 0 ? round($totalRealmXp / $totalUsers) : 0;
$avgTasksPerUser = $totalUsers > 0 ? round($allCompletedTasks / $totalUsers, 1) : 0;

// 3. Most Completed Task
$mostCompStmt = $db->query("
    SELECT t.title, t.category, COUNT(tc.id) as times_completed, SUM(tc.xp_awarded) as total_xp_generated
    FROM task_completions tc
    JOIN tasks t ON tc.task_id = t.id
    GROUP BY tc.task_id
    ORDER BY times_completed DESC
    LIMIT 1
");
$mostCompletedTask = $mostCompStmt->fetch();

// 4. Most Active Heroes
$activeHeroesStmt = $db->query("
    SELECT u.id, u.username, u.level, u.total_xp, u.current_streak,
           COUNT(tc.id) as quests_done
    FROM users u
    LEFT JOIN task_completions tc ON u.id = tc.user_id
    WHERE u.is_active = 1
    GROUP BY u.id
    ORDER BY quests_done DESC, u.total_xp DESC
    LIMIT 5
");
$mostActiveHeroes = $activeHeroesStmt->fetchAll();

// 5. Chart 1: Daily Task Completions in Selected Date Range
$dailyCompStmt = $db->prepare("
    SELECT DATE_FORMAT(completed_at, '%b %d') as dt_label, COUNT(*) as comp_count, SUM(xp_awarded) as xp_sum
    FROM task_completions
    WHERE completed_at BETWEEN ? AND ?
    GROUP BY DATE(completed_at)
    ORDER BY MIN(completed_at) ASC
");
$dailyCompStmt->execute([$startDate, $endDate]);
$dailyData = $dailyCompStmt->fetchAll();

$chartDailyLabels = array_column($dailyData, 'dt_label');
$chartDailyCompletions = array_map('intval', array_column($dailyData, 'comp_count'));
$chartDailyXp = array_map('intval', array_column($dailyData, 'xp_sum'));

// 6. Chart 2: Category Productivity Share
$catShareStmt = $db->query("
    SELECT t.category, COUNT(tc.id) as completion_count
    FROM tasks t
    LEFT JOIN task_completions tc ON t.id = tc.task_id
    GROUP BY t.category
");
$catShareData = $catShareStmt->fetchAll();
$chartCatNames = array_column($catShareData, 'category');
$chartCatCounts = array_map('intval', array_column($catShareData, 'completion_count'));

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/sidebar.php';
?>

<div class="admin-main">
    <?php require_once __DIR__ . '/includes/navbar.php'; ?>

    <div class="content-body">
        <?php display_flash_messages(); ?>

        <!-- Header with Date Filters -->
        <div class="d-flex flex-column flex-lg-row justify-content-between align-items-lg-center gap-3 mb-4">
            <div>
                <h2 class="fw-bold text-white mb-1">Realm Analytics & Progression Metrics</h2>
                <p class="text-secondary mb-0">Detailed breakdown of player retention, XP velocity, and quest throughput.</p>
            </div>

            <!-- Date Filter Pills -->
            <div class="card-rpg p-2">
                <div class="btn-group btn-group-sm flex-wrap">
                    <a href="?range=today" class="btn <?= $filter === 'today' ? 'btn-gold' : 'btn-dark-rpg' ?>">Today</a>
                    <a href="?range=7" class="btn <?= $filter === '7' ? 'btn-gold' : 'btn-dark-rpg' ?>">7 Days</a>
                    <a href="?range=30" class="btn <?= $filter === '30' ? 'btn-gold' : 'btn-dark-rpg' ?>">30 Days</a>
                    <a href="?range=90" class="btn <?= $filter === '90' ? 'btn-gold' : 'btn-dark-rpg' ?>">90 Days</a>
                    <button type="button" class="btn <?= $filter === 'custom' ? 'btn-gold' : 'btn-dark-rpg' ?>" data-bs-toggle="collapse" data-bs-target="#customRangeCollapse">
                        <i class="bi bi-calendar-range me-1"></i> Custom Range
                    </button>
                </div>
            </div>
        </div>

        <!-- Custom Range Collapse Form -->
        <div class="collapse <?= $filter === 'custom' ? 'show' : '' ?> mb-4" id="customRangeCollapse">
            <div class="card-rpg p-3 bg-dark">
                <form method="GET" action="analytics.php" class="row g-2 align-items-center">
                    <input type="hidden" name="range" value="custom">
                    <div class="col-12 col-sm-4">
                        <label class="form-label-rpg small">From Date</label>
                        <input type="date" name="from" class="form-control form-control-rpg" value="<?= e($customFrom) ?>" required>
                    </div>
                    <div class="col-12 col-sm-4">
                        <label class="form-label-rpg small">To Date</label>
                        <input type="date" name="to" class="form-control form-control-rpg" value="<?= e($customTo) ?>">
                    </div>
                    <div class="col-12 col-sm-4 d-flex align-items-end">
                        <button type="submit" class="btn btn-gold w-100"><i class="bi bi-filter me-1"></i> Apply Range</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Analytics Overview Stats -->
        <div class="row g-3 mb-4">
            <div class="col-6 col-md-3">
                <div class="card-rpg stat-card">
                    <div class="stat-lbl">New Heroes in Range</div>
                    <div class="stat-val text-info">+<?= number_format($newUsers) ?></div>
                    <small class="text-muted">Total: <?= number_format($totalUsers) ?></small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="card-rpg stat-card">
                    <div class="stat-lbl">Quests Finished in Range</div>
                    <div class="stat-val text-success"><?= number_format($rangeCompletedTasks) ?></div>
                    <small class="text-muted">Overall Rate: <?= $completionRate ?>%</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="card-rpg stat-card">
                    <div class="stat-lbl">XP Earned in Range</div>
                    <div class="stat-val text-warning">+<?= number_format($rangeXpEarned) ?></div>
                    <small class="text-muted">Realm Avg: <?= number_format($avgXpPerUser) ?> XP/hero</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="card-rpg stat-card">
                    <div class="stat-lbl">Avg Quests / Hero</div>
                    <div class="stat-val text-white"><?= $avgTasksPerUser ?></div>
                    <small class="text-muted">Active: <?= $activeUsers ?> questers</small>
                </div>
            </div>
        </div>

        <!-- Charts Row -->
        <div class="row g-4 mb-4">
            <!-- Line Chart: Completions & XP Velocity -->
            <div class="col-12 col-lg-8">
                <div class="card-rpg">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <div>
                            <h5 class="fw-bold mb-0">Quest Velocity & Experience Flow</h5>
                            <small class="text-secondary">Historical completion timeline across chosen timeframe</small>
                        </div>
                        <span class="badge badge-gold"><i class="bi bi-graph-up me-1"></i>Dynamic</span>
                    </div>
                    <div style="position: relative; height: 320px;">
                        <canvas id="velocityChart"></canvas>
                    </div>
                </div>
            </div>

            <!-- Doughnut Chart: Category Distribution -->
            <div class="col-12 col-lg-4">
                <div class="card-rpg">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <div>
                            <h5 class="fw-bold mb-0">Discipline Distribution</h5>
                            <small class="text-secondary">Completions by quest category</small>
                        </div>
                    </div>
                    <div style="position: relative; height: 320px;">
                        <canvas id="categoryDoughnut"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <!-- Tables Row: Most Completed Task & Most Active Heroes -->
        <div class="row g-4">
            <!-- Most Completed Quest Card -->
            <div class="col-12 col-lg-5">
                <div class="card-rpg h-100">
                    <h5 class="fw-bold text-white mb-3"><i class="bi bi-star-fill text-warning me-2"></i>Most Popular Quest</h5>

                    <?php if ($mostCompletedTask): ?>
                        <div class="p-4 rounded bg-dark border border-secondary text-center">
                            <div class="stat-icon-box icon-gold mx-auto mb-3" style="width: 56px; height: 56px; font-size: 1.6rem;">
                                <i class="bi bi-fire"></i>
                            </div>
                            <h4 class="fw-bold text-white mb-1"><?= e($mostCompletedTask['title']) ?></h4>
                            <span class="badge badge-category mb-3"><?= e($mostCompletedTask['category']) ?></span>

                            <div class="row g-2 mt-2 pt-2 border-top border-secondary">
                                <div class="col-6">
                                    <div class="text-success fw-bold fs-5"><?= number_format($mostCompletedTask['times_completed']) ?></div>
                                    <small class="text-muted">TIMES COMPLETED</small>
                                </div>
                                <div class="col-6">
                                    <div class="text-warning fw-bold fs-5">+<?= number_format($mostCompletedTask['total_xp_generated']) ?> XP</div>
                                    <small class="text-muted">TOTAL XP AWARDED</small>
                                </div>
                            </div>
                        </div>
                    <?php else: ?>
                        <div class="text-center py-4 text-muted">No quest completions recorded yet.</div>
                    <?php endif; ?>
                </div>
            </div>

            <!-- Most Active Heroes Table -->
            <div class="col-12 col-lg-7">
                <div class="card-rpg h-100">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold text-white mb-0"><i class="bi bi-award-fill text-warning me-2"></i>Most Active Heroes</h5>
                        <a href="leaderboard.php" class="text-warning small text-decoration-none">Full Leaderboard &rarr;</a>
                    </div>

                    <div class="table-responsive">
                        <table class="table-rpg">
                            <thead>
                                <tr>
                                    <th>Hero</th>
                                    <th>Level</th>
                                    <th>Quests Completed</th>
                                    <th>Current Streak</th>
                                    <th class="text-end">Total XP</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($mostActiveHeroes as $idx => $hero): ?>
                                    <tr>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <span class="fw-bold text-warning" style="width: 20px;">#<?= $idx + 1 ?></span>
                                                <a href="user-view.php?id=<?= $hero['id'] ?>" class="text-white fw-semibold text-decoration-none">
                                                    <?= e($hero['username']) ?>
                                                </a>
                                            </div>
                                        </td>
                                        <td>
                                            <span class="level-badge py-0 px-2">LVL <?= $hero['level'] ?></span>
                                        </td>
                                        <td>
                                            <span class="badge badge-category"><?= $hero['quests_done'] ?> finished</span>
                                        </td>
                                        <td>
                                            <span class="text-danger fw-bold small"><i class="bi bi-fire text-warning me-1"></i><?= $hero['current_streak'] ?>d</span>
                                        </td>
                                        <td class="text-end text-warning fw-bold">
                                            <?= number_format($hero['total_xp']) ?> XP
                                        </td>
                                    </tr>
                                <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', () => {
    Chart.defaults.color = '#94A3B8';
    Chart.defaults.borderColor = '#1E293B';

    // 1. Velocity Chart
    const ctxVel = document.getElementById('velocityChart');
    if (ctxVel) {
        new Chart(ctxVel, {
            type: 'bar',
            data: {
                labels: <?= json_encode(!empty($chartDailyLabels) ? $chartDailyLabels : ['Day 1', 'Day 2', 'Day 3']) ?>,
                datasets: [
                    {
                        type: 'line',
                        label: 'XP Gained',
                        data: <?= json_encode(!empty($chartDailyXp) ? $chartDailyXp : [120, 240, 180]) ?>,
                        borderColor: '#F5B942',
                        backgroundColor: 'rgba(245, 185, 66, 0.1)',
                        borderWidth: 2,
                        tension: 0.3,
                        yAxisID: 'y1'
                    },
                    {
                        type: 'bar',
                        label: 'Completed Quests',
                        data: <?= json_encode(!empty($chartDailyCompletions) ? $chartDailyCompletions : [2, 4, 3]) ?>,
                        backgroundColor: '#38BDF8',
                        borderRadius: 4,
                        yAxisID: 'y'
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { position: 'top' } },
                scales: {
                    x: { grid: { display: false } },
                    y: { beginAtZero: true, grid: { color: 'rgba(30, 41, 59, 0.6)' }, title: { display: true, text: 'Quests' } },
                    y1: { position: 'right', beginAtZero: true, grid: { display: false }, title: { display: true, text: 'XP' } }
                }
            }
        });
    }

    // 2. Category Doughnut Chart
    const ctxDoughnut = document.getElementById('categoryDoughnut');
    if (ctxDoughnut) {
        new Chart(ctxDoughnut, {
            type: 'doughnut',
            data: {
                labels: <?= json_encode(!empty($chartCatNames) ? $chartCatNames : ['Fitness', 'Study', 'Personal']) ?>,
                datasets: [{
                    data: <?= json_encode(!empty($chartCatCounts) ? $chartCatCounts : [4, 3, 2]) ?>,
                    backgroundColor: ['#F5B942', '#38BDF8', '#10B981', '#A855F7', '#EF4444', '#64748B'],
                    borderWidth: 2,
                    borderColor: '#162033'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { position: 'bottom', labels: { boxWidth: 12 } } }
            }
        });
    }
});
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
