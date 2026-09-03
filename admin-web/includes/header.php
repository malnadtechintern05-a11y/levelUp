<?php
/**
 * LevelUp Web Admin Panel - Header Layout
 */
$pageTitle = $pageTitle ?? 'LevelUp Admin Dashboard';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="LevelUp Real-Life RPG Web Admin Management Dashboard">
    <title><?= e($pageTitle) ?> | LevelUp RPG Admin</title>

    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Outfit:wght@500;600;700;800;900&display=swap" rel="stylesheet">

    <!-- Bootstrap 5 CSS & Bootstrap Icons (Local Offline Assets) -->
    <link href="/admin-web/assets/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="/admin-web/assets/css/bootstrap-icons.min.css">

    <!-- Chart.js (Local Offline Asset) -->
    <script src="/admin-web/assets/js/chart.umd.min.js"></script>

    <!-- Custom LevelUp Admin CSS -->
    <link rel="stylesheet" href="/admin-web/assets/css/admin.css?v=<?= time() ?>">
</head>
<body>
<div class="admin-wrapper">
