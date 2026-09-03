<?php
/**
 * LevelUp Web Admin Panel - Sidebar Component
 */
$currentPage = $currentPage ?? '';
?>
<!-- Mobile Overlay -->
<div id="sidebarOverlay" class="position-fixed top-0 start-0 w-100 h-100 bg-dark opacity-50 d-lg-none" style="display: none; z-index: 1015;"></div>

<aside id="adminSidebar" class="admin-sidebar">
    <div class="sidebar-header">
        <a href="dashboard.php" class="brand-logo">
            <div class="brand-badge">
                <i class="bi bi-shield-fill-check"></i>
            </div>
            <div>
                <div class="brand-title">LEVELUP</div>
                <div class="brand-sub">Real-Life RPG</div>
            </div>
        </a>
    </div>

    <nav class="sidebar-nav">
        <span class="nav-label">Core Mission</span>
        
        <a href="dashboard.php" class="nav-link-custom <?= ($currentPage === 'dashboard') ? 'active' : '' ?>">
            <i class="bi bi-grid-1x2-fill"></i>
            <span>Dashboard</span>
        </a>

        <a href="users.php" class="nav-link-custom <?= ($currentPage === 'users' || $currentPage === 'user-view' || $currentPage === 'user-edit') ? 'active' : '' ?>">
            <i class="bi bi-people-fill"></i>
            <span>Users & Heroes</span>
        </a>

        <a href="tasks.php" class="nav-link-custom <?= ($currentPage === 'tasks' || $currentPage === 'task-add' || $currentPage === 'task-edit') ? 'active' : '' ?>">
            <i class="bi bi-check2-square"></i>
            <span>Quest Tasks</span>
        </a>

        <a href="achievements.php" class="nav-link-custom <?= ($currentPage === 'achievements') ? 'active' : '' ?>">
            <i class="bi bi-trophy-fill"></i>
            <span>Achievements</span>
        </a>

        <span class="nav-label mt-2">Insights & Community</span>

        <a href="analytics.php" class="nav-link-custom <?= ($currentPage === 'analytics') ? 'active' : '' ?>">
            <i class="bi bi-bar-chart-line-fill"></i>
            <span>Analytics</span>
        </a>

        <a href="leaderboard.php" class="nav-link-custom <?= ($currentPage === 'leaderboard') ? 'active' : '' ?>">
            <i class="bi bi-award-fill"></i>
            <span>Leaderboard</span>
        </a>

        <a href="notifications.php" class="nav-link-custom <?= ($currentPage === 'notifications') ? 'active' : '' ?>">
            <i class="bi bi-bell-fill"></i>
            <span>Notifications</span>
        </a>

        <span class="nav-label mt-2">Configuration</span>

        <a href="settings.php" class="nav-link-custom <?= ($currentPage === 'settings') ? 'active' : '' ?>">
            <i class="bi bi-gear-fill"></i>
            <span>Settings</span>
        </a>
    </nav>

    <div class="sidebar-footer">
        <a href="logout.php" class="nav-link-custom text-danger" data-confirm="Are you sure you want to log out of the LevelUp Admin Panel?">
            <i class="bi bi-box-arrow-right text-danger"></i>
            <span>Logout</span>
        </a>
    </div>
</aside>
