<?php
/**
 * LevelUp Web Admin Panel - Privacy Policy Management & Editor
 */
require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/functions.php';

require_admin_auth();

$pageTitle = 'Privacy Policy Management';
$currentPage = 'privacy-policy';

$db = getDB();

// Handle Form Submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $csrfToken = $_POST['csrf_token'] ?? '';
    $formType = $_POST['form_type'] ?? '';

    if (!verify_csrf_token($csrfToken)) {
        set_flash('danger', 'Security validation failed (invalid CSRF token).');
        header('Location: privacy-policy.php');
        exit;
    }

    if ($formType === 'save_privacy_policy') {
        $settingsToSave = [
            'privacy_policy_last_updated' => trim($_POST['privacy_policy_last_updated'] ?? '28 September 2026'),
            'privacy_policy_intro' => trim($_POST['privacy_policy_intro'] ?? ''),
            'privacy_policy_info_collected' => trim($_POST['privacy_policy_info_collected'] ?? ''),
            'privacy_policy_how_we_use' => trim($_POST['privacy_policy_how_we_use'] ?? ''),
            'privacy_policy_data_security' => trim($_POST['privacy_policy_data_security'] ?? ''),
            'privacy_policy_log_data' => trim($_POST['privacy_policy_log_data'] ?? ''),
            'privacy_policy_cookies' => trim($_POST['privacy_policy_cookies'] ?? ''),
            'privacy_policy_children' => trim($_POST['privacy_policy_children'] ?? ''),
            'privacy_policy_changes' => trim($_POST['privacy_policy_changes'] ?? ''),
            'pusherhub_last_updated' => trim($_POST['pusherhub_last_updated'] ?? '28 September 2026'),
            'pusherhub_intro' => trim($_POST['pusherhub_intro'] ?? ''),
            'pusherhub_grievance_officer' => trim($_POST['pusherhub_grievance_officer'] ?? 'Harsha'),
            'pusherhub_grievance_email' => trim($_POST['pusherhub_grievance_email'] ?? 'harsha.malnadtech@gmail.com'),
        ];

        $stmt = $db->prepare("INSERT INTO app_settings (setting_key, setting_value) VALUES (?, ?) ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value), updated_at = NOW()");
        foreach ($settingsToSave as $key => $val) {
            $stmt->execute([$key, $val]);
        }

        log_activity(null, $_SESSION['admin_id'] ?? null, 'admin_action', "Updated application Privacy Policies");
        set_flash('success', 'Privacy Policies successfully updated and published.');
        header('Location: privacy-policy.php');
        exit;
    }
}

// Fetch current settings from app_settings
$stmt = $db->query("SELECT setting_key, setting_value FROM app_settings");
$settings = [];
while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    $settings[$row['setting_key']] = $row['setting_value'];
}

$luLastUpdated = $settings['privacy_policy_last_updated'] ?? '28 September 2026';
$luIntro = $settings['privacy_policy_intro'] ?? 'Welcome to LevelUp ("we," "our," or "the app"). LevelUp is designed to turn your daily habits, self-improvement routines, and productivity into an engaging real-life RPG adventure. This Privacy Policy explains how your information is handled when you use the app.';
$luInfoCollected = $settings['privacy_policy_info_collected'] ?? "LevelUp collects minimal information strictly necessary to power your RPG experience:\n\n• Profile Data: Hero username and selected avatar profile.\n• Quest & Habit Data: Quest titles, categories, completion timestamps, countdown timer durations, and daily drinking water logs.\n• App Preferences: Theme preference (Light/Dark mode) and notification settings.";
$luHowWeUse = $settings['privacy_policy_how_we_use'] ?? "We use your data exclusively to:\n\n• Calculate your level, experience points (XP), gold, and skill statistics (Strength, Knowledge, Discipline).\n• Track daily streak continuity and unlock earned achievements.\n• Provide hydration tracking and scheduled quest availability.";
$luDataSecurity = $settings['privacy_policy_data_security'] ?? 'All user profile information, quests, hydration logs, and achievements are stored directly on your physical device using local SQLite database and SharedPreferences storage. You have full offline access at all times.';
$luLogData = $settings['privacy_policy_log_data'] ?? 'We want to inform you that whenever you use our Service, in a case of an error in the app we collect data and information (through third-party products) on your phone called Log Data. This Log Data may include information such as your device Internet Protocol ("IP") address, device name, operating system version, the configuration of the app when utilizing our Service, the time and date of your use of the Service, and other statistics.';
$luCookies = $settings['privacy_policy_cookies'] ?? 'Cookies are files with a small amount of data that are commonly used as anonymous unique identifiers. These are sent to your browser from the websites that you visit and are stored on your device\'s internal memory.';
$luChildren = $settings['privacy_policy_children'] ?? 'LevelUp is safe for users of all ages. We do not knowingly collect personal identifiable information from children under 13.';
$luChanges = $settings['privacy_policy_changes'] ?? 'We may update our Privacy Policy periodically. Any modifications will be reflected immediately with an updated "Last Updated" date.';

