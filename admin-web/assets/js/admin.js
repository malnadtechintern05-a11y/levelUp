/**
 * LevelUp (Real-Life RPG) - Admin Panel Core Scripts
 */

document.addEventListener('DOMContentLoaded', () => {
    // 1. Mobile Sidebar Off-Canvas Toggle
    const sidebarToggleBtn = document.getElementById('sidebarToggle');
    const adminSidebar = document.getElementById('adminSidebar');
    const sidebarOverlay = document.getElementById('sidebarOverlay');

    if (sidebarToggleBtn && adminSidebar) {
        sidebarToggleBtn.addEventListener('click', () => {
            adminSidebar.classList.toggle('show-mobile');
            if (sidebarOverlay) {
                sidebarOverlay.classList.toggle('show');
            }
        });
    }

    if (sidebarOverlay) {
        sidebarOverlay.addEventListener('click', () => {
            adminSidebar.classList.remove('show-mobile');
            sidebarOverlay.classList.remove('show');
        });
    }

    // 2. Password Visibility Toggle
    const togglePasswordBtns = document.querySelectorAll('.toggle-password-btn');
    togglePasswordBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            const targetId = btn.getAttribute('data-target');
            const targetInput = document.getElementById(targetId);
            if (targetInput) {
                const isPassword = targetInput.getAttribute('type') === 'password';
                targetInput.setAttribute('type', isPassword ? 'text' : 'password');
                const icon = btn.querySelector('i');
                if (icon) {
                    icon.classList.toggle('bi-eye');
                    icon.classList.toggle('bi-eye-slash');
                }
            }
        });
    });

    // 3. Hydration vs Normal Task Type Dynamic Switcher
    const taskTypeSelect = document.getElementById('taskTypeSelect');
    const normalDurationGroup = document.getElementById('normalDurationGroup');
    const hydrationGoalGroup = document.getElementById('hydrationGoalGroup');

    if (taskTypeSelect && normalDurationGroup && hydrationGoalGroup) {
        const updateTaskTypeVisibility = () => {
            if (taskTypeSelect.value === 'hydration') {
                normalDurationGroup.style.display = 'none';
                hydrationGoalGroup.style.display = 'block';
            } else {
                normalDurationGroup.style.display = 'block';
                hydrationGoalGroup.style.display = 'none';
            }
        };

        taskTypeSelect.addEventListener('change', updateTaskTypeVisibility);
        updateTaskTypeVisibility(); // Initial trigger
    }

    // 4. Auto Dismiss Alerts after 5 seconds
    const flashAlerts = document.querySelectorAll('.alert-dismissible');
    flashAlerts.forEach(alert => {
        setTimeout(() => {
            try {
                const bsAlert = new bootstrap.Alert(alert);
                bsAlert.close();
            } catch (e) {}
        }, 5000);
    });

    // 5. Global Confirmation Modal Handler
    const confirmTriggers = document.querySelectorAll('[data-confirm]');
    confirmTriggers.forEach(el => {
        el.addEventListener('click', (e) => {
            const msg = el.getAttribute('data-confirm') || 'Are you sure you want to proceed?';
            if (!confirm(msg)) {
                e.preventDefault();
            }
        });
    });
});
