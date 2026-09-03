<?php
/**
 * LevelUp Web Admin Panel - Quest Task Management
 */
require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/functions.php';

require_admin_auth();

$pageTitle = 'Quest Catalog & Tasks';
$currentPage = 'tasks';

$db = getDB();
$currentDate = date('Y-m-d');

// Handle POST actions: Activate, Deactivate, Delete, Complete
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    $taskId = trim($_POST['task_id'] ?? '');
    $csrfToken = $_POST['csrf_token'] ?? '';
    $adminOverride = isset($_POST['admin_override']) && $_POST['admin_override'] == '1';

    if (!verify_csrf_token($csrfToken)) {
        set_flash('danger', 'Security validation failed (invalid CSRF token).');
        header('Location: tasks.php');
        exit;
    }

    if (!empty($taskId)) {
        // Fetch task
        $tStmt = $db->prepare("SELECT * FROM tasks WHERE id = ?");
        $tStmt->execute([$taskId]);
        $task = $tStmt->fetch();

        if ($task) {
            if ($action === 'activate') {
                $stmt = $db->prepare("UPDATE tasks SET is_active = 1 WHERE id = ?");
                $stmt->execute([$taskId]);
                log_activity(null, $_SESSION['admin_id'] ?? null, 'admin_action', "Activated quest '{$task['title']}'");
                set_flash('success', "Quest '{$task['title']}' activated.");
            } elseif ($action === 'deactivate') {
                $stmt = $db->prepare("UPDATE tasks SET is_active = 0 WHERE id = ?");
                $stmt->execute([$taskId]);
                log_activity(null, $_SESSION['admin_id'] ?? null, 'admin_action', "Deactivated quest '{$task['title']}'");
                set_flash('warning', "Quest '{$task['title']}' deactivated.");
            } elseif ($action === 'delete') {
                $stmt = $db->prepare("DELETE FROM tasks WHERE id = ?");
                $stmt->execute([$taskId]);
                log_activity(null, $_SESSION['admin_id'] ?? null, 'admin_action', "Deleted quest '{$task['title']}'");
                set_flash('success', "Quest '{$task['title']}' deleted.");
            } elseif ($action === 'complete') {
                // Check LevelUp Game Rule: Future tasks cannot be completed unless scheduled_date <= today OR admin override
                $scheduledDate = $task['scheduled_date'];
                $isFuture = ($scheduledDate > $currentDate);

                if ($isFuture && !$adminOverride) {
                    set_flash('danger', "Game Rule Enforced: Quest '{$task['title']}' is scheduled for {$scheduledDate} (Future). Tasks cannot be completed ahead of schedule without Admin Override.");
                } else {
                    // Mark completed
                    $stmt = $db->prepare("UPDATE tasks SET is_completed = 1, timer_status = 'Completed' WHERE id = ?");
                    $stmt->execute([$taskId]);

                    // If assigned user, award XP and log completion
                    if (!empty($task['assigned_user_id'])) {
                        $xp = (int)$task['xp_reward'];
                        $userId = (int)$task['assigned_user_id'];
                        
                        // Add completion record
                        $cStmt = $db->prepare("INSERT INTO task_completions (task_id, user_id, xp_awarded, completed_at) VALUES (?, ?, ?, NOW())");
                        $cStmt->execute([$taskId, $userId, $xp]);

                        // Increment user XP
                        $uStmt = $db->prepare("UPDATE users SET total_xp = total_xp + ? WHERE id = ?");
                        $uStmt->execute([$xp, $userId]);

                        log_activity($userId, $_SESSION['admin_id'] ?? null, 'task_completed', "Hero completed quest '{$task['title']}' (+$xp XP)" . ($adminOverride ? " [Admin Override]" : ""));
                    }

                    set_flash('success', "Quest '{$task['title']}' marked as Completed successfully!" . ($adminOverride ? " (Admin Override Applied)" : ""));
                }
            }
        }
    }

    header('Location: tasks.php');
    exit;
}

// Filters
$search = trim($_GET['search'] ?? '');
$categoryFilter = $_GET['category'] ?? '';
$typeFilter = $_GET['task_type'] ?? '';
$scheduleFilter = $_GET['schedule'] ?? '';
$statusFilter = $_GET['status'] ?? '';

$whereClauses = [];
$params = [];

if ($search !== '') {
    $whereClauses[] = "(title LIKE ? OR description LIKE ?)";
    $params[] = "%$search%";
    $params[] = "%$search%";
}

if ($categoryFilter !== '') {
    $whereClauses[] = "category = ?";
    $params[] = $categoryFilter;
}

