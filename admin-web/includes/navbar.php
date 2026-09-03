<?php
/**
 * LevelUp Web Admin Panel - Top Navbar Component
 */
$adminUser = get_logged_in_admin() ?? [
    'username' => 'Administrator',
    'email' => 'admin@levelup.com',
    'role' => 'Superadmin'
];

// Unread notifications count
try {
    $db = getDB();
    $unreadStmt = $db->query("SELECT COUNT(*) FROM notifications WHERE is_read = 0");
    $unreadCount = (int)$unreadStmt->fetchColumn();
} catch (Exception $e) {
    $unreadCount = 0;
}
?>
<header class="admin-navbar">
    <div class="d-flex align-items-center gap-3">
        <!-- Mobile Sidebar Toggle -->
        <button id="sidebarToggle" class="btn btn-dark-rpg d-lg-none px-2 py-1" aria-label="Toggle navigation">
            <i class="bi bi-list fs-5"></i>
        </button>
        <div>
            <h4 class="mb-0 fw-bold fs-5 text-white"><?= e($pageTitle ?? 'Dashboard') ?></h4>
        </div>
    </div>

    <!-- Right Controls -->
    <div class="d-flex align-items-center gap-3">
        <!-- Search bar -->
        <div class="search-wrapper d-none d-md-flex">
            <i class="bi bi-search search-icon"></i>
            <form action="users.php" method="GET">
                <input type="text" name="search" class="top-search-input" placeholder="Search heroes, tasks..." value="<?= e($_GET['search'] ?? '') ?>">
            </form>
        </div>

        <!-- Notification Bell -->
        <div class="dropdown">
            <a href="notifications.php" class="btn btn-dark-rpg position-relative px-2 py-1 rounded-circle" style="width: 38px; height: 38px; display: inline-flex; align-items: center; justify-content: center;" title="View Notifications">
                <i class="bi bi-bell-fill text-white"></i>
                <?php if ($unreadCount > 0): ?>
                    <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger border border-dark" style="font-size: 0.65rem;">
                        <?= $unreadCount ?>
                    </span>
                <?php endif; ?>
            </a>
        </div>

        <!-- Admin Profile Dropdown -->
        <div class="dropdown">
            <button class="btn btn-dark-rpg d-flex align-items-center gap-2 py-1 px-2 dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                <div class="avatar-ring" style="width: 32px; height: 32px; font-size: 0.85rem;">
                    <?= strtoupper(substr($adminUser['username'] ?? 'A', 0, 1)) ?>
                </div>
                <div class="text-start d-none d-sm-block">
                    <div class="text-white fw-semibold small lh-1"><?= e($adminUser['username']) ?></div>
                    <small class="text-warning text-uppercase" style="font-size: 0.65rem; letter-spacing: 0.05em;"><?= e($adminUser['role']) ?></small>
                </div>
            </button>
            <ul class="dropdown-menu dropdown-menu-end shadow-lg" style="background-color: #162033; border: 1px solid #1E293B;">
                <li><h6 class="dropdown-header text-muted small"><?= e($adminUser['email']) ?></h6></li>
                <li><a class="dropdown-item text-white py-2" href="settings.php"><i class="bi bi-person-gear me-2 text-warning"></i>Admin Settings</a></li>
                <li><hr class="dropdown-divider border-secondary"></li>
                <li><a class="dropdown-item text-danger py-2" href="logout.php"><i class="bi bi-box-arrow-right me-2"></i>Sign Out</a></li>
            </ul>
        </div>
    </div>
</header>
