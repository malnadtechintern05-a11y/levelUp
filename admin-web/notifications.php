<?php
/**
 * LevelUp Web Admin Panel - Notifications Dispatch Center
 */
require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/functions.php';

require_admin_auth();

$pageTitle = 'Notification Broadcast Center';
$currentPage = 'notifications';

$db = getDB();

// Handle POST: Create or Delete
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    $csrfToken = $_POST['csrf_token'] ?? '';

    if (!verify_csrf_token($csrfToken)) {
        set_flash('danger', 'Security validation failed (invalid CSRF token).');
        header('Location: notifications.php');
        exit;
    }

    if ($action === 'create') {
        $title = trim($_POST['title'] ?? '');
        $message = trim($_POST['message'] ?? '');
        $category = $_POST['category'] ?? 'System';
        $type = $_POST['type'] ?? 'announcement';
        $targetUserId = !empty($_POST['target_user_id']) ? (int)$_POST['target_user_id'] : null;

        if (empty($title) || empty($message)) {
            set_flash('danger', 'Both Notification Title and Message Body are required.');
        } else {
            create_notification($title, $message, $category, $type, $targetUserId);
            $targetDesc = $targetUserId ? "Hero #$targetUserId" : "All Realm Heroes";
            log_activity($targetUserId, $_SESSION['admin_id'] ?? null, 'admin_action', "Broadcast notification '$title' to $targetDesc");
            set_flash('success', "Notification dispatched successfully to $targetDesc!");
        }
    } elseif ($action === 'delete') {
        $notifId = trim($_POST['notif_id'] ?? '');
        if (!empty($notifId)) {
            $stmt = $db->prepare("DELETE FROM notifications WHERE id = ?");
            $stmt->execute([$notifId]);
            set_flash('success', "Notification record deleted.");
        }
    }

    header('Location: notifications.php');
    exit;
}

// Fetch active heroes for target dropdown
$heroes = $db->query("SELECT id, username, level FROM users WHERE is_active = 1 ORDER BY username ASC")->fetchAll();

// Fetch notifications with target user details
$notifsQuery = "
    SELECT n.*, u.username as target_hero_name
    FROM notifications n
    LEFT JOIN users u ON n.target_user_id = u.id
    ORDER BY n.created_at DESC
";
$notifications = $db->query($notifsQuery)->fetchAll();

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/sidebar.php';
?>

