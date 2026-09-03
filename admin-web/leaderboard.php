<?php
/**
 * LevelUp Web Admin Panel - Gamified Leaderboard
 */
require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/functions.php';

require_admin_auth();

$pageTitle = 'Realm Hall of Fame & Leaderboard';
$currentPage = 'leaderboard';

$db = getDB();

// Criteria selector: xp, level, tasks, streak
$metric = $_GET['metric'] ?? 'xp';

$orderClause = match($metric) {
    'level' => 'u.level DESC, u.total_xp DESC',
    'tasks' => 'tasks_done DESC, u.total_xp DESC',
    'streak' => 'u.current_streak DESC, u.total_xp DESC',
    default => 'u.total_xp DESC, u.level DESC'
};

$query = "
    SELECT u.*, 
           (SELECT COUNT(*) FROM task_completions tc WHERE tc.user_id = u.id) as tasks_done,
           (SELECT COUNT(*) FROM user_achievements ua WHERE ua.user_id = u.id) as trophies_won
    FROM users u
    WHERE u.is_active = 1
    ORDER BY $orderClause
    LIMIT 20
";
$topHeroes = $db->query($query)->fetchAll();

// Separate top 3 for podium
$podium1 = $topHeroes[0] ?? null;
$podium2 = $topHeroes[1] ?? null;
$podium3 = $topHeroes[2] ?? null;

$restOfHeroes = array_slice($topHeroes, 3);

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/sidebar.php';
?>

