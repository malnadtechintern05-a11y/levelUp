# LevelUp Real-Life RPG - Online Multi-User & Multi-Device System

This document explains the online multi-user architecture for the **LevelUp (Real-Life RPG)** Flutter application and its unified **MySQL Backend** and **Web Admin Panel**.

---

## 1. System Architecture

```
┌───────────────────────────┐      ┌───────────────────────────┐
│     Phone A (Harsha)      │      │  Phone B (Harsha / Rahul) │
│  Flutter Mobile Client    │      │  Flutter Mobile Client    │
└─────────────┬─────────────┘      └─────────────┬─────────────┘
              │                                  │
              │  Authorization: Bearer <TOKEN>   │
              ▼                                  ▼
┌──────────────────────────────────────────────────────────────┐
│                    PHP REST API (`backend/`)                 │
│  ├── auth/         (register, login, logout, me)             │
│  ├── users/        (profile, public_profile)                 │
│  ├── tasks/        (list, create, complete, delete)          │
│  ├── hydration/    (add, history)                            │
│  ├── achievements/ (list)                                    │
│  └── rankings/     (leaderboard)                             │
└──────────────────────────────┬───────────────────────────────┘
                               │ PDO Prepared Statements
                               ▼
┌──────────────────────────────────────────────────────────────┐
│             MySQL Database Server (`levelup_rpg`)            │
│  users, user_tokens, tasks, task_completions, hydration_logs,│
│  achievements, user_achievements, user_settings, admins      │
└──────────────────────────────▲───────────────────────────────┘
                               │ Direct PDO
┌──────────────────────────────┴───────────────────────────────┐
│                 Web Admin Panel (`admin-web/`)               │
│  PHP, Bootstrap 5, Real-time Dashboard, Analytics, Modals    │
└──────────────────────────────────────────────────────────────┘
```

---

## 2. Prerequisites & Server Setup

### A. Database (MySQL via XAMPP)
- **Host**: `127.0.0.1:3306`
- **Database**: `levelup_rpg`
- **User**: `root`
- **Password**: `""` (empty by default in XAMPP)

To run or re-apply schema updates:
```bash
mysql -u root -e "source c:/Users/Malnad/Desktop/real-life-rpg/backend/database/schema_update.sql"
```

### B. Starting the Unified Dev Server
Run the built-in PHP server with the included `router.php` which automatically routes both `/api/*` to the REST API and serves the Web Admin Panel:
```powershell
php -S 0.0.0.0:8080 router.php
```
- **Web Admin Panel**: `http://localhost:8080/admin-web/`
- **REST API**: `http://localhost:8080/api/`

---

## 3. Configuring Flutter App Network Host

The Flutter app includes an **In-App Server Configuration Dialog** directly on the Login screen:
1. Tap the **Server Settings** icon (`settings_ethernet`) in the top right of the Login Screen.
2. Enter the appropriate URL based on your target device:
   - **Android Emulator**: `http://10.0.2.2:8080/api` (default on Android)
   - **Windows / Desktop / Web**: `http://127.0.0.1:8080/api` (default on desktop)
   - **Physical Android Phone**: `http://192.168.x.x:8080/api` (your PC's local WiFi IP)
3. Tap **Save**. The URL is securely stored in `SharedPreferences` and used for all requests.

---

## 4. Multi-Device Synchronization & Two-Account Test

### Verification Flow

#### Step 1: Create Account A on Device 1 (Phone A)
1. Launch the app and tap **Create a new hero account**.
2. Enter:
   - **Username**: `harsha_test`
   - **Email**: `harsha@example.com`
   - **Password**: `Harsha123!`
   - **Avatar**: Choose any hero avatar
3. Tap **CREATE HERO ACCOUNT**.
4. The account is created in MySQL with:
   - `total_xp = 0`
   - `level = 1`
   - `current_streak = 0`
   - 30-day session token issued.

#### Step 2: Complete a Task on Account A
1. Go to the Quests screen and complete a quest (or create one for today and conquer it).
2. Account A receives **+50 XP**.
3. In MySQL, `total_xp` is updated to `50` and an entry is logged in `task_completions`.

#### Step 3: Login as Account A on Device 2 (Phone B)
1. On Device 2 (or a fresh app instance), open the Login Screen.
2. Enter:
   - **Username**: `harsha_test`
   - **Password**: `Harsha123!`
3. The app connects to `/api/auth/login.php` and loads:
   - Exact XP (50 XP), Level 1, streak, completed quests, and trophies from MySQL!

#### Step 4: Register Account B (`rahul_test`)
1. Log out and register a new hero:
   - **Username**: `rahul_test`
   - **Email**: `rahul@example.com`
   - **Password**: `Rahul123!`
2. Verify **Account B** starts fresh with 0 XP, Level 1, and cannot see Account A's tasks or private hydration logs.

#### Step 5: Check Rankings / Leaderboard
1. Open the **Rankings** screen (`🏆 Rankings`).
2. Both real players appear on the leaderboard ranked by XP:
   - `#1 harsha_test (50 XP)`
   - `#2 rahul_test (0 XP)`
3. Tap on `harsha_test` to open the **Public Codex Profile**:
   - Only safe public stats (level, XP, completed tasks, streak, trophies) are shown.
   - Private passwords and emails are strictly excluded by the backend.

---

## 5. Future Task Date Rule

- **Flutter Client**:
  - Quests scheduled for future dates (`scheduled_date > today`) are labeled **🔒 Available Tomorrow** (or on the scheduled date).
  - Attempting to start the timer or complete a future quest shows a warning snackbar and blocks completion.
- **Backend API**:
  - `/api/tasks/complete.php` performs an authoritative server-side check:
    ```php
    if ($task['scheduled_date'] > date('Y-m-d')) {
        sendJson(403, ['code' => 'FUTURE_TASK_LOCKED', ...]);
    }
    ```
  - Future quest completion is rejected with **HTTP 403 Forbidden**.

---

## 6. Token Authentication & Security Rules

- **Bcrypt Password Hashing**:
  - Passwords are encrypted using `password_hash($password, PASSWORD_BCRYPT)`.
  - Plaintext passwords are never stored in the database.
- **Bearer Tokens**:
  - Clients send `Authorization: Bearer <TOKEN>`.
  - Tokens expire after 30 days.
  - If a token is revoked or expired, the backend returns **HTTP 401**, and Flutter automatically clears credentials and redirects to `/login`.
- **Database Sharing**:
  - The Flutter app and the Web Admin Panel share the exact same `levelup_rpg` database, ensuring all updates reflect immediately in the admin dashboard.
