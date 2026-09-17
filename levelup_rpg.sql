-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: levelup_rpg
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `achievements`
--

DROP TABLE IF EXISTS `achievements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `achievements` (
  `id` varchar(50) NOT NULL,
  `name` varchar(150) NOT NULL,
  `description` text NOT NULL,
  `xp_reward` int(11) NOT NULL DEFAULT 0,
  `unlock_requirement` varchar(255) NOT NULL DEFAULT '',
  `icon_name` varchar(50) NOT NULL DEFAULT 'trophy',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `achievements`
--

LOCK TABLES `achievements` WRITE;
/*!40000 ALTER TABLE `achievements` DISABLE KEYS */;
INSERT INTO `achievements` VALUES ('30_day_streak','Iron Will','Maintain an unbroken habit streak for 30 whole days.',800,'Maintain a 30-day streak','shield-check',1,'2026-09-03 05:16:58'),('7_day_streak','7 Day Streak','Maintain an unbroken consecutive daily habit streak for 7 days.',250,'Maintain a 7-day streak','fire',1,'2026-09-03 05:16:58'),('first_quest','First Quest','Complete your very first real-life RPG quest.',50,'Complete 1 task','trophy',1,'2026-09-03 05:16:58'),('hydration_hero','Aqua Ascendant','Reach daily hydration goal 7 days in a row.',200,'Drink target water for 7 days','droplet-half',1,'2026-09-03 05:16:58'),('level_10','Level 10 Conqueror','Ascend your hero to Level 10.',300,'Reach Level 10','chevron-double-up',1,'2026-09-03 05:16:58'),('level_20','Level 20 Demigod','Ascend your hero to Level 20.',750,'Reach Level 20','crown',1,'2026-09-03 05:16:58'),('quest_champion','Quest Champion','Complete 50 tasks to cement your legendary discipline.',600,'Complete 50 tasks','star',1,'2026-09-03 05:16:58'),('quest_master','Quest Master','Complete 10 real-life tasks and demonstrate high discipline.',200,'Complete 10 tasks','award',1,'2026-09-03 05:16:58'),('xp_legend','XP Legend','Earn 10,000 XP and transcend mortal limits.',1000,'Earn 10,000 XP','gem',1,'2026-09-03 05:16:58'),('xp_warrior','XP Warrior','Earn a total of 1,000 XP through deliberate self-improvement.',150,'Earn 1,000 XP','lightning-charge',1,'2026-09-03 05:16:58');
/*!40000 ALTER TABLE `achievements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `activity_logs`
--

DROP TABLE IF EXISTS `activity_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `activity_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `activity_type` varchar(50) NOT NULL,
  `description` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `admin_id` (`admin_id`),
  KEY `idx_activity_date` (`created_at`),
  CONSTRAINT `activity_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `activity_logs_ibfk_2` FOREIGN KEY (`admin_id`) REFERENCES `admins` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activity_logs`
--