<div class="admin-main">
    <?php require_once __DIR__ . '/includes/navbar.php'; ?>

    <div class="content-body">
        <?php display_flash_messages(); ?>

        <!-- Header -->
        <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
            <div>
                <h2 class="fw-bold text-white mb-1">Hall of Fame & Leaderboard</h2>
                <p class="text-secondary mb-0">Ranking heroes across all disciplines of the LevelUp RPG universe.</p>
            </div>

            <!-- Metric Filter -->
            <div class="btn-group">
                <a href="?metric=xp" class="btn <?= $metric === 'xp' ? 'btn-gold' : 'btn-dark-rpg' ?>">
                    <i class="bi bi-lightning-charge-fill me-1"></i> XP Rank
                </a>
                <a href="?metric=level" class="btn <?= $metric === 'level' ? 'btn-gold' : 'btn-dark-rpg' ?>">
                    <i class="bi bi-shield-fill me-1"></i> Level Rank
                </a>
                <a href="?metric=tasks" class="btn <?= $metric === 'tasks' ? 'btn-gold' : 'btn-dark-rpg' ?>">
                    <i class="bi bi-check2-circle me-1"></i> Quests Done
                </a>
                <a href="?metric=streak" class="btn <?= $metric === 'streak' ? 'btn-gold' : 'btn-dark-rpg' ?>">
                    <i class="bi bi-fire me-1"></i> Daily Streak
                </a>
            </div>
        </div>

        <!-- Top 3 Podium Cards -->
        <?php if ($podium1): ?>
            <div class="row g-3 justify-content-center align-items-end mb-4">
                <!-- 2nd Place (Silver) -->
                <?php if ($podium2): ?>
                    <div class="col-12 col-md-4 order-2 order-md-1">
                        <div class="podium-card podium-rank-2">
                            <span class="badge rounded-pill bg-secondary px-3 py-1 mb-3 fw-bold">#2 SILVER</span>
                            <div class="avatar-ring mx-auto mb-3" style="width: 60px; height: 60px; font-size: 1.5rem; border-color: #94A3B8;">
                                <?= strtoupper(substr($podium2['username'], 0, 1)) ?>
                            </div>
                            <h5 class="fw-bold text-white mb-1"><?= e($podium2['username']) ?></h5>
                            <div class="level-badge mb-2">LVL <?= $podium2['level'] ?></div>
                            <div class="text-warning fw-bold fs-5 mb-2"><?= number_format($podium2['total_xp']) ?> XP</div>
                            <div class="d-flex justify-content-center gap-3 text-muted small">
                                <span><i class="bi bi-check2 me-1 text-success"></i><?= $podium2['tasks_done'] ?> quests</span>
                                <span><i class="bi bi-fire me-1 text-warning"></i><?= $podium2['current_streak'] ?>d streak</span>
                            </div>
                            <a href="user-view.php?id=<?= $podium2['id'] ?>" class="btn btn-dark-rpg btn-sm mt-3 w-100">Inspect Hero</a>
                        </div>
                    </div>
                <?php endif; ?>

                <!-- 1st Place (Gold Champion) -->
                <div class="col-12 col-md-4 order-1 order-md-2">
                    <div class="podium-card podium-rank-1 pb-4">
                        <div class="position-absolute top-0 start-50 translate-middle">
                            <span class="badge badge-gold px-3 py-2 fw-black shadow-lg" style="font-size: 0.85rem;">
                                <i class="bi bi-crown-fill me-1"></i> #1 CHAMPION
                            </span>
                        </div>
                        <div class="avatar-ring mx-auto mb-3 mt-2" style="width: 76px; height: 76px; font-size: 2rem; border-width: 3px;">
                            <?= strtoupper(substr($podium1['username'], 0, 1)) ?>
                        </div>
                        <h4 class="fw-bold text-white mb-1"><?= e($podium1['username']) ?></h4>
                        <div class="level-badge mb-2 fs-6">LEVEL <?= $podium1['level'] ?></div>
                        <div class="fs-4 fw-black mb-2" style="color: #F5B942;"><?= number_format($podium1['total_xp']) ?> XP</div>
                        <div class="d-flex justify-content-center gap-3 text-secondary small">
                            <span><i class="bi bi-check2-circle text-success me-1"></i><?= $podium1['tasks_done'] ?> quests</span>
                            <span><i class="bi bi-fire text-warning me-1"></i><?= $podium1['current_streak'] ?>d streak</span>
                            <span><i class="bi bi-trophy text-info me-1"></i><?= $podium1['trophies_won'] ?> trophies</span>
                        </div>
                        <a href="user-view.php?id=<?= $podium1['id'] ?>" class="btn btn-gold btn-sm mt-3 w-100">Inspect Champion</a>
                    </div>
                </div>

                <!-- 3rd Place (Bronze) -->
                <?php if ($podium3): ?>
                    <div class="col-12 col-md-4 order-3 order-md-3">
                        <div class="podium-card podium-rank-3">
                            <span class="badge rounded-pill px-3 py-1 mb-3 fw-bold" style="background-color: #CD7F32; color: #fff;">#3 BRONZE</span>
                            <div class="avatar-ring mx-auto mb-3" style="width: 60px; height: 60px; font-size: 1.5rem; border-color: #CD7F32;">
                                <?= strtoupper(substr($podium3['username'], 0, 1)) ?>
                            </div>
                            <h5 class="fw-bold text-white mb-1"><?= e($podium3['username']) ?></h5>
                            <div class="level-badge mb-2">LVL <?= $podium3['level'] ?></div>
                            <div class="text-warning fw-bold fs-5 mb-2"><?= number_format($podium3['total_xp']) ?> XP</div>
                            <div class="d-flex justify-content-center gap-3 text-muted small">
                                <span><i class="bi bi-check2 me-1 text-success"></i><?= $podium3['tasks_done'] ?> quests</span>
                                <span><i class="bi bi-fire me-1 text-warning"></i><?= $podium3['current_streak'] ?>d streak</span>
                            </div>
                            <a href="user-view.php?id=<?= $podium3['id'] ?>" class="btn btn-dark-rpg btn-sm mt-3 w-100">Inspect Hero</a>
                        </div>
                    </div>
                <?php endif; ?>
            </div>
        <?php endif; ?>

        <!-- Ranked Roster Table -->
        <div class="card-rpg p-0 overflow-hidden">
            <div class="p-3 border-bottom border-secondary d-flex justify-content-between align-items-center">
                <h5 class="fw-bold text-white mb-0">Contenders Ranking (#4 onwards)</h5>
                <span class="badge badge-category"><?= count($topHeroes) ?> Total Ranked</span>
            </div>

            <div class="table-responsive">
                <table class="table-rpg">
                    <thead>
                        <tr>
                            <th style="width: 60px;">Rank</th>
                            <th>Hero</th>
                            <th>Level</th>
                            <th>Total XP</th>
                            <th>Quests Done</th>
                            <th>Daily Streak</th>
                            <th>Trophies</th>
                            <th class="text-end">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php if (empty($restOfHeroes)): ?>
                            <tr>
                                <td colspan="8" class="text-center py-4 text-muted">No additional heroes in ranking.</td>
                            </tr>
                        <?php else: ?>
                            <?php foreach ($restOfHeroes as $idx => $hero): ?>
                                <tr>
                                    <td class="fw-bold text-secondary fs-6">#<?= $idx + 4 ?></td>
                                    <td>
                                        <div class="d-flex align-items-center gap-2">
                                            <div class="avatar-ring" style="width: 32px; height: 32px; font-size: 0.8rem;">
                                                <?= strtoupper(substr($hero['username'], 0, 1)) ?>
                                            </div>
                                            <a href="user-view.php?id=<?= $hero['id'] ?>" class="text-white fw-semibold text-decoration-none">
                                                <?= e($hero['username']) ?>
                                            </a>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="level-badge py-0 px-2">LVL <?= $hero['level'] ?></span>
                                    </td>
                                    <td class="text-warning fw-bold">
                                        <?= number_format($hero['total_xp']) ?> XP
                                    </td>
                                    <td>
                                        <span class="badge badge-category"><?= $hero['tasks_done'] ?></span>
                                    </td>
                                    <td>
                                        <span class="text-danger fw-bold small"><i class="bi bi-fire text-warning me-1"></i><?= $hero['current_streak'] ?>d</span>
                                    </td>
                                    <td>
                                        <span class="text-info fw-semibold small"><i class="bi bi-trophy-fill text-warning me-1"></i><?= $hero['trophies_won'] ?></span>
                                    </td>
                                    <td class="text-end">
                                        <a href="user-view.php?id=<?= $hero['id'] ?>" class="btn btn-dark-rpg btn-sm py-0 px-2">Inspect</a>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>

    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
