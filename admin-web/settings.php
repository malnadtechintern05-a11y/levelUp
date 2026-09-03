<?php
/**
 * LevelUp Web Admin Panel - App Settings & Security Configuration
 */
require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/functions.php';

require_admin_auth();

$pageTitle = 'Realm Configuration & Settings';
$currentPage = 'settings';

$db = getDB();

// Handle Form Submissions
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $csrfToken = $_POST['csrf_token'] ?? '';
    $formType = $_POST['form_type'] ?? '';

    if (!verify_csrf_token($csrfToken)) {
        set_flash('danger', 'Security validation failed (invalid CSRF token).');
        header('Location: settings.php');
        exit;
    }

    if ($formType === 'app_settings') {
        $settingsToSave = [
            'app_name' => trim($_POST['app_name'] ?? 'LevelUp - Real-Life RPG'),
            'app_description' => trim($_POST['app_description'] ?? ''),
            'default_xp' => (string)max(5, (int)($_POST['default_xp'] ?? 50)),
            'default_task_duration' => (string)max(10, (int)($_POST['default_task_duration'] ?? 30)),
            'daily_reminder' => isset($_POST['daily_reminder']) ? '1' : '0',
            'achievement_notifications' => isset($_POST['achievement_notifications']) ? '1' : '0',
            'task_completion_notifications' => isset($_POST['task_completion_notifications']) ? '1' : '0',
            'streak_notifications' => isset($_POST['streak_notifications']) ? '1' : '0',
        ];

        $stmt = $db->prepare("INSERT INTO app_settings (setting_key, setting_value) VALUES (?, ?) ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value), updated_at = NOW()");
        foreach ($settingsToSave as $key => $val) {
            $stmt->execute([$key, $val]);
        }

        log_activity(null, $_SESSION['admin_id'] ?? null, 'admin_action', "Updated global realm settings");
        set_flash('success', 'Application settings successfully updated.');
        header('Location: settings.php');
        exit;
    } elseif ($formType === 'admin_security') {
        $currentPassword = $_POST['current_password'] ?? '';
        $newPassword = $_POST['new_password'] ?? '';
        $confirmPassword = $_POST['confirm_password'] ?? '';
        $adminId = $_SESSION['admin_id'];

        if (empty($currentPassword) || empty($newPassword)) {
            set_flash('danger', 'Please enter your current and new password.');
        } elseif ($newPassword !== $confirmPassword) {
            set_flash('danger', 'New passwords do not match.');
        } elseif (strlen($newPassword) < 6) {
            set_flash('danger', 'New password must be at least 6 characters long.');
        } else {
            // Verify current password
            $aStmt = $db->prepare("SELECT password_hash, username FROM admins WHERE id = ?");
            $aStmt->execute([$adminId]);
            $adminRow = $aStmt->fetch();

            if ($adminRow && password_verify($currentPassword, $adminRow['password_hash'])) {
                $newHash = password_hash($newPassword, PASSWORD_BCRYPT);
                $updatePassStmt = $db->prepare("UPDATE admins SET password_hash = ? WHERE id = ?");
                $updatePassStmt->execute([$newHash, $adminId]);

                log_activity(null, $adminId, 'admin_action', "Admin '{$adminRow['username']}' updated their master password");
                set_flash('success', 'Admin master password changed successfully!');
            } else {
                set_flash('danger', 'Incorrect current password provided.');
            }
        }
        header('Location: settings.php');
        exit;
    }
}

$settings = get_app_settings();

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/sidebar.php';
?>

