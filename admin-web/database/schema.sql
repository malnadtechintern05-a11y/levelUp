-- LevelUp (Real-Life RPG) MySQL Database Schema
-- Compatible with LevelUp Flutter Application data structures

-- NOTE FOR HOSTING (e.g. InfinityFree / cPanel / Shared Hosting):
-- Shared hosts do not allow creating or selecting databases via SQL commands (#1044 Access Denied).
-- In phpMyAdmin, click your database name on the left sidebar FIRST, then import this SQL file.
-- CREATE DATABASE IF NOT EXISTS `levelup_rpg` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- USE `levelup_rpg`;

-- 1. Admins Table
CREATE TABLE IF NOT EXISTS `admins` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `username` VARCHAR(50) NOT NULL,
    `email` VARCHAR(100) NOT NULL UNIQUE,
    `password_hash` VARCHAR(255) NOT NULL,
    `role` VARCHAR(20) NOT NULL DEFAULT 'superadmin',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `last_login` TIMESTAMP NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Users Table (matches Flutter UserProfile)
CREATE TABLE IF NOT EXISTS `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `username` VARCHAR(100) NOT NULL,
    `email` VARCHAR(150) UNIQUE,
    `avatar_id` VARCHAR(50) DEFAULT 'hero1',
    `profile_image_path` VARCHAR(255) NULL,
    `level` INT NOT NULL DEFAULT 1,
    `total_xp` INT NOT NULL DEFAULT 0,
    `gold` INT NOT NULL DEFAULT 0,
    `current_streak` INT NOT NULL DEFAULT 0,
    `best_streak` INT NOT NULL DEFAULT 0,
    `skills_json` TEXT NULL,
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `hydration_current_streak` INT NOT NULL DEFAULT 0,
    `hydration_best_streak` INT NOT NULL DEFAULT 0,
    `last_hydration_date` VARCHAR(50) NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_users_level` (`level`),
    INDEX `idx_users_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Tasks Table (matches Flutter RPGTask)
CREATE TABLE IF NOT EXISTS `tasks` (
    `id` VARCHAR(50) PRIMARY KEY,
    `title` VARCHAR(255) NOT NULL,
    `description` TEXT,
    `category` ENUM('Fitness', 'Study', 'Health', 'Work', 'Personal', 'Hydration', 'Other') NOT NULL DEFAULT 'Personal',
    `xp_reward` INT NOT NULL DEFAULT 10,
    `is_completed` TINYINT(1) NOT NULL DEFAULT 0,
    `scheduled_date` DATE NOT NULL,
    `scheduled_time` VARCHAR(10) NULL,
    `duration_minutes` INT NOT NULL DEFAULT 0,
    `time_spent_seconds` INT NOT NULL DEFAULT 0,
    `timer_status` VARCHAR(20) NOT NULL DEFAULT 'Not Started',
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `task_type` ENUM('normal', 'hydration') NOT NULL DEFAULT 'normal',
    `water_goal_ml` INT NOT NULL DEFAULT 2000,
    `current_water_ml` INT NOT NULL DEFAULT 0,
    `assigned_user_id` INT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`assigned_user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
    INDEX `idx_tasks_date` (`scheduled_date`),
    INDEX `idx_tasks_status` (`is_completed`),
    INDEX `idx_tasks_category` (`category`),
    INDEX `idx_tasks_type` (`task_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Task Completions History Table
CREATE TABLE IF NOT EXISTS `task_completions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `task_id` VARCHAR(50) NOT NULL,
    `user_id` INT NOT NULL,
    `xp_awarded` INT NOT NULL DEFAULT 0,
    `completed_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    INDEX `idx_completions_user` (`user_id`),
    INDEX `idx_completions_task` (`task_id`),
    INDEX `idx_completions_date` (`completed_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Hydration Logs Table
CREATE TABLE IF NOT EXISTS `hydration_logs` (
    `id` VARCHAR(50) PRIMARY KEY,
    `user_id` INT NOT NULL,
    `task_id` VARCHAR(50) NULL,
    `amount_ml` INT NOT NULL,
    `logged_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    INDEX `idx_hydration_user` (`user_id`),
    INDEX `idx_hydration_date` (`logged_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Achievements Table (matches Flutter Achievement)
CREATE TABLE IF NOT EXISTS `achievements` (
    `id` VARCHAR(50) PRIMARY KEY,
    `name` VARCHAR(150) NOT NULL,
    `description` TEXT NOT NULL,
    `xp_reward` INT NOT NULL DEFAULT 0,
    `unlock_requirement` VARCHAR(255) NOT NULL DEFAULT '',
    `icon_name` VARCHAR(50) NOT NULL DEFAULT 'trophy',
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. User Achievements Unlock Pivot Table
CREATE TABLE IF NOT EXISTS `user_achievements` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `achievement_id` VARCHAR(50) NOT NULL,
    `unlocked_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`achievement_id`) REFERENCES `achievements`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `user_achievement_unique` (`user_id`, `achievement_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. Notifications Table
CREATE TABLE IF NOT EXISTS `notifications` (
    `id` VARCHAR(50) PRIMARY KEY,
    `title` VARCHAR(255) NOT NULL,
    `message` TEXT NOT NULL,
    `category` VARCHAR(50) NOT NULL DEFAULT 'System',
    `type` VARCHAR(50) NOT NULL DEFAULT 'announcement',
    `target_user_id` INT NULL,
    `is_read` TINYINT(1) NOT NULL DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`target_user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    INDEX `idx_notifications_target` (`target_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. App Settings Table
CREATE TABLE IF NOT EXISTS `app_settings` (
    `setting_key` VARCHAR(50) PRIMARY KEY,
    `setting_value` TEXT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. Activity Logs Table
CREATE TABLE IF NOT EXISTS `activity_logs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NULL,
    `admin_id` INT NULL,
    `activity_type` VARCHAR(50) NOT NULL,
    `description` TEXT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
    FOREIGN KEY (`admin_id`) REFERENCES `admins`(`id`) ON DELETE SET NULL,
    INDEX `idx_activity_date` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- SEED DATA
-- ============================================================

-- Safe Development Admin Account:
-- Email: admin@levelup.com
-- Password: admin123 (Bcrypt hash: $2y$10$15UT5vHKF9hzbI0vnUaQpeVGsLJFxMqeLkwV1KPBW0aHjnKVlH2Si)
-- You can change this directly in this table or via the admin Settings page.
INSERT INTO `admins` (`id`, `username`, `email`, `password_hash`, `role`) VALUES
(1, 'Commander Admin', 'admin@levelup.com', '$2y$10$15UT5vHKF9hzbI0vnUaQpeVGsLJFxMqeLkwV1KPBW0aHjnKVlH2Si', 'superadmin')
ON DUPLICATE KEY UPDATE `email` = VALUES(`email`);

-- Starter Users with realistic RPG levels and streaks
INSERT INTO `users` (`id`, `username`, `email`, `avatar_id`, `level`, `total_xp`, `gold`, `current_streak`, `best_streak`, `skills_json`, `is_active`, `hydration_current_streak`, `hydration_best_streak`, `created_at`) VALUES
(1, 'ShadowKnight', 'shadow@levelup.com', 'hero1', 25, 12500, 340, 14, 21, '{"Strength": 85, "Knowledge": 70, "Discipline": 90}', 1, 10, 15, DATE_SUB(NOW(), INTERVAL 45 DAY)),
(2, 'CyberMage', 'mage@levelup.com', 'hero2', 22, 10800, 290, 9, 14, '{"Strength": 40, "Knowledge": 95, "Discipline": 80}', 1, 7, 12, DATE_SUB(NOW(), INTERVAL 35 DAY)),
(3, 'ValkyrieRunner', 'valk@levelup.com', 'hero3', 19, 8950, 210, 12, 18, '{"Strength": 90, "Knowledge": 60, "Discipline": 88}', 1, 8, 14, DATE_SUB(NOW(), INTERVAL 28 DAY)),
(4, 'CodeWarrior', 'dev@levelup.com', 'hero1', 16, 7200, 180, 5, 10, '{"Strength": 55, "Knowledge": 88, "Discipline": 75}', 1, 4, 8, DATE_SUB(NOW(), INTERVAL 21 DAY)),
(5, 'AuraHealer', 'aura@levelup.com', 'hero2', 12, 5100, 130, 7, 11, '{"Strength": 50, "Knowledge": 75, "Discipline": 82}', 1, 12, 16, DATE_SUB(NOW(), INTERVAL 18 DAY)),
(6, 'ZenMaster', 'zen@levelup.com', 'hero3', 10, 4200, 95, 15, 15, '{"Strength": 65, "Knowledge": 80, "Discipline": 95}', 1, 15, 15, DATE_SUB(NOW(), INTERVAL 15 DAY)),
(7, 'IronPaladin', 'iron@levelup.com', 'hero1', 8, 3100, 70, 3, 6, '{"Strength": 78, "Knowledge": 50, "Discipline": 65}', 1, 2, 5, DATE_SUB(NOW(), INTERVAL 12 DAY)),
(8, 'PixelScout', 'scout@levelup.com', 'hero2', 5, 1950, 45, 4, 7, '{"Strength": 60, "Knowledge": 65, "Discipline": 60}', 1, 3, 6, DATE_SUB(NOW(), INTERVAL 7 DAY)),
(9, 'NovaRookie', 'rookie@levelup.com', 'hero3', 3, 900, 20, 2, 3, '{"Strength": 45, "Knowledge": 50, "Discipline": 40}', 1, 2, 2, DATE_SUB(NOW(), INTERVAL 3 DAY)),
(10, 'InactiveGhost', 'ghost@levelup.com', 'hero1', 2, 450, 10, 0, 2, '{"Strength": 30, "Knowledge": 35, "Discipline": 20}', 0, 0, 1, DATE_SUB(NOW(), INTERVAL 60 DAY))
ON DUPLICATE KEY UPDATE `username` = VALUES(`username`);

-- Standard RPG Achievements
INSERT INTO `achievements` (`id`, `name`, `description`, `xp_reward`, `unlock_requirement`, `icon_name`, `is_active`) VALUES
('first_quest', 'First Quest', 'Complete your very first real-life RPG quest.', 50, 'Complete 1 task', 'trophy', 1),
('quest_master', 'Quest Master', 'Complete 10 real-life tasks and demonstrate high discipline.', 200, 'Complete 10 tasks', 'award', 1),
('quest_champion', 'Quest Champion', 'Complete 50 tasks to cement your legendary discipline.', 600, 'Complete 50 tasks', 'star', 1),
('xp_warrior', 'XP Warrior', 'Earn a total of 1,000 XP through deliberate self-improvement.', 150, 'Earn 1,000 XP', 'lightning-charge', 1),
('xp_legend', 'XP Legend', 'Earn 10,000 XP and transcend mortal limits.', 1000, 'Earn 10,000 XP', 'gem', 1),
('7_day_streak', '7 Day Streak', 'Maintain an unbroken consecutive daily habit streak for 7 days.', 250, 'Maintain a 7-day streak', 'fire', 1),
('30_day_streak', 'Iron Will', 'Maintain an unbroken habit streak for 30 whole days.', 800, 'Maintain a 30-day streak', 'shield-check', 1),
('level_10', 'Level 10 Conqueror', 'Ascend your hero to Level 10.', 300, 'Reach Level 10', 'chevron-double-up', 1),
('level_20', 'Level 20 Demigod', 'Ascend your hero to Level 20.', 750, 'Reach Level 20', 'crown', 1),
('hydration_hero', 'Aqua Ascendant', 'Reach daily hydration goal 7 days in a row.', 200, 'Drink target water for 7 days', 'droplet-half', 1)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

-- User Achievements (Sample unlocks)
INSERT INTO `user_achievements` (`user_id`, `achievement_id`, `unlocked_at`) VALUES
(1, 'first_quest', DATE_SUB(NOW(), INTERVAL 40 DAY)),
(1, 'quest_master', DATE_SUB(NOW(), INTERVAL 30 DAY)),
(1, 'xp_warrior', DATE_SUB(NOW(), INTERVAL 35 DAY)),
(1, '7_day_streak', DATE_SUB(NOW(), INTERVAL 25 DAY)),
(1, 'level_10', DATE_SUB(NOW(), INTERVAL 20 DAY)),
(1, 'xp_legend', DATE_SUB(NOW(), INTERVAL 5 DAY)),
(1, 'level_20', DATE_SUB(NOW(), INTERVAL 4 DAY)),
(2, 'first_quest', DATE_SUB(NOW(), INTERVAL 32 DAY)),
(2, 'quest_master', DATE_SUB(NOW(), INTERVAL 20 DAY)),
(2, 'xp_warrior', DATE_SUB(NOW(), INTERVAL 28 DAY)),
(2, '7_day_streak', DATE_SUB(NOW(), INTERVAL 15 DAY)),
(2, 'level_10', DATE_SUB(NOW(), INTERVAL 14 DAY)),
(2, 'level_20', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(3, 'first_quest', DATE_SUB(NOW(), INTERVAL 26 DAY)),
(3, 'quest_master', DATE_SUB(NOW(), INTERVAL 18 DAY)),
(3, 'xp_warrior', DATE_SUB(NOW(), INTERVAL 22 DAY)),
(3, '7_day_streak', DATE_SUB(NOW(), INTERVAL 10 DAY)),
(3, 'level_10', DATE_SUB(NOW(), INTERVAL 8 DAY)),
(4, 'first_quest', DATE_SUB(NOW(), INTERVAL 20 DAY)),
(4, 'quest_master', DATE_SUB(NOW(), INTERVAL 12 DAY)),
(4, 'xp_warrior', DATE_SUB(NOW(), INTERVAL 15 DAY)),
(4, 'level_10', DATE_SUB(NOW(), INTERVAL 3 DAY)),
(5, 'first_quest', DATE_SUB(NOW(), INTERVAL 17 DAY)),
(5, 'hydration_hero', DATE_SUB(NOW(), INTERVAL 4 DAY)),
(6, 'first_quest', DATE_SUB(NOW(), INTERVAL 14 DAY)),
(6, '7_day_streak', DATE_SUB(NOW(), INTERVAL 6 DAY)),
(6, 'hydration_hero', DATE_SUB(NOW(), INTERVAL 2 DAY))
ON DUPLICATE KEY UPDATE `achievement_id` = VALUES(`achievement_id`);

-- Tasks (normal timer-based tasks, future tasks, and hydration tasks)
INSERT INTO `tasks` (`id`, `title`, `description`, `category`, `xp_reward`, `is_completed`, `scheduled_date`, `scheduled_time`, `duration_minutes`, `time_spent_seconds`, `timer_status`, `is_active`, `task_type`, `water_goal_ml`, `current_water_ml`, `assigned_user_id`, `created_at`) VALUES
('task_001', 'Morning Deep Focus Study', 'Study algorithmic problem solving and architecture patterns.', 'Study', 60, 1, CURDATE(), '08:00', 45, 2700, 'Completed', 1, 'normal', 0, 0, 1, NOW()),
('task_002', 'High-Intensity Kettlebell Circuit', 'Complete 5 rounds of swings, clean and press, and lunges.', 'Fitness', 75, 1, CURDATE(), '09:30', 30, 1800, 'Completed', 1, 'normal', 0, 0, 1, NOW()),
('task_003', 'Hydration Mastery (2.5L)', 'Hydrate systematically throughout the day to boost cognition.', 'Hydration', 50, 0, CURDATE(), NULL, 0, 0, 'Not Started', 1, 'hydration', 2500, 1800, 1, NOW()),
('task_004', 'Read 20 Pages of Clean Architecture', 'Read book and synthesize key concepts into notes.', 'Study', 40, 0, CURDATE(), '17:00', 30, 0, 'Not Started', 1, 'normal', 0, 0, 2, NOW()),
('task_005', 'Evening Mobility & Stretching', 'Full body hip flexor and spine mobility session.', 'Health', 35, 0, CURDATE(), '21:00', 20, 0, 'Not Started', 1, 'normal', 0, 0, 2, NOW()),
('task_006', 'Future Sprint Planning (Tomorrow)', 'Plan sprint objectives and break down high-level epics.', 'Work', 50, 0, DATE_ADD(CURDATE(), INTERVAL 1 DAY), '10:00', 45, 0, 'Not Started', 1, 'normal', 0, 0, 3, NOW()),
('task_007', 'Future 10K Endurance Run', 'Scheduled long run in the morning.', 'Fitness', 120, 0, DATE_ADD(CURDATE(), INTERVAL 2 DAY), '06:30', 60, 0, 'Not Started', 1, 'normal', 0, 0, 3, NOW()),
('task_008', 'Hydration Challenge - 3.0L', 'Target 3 liters hydration goal.', 'Hydration', 60, 0, DATE_ADD(CURDATE(), INTERVAL 1 DAY), NULL, 0, 0, 'Not Started', 1, 'hydration', 3000, 0, 4, NOW()),
('task_009', 'Clean Workspace & Organize Desk', 'Personal environmental declutter session.', 'Personal', 25, 1, DATE_SUB(CURDATE(), INTERVAL 1 DAY), '18:00', 15, 900, 'Completed', 1, 'normal', 0, 0, 5, DATE_SUB(NOW(), INTERVAL 1 DAY)),
('task_010', 'Cardio Intervals 30 Min', 'Running intervals on the track.', 'Fitness', 60, 1, DATE_SUB(CURDATE(), INTERVAL 2 DAY), '07:00', 30, 1800, 'Completed', 1, 'normal', 0, 0, 6, DATE_SUB(NOW(), INTERVAL 2 DAY))
ON DUPLICATE KEY UPDATE `title` = VALUES(`title`);

-- Task Completions History
INSERT INTO `task_completions` (`task_id`, `user_id`, `xp_awarded`, `completed_at`) VALUES
('task_001', 1, 60, DATE_SUB(NOW(), INTERVAL 2 HOUR)),
('task_002', 1, 75, DATE_SUB(NOW(), INTERVAL 1 HOUR)),
('task_009', 5, 25, DATE_SUB(NOW(), INTERVAL 1 DAY)),
('task_010', 6, 60, DATE_SUB(NOW(), INTERVAL 2 DAY)),
('task_hist_1', 2, 50, DATE_SUB(NOW(), INTERVAL 3 DAY)),
('task_hist_2', 3, 70, DATE_SUB(NOW(), INTERVAL 4 DAY)),
('task_hist_3', 4, 40, DATE_SUB(NOW(), INTERVAL 5 DAY)),
('task_hist_4', 1, 100, DATE_SUB(NOW(), INTERVAL 6 DAY)),
('task_hist_5', 2, 45, DATE_SUB(NOW(), INTERVAL 7 DAY))
ON DUPLICATE KEY UPDATE `xp_awarded` = VALUES(`xp_awarded`);

-- Hydration Logs
INSERT INTO `hydration_logs` (`id`, `user_id`, `task_id`, `amount_ml`, `logged_at`) VALUES
('hl_001', 1, 'task_003', 500, DATE_SUB(NOW(), INTERVAL 4 HOUR)),
('hl_002', 1, 'task_003', 600, DATE_SUB(NOW(), INTERVAL 2 HOUR)),
('hl_003', 1, 'task_003', 700, DATE_SUB(NOW(), INTERVAL 30 MINUTE)),
('hl_004', 2, NULL, 500, DATE_SUB(NOW(), INTERVAL 3 HOUR)),
('hl_005', 3, NULL, 750, DATE_SUB(NOW(), INTERVAL 5 HOUR)),
('hl_006', 5, NULL, 800, DATE_SUB(NOW(), INTERVAL 6 HOUR))
ON DUPLICATE KEY UPDATE `amount_ml` = VALUES(`amount_ml`);

-- Notifications
INSERT INTO `notifications` (`id`, `title`, `message`, `category`, `type`, `target_user_id`, `is_read`, `created_at`) VALUES
('notif_001', 'Welcome to Season 2 of LevelUp!', 'A new quest cycle has begun. Complete your daily quests to earn double XP this weekend!', 'System', 'announcement', NULL, 0, DATE_SUB(NOW(), INTERVAL 2 DAY)),
('notif_002', 'Streak Protection Activated', 'Keep pushing! Maintain your daily streak to unlock legendary prestige titles.', 'System', 'reminder', NULL, 0, DATE_SUB(NOW(), INTERVAL 1 DAY)),
('notif_003', 'Hydration Milestone Unlocked', 'Outstanding work hitting 2.5L water consumption today!', 'Health', 'achievement', 1, 1, DATE_SUB(NOW(), INTERVAL 3 HOUR))
ON DUPLICATE KEY UPDATE `title` = VALUES(`title`);

-- App Settings
INSERT INTO `app_settings` (`setting_key`, `setting_value`) VALUES
('app_name', 'LevelUp - Real-Life RPG'),
('app_description', 'Transform your real life into an epic RPG progression experience.'),
('default_xp', '50'),
('default_task_duration', '30'),
('daily_reminder', '1'),
('achievement_notifications', '1'),
('task_completion_notifications', '1'),
('streak_notifications', '1'),
('maintenance_mode', '0'),
('hero_banner_image', '')
ON DUPLICATE KEY UPDATE `setting_value` = VALUES(`setting_value`);

-- Activity Logs
INSERT INTO `activity_logs` (`user_id`, `admin_id`, `activity_type`, `description`, `created_at`) VALUES
(1, NULL, 'task_completed', 'ShadowKnight completed quest "Morning Deep Focus Study" (+60 XP)', DATE_SUB(NOW(), INTERVAL 2 HOUR)),
(1, NULL, 'task_completed', 'ShadowKnight completed quest "High-Intensity Kettlebell Circuit" (+75 XP)', DATE_SUB(NOW(), INTERVAL 1 HOUR)),
(1, NULL, 'achievement_unlocked', 'ShadowKnight unlocked achievement "XP Legend" (+1000 XP)', DATE_SUB(NOW(), INTERVAL 5 DAY)),
(1, NULL, 'level_up', 'ShadowKnight leveled up to Level 25!', DATE_SUB(NOW(), INTERVAL 4 DAY)),
(2, NULL, 'level_up', 'CyberMage leveled up to Level 22!', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(3, NULL, 'achievement_unlocked', 'ValkyrieRunner unlocked achievement "7 Day Streak" (+250 XP)', DATE_SUB(NOW(), INTERVAL 10 DAY)),
(9, NULL, 'user_registered', 'NovaRookie registered a new hero account!', DATE_SUB(NOW(), INTERVAL 3 DAY)),
(NULL, 1, 'admin_action', 'Commander Admin updated global app settings', DATE_SUB(NOW(), INTERVAL 1 DAY));
