<?php
/**
 * LevelUp Web Admin Panel - Achievements Management
 */
require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/functions.php';

require_admin_auth();

$pageTitle = 'Trophies & Achievements';
$currentPage = 'achievements';

$db = getDB();

// Handle POST actions: Add, Edit, Delete, Toggle Active
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    $csrfToken = $_POST['csrf_token'] ?? '';

    if (!verify_csrf_token($csrfToken)) {
        set_flash('danger', 'Security validation failed (invalid CSRF token).');
        header('Location: achievements.php');
        exit;
    }

    if ($action === 'add') {
        $name = trim($_POST['name'] ?? '');
        $description = trim($_POST['description'] ?? '');
        $unlockReq = trim($_POST['unlock_requirement'] ?? '');
        $xpReward = max(0, (int)($_POST['xp_reward'] ?? 50));
        $iconName = trim($_POST['icon_name'] ?? 'trophy');
        $isActive = isset($_POST['is_active']) ? 1 : 0;

        if (empty($name) || empty($unlockReq)) {
            set_flash('danger', 'Achievement name and requirement are required.');
        } else {
            $id = strtolower(preg_replace('/[^a-zA-Z0-9_]/', '_', $name)) . '_' . bin2hex(random_bytes(2));
            $stmt = $db->prepare("INSERT INTO achievements (id, name, description, xp_reward, unlock_requirement, icon_name, is_active, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, NOW())");
            $stmt->execute([$id, $name, $description, $xpReward, $unlockReq, $iconName, $isActive]);

            log_activity(null, $_SESSION['admin_id'] ?? null, 'admin_action', "Created achievement '$name'");
            set_flash('success', "Achievement '{$name}' created successfully!");
        }
    } elseif ($action === 'edit') {
        $id = trim($_POST['id'] ?? '');
        $name = trim($_POST['name'] ?? '');
        $description = trim($_POST['description'] ?? '');
        $unlockReq = trim($_POST['unlock_requirement'] ?? '');
        $xpReward = max(0, (int)($_POST['xp_reward'] ?? 50));
        $iconName = trim($_POST['icon_name'] ?? 'trophy');
        $isActive = isset($_POST['is_active']) ? 1 : 0;

        if (!empty($id) && !empty($name)) {
            $stmt = $db->prepare("UPDATE achievements SET name = ?, description = ?, xp_reward = ?, unlock_requirement = ?, icon_name = ?, is_active = ? WHERE id = ?");
            $stmt->execute([$name, $description, $xpReward, $unlockReq, $iconName, $isActive, $id]);

            log_activity(null, $_SESSION['admin_id'] ?? null, 'admin_action', "Updated achievement '$name'");
            set_flash('success', "Achievement '{$name}' updated successfully!");
        }
    } elseif ($action === 'toggle_active') {
        $id = trim($_POST['id'] ?? '');
        if (!empty($id)) {
            $stmt = $db->prepare("UPDATE achievements SET is_active = IF(is_active=1, 0, 1) WHERE id = ?");
            $stmt->execute([$id]);
            set_flash('success', "Achievement status toggled.");
        }
    } elseif ($action === 'delete') {
        $id = trim($_POST['id'] ?? '');
        if (!empty($id)) {
            $stmt = $db->prepare("DELETE FROM achievements WHERE id = ?");
            $stmt->execute([$id]);
            log_activity(null, $_SESSION['admin_id'] ?? null, 'admin_action', "Deleted achievement ID '$id'");
            set_flash('success', "Achievement permanently removed.");
        }
    }

    header('Location: achievements.php');
    exit;
}

// Fetch all achievements with claim counts
$query = "
    SELECT a.*, 
           (SELECT COUNT(*) FROM user_achievements ua WHERE ua.achievement_id = a.id) as unlock_count
    FROM achievements a
    ORDER BY a.xp_reward ASC, a.name ASC