LOCK TABLES `activity_logs` WRITE;
/*!40000 ALTER TABLE `activity_logs` DISABLE KEYS */;
INSERT INTO `activity_logs` VALUES (1,NULL,NULL,'task_completed','ShadowKnight completed quest \"Morning Deep Focus Study\" (+60 XP)','2026-09-03 03:16:58'),(2,NULL,NULL,'task_completed','ShadowKnight completed quest \"High-Intensity Kettlebell Circuit\" (+75 XP)','2026-09-03 04:16:58'),(3,NULL,NULL,'achievement_unlocked','ShadowKnight unlocked achievement \"XP Legend\" (+1000 XP)','2026-08-29 05:16:58'),(4,NULL,NULL,'level_up','ShadowKnight leveled up to Level 25!','2026-08-30 05:16:58'),(5,NULL,NULL,'level_up','CyberMage leveled up to Level 22!','2026-09-01 05:16:58'),(6,NULL,NULL,'achievement_unlocked','ValkyrieRunner unlocked achievement \"7 Day Streak\" (+250 XP)','2026-08-24 05:16:58'),(7,NULL,NULL,'user_registered','NovaRookie registered a new hero account!','2026-08-31 05:16:58'),(8,NULL,1,'admin_action','Commander Admin updated global app settings','2026-09-02 05:16:58'),(9,NULL,1,'admin_login','Admin \'Commander Admin\' logged in successfully','2026-09-03 05:26:39'),(10,NULL,1,'admin_action','Created new quest \'Automated Integration Test Quest\' (+75 XP)','2026-09-03 05:26:39'),(11,NULL,1,'admin_login','Admin \'Commander Admin\' logged in successfully','2026-09-03 05:30:40'),(12,NULL,1,'admin_action','Updated global realm settings','2026-09-03 05:31:52'),(13,NULL,1,'admin_login','Admin \'Commander Admin\' logged in successfully','2026-09-03 09:51:03'),(14,NULL,1,'admin_action','Deactivated quest \'Cardio Intervals 30 Min\'','2026-09-03 10:15:48'),(15,NULL,1,'admin_action','Activated quest \'Cardio Intervals 30 Min\'','2026-09-03 10:15:55'),(16,NULL,1,'task_completed','Hero completed quest \'Hydration Challenge - 3.0L\' (+60 XP) [Admin Override]','2026-09-03 10:16:15'),(17,NULL,1,'admin_logout','Admin \'Commander Admin\' logged out','2026-09-03 10:53:53'),(18,NULL,1,'admin_login','Admin \'Commander Admin\' logged in successfully','2026-09-03 10:53:59'),(19,NULL,1,'admin_action','Created new quest \'yoga\' (+50 XP)','2026-09-03 10:55:05'),(20,NULL,1,'admin_action','Deleted user \'rahul_test\' (ID #31)','2026-09-03 10:56:41'),(21,NULL,1,'admin_action','Deleted quest \'Cardio Intervals 30 Min\'','2026-09-03 10:57:21'),(22,NULL,1,'admin_login','Admin \'Commander Admin\' logged in successfully','2026-09-05 05:25:08'),(23,NULL,1,'admin_action','Deleted user \'harsha_test\' (ID #30)','2026-09-05 05:29:46'),(24,NULL,1,'admin_action','Deleted user \'Hero\' (ID #19)','2026-09-05 05:29:48'),(25,NULL,1,'admin_action','Deleted user \'NovaRookie\' (ID #9)','2026-09-05 05:29:51'),(26,NULL,1,'admin_action','Deleted user \'InactiveGhost\' (ID #10)','2026-09-05 05:29:53'),(27,NULL,1,'admin_action','Deleted user \'PixelScout\' (ID #8)','2026-09-05 05:29:56'),(28,NULL,1,'admin_action','Deleted user \'IronPaladin\' (ID #7)','2026-09-05 05:29:58'),(29,NULL,1,'admin_action','Deleted user \'ShadowKnight\' (ID #1)','2026-09-05 05:30:02'),(30,NULL,1,'admin_action','Deleted user \'CodeWarrior\' (ID #4)','2026-09-05 05:30:04'),(31,NULL,1,'admin_action','Deleted user \'ValkyrieRunner\' (ID #3)','2026-09-05 05:30:06'),(32,NULL,1,'admin_action','Deleted user \'AuraHealer\' (ID #5)','2026-09-05 05:30:09'),(33,NULL,1,'admin_action','Deleted user \'CyberMage\' (ID #2)','2026-09-05 05:30:13'),(34,32,1,'user_registered','Admin registered new hero \'effwefef\' (ID #32)','2026-09-05 05:49:33'),(35,NULL,1,'admin_action','Updated mobile app hero banner image','2026-09-05 06:14:08'),(36,NULL,1,'admin_login','Admin \'Commander Admin\' logged in successfully','2026-09-05 09:03:50'),(37,NULL,1,'admin_action','Created new quest \'push ups\' (+50 XP)','2026-09-05 09:49:25'),(38,NULL,1,'admin_action','Updated mobile app hero banner image','2026-09-05 10:18:41'),(39,33,1,'user_registered','Admin registered new hero \'jjjjjrrrrr\' (ID #33)','2026-09-05 10:47:48'),(40,NULL,1,'admin_login','Admin \'Commander Admin\' logged in successfully','2026-09-08 05:02:42'),(41,NULL,1,'admin_action','Updated mobile app hero banner image','2026-09-08 05:06:04'),(42,34,1,'user_registered','Admin registered new hero \'admin\' (ID #34)','2026-09-08 05:07:46'),(43,NULL,1,'admin_action','Removed mobile app hero banner image (reverted to default clean RPG gradient)','2026-09-08 05:13:23'),(44,NULL,1,'admin_action','Updated mobile app hero banner image','2026-09-08 05:13:36'),(45,NULL,1,'admin_action','Updated global realm settings','2026-09-08 05:16:01'),(46,NULL,1,'admin_login','Admin \'Commander Admin\' logged in successfully','2026-09-08 05:17:30'),(47,NULL,1,'admin_login','Admin \'Commander Admin\' logged in successfully','2026-09-08 05:30:35'),(48,NULL,1,'admin_action','Removed mobile app hero banner image (reverted to default clean RPG gradient)','2026-09-08 05:31:17'),(49,NULL,1,'admin_action','Updated mobile app hero banner image','2026-09-08 05:31:24'),(50,NULL,1,'admin_action','Updated mobile app hero banner image','2026-09-08 06:03:27'),(51,NULL,1,'admin_login','Admin \'Commander Admin\' logged in successfully','2026-09-09 05:36:01'),(52,NULL,1,'admin_action','Updated mobile app hero banner image','2026-09-09 06:15:27'),(53,NULL,1,'admin_login','Admin \'Commander Admin\' logged in successfully','2026-09-09 13:28:37'),(54,41,1,'user_registered','Admin registered new hero \'sigma\' (ID #41)','2026-09-09 13:29:43'),(55,NULL,1,'admin_login','Admin \'Commander Admin\' logged in successfully','2026-09-10 04:48:26'),(56,NULL,1,'admin_action','Updated mobile app hero banner image','2026-09-10 04:50:08'),(57,NULL,1,'admin_login','Admin \'Commander Admin\' logged in successfully','2026-09-15 05:56:44');
/*!40000 ALTER TABLE `activity_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admins`
--

DROP TABLE IF EXISTS `admins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admins` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` varchar(20) NOT NULL DEFAULT 'superadmin',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_login` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admins`
--

LOCK TABLES `admins` WRITE;
/*!40000 ALTER TABLE `admins` DISABLE KEYS */;
INSERT INTO `admins` VALUES (1,'Commander Admin','admin@levelup.com','$2y$10$15UT5vHKF9hzbI0vnUaQpeVGsLJFxMqeLkwV1KPBW0aHjnKVlH2Si','superadmin','2026-09-03 05:16:58','2026-09-15 05:56:44');
/*!40000 ALTER TABLE `admins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `app_settings`
--

DROP TABLE IF EXISTS `app_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `app_settings` (
  `setting_key` varchar(50) NOT NULL,
  `setting_value` text DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`setting_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_settings`
--

LOCK TABLES `app_settings` WRITE;
/*!40000 ALTER TABLE `app_settings` DISABLE KEYS */;
INSERT INTO `app_settings` VALUES ('achievement_notifications','1','2026-09-08 05:16:01'),('app_description','Transform your real life into an epic RPG progression experience.','2026-09-08 05:16:01'),('app_name','LevelUp - Level Up Your Real Life','2026-09-15 11:50:56'),('daily_reminder','1','2026-09-08 05:16:01'),('default_task_duration','30','2026-09-08 05:16:01'),('default_water_goal_ml','2500','2026-09-08 05:16:01'),('default_xp','60','2026-09-08 05:16:01'),('hero_banner_enabled','1','2026-09-08 05:16:01'),('hero_banner_image','/admin-web/uploads/banners/hero_banner_20260910_065008_adee72be.jpg','2026-09-10 04:50:08'),('hero_banner_subtitle','','2026-09-08 05:16:01'),('hero_banner_title','','2026-09-08 05:16:01'),('maintenance_message','LevelUp realm is currently undergoing scheduled upgrades. Please check back shortly!','2026-09-15 11:50:56'),('maintenance_mode','0','2026-09-08 05:16:01'),('quote_of_the_day','You\'re getting stronger every day! 💪','2026-09-08 05:16:01'),('streak_notifications','1','2026-09-08 05:16:01'),('task_completion_notifications','1','2026-09-08 05:16:01');
/*!40000 ALTER TABLE `app_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hydration_logs`
--

DROP TABLE IF EXISTS `hydration_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hydration_logs` (
  `id` varchar(50) NOT NULL,
  `user_id` int(11) NOT NULL,
  `task_id` varchar(50) DEFAULT NULL,
  `amount_ml` int(11) NOT NULL,
  `logged_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_hydration_user` (`user_id`),
  KEY `idx_hydration_date` (`logged_at`),
  CONSTRAINT `hydration_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hydration_logs`
--

LOCK TABLES `hydration_logs` WRITE;
/*!40000 ALTER TABLE `hydration_logs` DISABLE KEYS */;
INSERT INTO `hydration_logs` VALUES ('hydro_1788608251_621',32,'task_003',250,'2026-09-05 11:37:31'),('hydro_1789456477_481',32,'task_today_water',150,'2026-09-15 07:14:37'),('hydro_1789456479_467',32,'task_today_water',250,'2026-09-15 07:14:39'),('hydro_1789456480_658',32,'task_today_water',500,'2026-09-15 07:14:40');
/*!40000 ALTER TABLE `hydration_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notifications` (
  `id` varchar(50) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `category` varchar(50) NOT NULL DEFAULT 'System',
  `type` varchar(50) NOT NULL DEFAULT 'announcement',
  `target_user_id` int(11) DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_notifications_target` (`target_user_id`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`target_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES ('notif_001','Welcome to Season 2 of LevelUp!','A new quest cycle has begun. Complete your daily quests to earn double XP this weekend!','System','announcement',NULL,0,'2026-09-01 05:16:58'),('notif_002','Streak Protection Activated','Keep pushing! Maintain your daily streak to unlock legendary prestige titles.','System','reminder',NULL,0,'2026-09-02 05:16:58'),('notif_1788950045_186','Welcome to LevelUp, Hero!','Your epic real-life RPG adventure begins now. Complete daily quests, earn XP, level up, and conquer your goals!','System','announcement',37,0,'2026-09-09 10:34:05'),('notif_1788950269_947','Welcome to LevelUp, Hero!','Your epic real-life RPG adventure begins now. Complete daily quests, earn XP, level up, and conquer your goals!','System','announcement',38,0,'2026-09-09 10:37:49'),('notif_1788952977_372','Welcome to LevelUp, Hero!','Your epic real-life RPG adventure begins now. Complete daily quests, earn XP, level up, and conquer your goals!','System','announcement',39,0,'2026-09-09 11:22:57'),('notif_1788953008_683','Welcome to LevelUp, Hero!','Your epic real-life RPG adventure begins now. Complete daily quests, earn XP, level up, and conquer your goals!','System','announcement',40,0,'2026-09-09 11:23:28');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_completions`
--

DROP TABLE IF EXISTS `task_completions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `task_completions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `task_id` varchar(50) NOT NULL,
  `user_id` int(11) NOT NULL,
  `xp_awarded` int(11) NOT NULL DEFAULT 0,
  `completed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_completions_user` (`user_id`),
  KEY `idx_completions_task` (`task_id`),
  KEY `idx_completions_date` (`completed_at`),
  CONSTRAINT `task_completions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_completions`
--

LOCK TABLES `task_completions` WRITE;
/*!40000 ALTER TABLE `task_completions` DISABLE KEYS */;
INSERT INTO `task_completions` VALUES (4,'task_010',6,60,'2026-09-01 05:16:58');
/*!40000 ALTER TABLE `task_completions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tasks`
--

DROP TABLE IF EXISTS `tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tasks` (
  `id` varchar(50) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `category` enum('Fitness','Study','Health','Work','Personal','Hydration','Other') NOT NULL DEFAULT 'Personal',
  `xp_reward` int(11) NOT NULL DEFAULT 10,
  `is_completed` tinyint(1) NOT NULL DEFAULT 0,
  `scheduled_date` date NOT NULL,
  `scheduled_time` varchar(10) DEFAULT NULL,
  `duration_minutes` int(11) NOT NULL DEFAULT 0,
  `time_spent_seconds` int(11) NOT NULL DEFAULT 0,
  `timer_status` varchar(20) NOT NULL DEFAULT 'Not Started',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `task_type` enum('normal','hydration') NOT NULL DEFAULT 'normal',
  `water_goal_ml` int(11) NOT NULL DEFAULT 2000,
  `current_water_ml` int(11) NOT NULL DEFAULT 0,
  `assigned_user_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `assigned_user_id` (`assigned_user_id`),
  KEY `idx_tasks_date` (`scheduled_date`),
  KEY `idx_tasks_status` (`is_completed`),
  KEY `idx_tasks_category` (`category`),
  KEY `idx_tasks_type` (`task_type`),
  CONSTRAINT `tasks_ibfk_1` FOREIGN KEY (`assigned_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tasks`
--

LOCK TABLES `tasks` WRITE;
/*!40000 ALTER TABLE `tasks` DISABLE KEYS */;
INSERT INTO `tasks` VALUES ('task_001',NULL,'Morning Deep Focus Study','Study algorithmic problem solving and architecture patterns.','Study',60,1,'2026-09-03','08:00',45,2700,'Completed',1,'normal',0,0,NULL,'2026-09-03 05:16:58','2026-09-05 11:16:27'),('task_002',NULL,'High-Intensity Kettlebell Circuit','Complete 5 rounds of swings, clean and press, and lunges.','Fitness',75,1,'2026-09-03','09:30',30,1800,'Completed',1,'normal',0,0,NULL,'2026-09-03 05:16:58','2026-09-05 11:16:27'),('task_003',NULL,'Hydration Mastery (2.5L)','Hydrate systematically throughout the day to boost cognition.','Hydration',50,0,'2026-09-03',NULL,0,0,'Not Started',1,'hydration',2500,1800,NULL,'2026-09-03 05:16:58','2026-09-05 11:16:27'),('task_004',NULL,'Read 20 Pages of Clean Architecture','Read book and synthesize key concepts into notes.','Study',40,0,'2026-09-03','17:00',30,0,'Not Started',1,'normal',0,0,NULL,'2026-09-03 05:16:58','2026-09-05 11:16:27'),('task_005',NULL,'Evening Mobility & Stretching','Full body hip flexor and spine mobility session.','Health',35,0,'2026-09-03','21:00',20,0,'Not Started',1,'normal',0,0,NULL,'2026-09-03 05:16:58','2026-09-05 11:16:27'),('task_006',NULL,'Future Sprint Planning (Tomorrow)','Plan sprint objectives and break down high-level epics.','Work',50,0,'2026-09-04','10:00',45,0,'Not Started',1,'normal',0,0,NULL,'2026-09-03 05:16:58','2026-09-05 11:16:27'),('task_007',NULL,'Future 10K Endurance Run','Scheduled long run in the morning.','Fitness',120,0,'2026-09-05','06:30',60,0,'Not Started',1,'normal',0,0,NULL,'2026-09-03 05:16:58','2026-09-05 11:16:27'),('task_008',NULL,'Hydration Challenge - 3.0L','Target 3 liters hydration goal.','Hydration',60,1,'2026-09-04',NULL,0,0,'Completed',1,'hydration',3000,0,NULL,'2026-09-03 05:16:58','2026-09-05 11:16:27'),('task_009',NULL,'Clean Workspace & Organize Desk','Personal environmental declutter session.','Personal',25,1,'2026-09-02','18:00',15,900,'Completed',1,'normal',0,0,NULL,'2026-09-02 05:16:58','2026-09-05 11:16:27'),('task_1788419045_6783',NULL,'Future Quest of Valor','','Personal',100,0,'2026-09-05','09:04',20,0,'Not Started',1,'normal',2000,0,NULL,'2026-09-03 07:04:05','2026-09-05 11:16:27'),('task_1788419045_9992',NULL,'Conquer Clean Code Sprint','','Work',50,1,'2026-09-03','09:04',30,1800,'Completed',1,'normal',2000,0,NULL,'2026-09-03 07:04:05','2026-09-05 11:16:27'),('task_1788419761_4815',NULL,'Conquer Clean Code Sprint','','Work',50,1,'2026-09-03','09:16',30,1800,'Completed',1,'normal',2000,0,NULL,'2026-09-03 07:16:01','2026-09-05 11:16:27'),('task_1788419761_5493',NULL,'Future Quest of Valor','','Personal',100,0,'2026-09-05','09:16',20,0,'Not Started',1,'normal',2000,0,NULL,'2026-09-03 07:16:01','2026-09-05 11:16:27'),('task_1788420323_6813',NULL,'Conquer Clean Code Sprint','','Work',50,1,'2026-09-03','09:25',30,1800,'Completed',1,'normal',2000,0,NULL,'2026-09-03 07:25:23','2026-09-05 11:16:27'),('task_1788420323_9482',NULL,'Future Quest of Valor','','Personal',100,0,'2026-09-05','09:25',20,0,'Not Started',1,'normal',2000,0,NULL,'2026-09-03 07:25:23','2026-09-05 11:16:27'),('task_1788420858_3507',NULL,'Conquer Clean Code Sprint','','Work',50,1,'2026-09-03','09:34',30,1800,'Completed',1,'normal',2000,0,NULL,'2026-09-03 07:34:18','2026-09-05 11:16:27'),('task_1788420858_5593',NULL,'Future Quest of Valor','','Personal',100,0,'2026-09-05','09:34',20,0,'Not Started',1,'normal',2000,0,NULL,'2026-09-03 07:34:18','2026-09-05 11:16:27'),('task_1788425885_2812',NULL,'Future Quest of Valor','','Personal',100,0,'2026-09-05','10:58',20,0,'Not Started',1,'normal',2000,0,NULL,'2026-09-03 08:58:05','2026-09-05 11:16:27'),('task_1788425885_9088',NULL,'Conquer Clean Code Sprint','','Work',50,1,'2026-09-03','10:58',30,1800,'Completed',1,'normal',2000,0,NULL,'2026-09-03 08:58:05','2026-09-05 11:16:27'),('task_1788427968_3961',NULL,'Conquer Clean Code Sprint','','Work',50,1,'2026-09-03','11:32',30,1800,'Completed',1,'normal',2000,0,NULL,'2026-09-03 09:32:48','2026-09-05 11:16:27'),('task_1788427968_4332',NULL,'Future Quest of Valor','','Personal',100,0,'2026-09-05','11:32',20,0,'Not Started',1,'normal',2000,0,NULL,'2026-09-03 09:32:48','2026-09-05 11:16:27'),('task_1788429289_3266',NULL,'Conquer Clean Code Sprint','','Work',50,1,'2026-09-03','11:54',30,1800,'Completed',1,'normal',2000,0,NULL,'2026-09-03 09:54:49','2026-09-05 11:16:27'),('task_1788429289_7960',NULL,'Future Quest of Valor','','Personal',100,0,'2026-09-05','11:54',20,0,'Not Started',1,'normal',2000,0,NULL,'2026-09-03 09:54:49','2026-09-05 11:16:27'),('task_1788429708_1369',NULL,'Future Quest of Valor','','Personal',100,0,'2026-09-05','12:01',20,0,'Not Started',1,'normal',2000,0,NULL,'2026-09-03 10:01:48','2026-09-05 11:16:27'),('task_1788429708_9442',NULL,'Conquer Clean Code Sprint','','Work',50,1,'2026-09-03','12:01',30,1800,'Completed',1,'normal',2000,0,NULL,'2026-09-03 10:01:48','2026-09-05 11:16:27'),('task_1788430324_3625',NULL,'Future Quest of Valor','','Personal',100,0,'2026-09-05','12:12',20,0,'Not Started',1,'normal',2000,0,NULL,'2026-09-03 10:12:04','2026-09-05 11:16:27'),('task_1788430324_7665',NULL,'Conquer Clean Code Sprint','','Work',50,1,'2026-09-03','12:12',30,1800,'Completed',1,'normal',2000,0,NULL,'2026-09-03 10:12:04','2026-09-05 11:16:27'),('task_1788431293_2064',NULL,'Conquer Clean Code Sprint','','Work',50,1,'2026-09-03','12:28',30,1800,'Completed',1,'normal',2000,0,NULL,'2026-09-03 10:28:13','2026-09-05 11:16:27'),('task_1788431293_9050',NULL,'Future Quest of Valor','','Personal',100,0,'2026-09-05','12:28',20,0,'Not Started',1,'normal',2000,0,NULL,'2026-09-03 10:28:13','2026-09-05 11:16:27'),('task_1788950381_3400',38,'blowjob','10 times per day','',50,0,'2026-09-09','4:15 PM',10,0,'Not Started',1,'normal',2000,0,38,'2026-09-09 10:39:41','2026-09-09 10:39:41'),('task_68b16ca83b2d',NULL,'push ups','total 50','Personal',50,0,'2026-09-05',NULL,10,0,'Not Started',1,'normal',0,0,NULL,'2026-09-05 09:49:25','2026-09-05 09:49:25'),('task_f087e1b4e93a',NULL,'yoga','part time','Personal',50,0,'2026-09-03',NULL,30,0,'Not Started',1,'normal',0,0,NULL,'2026-09-03 10:55:05','2026-09-03 10:55:05'),('task_today_cleaning',NULL,'Clean Your Study Desk','Clear clutter, dust desk surfaces, and organize work accessories.','Personal',30,0,'2026-09-05','17:00',15,0,'Not Started',1,'normal',0,0,NULL,'2026-09-05 11:17:01','2026-09-05 11:17:01'),('task_today_coding',NULL,'Complete Flutter Login Screen','Refactor state management and test API client integration.','Personal',100,0,'2026-09-05','15:30',45,0,'Not Started',1,'normal',0,0,NULL,'2026-09-05 11:17:01','2026-09-05 11:17:01'),('task_today_creative',NULL,'Draw for 30 Minutes','Sketch characters, environment concepts, or daily creative studies.','Personal',45,0,'2026-09-05','19:00',30,0,'Not Started',1,'normal',0,0,NULL,'2026-09-05 11:17:01','2026-09-05 11:17:01'),('task_today_habit',NULL,'Wake Up Before 7 AM','Kickstart the morning with discipline and intentional morning routine.','Personal',40,0,'2026-09-05','06:45',10,0,'Not Started',1,'normal',0,0,NULL,'2026-09-05 11:17:01','2026-09-05 11:17:01'),('task_today_meditation',NULL,'15 Minute Meditation','Mindful breathing practice to reset focus and reduce mental stress.','Personal',35,0,'2026-09-05','18:00',15,0,'Not Started',1,'normal',0,0,NULL,'2026-09-05 11:17:01','2026-09-05 11:17:01'),('task_today_reading',NULL,'Read 20 Pages','Deep focus reading session.','Personal',40,0,'2026-09-05','14:00',30,0,'Not Started',1,'normal',0,0,NULL,'2026-09-05 11:17:01','2026-09-05 11:17:01'),('task_today_social',NULL,'Call a Friend','Check in with a close friend or family member for a meaningful chat.','Personal',25,0,'2026-09-05','20:00',15,0,'Not Started',1,'normal',0,0,NULL,'2026-09-05 11:17:01','2026-09-05 11:17:01'),('task_today_study',NULL,'Study Mathematics','Calculus and linear algebra chapter revision.','Study',60,0,'2026-09-05','11:00',45,0,'Not Started',1,'normal',0,0,NULL,'2026-09-05 11:17:01','2026-09-05 11:17:01'),('task_today_walking',NULL,'Evening 4000 Steps Walk','Brisk outdoor walk for daily movement and fresh air.','Fitness',50,0,'2026-09-05','20:30',25,0,'Not Started',1,'normal',0,0,NULL,'2026-09-05 11:17:01','2026-09-05 11:17:01'),('task_today_water',NULL,'Daily Drinking Water','Daily hydration goal: 2.5 L','Health',50,0,'2026-09-05','08:00',0,0,'Not Started',1,'hydration',2500,0,NULL,'2026-09-05 11:17:01','2026-09-05 11:17:01'),('task_today_workout',NULL,'30 Minute Workout','Full body workout to boost stamina and strength.','Fitness',70,0,'2026-09-05','09:00',30,0,'Not Started',1,'normal',0,0,NULL,'2026-09-05 11:17:01','2026-09-05 11:17:01'),('task_tom_2',NULL,'Gym Strength Training Session','Chest, shoulders, and triceps focus','Fitness',90,0,'2026-09-06','09:00',45,0,'Not Started',1,'normal',0,0,NULL,'2026-09-05 11:17:01','2026-09-05 11:17:01'),('task_tom_3',NULL,'Learn Advanced SQL Queries','Joins, indexing, and query optimization','Study',110,0,'2026-09-06','11:00',60,0,'Not Started',1,'normal',0,0,NULL,'2026-09-05 11:17:01','2026-09-05 11:17:01'),('task_tom_4',NULL,'Team Sprint Review & Planning','Review milestones and track deliverables','Work',85,0,'2026-09-06','14:00',40,0,'Not Started',1,'normal',0,0,NULL,'2026-09-05 11:17:01','2026-09-05 11:17:01'),('task_tom_5',NULL,'Mindfulness & Gratitude Journal','Write 3 accomplishments and 3 reflections','Personal',40,0,'2026-09-06','21:00',15,0,'Not Started',1,'normal',0,0,NULL,'2026-09-05 11:17:01','2026-09-05 11:17:01'),('task_tom_water',NULL,'Daily Drinking Water','Daily hydration goal: 2.5 L','Health',50,0,'2026-09-06','08:00',0,0,'Not Started',1,'hydration',2500,0,NULL,'2026-09-05 11:17:01','2026-09-05 11:17:01'),('task_yest_2',NULL,'Morning Cardio & Stretch','20 minutes of cardio to boost energy','Fitness',60,1,'2026-09-04','09:00',20,0,'Not Started',1,'normal',0,0,NULL,'2026-09-05 11:17:01','2026-09-05 11:17:01'),('task_yest_3',NULL,'Study Flutter Architecture','Provider & SQLite architectural patterns','Study',100,1,'2026-09-04','11:00',45,0,'Not Started',1,'normal',0,0,NULL,'2026-09-05 11:17:01','2026-09-05 11:17:01'),('task_yest_4',NULL,'Read 15 Pages of Book','Atomic Habits chapter reading','Personal',40,1,'2026-09-04','14:00',20,0,'Not Started',1,'normal',0,0,NULL,'2026-09-05 11:17:01','2026-09-05 11:17:01'),('task_yest_5',NULL,'Code Review & Sprint Tasks','Refactor components and optimize code','Work',80,1,'2026-09-04','16:00',30,0,'Not Started',1,'normal',0,0,NULL,'2026-09-05 11:17:01','2026-09-05 11:17:01'),('task_yest_water',NULL,'Daily Drinking Water','Daily hydration goal: 2.5 L','Health',50,1,'2026-09-04','08:00',0,0,'Not Started',1,'hydration',2500,0,NULL,'2026-09-05 11:17:01','2026-09-05 11:17:01');
/*!40000 ALTER TABLE `tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_achievements`
--

DROP TABLE IF EXISTS `user_achievements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_achievements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `achievement_id` varchar(50) NOT NULL,
  `unlocked_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_achievement_unique` (`user_id`,`achievement_id`),
  KEY `achievement_id` (`achievement_id`),
  CONSTRAINT `user_achievements_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_achievements_ibfk_2` FOREIGN KEY (`achievement_id`) REFERENCES `achievements` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_achievements`
--

LOCK TABLES `user_achievements` WRITE;
/*!40000 ALTER TABLE `user_achievements` DISABLE KEYS */;
INSERT INTO `user_achievements` VALUES (25,6,'first_quest','2026-08-20 05:16:58'),(26,6,'7_day_streak','2026-08-28 05:16:58'),(27,6,'hydration_hero','2026-09-01 05:16:58');
/*!40000 ALTER TABLE `user_achievements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_settings`
--

DROP TABLE IF EXISTS `user_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `dark_mode` tinyint(1) NOT NULL DEFAULT 1,
  `sound_effects` tinyint(1) NOT NULL DEFAULT 1,
  `selected_alarm_song` varchar(50) NOT NULL DEFAULT 'fanfare_victory',
  `task_notifications` tinyint(1) NOT NULL DEFAULT 1,
  `achievement_notifications` tinyint(1) NOT NULL DEFAULT 1,
  `daily_reminders` tinyint(1) NOT NULL DEFAULT 1,
  `streak_reminders` tinyint(1) NOT NULL DEFAULT 1,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `user_settings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_settings`
--

LOCK TABLES `user_settings` WRITE;
/*!40000 ALTER TABLE `user_settings` DISABLE KEYS */;
INSERT INTO `user_settings` VALUES (21,37,1,1,'fanfare_victory',1,1,1,1,'2026-09-09 10:34:05'),(22,38,1,1,'fanfare_victory',1,1,1,1,'2026-09-09 10:37:49'),(23,39,1,1,'fanfare_victory',1,1,1,1,'2026-09-09 11:22:57'),(24,40,1,1,'fanfare_victory',1,1,1,1,'2026-09-09 11:23:28');
/*!40000 ALTER TABLE `user_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_tokens`
--

DROP TABLE IF EXISTS `user_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_tokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `token` varchar(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`),
  KEY `idx_token_lookup` (`token`),
  KEY `idx_user_tokens` (`user_id`),
  KEY `idx_token_expiry` (`expires_at`),
  CONSTRAINT `user_tokens_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=55 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_tokens`
--

LOCK TABLES `user_tokens` WRITE;
/*!40000 ALTER TABLE `user_tokens` DISABLE KEYS */;
INSERT INTO `user_tokens` VALUES (38,32,'3a2422cabfdd04c31021aded37ca12143c9085a712dbf23ce91fd4c8151e8b35','2026-10-05 12:04:18','2026-09-05 10:04:18'),(39,32,'e91c4488016935bdc5220f0e21d2c25c00fe358f94eff8fef44dc0320d80bbf8','2026-10-05 12:04:40','2026-09-05 10:04:40'),(40,6,'dd7526b24fec16579adf6217cbd268757a7ac30a5479293123d64fa55bc10cd7','2026-10-05 12:04:58','2026-09-05 10:04:58'),(41,32,'986436c77fa3958811d638a2c7a540843448bda52bbc8da745e72365b480d987','2026-10-05 12:16:58','2026-09-05 10:16:58'),(42,32,'9326441f0a9ce255e20577fb9a0a200c750d806f09a696764bec178d23ebf47d','2026-10-05 13:10:56','2026-09-05 11:10:56'),(43,32,'fdf7de24ff3b5f0478bdaaa1c357f173ef66dcd7383b36515a6bc259355373d4','2026-10-05 13:17:13','2026-09-05 11:17:13'),(44,32,'00a29172928b52c326cd676b5297bbf3453efaa9353bbe57fbb35a1ddfdc64e5','2026-10-09 11:13:17','2026-09-09 09:13:17'),(45,37,'a5b7a0541255d9fe2447255df267e663c4955340ab8fad1b54a1c7c3414d71f5','2026-10-09 12:34:05','2026-09-09 10:34:05'),(47,39,'cd18f73f4197c4710f31588865e25cb2451e9b705cfc4fda4357365086c2b88c','2026-10-09 13:22:57','2026-09-09 11:22:57'),(48,40,'99725044a775cb58b8b60e117b6c0d9d966b3aebaa3b1daedfefe72702f6d900','2026-10-09 13:23:28','2026-09-09 11:23:28'),(49,34,'730a2f863e94ecf9c13a28e836f76baf8d71f13adbdbf3e8c6c97f4271df14d0','2026-10-15 12:16:19','2026-09-15 10:16:19'),(50,34,'43be797ce4f06043c4e9c8a228df64df2d98074a2840cddb16e09ed7b7edd84a','2026-10-15 12:16:20','2026-09-15 10:16:20'),(51,35,'670b4880ba2fbee437d2ce501511e07db01a59c841b14d42cf0fd5534dee1055','2026-10-15 12:16:20','2026-09-15 10:16:20'),(52,35,'19a66b09d895cdf99a8c967ccdb4e47d12ed8a3a4c703a5eae99d750bccf3aeb','2026-10-15 12:16:20','2026-09-15 10:16:20'),(53,32,'72e1e929c7767720f31476da21d5cc52672dcc0e49b18b24fc4045e61ee81592','2026-10-15 12:16:20','2026-09-15 10:16:20'),(54,32,'baf791664eabea4f51f8c0f398a5dd16a10dcddafd462106d7149d03d6999cd2','2026-10-15 12:17:46','2026-09-15 10:17:46');
/*!40000 ALTER TABLE `user_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(100) NOT NULL,
  `display_name` varchar(100) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `avatar_id` varchar(50) DEFAULT 'hero1',
  `profile_image_path` varchar(255) DEFAULT NULL,
  `level` int(11) NOT NULL DEFAULT 1,
  `total_xp` int(11) NOT NULL DEFAULT 0,
  `gold` int(11) NOT NULL DEFAULT 0,
  `current_streak` int(11) NOT NULL DEFAULT 0,
  `best_streak` int(11) NOT NULL DEFAULT 0,
  `skills_json` text DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `show_on_leaderboard` tinyint(1) NOT NULL DEFAULT 1,
  `hydration_current_streak` int(11) NOT NULL DEFAULT 0,
  `hydration_best_streak` int(11) NOT NULL DEFAULT 0,
  `last_hydration_date` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_users_level` (`level`),
  KEY `idx_users_is_active` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (6,'ZenMaster',NULL,'zen@levelup.com','$2y$10$x9yCunR3VGth1q517M/r2eQ0Q53B.9BQ8gWE7sYu6kgMVm6IzysN6','hero3',NULL,10,4200,95,15,15,'{\"Strength\": 65, \"Knowledge\": 80, \"Discipline\": 95}',1,1,15,15,NULL,'2026-08-19 05:16:58','2026-09-15 10:15:49'),(32,'harsha','harsha','malnadtech.intern05@gmail.com','$2y$10$.8bb5bNma1W5hhyC7C7C4u4K96CqhVToO/34dEexqIRl.2EHGqTiq','hero1',NULL,1,5,50,0,0,'{\"Strength\":50,\"Knowledge\":50,\"Discipline\":50}',1,1,0,0,NULL,'2026-09-05 05:49:33','2026-09-15 10:15:49'),(33,'jjjjjrrrrr',NULL,'hjsshasgdasg@gmail.com','$2y$10$5gaXBZN/aOAiMJfoRUuiuO/wkqof.YZgpqll7O8RfLBiZBMug5tDu','hero1',NULL,1,0,500,0,0,'{\"Strength\":50,\"Knowledge\":50,\"Discipline\":50}',1,1,0,0,NULL,'2026-09-05 10:47:48','2026-09-05 11:15:49'),(34,'admin',NULL,'admin@levelup.com','$2y$10$FpuF0/0PkUYhaNuubtBYMOumZWYShyiEpTfHlbWRmOnoMnNH.waDW','hero1',NULL,1,0,50,0,0,'{\"Strength\":50,\"Knowledge\":50,\"Discipline\":50}',1,1,0,0,NULL,'2026-09-08 05:07:46','2026-09-15 10:15:49'),(35,'Hero','Hero','hero@example.com','$2y$10$fJJbnt7BJCaFKAKUbJ6QH.aAa.WUjtgXSUTqDmjgysoMhNEH4jybK','hero1',NULL,1,0,100,0,0,NULL,1,1,0,0,NULL,'2026-09-09 09:11:50','2026-09-15 10:15:49'),(36,'sujan','sujan','sujusujans700@gmail.com','$2y$10$yljLM.x6lTTjDInui8ICYeIZfS/TOLjSAY4OeHMXvPohgH72t29kO','hero1',NULL,1,0,100,0,0,NULL,1,1,0,0,NULL,'2026-09-09 10:09:25','2026-09-09 10:09:25'),(37,'adim','adim','admin@gmail.com','$2y$10$emZ4tZiWv8PqaRSITQbNQ.lAwcpbi.gHC.edLAE0Gw5KetJtNpPtK','hero1',NULL,1,0,100,0,0,'{\"Strength\":50,\"Knowledge\":50,\"Discipline\":50}',1,1,0,0,NULL,'2026-09-09 10:34:05','2026-09-15 10:15:49'),(38,'akshay','akshay','mday95507@gmail.com','$2y$10$3m4Lmhe5djEydjzBPEAHX.BHjoyAV7JquK6qxPOnIkWEN3VGP9GE2','hero1',NULL,1,0,100,0,0,'{\"Strength\":50,\"Knowledge\":50,\"Discipline\":50}',1,1,0,0,NULL,'2026-09-09 10:37:49','2026-09-09 10:37:49'),(39,'darshan','darshan','days58490@gmail.com','$2y$10$RvSHTuP4ZcrG6SJAFGX13.2G6XPSGtudPMyoDad0l/flr7bCjOY5O','hero1',NULL,1,0,100,0,0,'{\"Strength\":50,\"Knowledge\":50,\"Discipline\":50}',1,1,0,0,NULL,'2026-09-09 11:22:57','2026-09-09 11:22:57'),(40,'aaa','aaa','akshay123@gmail.com','$2y$10$pSGyMauLHfuZa6aXLzizd.8u2.PfK.KH/diJ5Izfn/RHxuHlTakN6','hero5',NULL,1,0,100,0,0,'{\"Strength\":50,\"Knowledge\":50,\"Discipline\":50}',1,1,0,0,NULL,'2026-09-09 11:23:28','2026-09-09 11:23:28'),(41,'sigma',NULL,'harsha1234@gmail.com','$2y$10$sC2/Ni8wJet0m7VX.1NRyey2auAYRlq74JxMH1iR7.cu.R1keVnSa','hero1',NULL,1,2000,600,0,0,'{\"Strength\":50,\"Knowledge\":50,\"Discipline\":50}',1,1,0,0,NULL,'2026-09-09 13:29:43','2026-09-09 13:29:43');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-16 16:43:54
