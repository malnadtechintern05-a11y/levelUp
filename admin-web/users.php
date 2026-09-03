<?php
/**
 * LevelUp Web Admin Panel - User Management
 */
require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/functions.php';

require_admin_auth();

$pageTitle = 'Hero Roster & Management';
$currentPage = 'users';

$db = getDB();

// Handle POST actions: Activate, Deactivate, Delete
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    $userId = (int)($_POST['user_id'] ?? 0);
    $csrfToken = $_POST['csrf_token'] ?? '';

    if (!verify_csrf_token($csrfToken)) {
        set_flash('danger', 'Security validation failed (invalid CSRF token).');
        header('Location: users.php');
        exit;
    }

    if ($userId > 0) {
        if ($action === 'activate') {
            $stmt = $db->prepare("UPDATE users SET is_active = 1 WHERE id = ?");
            $stmt->execute([$userId]);
            log_activity($userId, $_SESSION['admin_id'] ?? null, 'admin_action', "Activated user ID #$userId");
            set_flash('success', "Hero #$userId successfully activated.");
        } elseif ($action === 'deactivate') {
            $stmt = $db->prepare("UPDATE users SET is_active = 0 WHERE id = ?");
            $stmt->execute([$userId]);
            log_activity($userId, $_SESSION['admin_id'] ?? null, 'admin_action', "Deactivated user ID #$userId");
            set_flash('warning', "Hero #$userId deactivated.");
        } elseif ($action === 'delete') {
            // Fetch username for log
            $uStmt = $db->prepare("SELECT username FROM users WHERE id = ?");
            $uStmt->execute([$userId]);
            $userName = $uStmt->fetchColumn() ?: "Hero #$userId";

            $stmt = $db->prepare("DELETE FROM users WHERE id = ?");
            $stmt->execute([$userId]);
            log_activity(null, $_SESSION['admin_id'] ?? null, 'admin_action', "Deleted user '$userName' (ID #$userId)");
            set_flash('success', "Hero '$userName' permanently deleted from realm.");
        }
    }

    header('Location: users.php');
    exit;
}

// Filtering, Searching & Sorting parameters
$search = trim($_GET['search'] ?? '');
$statusFilter = $_GET['status'] ?? '';
$levelFilter = $_GET['level'] ?? '';
$sortBy = $_GET['sort'] ?? 'id';
$sortOrder = strtoupper($_GET['order'] ?? 'DESC') === 'ASC' ? 'ASC' : 'DESC';

$page = max(1, (int)($_GET['page'] ?? 1));
$perPage = 8;
$offset = ($page - 1) * $perPage;

// Build query
$whereClauses = [];
$params = [];

if ($search !== '') {
    $whereClauses[] = "(username LIKE ? OR email LIKE ? OR id = ?)";
    $params[] = "%$search%";
    $params[] = "%$search%";
    $params[] = is_numeric($search) ? (int)$search : -1;
}

if ($statusFilter !== '') {
    $whereClauses[] = "is_active = ?";
    $params[] = (int)$statusFilter;
}

if ($levelFilter !== '') {
    if ($levelFilter === '1-5') {
        $whereClauses[] = "level BETWEEN 1 AND 5";
    } elseif ($levelFilter === '6-10') {
        $whereClauses[] = "level BETWEEN 6 AND 10";
    } elseif ($levelFilter === '11-20') {
        $whereClauses[] = "level BETWEEN 11 AND 20";
    } elseif ($levelFilter === '20+') {
        $whereClauses[] = "level > 20";
    }
}

$whereSql = !empty($whereClauses) ? 'WHERE ' . implode(' AND ', $whereClauses) : '';

// Valid sort columns
$validSortColumns = ['id' => 'u.id', 'username' => 'u.username', 'level' => 'u.level', 'total_xp' => 'u.total_xp', 'current_streak' => 'u.current_streak', 'created_at' => 'u.created_at'];
$orderCol = $validSortColumns[$sortBy] ?? 'u.id';

// Count total
$countQuery = "SELECT COUNT(*) FROM users $whereSql";
$countStmt = $db->prepare($countQuery);
$countStmt->execute($params);
$totalRecords = (int)$countStmt->fetchColumn();
$totalPages = max(1, ceil($totalRecords / $perPage));

// Fetch records with completed task counts
$query = "
    SELECT u.*, 
           (SELECT COUNT(*) FROM task_completions tc WHERE tc.user_id = u.id) as completed_tasks_count
    FROM users u
    $whereSql
    ORDER BY $orderCol $sortOrder
    LIMIT $perPage OFFSET $offset
