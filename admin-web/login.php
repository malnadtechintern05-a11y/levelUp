<?php
/**
 * LevelUp Web Admin Panel - Secure Admin Login
 */
require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/functions.php';

// Redirect if already authenticated
if (is_admin_logged_in()) {
    header("Location: dashboard.php");
    exit;
}

$errorMessage = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = trim($_POST['email'] ?? '');
    $password = $_POST['password'] ?? '';
    $csrfToken = $_POST['csrf_token'] ?? '';

    // 1. Verify CSRF Token
    if (!verify_csrf_token($csrfToken)) {
        $errorMessage = 'Security validation failed (CSRF). Please try again.';
    } elseif (empty($email) || empty($password)) {
        $errorMessage = 'Please provide both email and password.';
    } else {
        try {
            $db = getDB();
            $stmt = $db->prepare("SELECT id, username, email, password_hash, role FROM admins WHERE email = ? LIMIT 1");
            $stmt->execute([$email]);
            $admin = $stmt->fetch();

            if ($admin && password_verify($password, $admin['password_hash'])) {
                // Successful authentication: regenerate session ID to prevent fixation
                session_regenerate_id(true);

                $_SESSION['admin_id'] = $admin['id'];
                $_SESSION['admin_username'] = $admin['username'];
                $_SESSION['admin_email'] = $admin['email'];
                $_SESSION['admin_role'] = $admin['role'];

                // Update last login timestamp
                $updateStmt = $db->prepare("UPDATE admins SET last_login = NOW() WHERE id = ?");
                $updateStmt->execute([$admin['id']]);

                // Log activity
                log_activity(null, $admin['id'], 'admin_login', "Admin '{$admin['username']}' logged in successfully");

                set_flash('success', "Welcome back, Commander {$admin['username']}!");
                header("Location: dashboard.php");
                exit;
            } else {
                $errorMessage = 'Invalid email or password. Please check your credentials.';
            }
        } catch (Exception $e) {
            error_log("Login error: " . $e->getMessage());
            $errorMessage = 'An internal system error occurred. Please try again later.';
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login | LevelUp RPG Command Center</title>

    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Outfit:wght@600;700;800;900&display=swap" rel="stylesheet">

    <!-- Bootstrap 5 & Icons (Local Offline Assets) -->
    <link href="/admin-web/assets/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="/admin-web/assets/css/bootstrap-icons.min.css">

    <!-- Custom CSS -->
    <link rel="stylesheet" href="/admin-web/assets/css/admin.css?v=<?= time() ?>">
</head>
<body class="d-flex align-items-center justify-content-center py-5" style="background: radial-gradient(circle at top center, #162544 0%, #0A0F1C 75%); min-height: 100vh;">

<div class="container">
    <div class="row justify-content-center">
        <div class="col-12 col-sm-10 col-md-8 col-lg-5 col-xl-4">
            
            <!-- Branding Header -->
            <div class="text-center mb-4">
                <div class="d-inline-flex align-items-center justify-content-center mb-3">
                    <div class="brand-badge p-3 fs-3 rounded-4">
                        <i class="bi bi-shield-shaded"></i>
                    </div>
                </div>
                <h2 class="fw-bold text-white mb-1">LEVELUP COMMAND</h2>
                <p class="text-secondary small mb-0">Authorized Administrator Access Only</p>
            </div>

            <!-- Login Card -->
            <div class="card-rpg shadow-lg p-4 p-sm-5 border-1">
                <?php if (!empty($errorMessage)): ?>
                    <div class="alert alert-danger d-flex align-items-center gap-2 mb-4" role="alert">
                        <i class="bi bi-shield-x fs-5"></i>
                        <div class="small"><?= e($errorMessage) ?></div>
                    </div>
                <?php endif; ?>

                <?php display_flash_messages(); ?>

                <form method="POST" action="login.php" autocomplete="off">
                    <?php csrf_field(); ?>

                    <div class="mb-3">
                        <label for="email" class="form-label-rpg">Admin Email</label>
                        <div class="input-group">
                            <span class="input-group-text bg-dark border-secondary text-secondary">
                                <i class="bi bi-envelope-fill"></i>
                            </span>
                            <input type="email" class="form-control form-control-rpg" id="email" name="email" 
                                   placeholder="admin@levelup.com" value="<?= e($_POST['email'] ?? 'admin@levelup.com') ?>" required autofocus>
                        </div>
                    </div>

                    <div class="mb-4">
                        <label for="password" class="form-label-rpg">Master Password</label>
                        <div class="input-group">
                            <span class="input-group-text bg-dark border-secondary text-secondary">
                                <i class="bi bi-key-fill"></i>
                            </span>
                            <input type="password" class="form-control form-control-rpg" id="password" name="password" 
                                   placeholder="••••••••••••" value="admin123" required>
                            <button type="button" class="btn btn-outline-secondary border-secondary toggle-password-btn" data-target="password" aria-label="Toggle password visibility">
                                <i class="bi bi-eye"></i>
                            </button>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-gold w-100 py-2 justify-content-center fs-6">
                        <i class="bi bi-box-arrow-in-right me-1"></i> Enter Command Center
                    </button>
                </form>

                <div class="mt-4 pt-3 border-top border-secondary text-center">
                    <small class="text-muted d-block mb-1">Default Development Account:</small>
                    <code class="text-warning small bg-dark px-2 py-1 rounded">admin@levelup.com / admin123</code>
                </div>
            </div>

            <!-- Footer info -->
            <div class="text-center mt-4 text-muted small">
                LevelUp Real-Life RPG Security Gateway &copy; <?= date('Y') ?>
            </div>

        </div>
    </div>
</div>

<!-- Bootstrap & JS (Local Offline Assets) -->
<script src="/admin-web/assets/js/bootstrap.bundle.min.js"></script>
<script src="/admin-web/assets/js/admin.js?v=<?= time() ?>"></script>
</body>
</html>