";
$achievements = $db->query($query)->fetchAll();

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
                <h2 class="fw-bold text-white mb-1">Trophies & Milestones</h2>
                <p class="text-secondary mb-0">Create heroic milestone badges that motivate heroes to sustain habits and conquer goals.</p>
            </div>
            <div>
                <button type="button" class="btn btn-gold" data-bs-toggle="modal" data-bs-target="#addAchievementModal">
                    <i class="bi bi-trophy-fill me-1"></i> Add Achievement
                </button>
            </div>
        </div>

        <!-- Grid Cards -->
        <div class="row g-3">
            <?php foreach ($achievements as $ach): ?>
                <div class="col-12 col-md-6 col-xl-4">
                    <div class="card-rpg h-100 d-flex flex-column justify-content-between">
                        <div>
                            <div class="d-flex justify-content-between align-items-start mb-3">
                                <div class="stat-icon-box icon-gold" style="width: 50px; height: 50px; font-size: 1.5rem;">
                                    <i class="bi bi-<?= e($ach['icon_name']) ?>"></i>
                                </div>
                                <div class="text-end">
                                    <span class="badge badge-gold font-monospace fs-6">
                                        +<?= number_format($ach['xp_reward']) ?> XP
                                    </span>
                                    <div class="mt-1">
                                        <?php if ($ach['is_active']): ?>
                                            <span class="badge badge-active" style="font-size: 0.7rem;">Active</span>
                                        <?php else: ?>
                                            <span class="badge badge-inactive" style="font-size: 0.7rem;">Disabled</span>
                                        <?php endif; ?>
                                    </div>
                                </div>
                            </div>

                            <h5 class="fw-bold text-white mb-1"><?= e($ach['name']) ?></h5>
                            <p class="text-secondary small mb-3"><?= e($ach['description']) ?></p>

                            <div class="p-2 rounded bg-dark border border-secondary mb-3">
                                <small class="text-muted text-uppercase d-block" style="font-size: 0.68rem; letter-spacing: 0.05em;">Unlock Requirement</small>
                                <span class="text-white fw-semibold small"><i class="bi bi-key-fill text-warning me-1"></i><?= e($ach['unlock_requirement']) ?></span>
                            </div>
                        </div>

                        <div class="pt-3 border-top border-secondary d-flex justify-content-between align-items-center">
                            <span class="text-muted small">
                                <i class="bi bi-person-check me-1 text-info"></i><?= $ach['unlock_count'] ?> heroes claimed
                            </span>

                            <div class="btn-group btn-group-sm">
                                <!-- Edit Modal Trigger -->
                                <button type="button" class="btn btn-dark-rpg px-2" data-bs-toggle="modal" data-bs-target="#editModal_<?= e($ach['id']) ?>" title="Edit">
                                    <i class="bi bi-pencil-square"></i>
                                </button>

                                <!-- Toggle Active Form -->
                                <form method="POST" action="achievements.php" class="d-inline">
                                    <?php csrf_field(); ?>
                                    <input type="hidden" name="id" value="<?= e($ach['id']) ?>">
                                    <input type="hidden" name="action" value="toggle_active">
                                    <button type="submit" class="btn btn-dark-rpg px-2 <?= $ach['is_active'] ? 'text-secondary' : 'text-success' ?>" title="Toggle Active Status">
                                        <i class="bi <?= $ach['is_active'] ? 'bi-pause-circle' : 'bi-play-circle' ?>"></i>
                                    </button>
                                </form>

                                <!-- Delete Form -->
                                <form method="POST" action="achievements.php" class="d-inline">
                                    <?php csrf_field(); ?>
                                    <input type="hidden" name="id" value="<?= e($ach['id']) ?>">
                                    <input type="hidden" name="action" value="delete">
                                    <button type="submit" class="btn btn-dark-rpg px-2 text-danger" title="Delete" data-confirm="Delete achievement '<?= e($ach['name']) ?>'?">
                                        <i class="bi bi-trash"></i>
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Edit Achievement Modal for this item -->
                <div class="modal fade" id="editModal_<?= e($ach['id']) ?>" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered">
                        <div class="modal-content modal-content-rpg">
                            <form method="POST" action="achievements.php">
                                <?php csrf_field(); ?>
                                <input type="hidden" name="action" value="edit">
                                <input type="hidden" name="id" value="<?= e($ach['id']) ?>">

                                <div class="modal-header modal-header-rpg">
                                    <h5 class="modal-title fw-bold text-white"><i class="bi bi-pencil-square text-warning me-2"></i>Edit Trophy</h5>
                                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                                </div>
                                <div class="modal-body p-4">
                                    <div class="mb-3">
                                        <label class="form-label-rpg">Achievement Name *</label>
                                        <input type="text" name="name" class="form-control form-control-rpg" value="<?= e($ach['name']) ?>" required>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label-rpg">Description</label>
                                        <textarea name="description" class="form-control form-control-rpg" rows="2"><?= e($ach['description']) ?></textarea>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label-rpg">Unlock Requirement *</label>
                                        <input type="text" name="unlock_requirement" class="form-control form-control-rpg" value="<?= e($ach['unlock_requirement']) ?>" required>
                                    </div>
                                    <div class="row g-2 mb-3">
                                        <div class="col-6">
                                            <label class="form-label-rpg">XP Reward</label>
                                            <input type="number" name="xp_reward" class="form-control form-control-rpg" value="<?= (int)$ach['xp_reward'] ?>" min="0">
                                        </div>
                                        <div class="col-6">
                                            <label class="form-label-rpg">Bootstrap Icon</label>
                                            <select name="icon_name" class="form-select form-select-rpg">
                                                <?php 
                                                    $icons = ['trophy', 'award', 'star', 'lightning-charge', 'gem', 'fire', 'shield-check', 'chevron-double-up', 'crown', 'droplet-half'];
                                                    foreach ($icons as $ic):
                                                ?>
                                                    <option value="<?= $ic ?>" <?= $ach['icon_name'] === $ic ? 'selected' : '' ?>><?= $ic ?></option>
                                                <?php endforeach; ?>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="form-check form-switch mt-2">
                                        <input class="form-check-input" type="checkbox" name="is_active" id="editActive_<?= e($ach['id']) ?>" <?= $ach['is_active'] ? 'checked' : '' ?>>
                                        <label class="form-check-label text-white" for="editActive_<?= e($ach['id']) ?>">Active & Unlockable</label>
                                    </div>
                                </div>
                                <div class="modal-footer modal-footer-rpg">
                                    <button type="button" class="btn btn-dark-rpg" data-bs-dismiss="modal">Cancel</button>
                                    <button type="submit" class="btn btn-gold">Save Changes</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

            <?php endforeach; ?>
        </div>

    </div>