if ($typeFilter !== '') {
    $whereClauses[] = "task_type = ?";
    $params[] = $typeFilter;
}

if ($statusFilter !== '') {
    if ($statusFilter === 'completed') {
        $whereClauses[] = "is_completed = 1";
    } elseif ($statusFilter === 'pending') {
        $whereClauses[] = "is_completed = 0";
    } elseif ($statusFilter === 'inactive') {
        $whereClauses[] = "is_active = 0";
    }
}

if ($scheduleFilter !== '') {
    if ($scheduleFilter === 'today') {
        $whereClauses[] = "scheduled_date = CURDATE()";
    } elseif ($scheduleFilter === 'future') {
        $whereClauses[] = "scheduled_date > CURDATE()";
    } elseif ($scheduleFilter === 'past') {
        $whereClauses[] = "scheduled_date < CURDATE()";
    }
}

$whereSql = !empty($whereClauses) ? 'WHERE ' . implode(' AND ', $whereClauses) : '';

$tasksQuery = "
    SELECT t.*, u.username as assigned_hero_name
    FROM tasks t
    LEFT JOIN users u ON t.assigned_user_id = u.id
    $whereSql
    ORDER BY t.scheduled_date ASC, t.created_at DESC
";
$stmt = $db->prepare($tasksQuery);
$stmt->execute($params);
$tasks = $stmt->fetchAll();

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
                <h2 class="fw-bold text-white mb-1">Quest Catalog & Tasks</h2>
                <p class="text-secondary mb-0">Manage daily quests, hydration targets, timer configurations, and schedule rules.</p>
            </div>
            <div>
                <a href="task-add.php" class="btn btn-gold">
                    <i class="bi bi-plus-circle-fill me-1"></i> Add New Quest
                </a>
            </div>
        </div>

        <!-- LevelUp Game Rule Alert Banner -->
        <div class="alert alert-info border-1 bg-opacity-10 py-3 mb-4" style="background-color: #0F2338; border-color: #38BDF8;">
            <div class="d-flex align-items-start gap-3">
                <i class="bi bi-shield-lock-fill text-info fs-4"></i>
                <div>
                    <h6 class="text-white fw-bold mb-1">LevelUp Scheduling & Progression Enforcement</h6>
                    <p class="text-secondary small mb-0">
                        A future-scheduled task cannot be started or marked as completed today by players. 
                        In the admin panel, future tasks are labeled with a <span class="badge bg-primary">Future</span> badge. You may only force-complete future tasks via explicit <strong>Admin Override</strong>.
                    </p>
                </div>
            </div>
        </div>

        <!-- Filter Card -->
        <div class="card-rpg mb-4 p-3">
            <form method="GET" action="tasks.php" class="row g-2 align-items-center">
                <!-- Search -->
                <div class="col-12 col-md-3">
                    <input type="text" name="search" class="form-control form-control-rpg" placeholder="Search quest name..." value="<?= e($search) ?>">
                </div>

                <!-- Category -->
                <div class="col-6 col-md-2">
                    <select name="category" class="form-select form-select-rpg">
                        <option value="">All Categories</option>
                        <option value="Fitness" <?= $categoryFilter === 'Fitness' ? 'selected' : '' ?>>Fitness</option>
                        <option value="Study" <?= $categoryFilter === 'Study' ? 'selected' : '' ?>>Study</option>
                        <option value="Health" <?= $categoryFilter === 'Health' ? 'selected' : '' ?>>Health</option>
                        <option value="Work" <?= $categoryFilter === 'Work' ? 'selected' : '' ?>>Work</option>
                        <option value="Personal" <?= $categoryFilter === 'Personal' ? 'selected' : '' ?>>Personal</option>
                        <option value="Hydration" <?= $categoryFilter === 'Hydration' ? 'selected' : '' ?>>Hydration</option>
                        <option value="Other" <?= $categoryFilter === 'Other' ? 'selected' : '' ?>>Other</option>
                    </select>
                </div>

                <!-- Type -->
                <div class="col-6 col-md-2">
                    <select name="task_type" class="form-select form-select-rpg">
                        <option value="">All Types</option>
                        <option value="normal" <?= $typeFilter === 'normal' ? 'selected' : '' ?>>Timer Quests</option>
                        <option value="hydration" <?= $typeFilter === 'hydration' ? 'selected' : '' ?>>Hydration Goals</option>
                    </select>
                </div>

                <!-- Schedule -->
                <div class="col-6 col-md-2">
                    <select name="schedule" class="form-select form-select-rpg">
                        <option value="">All Dates</option>
                        <option value="today" <?= $scheduleFilter === 'today' ? 'selected' : '' ?>>Today</option>
                        <option value="future" <?= $scheduleFilter === 'future' ? 'selected' : '' ?>>Future</option>
                        <option value="past" <?= $scheduleFilter === 'past' ? 'selected' : '' ?>>Past</option>
                    </select>
                </div>

                <!-- Status -->
                <div class="col-6 col-md-2">
                    <select name="status" class="form-select form-select-rpg">
                        <option value="">All Statuses</option>
                        <option value="completed" <?= $statusFilter === 'completed' ? 'selected' : '' ?>>Completed</option>
                        <option value="pending" <?= $statusFilter === 'pending' ? 'selected' : '' ?>>Pending</option>
                        <option value="inactive" <?= $statusFilter === 'inactive' ? 'selected' : '' ?>>Inactive</option>
                    </select>
                </div>

                <!-- Actions -->
                <div class="col-12 col-md-1 d-flex gap-1">
                    <button type="submit" class="btn btn-dark-rpg flex-grow-1" title="Filter"><i class="bi bi-funnel"></i></button>
                    <a href="tasks.php" class="btn btn-outline-secondary" title="Reset"><i class="bi bi-arrow-counterclockwise"></i></a>
                </div>
            </form>
        </div>

        <!-- Tasks Table Card -->
        <div class="card-rpg p-0 overflow-hidden">
            <div class="table-responsive">
                <table class="table-rpg">
                    <thead>
                        <tr>
                            <th>Quest Details</th>
                            <th>Category & Type</th>
                            <th>Reward</th>
                            <th>Duration / Goal</th>
                            <th>Scheduled Date</th>
                            <th>Status</th>
                            <th>Assigned Hero</th>
                            <th class="text-end">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php if (empty($tasks)): ?>
                            <tr>
                                <td colspan="8" class="text-center py-5 text-muted">
                                    <i class="bi bi-inbox fs-2 d-block mb-2"></i>
                                    No quests found matching criteria.
                                </td>
                            </tr>
                        <?php else: ?>
                            <?php foreach ($tasks as $task): ?>
                                <?php
                                    $isFuture = ($task['scheduled_date'] > $currentDate);
                                    $isToday = ($task['scheduled_date'] === $currentDate);
                                    $isPast = ($task['scheduled_date'] < $currentDate);
                                ?>
                                <tr>
                                    <td>
                                        <div class="fw-bold text-white"><?= e($task['title']) ?></div>
                                        <div class="text-muted small text-truncate" style="max-width: 250px;">
                                            <?= e($task['description']) ?>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="badge badge-category mb-1 d-inline-block"><?= e($task['category']) ?></span>
                                        <div>
                                            <?php if ($task['task_type'] === 'hydration'): ?>
                                                <span class="badge bg-info bg-opacity-25 text-info border border-info" style="font-size: 0.7rem;">
                                                    <i class="bi bi-droplet-fill me-1"></i>Hydration
                                                </span>
                                            <?php else: ?>
                                                <span class="badge bg-secondary bg-opacity-25 text-light border border-secondary" style="font-size: 0.7rem;">
                                                    <i class="bi bi-stopwatch me-1"></i>Timer
                                                </span>
                                            <?php endif; ?>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="badge badge-gold font-monospace">
                                            +<?= $task['xp_reward'] ?> XP
                                        </span>
                                    </td>
                                    <td>
                                        <?php if ($task['task_type'] === 'hydration'): ?>
                                            <div class="text-info fw-bold small">
                                                <i class="bi bi-droplet me-1"></i><?= ($task['water_goal_ml'] / 1000) ?> L (<?= $task['water_goal_ml'] ?> ml)
                                            </div>
                                            <div class="text-muted" style="font-size: 0.7rem;">
                                                Logged: <?= $task['current_water_ml'] ?> ml
                                            </div>
                                        <?php else: ?>
                                            <div class="text-white small">
                                                <i class="bi bi-clock me-1 text-secondary"></i><?= $task['duration_minutes'] ?> min
                                            </div>
                                            <div class="text-muted" style="font-size: 0.7rem;">
                                                <?= $task['timer_status'] ?>
                                            </div>
                                        <?php endif; ?>
                                    </td>
                                    <td>
                                        <div><?= date('M j, Y', strtotime($task['scheduled_date'])) ?></div>
                                        <?php if ($isFuture): ?>
                                            <span class="badge bg-primary bg-opacity-25 text-primary border border-primary" style="font-size: 0.68rem;">
                                                <i class="bi bi-calendar-event me-1"></i>Available Later
                                            </span>
                                        <?php elseif ($isToday): ?>
                                            <span class="badge bg-success bg-opacity-25 text-success border border-success" style="font-size: 0.68rem;">
                                                <i class="bi bi-check-circle me-1"></i>Available Today
                                            </span>
                                        <?php else: ?>
                                            <span class="badge bg-secondary text-light" style="font-size: 0.68rem;">
                                                Past Due
                                            </span>
                                        <?php endif; ?>
                                    </td>
                                    <td>
                                        <?php if ($task['is_completed']): ?>
                                            <span class="badge bg-success bg-opacity-25 text-success border border-success">
                                                <i class="bi bi-check-all me-1"></i>Completed
                                            </span>
                                        <?php elseif (!$task['is_active']): ?>
                                            <span class="badge badge-inactive">Inactive</span>
                                        <?php else: ?>
                                            <span class="badge bg-warning bg-opacity-25 text-warning border border-warning">Pending</span>
                                        <?php endif; ?>
                                    </td>
                                    <td>
                                        <?php if ($task['assigned_hero_name']): ?>
                                            <span class="badge badge-category"><?= e($task['assigned_hero_name']) ?></span>
                                        <?php else: ?>
                                            <span class="text-muted small">Global Realm</span>
                                        <?php endif; ?>
                                    </td>
                                    <td class="text-end">
                                        <div class="btn-group btn-group-sm">
                                            <!-- Quick Complete Action -->
                                            <?php if (!$task['is_completed']): ?>
                                                <form method="POST" action="tasks.php" class="d-inline">
                                                    <?php csrf_field(); ?>
                                                    <input type="hidden" name="task_id" value="<?= e($task['id']) ?>">
                                                    <input type="hidden" name="action" value="complete">
                                                    <?php if ($isFuture): ?>
                                                        <!-- Trigger with admin override modal/prompt -->
                                                        <input type="hidden" name="admin_override" value="1">
                                                        <button type="submit" class="btn btn-dark-rpg px-2 text-warning" title="Future Task: Force Complete (Admin Override)" data-confirm="GAME RULE OVERRIDE: This task is scheduled for the FUTURE (<?= $task['scheduled_date'] ?>). Normal heroes cannot complete future quests. As Admin, do you want to force-complete this quest now?">
                                                            <i class="bi bi-check-lg"></i>
                                                        </button>
                                                    <?php else: ?>
                                                        <button type="submit" class="btn btn-dark-rpg px-2 text-success" title="Mark as Completed" data-confirm="Mark '<?= e($task['title']) ?>' as completed and award XP?">
                                                            <i class="bi bi-check-lg"></i>
                                                        </button>
                                                    <?php endif; ?>
                                                </form>
                                            <?php endif; ?>

                                            <!-- Edit -->
                                            <a href="task-edit.php?id=<?= urlencode($task['id']) ?>" class="btn btn-dark-rpg px-2" title="Edit Quest">
                                                <i class="bi bi-pencil-square"></i>
                                            </a>

                                            <!-- Toggle Active -->
                                            <form method="POST" action="tasks.php" class="d-inline">
                                                <?php csrf_field(); ?>
                                                <input type="hidden" name="task_id" value="<?= e($task['id']) ?>">
                                                <?php if ($task['is_active']): ?>
                                                    <input type="hidden" name="action" value="deactivate">
                                                    <button type="submit" class="btn btn-dark-rpg px-2 text-secondary" title="Deactivate Quest">
                                                        <i class="bi bi-eye-slash"></i>
                                                    </button>
                                                <?php else: ?>
                                                    <input type="hidden" name="action" value="activate">
                                                    <button type="submit" class="btn btn-dark-rpg px-2 text-success" title="Activate Quest">
                                                        <i class="bi bi-eye"></i>
                                                    </button>
                                                <?php endif; ?>
                                            </form>

                                            <!-- Delete -->
                                            <form method="POST" action="tasks.php" class="d-inline">
                                                <?php csrf_field(); ?>
                                                <input type="hidden" name="task_id" value="<?= e($task['id']) ?>">
                                                <input type="hidden" name="action" value="delete">
                                                <button type="submit" class="btn btn-dark-rpg px-2 text-danger" title="Delete Quest" data-confirm="Are you sure you want to delete '<?= e($task['title']) ?>'?">
                                                    <i class="bi bi-trash"></i>
                                                </button>
                                            </form>
                                        </div>
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
