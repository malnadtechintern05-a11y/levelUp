<?php
/**
 * LevelUp Web Admin Panel - Footer Component
 */
?>
        </div> <!-- End .content-body -->

        <footer class="mt-auto py-3 px-4 text-center border-top" style="background-color: #0A0F1C; border-color: #1E293B !important;">
            <div class="d-flex flex-column flex-sm-row justify-content-between align-items-center text-muted small gap-2">
                <div>
                    <span class="text-warning fw-bold">LEVELUP</span> &bull; Real-Life RPG Management System &copy; <?= date('Y') ?>
                </div>
                <div class="d-flex gap-3">
                    <span class="badge badge-gold px-2 py-1"><i class="bi bi-shield-lock-fill me-1"></i>Secure Admin Engine</span>
                    <span>v2.5.0-PROD</span>
                </div>
            </div>
        </footer>
    </div> <!-- End .admin-main -->
</div> <!-- End .admin-wrapper -->

<!-- Bootstrap 5 Bundle JS (Local Offline Asset) -->
<script src="/admin-web/assets/js/bootstrap.bundle.min.js"></script>

<!-- Custom Admin JS -->
<script src="/admin-web/assets/js/admin.js?v=<?= time() ?>"></script>

</body>
</html>
