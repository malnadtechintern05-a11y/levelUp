<?php
/**
 * LevelUp Web Admin Panel - Add New Hero User
 */
require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/functions.php';

require_admin_auth();

$db = getDB();
$errors = [];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $csrfToken = $_POST['csrf_token'] ?? '';
    if (!verify_csrf_token($csrfToken)) {
        $errors[] = 'Security validation failed (invalid CSRF token).';
    } else {
        $username = trim($_POST['username'] ?? '');
        $email = trim($_POST['email'] ?? '');
        $level = max(1, (int)($_POST['level'] ?? 1));
        $totalXp = max(0, (int)($_POST['total_xp'] ?? 0));
        $gold = max(0, (int)($_POST['gold'] ?? 50));
        $avatarId = trim($_POST['avatar_id'] ?? 'hero1');

        if (empty($username)) {
            $errors[] = 'Hero username is required.';
        }

        if (!empty($email)) {
            $stmt = $db->prepare("SELECT COUNT(*) FROM users WHERE email = ?");
            $stmt->execute([$email]);
            if ($stmt->fetchColumn() > 0) {
                $errors[] = 'This email address is already bound to another hero.';
            }
        }

        $password = trim($_POST['password'] ?? '');
        if (empty($password)) {
            $password = '123456';
        }
        $passwordHash = password_hash($password, PASSWORD_BCRYPT);

        if (empty($errors)) {
            $defaultSkills = json_encode(['Strength' => 50, 'Knowledge' => 50, 'Discipline' => 50]);
            $insertStmt = $db->prepare("
                INSERT INTO users (username, email, password_hash, avatar_id, level, total_xp, gold, current_streak, best_streak, skills_json, is_active, created_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, 0, 0, ?, 1, NOW())
            ");
            $insertStmt->execute([
                $username,
                empty($email) ? null : $email,
                $passwordHash,
                $avatarId,
                $level,
                $totalXp,
                $gold,
                $defaultSkills
            ]);

            $newUserId = (int)$db->lastInsertId();
            log_activity($newUserId, $_SESSION['admin_id'] ?? null, 'user_registered', "Admin registered new hero '$username' (ID #$newUserId)");
            set_flash('success', "Hero '{$username}' successfully created and enrolled in LevelUp!");
            header("Location: user-view.php?id=$newUserId");
            exit;
        }
    }
}

$pageTitle = 'Enroll New Hero';
$currentPage = 'users';

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/sidebar.php';
?>

<div class="admin-main">
    <?php require_once __DIR__ . '/includes/navbar.php'; ?>

    <div class="content-body">
        <?php display_flash_messages(); ?>

        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <a href="users.php" class="btn btn-dark-rpg btn-sm mb-2"><i class="bi bi-arrow-left me-1"></i> Back to Hero Roster</a>
                <h2 class="fw-bold text-white mb-0">Enroll New Hero</h2>
                <p class="text-secondary small mb-0">Add a new player profile directly to the LevelUp universe database.</p>
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
            <form method="POST" action="user-add.php">
                <?php csrf_field(); ?>

                <div class="row g-3">
                    <div class="col-12 col-md-6">
                        <label for="username" class="form-label-rpg">Hero Username *</label>
                        <input type="text" class="form-control form-control-rpg" id="username" name="username" placeholder="e.g. PhoenixKnight" value="<?= e($_POST['username'] ?? '') ?>" required>
                    </div>

                    <div class="col-12 col-md-6">
                        <label for="email" class="form-label-rpg">Hero Email Address (Optional)</label>
                        <input type="email" class="form-control form-control-rpg" id="email" name="email" placeholder="hero@levelup.com" value="<?= e($_POST['email'] ?? '') ?>">
                    </div>

                    <div class="col-12 col-md-6">
                        <label for="password" class="form-label-rpg">Hero Password (Default: 123456)</label>
                        <input type="password" class="form-control form-control-rpg" id="password" name="password" placeholder="Leave empty for default: 123456">
                    </div>

                    <div class="col-6 col-md-4">
                        <label for="level" class="form-label-rpg">Starting Level</label>
                        <input type="number" class="form-control form-control-rpg" id="level" name="level" min="1" value="<?= (int)($_POST['level'] ?? 1) ?>" required>
                    </div>

                    <div class="col-6 col-md-4">
                        <label for="total_xp" class="form-label-rpg">Starting XP</label>
                        <input type="number" class="form-control form-control-rpg" id="total_xp" name="total_xp" min="0" value="<?= (int)($_POST['total_xp'] ?? 0) ?>" required>
                    </div>

                    <div class="col-12 col-md-4">
                        <label for="gold" class="form-label-rpg">Starting Gold Coins</label>
                        <input type="number" class="form-control form-control-rpg" id="gold" name="gold" min="0" value="<?= (int)($_POST['gold'] ?? 50) ?>">
                    </div>

                    <div class="col-12 col-md-6">
                        <label for="avatar_id" class="form-label-rpg">Default Avatar Class</label>
                        <select name="avatar_id" id="avatar_id" class="form-select form-select-rpg">
                            <option value="hero1">Hero Knight (Warrior)</option>
                            <option value="hero2">Cyber Mage (Scholar)</option>
                            <option value="hero3">Valkyrie Scout (Agility)</option>
                        </select>
                    </div>

                    <div class="col-12 mt-4 pt-3 border-top border-secondary d-flex gap-2">
                        <button type="submit" class="btn btn-gold px-4">
                            <i class="bi bi-person-plus-fill me-1"></i> Create Hero Account
                        </button>
                        <a href="users.php" class="btn btn-dark-rpg">Cancel</a>
                    </div>
                </div>
            </form>
        </div>

    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