<div class="admin-main">
    <?php require_once __DIR__ . '/includes/navbar.php'; ?>

    <div class="content-body">
        <?php display_flash_messages(); ?>

        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
            <div>
                <h2 class="fw-bold text-white mb-1">Notification Dispatch Center</h2>
                <p class="text-secondary mb-0">Transmit announcements, quest alerts, or system reminders to all players or targeted heroes.</p>
            </div>
            <div>
                <button type="button" class="btn btn-gold" data-bs-toggle="modal" data-bs-target="#newNotificationModal">
                    <i class="bi bi-broadcast me-1"></i> Compose Alert
                </button>
            </div>
        </div>

        <!-- Notifications Table Card -->
        <div class="card-rpg p-0 overflow-hidden">
            <div class="table-responsive">
                <table class="table-rpg">
                    <thead>
                        <tr>
                            <th>Alert Title & Message</th>
                            <th>Category</th>
                            <th>Dispatch Type</th>
                            <th>Target Audience</th>
                            <th>Broadcast Time</th>
                            <th class="text-end">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php if (empty($notifications)): ?>
                            <tr>
                                <td colspan="6" class="text-center py-5 text-muted">
                                    <i class="bi bi-bell-slash fs-2 d-block mb-2"></i>
                                    No notifications transmitted yet.
                                </td>
                            </tr>
                        <?php else: ?>
                            <?php foreach ($notifications as $n): ?>
                                <tr>
                                    <td>
                                        <div class="fw-bold text-white"><?= e($n['title']) ?></div>
                                        <div class="text-muted small"><?= e($n['message']) ?></div>
                                    </td>
                                    <td>
                                        <span class="badge badge-category"><?= e($n['category']) ?></span>
                                    </td>
                                    <td>
                                        <?php if ($n['type'] === 'announcement'): ?>
                                            <span class="badge bg-primary bg-opacity-25 text-primary border border-primary">Announcement</span>
                                        <?php elseif ($n['type'] === 'reminder'): ?>
                                            <span class="badge bg-warning bg-opacity-25 text-warning border border-warning">Reminder</span>
                                        <?php else: ?>
                                            <span class="badge bg-info bg-opacity-25 text-info border border-info"><?= e($n['type']) ?></span>
                                        <?php endif; ?>
                                    </td>
                                    <td>
                                        <?php if ($n['target_hero_name']): ?>
                                            <span class="badge bg-secondary text-white">
                                                <i class="bi bi-person-fill me-1"></i><?= e($n['target_hero_name']) ?>
                                            </span>
                                        <?php else: ?>
                                            <span class="badge badge-gold">
                                                <i class="bi bi-megaphone-fill me-1"></i>All Heroes (Broadcast)
                                            </span>
                                        <?php endif; ?>
                                    </td>
                                    <td class="text-muted small">
                                        <?= date('M j, Y - H:i', strtotime($n['created_at'])) ?>
                                    </td>
                                    <td class="text-end">
                                        <form method="POST" action="notifications.php" class="d-inline">
                                            <?php csrf_field(); ?>
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="notif_id" value="<?= e($n['id']) ?>">
                                            <button type="submit" class="btn btn-dark-rpg btn-sm text-danger" title="Delete Alert" data-confirm="Delete this notification record?">
                                                <i class="bi bi-trash"></i>
                                            </button>
                                        </form>
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

<!-- Compose Notification Modal -->
<div class="modal fade" id="newNotificationModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content modal-content-rpg">
            <form method="POST" action="notifications.php">
                <?php csrf_field(); ?>
                <input type="hidden" name="action" value="create">

                <div class="modal-header modal-header-rpg">
                    <h5 class="modal-title fw-bold text-white"><i class="bi bi-broadcast text-warning me-2"></i>Transmit Hero Notification</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="form-label-rpg">Title *</label>
                        <input type="text" name="title" class="form-control form-control-rpg" placeholder="e.g. Double XP Weekend Activated!" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label-rpg">Message Body *</label>
                        <textarea name="message" class="form-control form-control-rpg" rows="3" placeholder="Compose clear briefing for heroes..." required></textarea>
                    </div>

                    <div class="row g-2 mb-3">
                        <div class="col-6">
                            <label class="form-label-rpg">Category</label>
                            <select name="category" class="form-select form-select-rpg">
                                <option value="System">System</option>
                                <option value="LevelUp">LevelUp</option>
                                <option value="Fitness">Fitness</option>
                                <option value="Study">Study</option>
                                <option value="Health">Health</option>
                                <option value="Achievement">Achievement</option>
                            </select>
                        </div>
                        <div class="col-6">
                            <label class="form-label-rpg">Type</label>
                            <select name="type" class="form-select form-select-rpg">
                                <option value="announcement">Announcement</option>
                                <option value="reminder">Reminder</option>
                                <option value="taskCompletion">Task Completion</option>
                                <option value="levelUp">Level Up</option>
                            </select>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label-rpg">Target Audience</label>
                        <select name="target_user_id" class="form-select form-select-rpg">
                            <option value="">Broadcast to ALL Heroes</option>
                            <?php foreach ($heroes as $h): ?>
                                <option value="<?= $h['id'] ?>"><?= e($h['username']) ?> (LVL <?= $h['level'] ?>)</option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                </div>
                <div class="modal-footer modal-footer-rpg">
                    <button type="button" class="btn btn-dark-rpg" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-gold"><i class="bi bi-send-fill me-1"></i> Broadcast</button>
                </div>
            </form>
        </div>
    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
