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
            'hero_banner_title' => trim($_POST['hero_banner_title'] ?? ''),
            'hero_banner_subtitle' => trim($_POST['hero_banner_subtitle'] ?? ''),
            'hero_banner_enabled' => isset($_POST['hero_banner_enabled']) ? '1' : '0',
            'maintenance_mode' => isset($_POST['maintenance_mode']) ? '1' : '0',
            'maintenance_message' => trim($_POST['maintenance_message'] ?? 'LevelUp realm is currently undergoing scheduled upgrades. Please check back shortly!'),
            'default_water_goal_ml' => (string)max(500, (int)($_POST['default_water_goal_ml'] ?? 2500)),
            'quote_of_the_day' => trim($_POST['quote_of_the_day'] ?? "You're getting stronger every day! 💪"),
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
    } elseif ($formType === 'banner_image') {
        $savedPath = null;

        // 1. Check file upload first
        if (isset($_FILES['banner_file']) && $_FILES['banner_file']['error'] === UPLOAD_ERR_OK) {
            $file = $_FILES['banner_file'];
            $maxBytes = 8 * 1024 * 1024; // 8MB
            if ($file['size'] > $maxBytes) {
                set_flash('danger', 'The uploaded image exceeds the 8MB limit.');
                header('Location: settings.php');
                exit;
            }

            $ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
            $allowedExts = ['jpg', 'jpeg', 'png', 'webp', 'gif'];
            if (!in_array($ext, $allowedExts, true)) {
                set_flash('danger', 'Invalid file type. Only JPG, PNG, WEBP, and GIF images are allowed.');
                header('Location: settings.php');
                exit;
            }

            $imgInfo = @getimagesize($file['tmp_name']);
            if ($imgInfo === false) {
                set_flash('danger', 'The uploaded file is not a valid image.');
                header('Location: settings.php');
                exit;
            }

            $uploadDir = __DIR__ . '/uploads/banners/';
            if (!is_dir($uploadDir)) {
                mkdir($uploadDir, 0777, true);
            }

            $fileName = 'hero_banner_' . date('Ymd_His') . '_' . bin2hex(random_bytes(4)) . '.' . $ext;
            $destination = $uploadDir . $fileName;

            if (move_uploaded_file($file['tmp_name'], $destination)) {
                $savedPath = '/admin-web/uploads/banners/' . $fileName;
                // Auto-mirror to other server locations
                $mirrorDirs = [
                    'C:/Users/Malnad/Desktop/real-life-rpg/admin-web/uploads/banners/',
                    'C:/xampp/htdocs/real-life-rpg/admin-web/uploads/banners/',
                    'C:/xampp/htdocs/admin-web/uploads/banners/',
                ];
                foreach ($mirrorDirs as $mDir) {
                    if (!is_dir($mDir)) {
                        @mkdir($mDir, 0777, true);
                    }
                    if ($destination !== $mDir . $fileName) {
                        @copy($destination, $mDir . $fileName);
                    }
                }
            } else {
                set_flash('danger', 'Failed to save uploaded image. Please check directory permissions.');
                header('Location: settings.php');
                exit;
            }
        } elseif (!empty($_POST['banner_url'])) {
            $url = trim($_POST['banner_url']);
            if (filter_var($url, FILTER_VALIDATE_URL)) {
                $savedPath = $url;
            } else {
                set_flash('danger', 'Invalid URL format. Please enter a valid http/https image URL.');
                header('Location: settings.php');
                exit;
            }
        }

        if ($savedPath !== null) {
            // Delete old uploaded file if local
            $oldImage = $db->query("SELECT setting_value FROM app_settings WHERE setting_key = 'hero_banner_image'")->fetchColumn();
            if ($oldImage && str_starts_with($oldImage, '/admin-web/uploads/banners/')) {
                $oldFile = __DIR__ . substr($oldImage, strlen('/admin-web'));
                if (file_exists($oldFile)) {
                    @unlink($oldFile);
                }
            }

            $stmt = $db->prepare("INSERT INTO app_settings (setting_key, setting_value) VALUES ('hero_banner_image', ?) ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value), updated_at = NOW()");
            $stmt->execute([$savedPath]);

            log_activity(null, $_SESSION['admin_id'] ?? null, 'admin_action', "Updated mobile app hero banner image");
            set_flash('success', 'Mobile app hero banner image successfully updated!');
        } else {
            set_flash('warning', 'Please choose an image file to upload or enter an image URL.');
        }

        header('Location: settings.php');
        exit;
    } elseif ($formType === 'remove_banner') {
        $oldImage = $db->query("SELECT setting_value FROM app_settings WHERE setting_key = 'hero_banner_image'")->fetchColumn();
        if ($oldImage && str_starts_with($oldImage, '/admin-web/uploads/banners/')) {
            $oldFile = __DIR__ . substr($oldImage, strlen('/admin-web'));
            if (file_exists($oldFile)) {
                @unlink($oldFile);
            }
        }

        $db->exec("DELETE FROM app_settings WHERE setting_key = 'hero_banner_image'");
        log_activity(null, $_SESSION['admin_id'] ?? null, 'admin_action', "Removed mobile app hero banner image (reverted to default clean RPG gradient)");
        set_flash('success', 'Background image removed! The mobile app is now displaying the clean default RPG gradient.');
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

        <!-- Hero Banner Image Management -->
        <div class="card-rpg mb-4">
            <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3 pb-3 border-bottom border-secondary border-opacity-25">
                <div>
                    <h5 class="fw-bold text-white mb-1">
                        <i class="bi bi-image-fill text-warning me-2"></i>Mobile App Hero Banner (Level Card)
                    </h5>
                    <p class="text-secondary small mb-0">Control the background image displayed behind the Level & XP Card on the mobile app home screen.</p>
                </div>
                <div>
                    <?php if (!empty($settings['hero_banner_image'])): ?>
                        <span class="badge bg-success-subtle text-success border border-success px-3 py-2 rounded-pill">
                            <i class="bi bi-check-circle-fill me-1"></i> Custom Image Active
                        </span>
                    <?php else: ?>
                        <span class="badge bg-secondary-subtle text-light border border-secondary px-3 py-2 rounded-pill">
                            <i class="bi bi-palette-fill me-1"></i> Clean RPG Theme (No Image)
                        </span>
                    <?php endif; ?>
                </div>
            </div>

            <div class="row g-4 align-items-center">
                <!-- Mobile Mockup Preview -->
                <div class="col-12 col-lg-6">
                    <div class="p-3 rounded-4" style="background: rgba(10, 15, 28, 0.7); border: 1px dashed rgba(255, 255, 255, 0.15);">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="text-secondary small fw-bold text-uppercase"><i class="bi bi-phone me-1"></i> Mobile App Preview</span>
                            <?php if (!empty($settings['hero_banner_image'])): ?>
                                <span class="badge bg-warning text-dark small fw-bold">Live Banner</span>
                            <?php else: ?>
                                <span class="badge bg-secondary text-white small">Default Theme</span>
                            <?php endif; ?>
                        </div>

                        <?php
                            $bannerCssUrl = '';
                            if (!empty($settings['hero_banner_image'])) {
                                $imgVal = $settings['hero_banner_image'];
                                if (str_starts_with($imgVal, 'http://') || str_starts_with($imgVal, 'https://')) {
                                    $bannerCssUrl = $imgVal;
                                } elseif (str_starts_with($imgVal, '/admin-web/')) {
                                    $bannerCssUrl = substr($imgVal, strlen('/admin-web/'));
                                } else {
                                    $bannerCssUrl = ltrim($imgVal, '/');
                                }
                            }
                        ?>

                        <!-- Card Mockup that looks exactly like Flutter home screen -->
                        <div class="rounded-4 p-4 text-white position-relative overflow-hidden"
                             style="min-height: 160px;
                             <?php if (!empty($bannerCssUrl)): ?>
                                background: linear-gradient(rgba(0,0,0,0.45), rgba(0,0,0,0.55)), url('<?= e($bannerCssUrl) ?>') center/cover no-repeat;
                             <?php else: ?>
                                background: linear-gradient(135deg, #1e293b 0%, #0f172a 50%, #090d16 100%);
                                border: 1px solid rgba(245, 185, 66, 0.3);
                             <?php endif; ?>
                             box-shadow: 0 10px 25px rgba(0,0,0,0.4);">

                            <div class="position-relative z-1">
                                <div class="text-white-50 small fw-bold">Level</div>
                                <div class="fw-bold display-6 text-white mb-3" style="line-height: 1;">2</div>

                                <div class="d-flex justify-content-between small text-white-50 mb-1">
                                    <span>XP Progress</span>
                                    <span class="fw-bold text-white">0 / 200 XP</span>
                                </div>
                                <div class="progress rounded-pill" style="height: 8px; background: rgba(255,255,255,0.2);">
                                    <div class="progress-bar rounded-pill" style="width: 30%; background-color: #f5b942;"></div>
                                </div>
                            </div>
                        </div>

                        <div class="mt-2 text-secondary small d-flex justify-content-between">
                            <span>Status: <?= !empty($settings['hero_banner_image']) ? 'Custom image loaded' : 'Clean dark gradient (Distraction-free)' ?></span>
                            <?php if (!empty($settings['hero_banner_image'])): ?>
                                <span class="text-truncate ms-2 text-warning" style="max-width: 200px;" title="<?= e($settings['hero_banner_image']) ?>">
                                    <?= e($settings['hero_banner_image']) ?>
                                </span>
                            <?php endif; ?>
                        </div>
                    </div>
                </div>

                <!-- Form Controls -->
                <div class="col-12 col-lg-6">
                    <form method="POST" action="settings.php" enctype="multipart/form-data">
                        <?php csrf_field(); ?>
                        <input type="hidden" name="form_type" value="banner_image">

                        <div class="mb-3">
                            <label class="form-label-rpg fw-semibold text-white">
                                <i class="bi bi-cloud-arrow-up text-warning me-1"></i> Upload Image File
                            </label>
                            <input type="file" name="banner_file" class="form-control form-control-rpg" accept="image/png, image/jpeg, image/webp, image/gif">
                            <div class="form-text text-secondary small">Supports PNG, JPG, WEBP, GIF (Max 8MB). Recommended: 16:9 aspect ratio.</div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label-rpg fw-semibold text-white">
                                <i class="bi bi-link-45deg text-warning me-1"></i> Or Enter Image Web URL
                            </label>
                            <input type="url" name="banner_url" class="form-control form-control-rpg" placeholder="https://example.com/banner.jpg" value="<?= (!empty($settings['hero_banner_image']) && str_starts_with($settings['hero_banner_image'], 'http')) ? e($settings['hero_banner_image']) : '' ?>">
                        </div>

                        <div class="d-flex flex-wrap gap-2 pt-1">
                            <button type="submit" class="btn btn-gold px-3">
                                <i class="bi bi-check2-circle me-1"></i> Save & Apply Image
                            </button>
                    </form>

                    <?php if (!empty($settings['hero_banner_image'])): ?>
                        <form method="POST" action="settings.php" onsubmit="return confirm('Remove background image? The mobile app will revert back to the default clean dark RPG gradient.');">
                            <?php csrf_field(); ?>
                            <input type="hidden" name="form_type" value="remove_banner">
                            <button type="submit" class="btn btn-outline-danger px-3">
                                <i class="bi bi-trash3 me-1"></i> Remove Image
                            </button>
                        </form>
                    <?php endif; ?>
                        </div>
                </div>
            </div>
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

                        <div class="row g-3 mb-3">
                            <div class="col-6">
                                <label class="form-label-rpg">Default Task XP</label>
                                <input type="number" name="default_xp" class="form-control form-control-rpg" value="<?= (int)($settings['default_xp'] ?? 50) ?>" min="5">
                            </div>
                            <div class="col-6">
                                <label class="form-label-rpg">Default Duration (Min)</label>
                                <input type="number" name="default_task_duration" class="form-control form-control-rpg" value="<?= (int)($settings['default_task_duration'] ?? 30) ?>" min="10">
                            </div>
                        </div>

                        <div class="row g-3 mb-4">
                            <div class="col-6">
                                <label class="form-label-rpg"><i class="bi bi-droplet-fill text-info me-1"></i>Daily Hydration Goal (ml)</label>
                                <input type="number" name="default_water_goal_ml" class="form-control form-control-rpg" value="<?= (int)($settings['default_water_goal_ml'] ?? 2500) ?>" min="500" step="100">
                            </div>
                            <div class="col-6">
                                <label class="form-label-rpg"><i class="bi bi-chat-quote-fill text-warning me-1"></i>Daily Quote of the Day</label>
                                <input type="text" name="quote_of_the_day" class="form-control form-control-rpg" value="<?= e($settings['quote_of_the_day'] ?? "You're getting stronger every day! 💪") ?>">
                            </div>
                        </div>

                        <h6 class="text-warning fw-bold border-bottom border-secondary pb-2 mb-3">
                            <i class="bi bi-image me-2"></i>Hero Banner Customization
                        </h6>

                        <div class="form-check form-switch mb-3">
                            <input class="form-check-input" type="checkbox" id="hero_banner_enabled" name="hero_banner_enabled" <?= ($settings['hero_banner_enabled'] ?? '1') === '1' ? 'checked' : '' ?>>
                            <label class="form-check-label text-white fw-semibold" for="hero_banner_enabled">Enable Hero Banner on Mobile Home Screen</label>
                        </div>

                        <div class="row g-3 mb-4">
                            <div class="col-6">
                                <label class="form-label-rpg">Banner Title Override</label>
                                <input type="text" name="hero_banner_title" class="form-control form-control-rpg" placeholder="Leave empty for LEVEL {level} WARRIOR" value="<?= e($settings['hero_banner_title'] ?? '') ?>">
                            </div>
                            <div class="col-6">
                                <label class="form-label-rpg">Banner Subtitle / Motto</label>
                                <input type="text" name="hero_banner_subtitle" class="form-control form-control-rpg" placeholder="e.g. Conquer your day!" value="<?= e($settings['hero_banner_subtitle'] ?? '') ?>">
                            </div>
                        </div>

                        <h6 class="text-warning fw-bold border-bottom border-secondary pb-2 mb-3">
                            <i class="bi bi-tools me-2"></i>Realm Maintenance & Lockout
                        </h6>

                        <div class="form-check form-switch mb-2">
                            <input class="form-check-input" type="checkbox" id="maintenance_mode" name="maintenance_mode" <?= ($settings['maintenance_mode'] ?? '0') === '1' ? 'checked' : '' ?>>
                            <label class="form-check-label text-danger fw-bold" for="maintenance_mode">Activate Maintenance Mode (Show Maintenance Screen on Mobile App)</label>
                        </div>

                        <div class="mb-4">
                            <label class="form-label-rpg">Maintenance Notice to Players</label>
                            <input type="text" name="maintenance_message" class="form-control form-control-rpg" value="<?= e($settings['maintenance_message'] ?? 'LevelUp realm is currently undergoing scheduled upgrades. Please check back shortly!') ?>">
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