</div>

<!-- Add Achievement Modal -->
<div class="modal fade" id="addAchievementModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content modal-content-rpg">
            <form method="POST" action="achievements.php">
                <?php csrf_field(); ?>
                <input type="hidden" name="action" value="add">

                <div class="modal-header modal-header-rpg">
                    <h5 class="modal-title fw-bold text-white"><i class="bi bi-trophy-fill text-warning me-2"></i>Create New Trophy</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="form-label-rpg">Achievement Name *</label>
                        <input type="text" name="name" class="form-control form-control-rpg" placeholder="e.g. Century Slayer" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label-rpg">Description</label>
                        <textarea name="description" class="form-control form-control-rpg" rows="2" placeholder="Explain what valorous deed this celebrates..."></textarea>
                    </div>
                    <div class="mb-3">
                        <label class="form-label-rpg">Unlock Requirement *</label>
                        <input type="text" name="unlock_requirement" class="form-control form-control-rpg" placeholder="e.g. Complete 100 tasks" required>
                    </div>
                    <div class="row g-2 mb-3">
                        <div class="col-6">
                            <label class="form-label-rpg">XP Reward</label>
                            <input type="number" name="xp_reward" class="form-control form-control-rpg" value="250" min="0">
                        </div>
                        <div class="col-6">
                            <label class="form-label-rpg">Bootstrap Icon</label>
                            <select name="icon_name" class="form-select form-select-rpg">
                                <option value="trophy">trophy</option>
                                <option value="award">award</option>
                                <option value="star">star</option>
                                <option value="lightning-charge">lightning-charge</option>
                                <option value="gem">gem</option>
                                <option value="fire">fire</option>
                                <option value="shield-check">shield-check</option>
                                <option value="chevron-double-up">chevron-double-up</option>
                                <option value="crown">crown</option>
                                <option value="droplet-half">droplet-half</option>
                            </select>
                        </div>
                    </div>
                    <div class="form-check form-switch mt-2">
                        <input class="form-check-input" type="checkbox" name="is_active" id="addActive" checked>
                        <label class="form-check-label text-white" for="addActive">Active & Unlockable</label>
                    </div>
                </div>
                <div class="modal-footer modal-footer-rpg">
                    <button type="button" class="btn btn-dark-rpg" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-gold">Publish Trophy</button>
                </div>
            </form>
        </div>
    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
