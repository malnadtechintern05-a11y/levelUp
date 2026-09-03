<?php
/**
 * LevelUp Web Admin Panel - Edit User / Hero Stats
 */
require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/functions.php';

require_admin_auth();

$db = getDB();
$userId = (int)($_GET['id'] ?? 0);

if ($userId <= 0) {
    set_flash('danger', 'Invalid Hero ID.');
    header('Location: users.php');
    exit;
}

$stmt = $db->prepare("SELECT * FROM users WHERE id = ?");
$stmt->execute([$userId]);
$user = $stmt->fetch();

if (!$user) {
    set_flash('danger', 'Hero not found.');
    header('Location: users.php');
    exit;
}

$errors = [];

// Handle update form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $csrfToken = $_POST['csrf_token'] ?? '';
    if (!verify_csrf_token($csrfToken)) {
        $errors[] = 'Security validation failed (invalid CSRF token).';
    } else {
        $username = trim($_POST['username'] ?? '');
        $email = trim($_POST['email'] ?? '');
        $level = max(1, (int)($_POST['level'] ?? 1));
        $totalXp = max(0, (int)($_POST['total_xp'] ?? 0));
        $gold = max(0, (int)($_POST['gold'] ?? 0));
        $currentStreak = max(0, (int)($_POST['current_streak'] ?? 0));
        $bestStreak = max($currentStreak, (int)($_POST['best_streak'] ?? $currentStreak));
        $isActive = isset($_POST['is_active']) ? 1 : 0;

        $str = min(100, max(0, (int)($_POST['strength'] ?? 50)));
        $kno = min(100, max(0, (int)($_POST['knowledge'] ?? 50)));
        $dis = min(100, max(0, (int)($_POST['discipline'] ?? 50)));
        $skillsJson = json_encode(['Strength' => $str, 'Knowledge' => $kno, 'Discipline' => $dis]);

        if (empty($username)) {
            $errors[] = 'Hero username cannot be empty.';
        }

        // Email uniqueness check (if provided and different)
        if (!empty($email) && $email !== $user['email']) {
            $checkStmt = $db->prepare("SELECT COUNT(*) FROM users WHERE email = ? AND id != ?");
            $checkStmt->execute([$email, $userId]);
            if ($checkStmt->fetchColumn() > 0) {
                $errors[] = 'The provided email is already bound to another hero.';
            }
        }

        if (empty($errors)) {
            $updateStmt = $db->prepare("
                UPDATE users SET 
                    username = ?, 
                    email = ?, 
                    level = ?, 
                    total_xp = ?, 
                    gold = ?, 
                    current_streak = ?, 
                    best_streak = ?, 
                    skills_json = ?, 
                    is_active = ?,
                    updated_at = NOW()
                WHERE id = ?
            ");
            $updateStmt->execute([
                $username,
                empty($email) ? null : $email,
                $level,
                $totalXp,
                $gold,
                $currentStreak,
                $bestStreak,
                $skillsJson,
                $isActive,
                $userId
            ]);

            log_activity($userId, $_SESSION['admin_id'] ?? null, 'admin_action', "Modified stats for hero '$username' (LVL $level, $totalXp XP)");
            set_flash('success', "Hero stats for '{$username}' updated successfully!");
            header("Location: user-view.php?id=$userId");
            exit;
        }
    }
}

$pageTitle = "Edit Hero: " . $user['username'];
$currentPage = 'user-edit';

$skills = ['Strength' => 50, 'Knowledge' => 50, 'Discipline' => 50];
if (!empty($user['skills_json'])) {
    $decoded = json_decode($user['skills_json'], true);
    if (is_array($decoded)) {
        $skills = array_merge($skills, $decoded);
    }
}

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/sidebar.php';
?>

