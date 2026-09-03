<?php
/**
 * LevelUp Web Admin Panel - Edit Quest Task
 */
require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/functions.php';

require_admin_auth();

$db = getDB();
$taskId = trim($_GET['id'] ?? '');

if (empty($taskId)) {
    set_flash('danger', 'Invalid Quest ID specified.');
    header('Location: tasks.php');
    exit;
}

$stmt = $db->prepare("SELECT * FROM tasks WHERE id = ?");
$stmt->execute([$taskId]);
$task = $stmt->fetch();

if (!$task) {
    set_flash('danger', 'Quest not found.');
    header('Location: tasks.php');
    exit;
}

$errors = [];

// Fetch heroes for dropdown
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
        $isCompleted = isset($_POST['is_completed']) ? 1 : 0;

        $durationMinutes = 0;
        $waterGoalMl = 0;

        if ($taskType === 'hydration') {
            $waterGoalMl = max(250, (int)($_POST['water_goal_ml'] ?? 2000));
            $durationMinutes = 0;
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
            $updateStmt = $db->prepare("
                UPDATE tasks SET
                    title = ?,
                    description = ?,
                    category = ?,
                    xp_reward = ?,
                    task_type = ?,
                    duration_minutes = ?,
                    water_goal_ml = ?,
                    scheduled_date = ?,
                    scheduled_time = ?,
                    assigned_user_id = ?,
                    is_completed = ?,
                    is_active = ?,
                    updated_at = NOW()
                WHERE id = ?
            ");
            $updateStmt->execute([
                $title,
                $description,
                $category,
                $xpReward,
                $taskType,
                $durationMinutes,
                $waterGoalMl,
                $scheduledDate,
                $scheduledTime,
                $assignedUserId,
                $isCompleted,
                $isActive,
                $taskId
            ]);

            log_activity($assignedUserId, $_SESSION['admin_id'] ?? null, 'admin_action', "Updated quest '$title'");
            set_flash('success', "Quest '{$title}' updated successfully!");
            header('Location: tasks.php');
            exit;
        }
    }
}