";
$stmt = $db->prepare($query);
$stmt->execute($params);
$users = $stmt->fetchAll();

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
                <h2 class="fw-bold text-white mb-1">Hero Roster & Accounts</h2>
                <p class="text-secondary mb-0">Inspect hero stats, adjust levels, manage permissions, and track active streaks.</p>
            </div>
            <div>
                <a href="user-add.php" class="btn btn-gold">
                    <i class="bi bi-person-plus-fill"></i> Add New Hero
                </a>
            </div>
        </div>

        <!-- Filter & Search Card -->
        <div class="card-rpg mb-4 p-3">
            <form method="GET" action="users.php" class="row g-2 align-items-center">
                <!-- Search -->
                <div class="col-12 col-md-4">
                    <div class="input-group">
                        <span class="input-group-text bg-dark border-secondary text-secondary"><i class="bi bi-search"></i></span>
                        <input type="text" name="search" class="form-control form-control-rpg" placeholder="Search by name, email, or ID..." value="<?= e($search) ?>">
                    </div>
                </div>

                <!-- Status Filter -->
                <div class="col-6 col-md-2">
                    <select name="status" class="form-select form-select-rpg">
                        <option value="">All Statuses</option>
                        <option value="1" <?= $statusFilter === '1' ? 'selected' : '' ?>>Active Only</option>
                        <option value="0" <?= $statusFilter === '0' ? 'selected' : '' ?>>Inactive Only</option>
                    </select>
                </div>

                <!-- Level Filter -->
                <div class="col-6 col-md-2">
                    <select name="level" class="form-select form-select-rpg">
                        <option value="">All Levels</option>
                        <option value="1-5" <?= $levelFilter === '1-5' ? 'selected' : '' ?>>Level 1 - 5</option>
                        <option value="6-10" <?= $levelFilter === '6-10' ? 'selected' : '' ?>>Level 6 - 10</option>
                        <option value="11-20" <?= $levelFilter === '11-20' ? 'selected' : '' ?>>Level 11 - 20</option>
                        <option value="20+" <?= $levelFilter === '20+' ? 'selected' : '' ?>>Level 20+</option>
                    </select>
                </div>

                <!-- Sort -->
                <div class="col-6 col-md-2">
                    <select name="sort" class="form-select form-select-rpg">
                        <option value="id" <?= $sortBy === 'id' ? 'selected' : '' ?>>Sort: ID</option>
                        <option value="level" <?= $sortBy === 'level' ? 'selected' : '' ?>>Sort: Level</option>
                        <option value="total_xp" <?= $sortBy === 'total_xp' ? 'selected' : '' ?>>Sort: Total XP</option>
                        <option value="current_streak" <?= $sortBy === 'current_streak' ? 'selected' : '' ?>>Sort: Streak</option>
                        <option value="created_at" <?= $sortBy === 'created_at' ? 'selected' : '' ?>>Sort: Registered</option>
                    </select>
                </div>

                <!-- Submit / Reset -->
                <div class="col-6 col-md-2 d-flex gap-2">
                    <button type="submit" class="btn btn-dark-rpg flex-grow-1">Filter</button>
                    <a href="users.php" class="btn btn-outline-secondary" title="Reset Filters"><i class="bi bi-arrow-counterclockwise"></i></a>
                </div>
            </form>
        </div>

        <!-- Users Table Card -->
        <div class="card-rpg p-0 overflow-hidden">
            <div class="table-responsive">
                <table class="table-rpg">
                    <thead>
                        <tr>
                            <th>Hero / Email</th>
                            <th>Level & XP</th>
                            <th>XP Progress</th>
                            <th>Quests Done</th>
                            <th>Daily Streak</th>
                            <th>Status</th>
                            <th>Joined</th>
                            <th class="text-end">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php if (empty($users)): ?>
                            <tr>
                                <td colspan="8" class="text-center py-5 text-muted">
                                    <i class="bi bi-people fs-2 d-block mb-2"></i>
                                    No heroes found matching the criteria.
                                </td>
                            </tr>
                        <?php else: ?>
                            <?php foreach ($users as $user): ?>
                                <?php 
                                    $progress = calculate_level_progress((int)$user['level'], (int)$user['total_xp']); 
                                ?>
                                <tr>
                                    <td>
                                        <div class="d-flex align-items-center gap-3">
                                            <div class="avatar-ring">
                                                <?= strtoupper(substr($user['username'], 0, 1)) ?>
                                            </div>
                                            <div>
                                                <a href="user-view.php?id=<?= $user['id'] ?>" class="text-white fw-bold text-decoration-none hover-gold">
                                                    <?= e($user['username']) ?>
                                                </a>
                                                <div class="text-muted small"><?= e($user['email'] ?? 'No email bound') ?></div>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="level-badge mb-1">
                                            <i class="bi bi-shield-fill"></i> LVL <?= $user['level'] ?>
                                        </div>
                                        <div class="text-warning small fw-semibold"><?= number_format($user['total_xp']) ?> XP</div>
                                    </td>
                                    <td style="min-width: 140px;">
                                        <div class="d-flex justify-content-between text-muted" style="font-size: 0.72rem;">
                                            <span><?= $progress['percentage'] ?>%</span>
                                            <span><?= $progress['needed_xp'] ?> XP needed</span>
                                        </div>
                                        <div class="xp-progress-bar mt-1">
                                            <div class="xp-progress-fill" style="width: <?= $progress['percentage'] ?>%;"></div>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="badge badge-category">
                                            <i class="bi bi-check2 me-1 text-success"></i><?= $user['completed_tasks_count'] ?> Quests
                                        </span>
                                    </td>
                                    <td>
                                        <div class="d-flex align-items-center gap-1 text-danger fw-bold small">
                                            <i class="bi bi-fire text-warning"></i>
                                            <?= $user['current_streak'] ?> days
                                        </div>
                                        <div class="text-muted" style="font-size: 0.7rem;">Best: <?= $user['best_streak'] ?>d</div>
                                    </td>
                                    <td>
                                        <?php if ($user['is_active']): ?>
                                            <span class="badge badge-active"><i class="bi bi-check-circle-fill me-1"></i>Active</span>
                                        <?php else: ?>
                                            <span class="badge badge-inactive"><i class="bi bi-slash-circle-fill me-1"></i>Inactive</span>
                                        <?php endif; ?>
                                    </td>
                                    <td class="text-muted small">
                                        <?= date('M j, Y', strtotime($user['created_at'])) ?>
                                    </td>
                                    <td class="text-end">
                                        <div class="btn-group btn-group-sm">
                                            <a href="user-view.php?id=<?= $user['id'] ?>" class="btn btn-dark-rpg px-2" title="Inspect Profile">
                                                <i class="bi bi-eye"></i>
                                            </a>
                                            <a href="user-edit.php?id=<?= $user['id'] ?>" class="btn btn-dark-rpg px-2" title="Edit Hero Stats">
                                                <i class="bi bi-pencil-square"></i>
                                            </a>
                                            
                                            <!-- Toggle Status Form -->
                                            <form method="POST" action="users.php" class="d-inline">
                                                <?php csrf_field(); ?>
                                                <input type="hidden" name="user_id" value="<?= $user['id'] ?>">
                                                <?php if ($user['is_active']): ?>
                                                    <input type="hidden" name="action" value="deactivate">
                                                    <button type="submit" class="btn btn-dark-rpg px-2 text-warning" title="Deactivate User" data-confirm="Deactivate <?= e($user['username']) ?>?">
                                                        <i class="bi bi-pause-circle"></i>
                                                    </button>
                                                <?php else: ?>
                                                    <input type="hidden" name="action" value="activate">
                                                    <button type="submit" class="btn btn-dark-rpg px-2 text-success" title="Activate User">
                                                        <i class="bi bi-play-circle"></i>
                                                    </button>
                                                <?php endif; ?>
                                            </form>

                                            <!-- Delete User Form -->
                                            <form method="POST" action="users.php" class="d-inline">
                                                <?php csrf_field(); ?>
                                                <input type="hidden" name="user_id" value="<?= $user['id'] ?>">
                                                <input type="hidden" name="action" value="delete">
                                                <button type="submit" class="btn btn-dark-rpg px-2 text-danger" title="Permanently Delete Hero" data-confirm="WARNING: Are you sure you want to permanently delete '<?= e($user['username']) ?>'? All progress and task history will be erased!">
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

            <!-- Pagination -->
            <?php if ($totalPages > 1): ?>
                <div class="p-3 border-top border-secondary d-flex justify-content-between align-items-center flex-wrap gap-2">
                    <small class="text-muted">Showing page <?= $page ?> of <?= $totalPages ?> (<?= $totalRecords ?> heroes total)</small>
                    <nav aria-label="Page navigation">
                        <ul class="pagination pagination-sm mb-0">
                            <li class="page-item <?= ($page <= 1) ? 'disabled' : '' ?>">
                                <a class="page-link bg-dark border-secondary text-white" href="?<?= http_build_query(array_merge($_GET, ['page' => $page - 1])) ?>">Previous</a>
                            </li>
                            <?php for ($i = 1; $i <= $totalPages; $i++): ?>
                                <li class="page-item <?= ($page == $i) ? 'active' : '' ?>">
                                    <a class="page-link <?= ($page == $i) ? 'btn-gold border-0 text-dark fw-bold' : 'bg-dark border-secondary text-white' ?>" href="?<?= http_build_query(array_merge($_GET, ['page' => $i])) ?>"><?= $i ?></a>
                                </li>
                            <?php endfor; ?>
                            <li class="page-item <?= ($page >= $totalPages) ? 'disabled' : '' ?>">
                                <a class="page-link bg-dark border-secondary text-white" href="?<?= http_build_query(array_merge($_GET, ['page' => $page + 1])) ?>">Next</a>
                            </li>
                        </ul>
                    </nav>
                </div>
            <?php endif; ?>
        </div>

    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
