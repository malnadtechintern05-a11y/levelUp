-- ============================================================
-- LevelUp Online Multi-User Database Schema Updates
-- Compatible with LevelUp Flutter Application & Web Admin Panel
-- ============================================================

USE `levelup_rpg`;

-- 1. Ensure columns on users table
SET @dbname = DATABASE();
SET @tablename = "users";

-- Add password_hash
SET @columnname = "password_hash";
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (TABLE_SCHEMA = @dbname)
      AND (TABLE_NAME = @tablename)
      AND (COLUMN_NAME = @columnname)
  ) > 0,
  "SELECT 1",
  "ALTER TABLE users ADD COLUMN password_hash VARCHAR(255) NULL AFTER email;"
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Add display_name
SET @columnname = "display_name";
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (TABLE_SCHEMA = @dbname)
      AND (TABLE_NAME = @tablename)
      AND (COLUMN_NAME = @columnname)
  ) > 0,
  "SELECT 1",
  "ALTER TABLE users ADD COLUMN display_name VARCHAR(100) NULL AFTER username;"
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Add show_on_leaderboard
SET @columnname = "show_on_leaderboard";
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (TABLE_SCHEMA = @dbname)
      AND (TABLE_NAME = @tablename)
      AND (COLUMN_NAME = @columnname)
  ) > 0,
  "SELECT 1",
  "ALTER TABLE users ADD COLUMN show_on_leaderboard TINYINT(1) NOT NULL DEFAULT 1 AFTER is_active;"
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- 2. User Authentication Session Tokens Table
CREATE TABLE IF NOT EXISTS `user_tokens` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `token` VARCHAR(64) NOT NULL UNIQUE,
    `expires_at` DATETIME NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    INDEX `idx_token_lookup` (`token`),
    INDEX `idx_user_tokens` (`user_id`),
    INDEX `idx_token_expiry` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. User Settings Table
CREATE TABLE IF NOT EXISTS `user_settings` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL UNIQUE,
    `dark_mode` TINYINT(1) NOT NULL DEFAULT 1,
    `sound_effects` TINYINT(1) NOT NULL DEFAULT 1,
    `selected_alarm_song` VARCHAR(50) NOT NULL DEFAULT 'fanfare_victory',
    `task_notifications` TINYINT(1) NOT NULL DEFAULT 1,
    `achievement_notifications` TINYINT(1) NOT NULL DEFAULT 1,
    `daily_reminders` TINYINT(1) NOT NULL DEFAULT 1,
    `streak_reminders` TINYINT(1) NOT NULL DEFAULT 1,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Ensure tasks table has user_id
SET @tablename = "tasks";
SET @columnname = "user_id";
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (TABLE_SCHEMA = @dbname)
      AND (TABLE_NAME = @tablename)
      AND (COLUMN_NAME = @columnname)
  ) > 0,
  "SELECT 1",
  "ALTER TABLE tasks ADD COLUMN user_id INT NULL AFTER id;"
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Copy assigned_user_id to user_id if needed
UPDATE tasks SET user_id = assigned_user_id WHERE user_id IS NULL AND assigned_user_id IS NOT NULL;

-- 5. Give existing seed users default passwords ('Hero123!') if null
-- Hash for 'Hero123!'
SET @defaultHash = '$2y$10$wTf2a4jE9fWkH7/U7uWq7uT0s5A9aV3zLqg8Lq0zU5s4p3s1a2b3c';
UPDATE `users` SET `password_hash` = '$2y$10$yX3g1vJ3Jj2E/Yw1q7lPmeqWd6T5nK0vO6uB9A7zE4eL2rS0yU7qW' WHERE `password_hash` IS NULL;
