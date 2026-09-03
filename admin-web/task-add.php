<?php
/**
 * LevelUp Web Admin Panel - Create Quest Task
 */
require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/functions.php';

require_admin_auth();

$db = getDB();
$errors = [];

// Fetch all active heroes for assignment dropdown
$heroesStmt = $db->query("SELECT id, username, level FROM users WHERE is_active = 1 ORDER BY username ASC");
$heroes = $heroesStmt->fetchAll();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $csrfToken = $_POST['csrf_token'] ?? '';
    if (!verify_csrf_token($csrfToken)) {
        $errors[] = 'Security validation failed (invalid CSRF token).';
    } else {
        $title = trim($_POST['title'] ?? '');
        $description = trim($_POST['description'] ?? '');
        $category = $_POST['category'] ?? 'Personal';
        $xpReward = max(5, (int)($_POST['xp_reward'] ?? 10));
        $taskType = $_POST['task_type'] === 'hydration' ? 'hydration' : 'normal';
        $scheduledDate = $_POST['scheduled_date'] ?? date('Y-m-d');
        $scheduledTime = !empty($_POST['scheduled_time']) ? $_POST['scheduled_time'] : null;
        $assignedUserId = !empty($_POST['assigned_user_id']) ? (int)$_POST['assigned_user_id'] : null;
        $isActive = isset($_POST['is_active']) ? 1 : 0;

        $durationMinutes = 0;
        $waterGoalMl = 0;

        if ($taskType === 'hydration') {
            $waterGoalMl = max(250, (int)($_POST['water_goal_ml'] ?? 2000));
            $durationMinutes = 0; // No timer for hydration
        } else {
            $durationMinutes = max(10, (int)($_POST['duration_minutes'] ?? 30));
            $waterGoalMl = 0;
        }

        if (empty($title)) {
            $errors[] = 'Quest title cannot be empty.';
        }
        if (empty($scheduledDate)) {
            $errors[] = 'Please select a valid scheduled date.';
        }

        if (empty($errors)) {
            $taskId = 'task_' . bin2hex(random_bytes(6));
            $stmt = $db->prepare("
                INSERT INTO tasks (
                    id, title, description, category, xp_reward, is_completed, 
                    scheduled_date, scheduled_time, duration_minutes, timer_status, 
                    is_active, task_type, water_goal_ml, current_water_ml, assigned_user_id, created_at
                ) VALUES (
                    ?, ?, ?, ?, ?, 0, 
                    ?, ?, ?, 'Not Started', 
                    ?, ?, ?, 0, ?, NOW()
                )
            ");
            $stmt->execute([
                $taskId,
                $title,
                $description,
                $category,
                $xpReward,
                $scheduledDate,
                $scheduledTime,
                $durationMinutes,
                $isActive,
                $taskType,
                $waterGoalMl,
                $assignedUserId
            ]);

            log_activity($assignedUserId, $_SESSION['admin_id'] ?? null, 'admin_action', "Created new quest '$title' (+{$xpReward} XP)");
            set_flash('success', "Quest '{$title}' successfully published to the realm!");
            header('Location: tasks.php');
            exit;
        }
    }
}

$pageTitle = 'Create New Quest';
$currentPage = 'task-add';

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/sidebar.php';
?>