<div class="admin-main">
    <?php require_once __DIR__ . '/includes/navbar.php'; ?>

    <div class="content-body">
        <?php display_flash_messages(); ?>

        <div class="mb-4">
            <h2 class="fw-bold text-white mb-1">Realm Configuration & Settings</h2>
            <p class="text-secondary mb-0">Control gameplay defaults, notification behavior, and admin security credentials.</p>
        </div>

        <div class="row g-4">
            <!-- App Settings Column -->
            <div class="col-12 col-lg-7">
                <div class="card-rpg">
                    <h5 class="fw-bold text-white mb-3"><i class="bi bi-sliders text-warning me-2"></i>Gameplay & Application Defaults</h5>

                    <form method="POST" action="settings.php">
                        <?php csrf_field(); ?>
                        <input type="hidden" name="form_type" value="app_settings">

                        <div class="mb-3">
                            <label class="form-label-rpg">Application Name</label>
                            <input type="text" name="app_name" class="form-control form-control-rpg" value="<?= e($settings['app_name'] ?? 'LevelUp - Real-Life RPG') ?>" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label-rpg">Application Description</label>
                            <textarea name="app_description" class="form-control form-control-rpg" rows="2"><?= e($settings['app_description'] ?? '') ?></textarea>
                        </div>

                        <div class="row g-3 mb-4">
                            <div class="col-6">
                                <label class="form-label-rpg">Default Task XP</label>
                                <input type="number" name="default_xp" class="form-control form-control-rpg" value="<?= (int)($settings['default_xp'] ?? 50) ?>" min="5">
                            </div>
                            <div class="col-6">
                                <label class="form-label-rpg">Default Duration (Min)</label>
                                <input type="number" name="default_task_duration" class="form-control form-control-rpg" value="<?= (int)($settings['default_task_duration'] ?? 30) ?>" min="10">
                            </div>
                        </div>

                        <h6 class="text-warning fw-bold border-bottom border-secondary pb-2 mb-3">
                            <i class="bi bi-bell-fill me-2"></i>Notification Dispatches
                        </h6>

                        <div class="form-check form-switch mb-2">
                            <input class="form-check-input" type="checkbox" id="daily_reminder" name="daily_reminder" <?= ($settings['daily_reminder'] ?? '1') === '1' ? 'checked' : '' ?>>
                            <label class="form-check-label text-white" for="daily_reminder">Daily Quest Reminder Alerts</label>
                        </div>

                        <div class="form-check form-switch mb-2">
                            <input class="form-check-input" type="checkbox" id="achievement_notifications" name="achievement_notifications" <?= ($settings['achievement_notifications'] ?? '1') === '1' ? 'checked' : '' ?>>
                            <label class="form-check-label text-white" for="achievement_notifications">Achievement Unlocked Celebrations</label>
                        </div>

                        <div class="form-check form-switch mb-2">
                            <input class="form-check-input" type="checkbox" id="task_completion_notifications" name="task_completion_notifications" <?= ($settings['task_completion_notifications'] ?? '1') === '1' ? 'checked' : '' ?>>
                            <label class="form-check-label text-white" for="task_completion_notifications">Task Completion & XP Award Notifications</label>
                        </div>

                        <div class="form-check form-switch mb-4">
                            <input class="form-check-input" type="checkbox" id="streak_notifications" name="streak_notifications" <?= ($settings['streak_notifications'] ?? '1') === '1' ? 'checked' : '' ?>>
                            <label class="form-check-label text-white" for="streak_notifications">Streak Milestone & Protection Alerts</label>
                        </div>

                        <button type="submit" class="btn btn-gold px-4">
                            <i class="bi bi-check2-circle me-1"></i> Save Configuration
                        </button>
                    </form>
                </div>
            </div>

            <!-- Admin Security Column -->
            <div class="col-12 col-lg-5">
                <!-- Change Password Card -->
                <div class="card-rpg mb-4">
                    <h5 class="fw-bold text-white mb-3"><i class="bi bi-shield-lock-fill text-warning me-2"></i>Admin Security</h5>
                    
                    <form method="POST" action="settings.php">
                        <?php csrf_field(); ?>
                        <input type="hidden" name="form_type" value="admin_security">

                        <div class="mb-3">
                            <label class="form-label-rpg">Current Password</label>
                            <input type="password" name="current_password" class="form-control form-control-rpg" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label-rpg">New Password</label>
                            <input type="password" name="new_password" class="form-control form-control-rpg" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label-rpg">Confirm New Password</label>
                            <input type="password" name="confirm_password" class="form-control form-control-rpg" required>
                        </div>

                        <button type="submit" class="btn btn-gold w-100">
                            <i class="bi bi-key-fill me-1"></i> Update Admin Password
                        </button>
                    </form>
                </div>

                <!-- Flutter Backend Compatibility Card -->
                <div class="card-rpg">
                    <h6 class="fw-bold text-white mb-2"><i class="bi bi-phone-fill text-info me-2"></i>Flutter Mobile Sync Status</h6>
                    <p class="text-secondary small mb-3">
                        The web admin panel is designed with normalized tables directly compatible with LevelUp's Flutter models:
                    </p>
                    <ul class="text-secondary small ps-3 mb-0">
                        <li><code>users</code> &harr; <code>UserProfile</code></li>
                        <li><code>tasks</code> &harr; <code>RPGTask</code> (Normal &amp; Hydration)</li>
                        <li><code>achievements</code> &harr; <code>Achievement</code></li>
                        <li><code>notifications</code> &harr; <code>AppNotification</code></li>
                    </ul>
                </div>
            </div>
        </div>

    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