$phLastUpdated = $settings['pusherhub_last_updated'] ?? '28 September 2026';
$phIntro = $settings['pusherhub_intro'] ?? 'This policy explains what personal data PusherHub collects, why, and what you can do about it. It covers the hosted PusherHub service — the website, the dashboard, the REST API and the SDKs. It doesn\'t cover copies of PusherHub that other people host on their own servers.' . "\n\n" . 'PusherHub is operated by Harsha ("we", "us"), who is responsible for your personal data under India\'s Digital Personal Data Protection Act, 2023.';
$phOfficer = $settings['pusherhub_grievance_officer'] ?? 'Harsha';
$phEmail = $settings['pusherhub_grievance_email'] ?? 'harsha.malnadtech@gmail.com';

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/sidebar.php';
?>

<div class="admin-main">
    <?php require_once __DIR__ . '/includes/navbar.php'; ?>

    <div class="content-body">
        <?php display_flash_messages(); ?>

        <div class="d-flex flex-wrap align-items-center justify-content-between gap-3 mb-4">
            <div>
                <h2 class="fw-bold text-white mb-1"><i class="bi bi-shield-check text-warning me-2"></i>Privacy Policy Management</h2>
                <p class="text-secondary mb-0">View, modify and publish real-time Privacy Policies for LevelUp App & PusherHub (DPDP Act 2023).</p>
            </div>
            <div>
                <span class="badge badge-gold px-3 py-2"><i class="bi bi-broadcast me-1"></i>Live Synchronized</span>
            </div>
        </div>

        <!-- Nav Pills -->
        <ul class="nav nav-pills mb-4 gap-2" id="policyTabs" role="tablist">
            <li class="nav-item" role="presentation">
                <button class="nav-link active rounded-pill px-4" id="levelup-tab" data-bs-toggle="pill" data-bs-target="#levelup-policy" type="button" role="tab">
                    <i class="bi bi-shield-fill me-1"></i> LevelUp App Policy
                </button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link rounded-pill px-4" id="pusherhub-tab" data-bs-toggle="pill" data-bs-target="#pusherhub-policy" type="button" role="tab">
                    <i class="bi bi-bell-fill me-1"></i> PusherHub Policy (DPDP Act)
                </button>
            </li>
        </ul>

        <form method="POST" action="privacy-policy.php">
            <?php csrf_field(); ?>
            <input type="hidden" name="form_type" value="save_privacy_policy">

            <div class="tab-content" id="policyTabsContent">
                <!-- TAB 1: LevelUp Privacy Policy -->
                <div class="tab-pane fade show active" id="levelup-policy" role="tabpanel">
                    <div class="card-rpg mb-4">
                        <div class="d-flex justify-content-between align-items-center mb-3 pb-3 border-bottom border-secondary border-opacity-25">
                            <h5 class="fw-bold text-white mb-0"><i class="bi bi-file-earmark-text text-warning me-2"></i>LevelUp Main Privacy Policy</h5>
                            <span class="badge bg-warning text-dark px-3 py-1 fw-bold">Live Policy</span>
                        </div>

                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label-rpg">Last Updated Date</label>
                                <input type="text" name="privacy_policy_last_updated" class="form-control form-control-rpg" value="<?= e($luLastUpdated) ?>">
                            </div>
                            <div class="col-12">
                                <label class="form-label-rpg">1. Introduction</label>
                                <textarea name="privacy_policy_intro" rows="3" class="form-control form-control-rpg"><?= e($luIntro) ?></textarea>
                            </div>
                            <div class="col-12">
                                <label class="form-label-rpg">2. Information We Collect</label>
                                <textarea name="privacy_policy_info_collected" rows="4" class="form-control form-control-rpg"><?= e($luInfoCollected) ?></textarea>
                            </div>
                            <div class="col-12">
                                <label class="form-label-rpg">3. How We Use Your Information</label>
                                <textarea name="privacy_policy_how_we_use" rows="4" class="form-control form-control-rpg"><?= e($luHowWeUse) ?></textarea>
                            </div>
                            <div class="col-12">
                                <label class="form-label-rpg">4. Data Storage & Security</label>
                                <textarea name="privacy_policy_data_security" rows="3" class="form-control form-control-rpg"><?= e($luDataSecurity) ?></textarea>
                            </div>
                            <div class="col-12">
                                <label class="form-label-rpg">5. Third-Party Service Providers (Linked in App)</label>
                                <div class="p-3 rounded border border-secondary" style="background: rgba(10, 15, 28, 0.7);">
                                    <div class="text-info fw-semibold mb-2"><i class="bi bi-link-45deg me-1"></i>Active Connected Service Providers:</div>
                                    <ul class="mb-0 text-secondary small" style="line-height: 1.8;">
                                        <li><strong class="text-light">Google Play Services</strong>: <code>https://policies.google.com/privacy</code></li>
                                        <li><strong class="text-light">AdMob</strong>: <code>https://support.google.com/admob/answer/6128543</code></li>
                                        <li><strong class="text-light">Google Analytics for Firebase</strong>: <code>https://firebase.google.com/policies/analytics</code></li>
                                        <li><strong class="text-light">Firebase Crashlytics</strong>: <code>https://firebase.google.com/support/privacy</code></li>
                                        <li><strong class="text-light">Facebook</strong>: <code>https://www.facebook.com/about/privacy/update/printable</code></li>
                                        <li><strong class="text-warning">PusherHub</strong>: In-App Complete DPDP Act Compliant Privacy Policy</li>
                                    </ul>
                                </div>
                            </div>
                            <div class="col-12">
                                <label class="form-label-rpg">6. Log Data</label>
                                <textarea name="privacy_policy_log_data" rows="3" class="form-control form-control-rpg"><?= e($luLogData) ?></textarea>
                            </div>
                            <div class="col-12">
                                <label class="form-label-rpg">7. Cookies</label>
                                <textarea name="privacy_policy_cookies" rows="3" class="form-control form-control-rpg"><?= e($luCookies) ?></textarea>
                            </div>
                            <div class="col-12">
                                <label class="form-label-rpg">8. Children's Privacy</label>
                                <textarea name="privacy_policy_children" rows="2" class="form-control form-control-rpg"><?= e($luChildren) ?></textarea>
                            </div>
                            <div class="col-12">
                                <label class="form-label-rpg">9. Changes to Policy</label>
                                <textarea name="privacy_policy_changes" rows="2" class="form-control form-control-rpg"><?= e($luChanges) ?></textarea>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- TAB 2: PusherHub Privacy Policy -->
                <div class="tab-pane fade" id="pusherhub-policy" role="tabpanel">
                    <div class="card-rpg mb-4">
                        <div class="d-flex justify-content-between align-items-center mb-3 pb-3 border-bottom border-secondary border-opacity-25">
                            <h5 class="fw-bold text-white mb-0"><i class="bi bi-bell-fill text-warning me-2"></i>PusherHub Privacy Policy</h5>
                            <span class="badge bg-info text-dark px-3 py-1 fw-bold">India DPDP Act, 2023 Compliant</span>
                        </div>

                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label-rpg">PusherHub Last Updated Date</label>
                                <input type="text" name="pusherhub_last_updated" class="form-control form-control-rpg" value="<?= e($phLastUpdated) ?>">
                            </div>
                            <div class="col-12">
                                <label class="form-label-rpg">Scope & Operator Overview</label>
                                <textarea name="pusherhub_intro" rows="4" class="form-control form-control-rpg"><?= e($phIntro) ?></textarea>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label-rpg">Grievance Officer Name</label>
                                <input type="text" name="pusherhub_grievance_officer" class="form-control form-control-rpg" value="<?= e($phOfficer) ?>">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label-rpg">Grievance Officer Email</label>
                                <input type="email" name="pusherhub_grievance_email" class="form-control form-control-rpg" value="<?= e($phEmail) ?>">
                            </div>
                            <div class="col-12">
                                <div class="p-3 rounded border border-secondary mt-2" style="background: rgba(10, 15, 28, 0.7);">
                                    <div class="text-warning fw-semibold mb-2"><i class="bi bi-shield-lock me-1"></i>DPDP Act (2023) Legal Clauses Active:</div>
                                    <div class="text-secondary small" style="line-height: 1.8;">
                                        ✔ Two Kinds of Data (Account Data vs. App Users' Data)<br>
                                        ✔ Transparent Device Token & FCM Notification Processing<br>
                                        ✔ No Data Selling, No Cross-App Behavioral Tracking<br>
                                        ✔ Standard DPDP Act User Rights (Summary, Correction, Erasure, Grievance Redressal)
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Bottom Action Bar -->
            <div class="d-flex justify-content-end gap-3 mb-4">
                <a href="settings.php" class="btn btn-dark-rpg px-4">Cancel</a>
                <button type="submit" class="btn btn-gold px-5 fw-bold"><i class="bi bi-save me-2"></i>Save & Publish Policies</button>
            </div>
        </form>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