<div class="admin-main">
    <?php require_once __DIR__ . '/includes/navbar.php'; ?>

    <div class="content-body">
        <?php display_flash_messages(); ?>

        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <a href="tasks.php" class="btn btn-dark-rpg btn-sm mb-2"><i class="bi bi-arrow-left me-1"></i> Back to Quests</a>
                <h2 class="fw-bold text-white mb-0">Craft New Quest</h2>
                <p class="text-secondary small mb-0">Configure standard timer-based training quests or hydration intake goals.</p>
            </div>
        </div>

        <?php if (!empty($errors)): ?>
            <div class="alert alert-danger" role="alert">
                <ul class="mb-0">
                    <?php foreach ($errors as $err): ?>
                        <li><?= e($err) ?></li>
                    <?php endforeach; ?>
                </ul>
            </div>
        <?php endif; ?>

        <div class="card-rpg">
            <form method="POST" action="task-add.php">
                <?php csrf_field(); ?>

                <div class="row g-3">
                    <!-- Title -->
                    <div class="col-12 col-md-8">
                        <label for="title" class="form-label-rpg">Quest Title *</label>
                        <input type="text" class="form-control form-control-rpg" id="title" name="title" placeholder="e.g. Deep Study Algorithms or Drink 2.5L Water" value="<?= e($_POST['title'] ?? '') ?>" required>
                    </div>

                    <!-- Category -->
                    <div class="col-12 col-md-4">
                        <label for="category" class="form-label-rpg">Category *</label>
                        <select name="category" id="category" class="form-select form-select-rpg" required>
                            <option value="Fitness" <?= ($_POST['category'] ?? '') === 'Fitness' ? 'selected' : '' ?>>Fitness</option>
                            <option value="Study" <?= ($_POST['category'] ?? '') === 'Study' ? 'selected' : '' ?>>Study</option>
                            <option value="Health" <?= ($_POST['category'] ?? '') === 'Health' ? 'selected' : '' ?>>Health</option>
                            <option value="Work" <?= ($_POST['category'] ?? '') === 'Work' ? 'selected' : '' ?>>Work</option>
                            <option value="Personal" <?= ($_POST['category'] ?? 'Personal') === 'Personal' ? 'selected' : '' ?>>Personal</option>
                            <option value="Hydration" <?= ($_POST['category'] ?? '') === 'Hydration' ? 'selected' : '' ?>>Hydration</option>
                            <option value="Other" <?= ($_POST['category'] ?? '') === 'Other' ? 'selected' : '' ?>>Other</option>
                        </select>
                    </div>

                    <!-- Description -->
                    <div class="col-12">
                        <label for="description" class="form-label-rpg">Quest Objective / Description</label>
                        <textarea class="form-control form-control-rpg" id="description" name="description" rows="3" placeholder="Provide clear instructions and heroic motivations..."><?= e($_POST['description'] ?? '') ?></textarea>
                    </div>

                    <!-- Task Type Switcher -->
                    <div class="col-12 col-md-4">
                        <label for="taskTypeSelect" class="form-label-rpg">Quest Mechanism *</label>
                        <select name="task_type" id="taskTypeSelect" class="form-select form-select-rpg" required>
                            <option value="normal" <?= ($_POST['task_type'] ?? '') !== 'hydration' ? 'selected' : '' ?>>Timer-Based Quest (Time Countdown)</option>
                            <option value="hydration" <?= ($_POST['task_type'] ?? '') === 'hydration' ? 'selected' : '' ?>>Hydration Quest (Daily Water Target - No Timer)</option>
                        </select>
                    </div>

                    <!-- Duration (Normal) -->
                    <div class="col-12 col-md-4" id="normalDurationGroup">
                        <label for="duration_minutes" class="form-label-rpg">Duration *</label>
                        <select name="duration_minutes" id="duration_minutes" class="form-select form-select-rpg">
                            <option value="10" <?= ($_POST['duration_minutes'] ?? '') == '10' ? 'selected' : '' ?>>10 minutes</option>
                            <option value="20" <?= ($_POST['duration_minutes'] ?? '') == '20' ? 'selected' : '' ?>>20 minutes</option>
                            <option value="30" <?= ($_POST['duration_minutes'] ?? '30') == '30' ? 'selected' : '' ?>>30 minutes (Standard)</option>
                            <option value="40" <?= ($_POST['duration_minutes'] ?? '') == '40' ? 'selected' : '' ?>>40 minutes</option>
                            <option value="45" <?= ($_POST['duration_minutes'] ?? '') == '45' ? 'selected' : '' ?>>45 minutes</option>
                            <option value="60" <?= ($_POST['duration_minutes'] ?? '') == '60' ? 'selected' : '' ?>>60 minutes (1 Hour)</option>
                            <option value="90" <?= ($_POST['duration_minutes'] ?? '') == '90' ? 'selected' : '' ?>>90 minutes (1.5 Hours)</option>
                            <option value="120" <?= ($_POST['duration_minutes'] ?? '') == '120' ? 'selected' : '' ?>>120 minutes (2 Hours)</option>
                        </select>
                    </div>

                    <!-- Hydration Goal (ml) -->
                    <div class="col-12 col-md-4" id="hydrationGoalGroup" style="display: none;">
                        <label for="water_goal_ml" class="form-label-rpg">Water Intake Goal *</label>
                        <select name="water_goal_ml" id="water_goal_ml" class="form-select form-select-rpg">
                            <option value="1500" <?= ($_POST['water_goal_ml'] ?? '') == '1500' ? 'selected' : '' ?>>1.5 Liters (1,500 ml)</option>
                            <option value="2000" <?= ($_POST['water_goal_ml'] ?? '2000') == '2000' ? 'selected' : '' ?>>2.0 Liters (2,000 ml - Standard)</option>
                            <option value="2500" <?= ($_POST['water_goal_ml'] ?? '') == '2500' ? 'selected' : '' ?>>2.5 Liters (2,500 ml)</option>
                            <option value="3000" <?= ($_POST['water_goal_ml'] ?? '') == '3000' ? 'selected' : '' ?>>3.0 Liters (3,000 ml - Athlete)</option>
                            <option value="3500" <?= ($_POST['water_goal_ml'] ?? '') == '3500' ? 'selected' : '' ?>>3.5 Liters (3,500 ml)</option>
                        </select>
                        <small class="text-info" style="font-size: 0.75rem;"><i class="bi bi-info-circle me-1"></i>Hydration quests never run timers</small>
                    </div>

                    <!-- XP Reward -->
                    <div class="col-12 col-md-4">
                        <label for="xp_reward" class="form-label-rpg">XP Reward *</label>
                        <input type="number" class="form-control form-control-rpg" id="xp_reward" name="xp_reward" min="5" max="1000" value="<?= (int)($_POST['xp_reward'] ?? 50) ?>" required>
                    </div>

                    <!-- Scheduled Date -->
                    <div class="col-12 col-md-4">
                        <label for="scheduled_date" class="form-label-rpg">Scheduled Date *</label>
                        <input type="date" class="form-control form-control-rpg" id="scheduled_date" name="scheduled_date" value="<?= e($_POST['scheduled_date'] ?? date('Y-m-d')) ?>" required>
                        <small class="text-secondary" style="font-size: 0.72rem;">Future dates will lock quest completion until that day</small>
                    </div>

                    <!-- Scheduled Time -->
                    <div class="col-12 col-md-4">
                        <label for="scheduled_time" class="form-label-rpg">Scheduled Time (Optional)</label>
                        <input type="time" class="form-control form-control-rpg" id="scheduled_time" name="scheduled_time" value="<?= e($_POST['scheduled_time'] ?? '') ?>">
                    </div>

                    <!-- Assigned Hero -->
                    <div class="col-12 col-md-4">
                        <label for="assigned_user_id" class="form-label-rpg">Assign Hero (Optional)</label>
                        <select name="assigned_user_id" id="assigned_user_id" class="form-select form-select-rpg">
                            <option value="">Global Template (All Heroes Can Quest)</option>
                            <?php foreach ($heroes as $h): ?>
                                <option value="<?= $h['id'] ?>" <?= ($_POST['assigned_user_id'] ?? '') == $h['id'] ? 'selected' : '' ?>>
                                    <?= e($h['username']) ?> (LVL <?= $h['level'] ?>)
                                </option>
                            <?php endforeach; ?>
                        </select>
                    </div>

                    <!-- Status -->
                    <div class="col-12 mt-3">
                        <div class="form-check form-switch">
                            <input class="form-check-input" type="checkbox" id="is_active" name="is_active" checked>
                            <label class="form-check-label text-white fw-semibold" for="is_active">Quest Active in Realm Catalog</label>
                        </div>
                    </div>

                    <div class="col-12 mt-4 pt-3 border-top border-secondary d-flex gap-2">
                        <button type="submit" class="btn btn-gold px-4">
                            <i class="bi bi-plus-circle-fill me-1"></i> Publish Quest
                        </button>
                        <a href="tasks.php" class="btn btn-dark-rpg">Cancel</a>
                    </div>
                </div>
            </form>
        </div>

    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