<div class="admin-main">
    <?php require_once __DIR__ . '/includes/navbar.php'; ?>

    <div class="content-body">
        <?php display_flash_messages(); ?>

        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <a href="user-view.php?id=<?= $user['id'] ?>" class="btn btn-dark-rpg btn-sm mb-2"><i class="bi bi-arrow-left me-1"></i> Back to Hero View</a>
                <h2 class="fw-bold text-white mb-0">Edit Hero Parameters</h2>
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
            <form method="POST" action="user-edit.php?id=<?= $user['id'] ?>">
                <?php csrf_field(); ?>

                <div class="row g-3">
                    <div class="col-12 col-md-6">
                        <label for="username" class="form-label-rpg">Hero Username *</label>
                        <input type="text" class="form-control form-control-rpg" id="username" name="username" value="<?= e($_POST['username'] ?? $user['username']) ?>" required>
                    </div>

                    <div class="col-12 col-md-6">
                        <label for="email" class="form-label-rpg">Hero Email Address</label>
                        <input type="email" class="form-control form-control-rpg" id="email" name="email" value="<?= e($_POST['email'] ?? $user['email']) ?>">
                    </div>

                    <div class="col-6 col-md-3">
                        <label for="level" class="form-label-rpg">Level</label>
                        <input type="number" class="form-control form-control-rpg" id="level" name="level" min="1" value="<?= (int)($_POST['level'] ?? $user['level']) ?>" required>
                    </div>

                    <div class="col-6 col-md-3">
                        <label for="total_xp" class="form-label-rpg">Total XP</label>
                        <input type="number" class="form-control form-control-rpg" id="total_xp" name="total_xp" min="0" value="<?= (int)($_POST['total_xp'] ?? $user['total_xp']) ?>" required>
                    </div>

                    <div class="col-6 col-md-3">
                        <label for="gold" class="form-label-rpg">Gold Coins</label>
                        <input type="number" class="form-control form-control-rpg" id="gold" name="gold" min="0" value="<?= (int)($_POST['gold'] ?? $user['gold']) ?>">
                    </div>

                    <div class="col-6 col-md-3">
                        <label for="current_streak" class="form-label-rpg">Current Streak (Days)</label>
                        <input type="number" class="form-control form-control-rpg" id="current_streak" name="current_streak" min="0" value="<?= (int)($_POST['current_streak'] ?? $user['current_streak']) ?>">
                    </div>

                    <div class="col-6 col-md-3">
                        <label for="best_streak" class="form-label-rpg">Best Streak (Days)</label>
                        <input type="number" class="form-control form-control-rpg" id="best_streak" name="best_streak" min="0" value="<?= (int)($_POST['best_streak'] ?? $user['best_streak']) ?>">
                    </div>

                    <!-- RPG Attributes -->
                    <div class="col-12 mt-4">
                        <h5 class="text-warning fw-bold border-bottom border-secondary pb-2 mb-3">
                            <i class="bi bi-shield-check me-2"></i>RPG Attributes (0 - 100)
                        </h5>
                    </div>

                    <div class="col-12 col-md-4">
                        <label for="strength" class="form-label-rpg">Strength</label>
                        <input type="number" class="form-control form-control-rpg" id="strength" name="strength" min="0" max="100" value="<?= (int)($_POST['strength'] ?? $skills['Strength'] ?? 50) ?>">
                    </div>

                    <div class="col-12 col-md-4">
                        <label for="knowledge" class="form-label-rpg">Knowledge</label>
                        <input type="number" class="form-control form-control-rpg" id="knowledge" name="knowledge" min="0" max="100" value="<?= (int)($_POST['knowledge'] ?? $skills['Knowledge'] ?? 50) ?>">
                    </div>

                    <div class="col-12 col-md-4">
                        <label for="discipline" class="form-label-rpg">Discipline</label>
                        <input type="number" class="form-control form-control-rpg" id="discipline" name="discipline" min="0" max="100" value="<?= (int)($_POST['discipline'] ?? $skills['Discipline'] ?? 50) ?>">
                    </div>

                    <!-- Status Switch -->
                    <div class="col-12 mt-3">
                        <div class="form-check form-switch">
                            <input class="form-check-input" type="checkbox" id="is_active" name="is_active" <?= (!empty($_POST) ? isset($_POST['is_active']) : $user['is_active']) ? 'checked' : '' ?>>
                            <label class="form-check-label text-white fw-semibold" for="is_active">Account Active & Enabled in Realm</label>
                        </div>
                    </div>

                    <div class="col-12 mt-4 pt-3 border-top border-secondary d-flex gap-2">
                        <button type="submit" class="btn btn-gold px-4">
                            <i class="bi bi-check2-circle me-1"></i> Save Changes
                        </button>
                        <a href="user-view.php?id=<?= $user['id'] ?>" class="btn btn-dark-rpg">Cancel</a>
                    </div>
                </div>
            </form>
        </div>

    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