$pageTitle = 'Edit Quest: ' . $task['title'];
$currentPage = 'task-edit';

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
                <h2 class="fw-bold text-white mb-0">Modify Quest Parameters</h2>
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
            <form method="POST" action="task-edit.php?id=<?= urlencode($task['id']) ?>">
                <?php csrf_field(); ?>

                <div class="row g-3">
                    <div class="col-12 col-md-8">
                        <label for="title" class="form-label-rpg">Quest Title *</label>
                        <input type="text" class="form-control form-control-rpg" id="title" name="title" value="<?= e($_POST['title'] ?? $task['title']) ?>" required>
                    </div>

                    <div class="col-12 col-md-4">
                        <label for="category" class="form-label-rpg">Category *</label>
                        <select name="category" id="category" class="form-select form-select-rpg" required>
                            <?php $curCat = $_POST['category'] ?? $task['category']; ?>
                            <option value="Fitness" <?= $curCat === 'Fitness' ? 'selected' : '' ?>>Fitness</option>
                            <option value="Study" <?= $curCat === 'Study' ? 'selected' : '' ?>>Study</option>
                            <option value="Health" <?= $curCat === 'Health' ? 'selected' : '' ?>>Health</option>
                            <option value="Work" <?= $curCat === 'Work' ? 'selected' : '' ?>>Work</option>
                            <option value="Personal" <?= $curCat === 'Personal' ? 'selected' : '' ?>>Personal</option>
                            <option value="Hydration" <?= $curCat === 'Hydration' ? 'selected' : '' ?>>Hydration</option>
                            <option value="Other" <?= $curCat === 'Other' ? 'selected' : '' ?>>Other</option>
                        </select>
                    </div>

                    <div class="col-12">
                        <label for="description" class="form-label-rpg">Quest Objective / Description</label>
                        <textarea class="form-control form-control-rpg" id="description" name="description" rows="3"><?= e($_POST['description'] ?? $task['description']) ?></textarea>
                    </div>

                    <!-- Task Type Switcher -->
                    <div class="col-12 col-md-4">
                        <label for="taskTypeSelect" class="form-label-rpg">Quest Mechanism *</label>
                        <?php $curType = $_POST['task_type'] ?? $task['task_type']; ?>
                        <select name="task_type" id="taskTypeSelect" class="form-select form-select-rpg" required>
                            <option value="normal" <?= $curType === 'normal' ? 'selected' : '' ?>>Timer-Based Quest</option>
                            <option value="hydration" <?= $curType === 'hydration' ? 'selected' : '' ?>>Hydration Quest (No Timer)</option>
                        </select>
                    </div>

                    <!-- Duration (Normal) -->
                    <div class="col-12 col-md-4" id="normalDurationGroup">
                        <label for="duration_minutes" class="form-label-rpg">Duration *</label>
                        <?php $curDur = $_POST['duration_minutes'] ?? $task['duration_minutes']; ?>
                        <select name="duration_minutes" id="duration_minutes" class="form-select form-select-rpg">
                            <option value="10" <?= $curDur == '10' ? 'selected' : '' ?>>10 minutes</option>
                            <option value="20" <?= $curDur == '20' ? 'selected' : '' ?>>20 minutes</option>
                            <option value="30" <?= $curDur == '30' ? 'selected' : '' ?>>30 minutes</option>
                            <option value="40" <?= $curDur == '40' ? 'selected' : '' ?>>40 minutes</option>
                            <option value="45" <?= $curDur == '45' ? 'selected' : '' ?>>45 minutes</option>
                            <option value="60" <?= $curDur == '60' ? 'selected' : '' ?>>60 minutes</option>
                            <option value="90" <?= $curDur == '90' ? 'selected' : '' ?>>90 minutes</option>
                            <option value="120" <?= $curDur == '120' ? 'selected' : '' ?>>120 minutes</option>
                        </select>
                    </div>

                    <!-- Hydration Goal (ml) -->
                    <div class="col-12 col-md-4" id="hydrationGoalGroup" style="display: none;">
                        <label for="water_goal_ml" class="form-label-rpg">Water Intake Goal *</label>
                        <?php $curGoal = $_POST['water_goal_ml'] ?? $task['water_goal_ml']; ?>
                        <select name="water_goal_ml" id="water_goal_ml" class="form-select form-select-rpg">
                            <option value="1500" <?= $curGoal == '1500' ? 'selected' : '' ?>>1.5 Liters (1,500 ml)</option>
                            <option value="2000" <?= $curGoal == '2000' ? 'selected' : '' ?>>2.0 Liters (2,000 ml)</option>
                            <option value="2500" <?= $curGoal == '2500' ? 'selected' : '' ?>>2.5 Liters (2,500 ml)</option>
                            <option value="3000" <?= $curGoal == '3000' ? 'selected' : '' ?>>3.0 Liters (3,000 ml)</option>
                            <option value="3500" <?= $curGoal == '3500' ? 'selected' : '' ?>>3.5 Liters (3,500 ml)</option>
                        </select>
                    </div>

                    <!-- XP Reward -->
                    <div class="col-12 col-md-4">
                        <label for="xp_reward" class="form-label-rpg">XP Reward *</label>
                        <input type="number" class="form-control form-control-rpg" id="xp_reward" name="xp_reward" min="5" value="<?= (int)($_POST['xp_reward'] ?? $task['xp_reward']) ?>" required>
                    </div>

                    <!-- Scheduled Date -->
                    <div class="col-12 col-md-4">
                        <label for="scheduled_date" class="form-label-rpg">Scheduled Date *</label>
                        <input type="date" class="form-control form-control-rpg" id="scheduled_date" name="scheduled_date" value="<?= e($_POST['scheduled_date'] ?? $task['scheduled_date']) ?>" required>
                    </div>

                    <!-- Scheduled Time -->
                    <div class="col-12 col-md-4">
                        <label for="scheduled_time" class="form-label-rpg">Scheduled Time</label>
                        <input type="time" class="form-control form-control-rpg" id="scheduled_time" name="scheduled_time" value="<?= e($_POST['scheduled_time'] ?? $task['scheduled_time']) ?>">
                    </div>

                    <!-- Assigned Hero -->
                    <div class="col-12 col-md-4">
                        <label for="assigned_user_id" class="form-label-rpg">Assigned Hero</label>
                        <?php $curHero = $_POST['assigned_user_id'] ?? $task['assigned_user_id']; ?>
                        <select name="assigned_user_id" id="assigned_user_id" class="form-select form-select-rpg">
                            <option value="">Global Template (Unassigned)</option>
                            <?php foreach ($heroes as $h): ?>
                                <option value="<?= $h['id'] ?>" <?= $curHero == $h['id'] ? 'selected' : '' ?>>
                                    <?= e($h['username']) ?> (LVL <?= $h['level'] ?>)
                                </option>
                            <?php endforeach; ?>
                        </select>
                    </div>

                    <!-- Toggles -->
                    <div class="col-12 col-md-6 mt-4">
                        <div class="form-check form-switch">
                            <input class="form-check-input" type="checkbox" id="is_completed" name="is_completed" <?= (!empty($_POST) ? isset($_POST['is_completed']) : $task['is_completed']) ? 'checked' : '' ?>>
                            <label class="form-check-label text-white fw-semibold" for="is_completed">Mark as Completed</label>
                        </div>
                    </div>

                    <div class="col-12 col-md-6 mt-4">
                        <div class="form-check form-switch">
                            <input class="form-check-input" type="checkbox" id="is_active" name="is_active" <?= (!empty($_POST) ? isset($_POST['is_active']) : $task['is_active']) ? 'checked' : '' ?>>
                            <label class="form-check-label text-white fw-semibold" for="is_active">Quest Active in Realm Catalog</label>
                        </div>
                    </div>

                    <div class="col-12 mt-4 pt-3 border-top border-secondary d-flex gap-2">
                        <button type="submit" class="btn btn-gold px-4">
                            <i class="bi bi-check2-circle me-1"></i> Save Changes
                        </button>
                        <a href="tasks.php" class="btn btn-dark-rpg">Cancel</a>
                    </div>
                </div>
            </form>
        </div>

    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
