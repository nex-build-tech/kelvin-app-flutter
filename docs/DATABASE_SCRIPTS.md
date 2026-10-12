# 🗄️ Database Scripts & Migrations Automation Guide

This document is a comprehensive manual for the **Kelvin Mech** database tooling suite. It covers automated migrations, rollbacks, backup & restore, seed data management, database resets, and health diagnostics.

---

## 📑 Table of Contents

- [1. Quick Command Cheat Sheet](#1-quick-command-cheat-sheet)
- [2. Directory Structure](#2-directory-structure)
- [3. Migration System](#3-migration-system)
  - [How Migrations Work](#how-migrations-work)
  - [Applying Migrations (`db:migrate`)](#applying-migrations-dbmigrate)
  - [Rolling Back Migrations (`db:migrate:down`)](#rolling-back-migrations-dbmigratedown)
  - [Checking Migration Status (`db:migrate:status`)](#checking-migration-status-dbmigratestatus)
  - [Creating New Migrations (`db:create-migration`)](#creating-new-migrations-dbcreate-migration)
- [4. Seed Data Script (`db:seed`)](#4-seed-data-script-dbseed)
- [5. Complete Database Reset (`db:reset`)](#5-complete-database-reset-dbreset)
- [6. Backup & Restore System](#6-backup--restore-system)
  - [Creating a Backup (`db:backup`)](#creating-a-backup-dbbackup)
  - [Restoring from Backup (`db:restore`)](#restoring-from-backup-dbrestore)
- [7. Database Health Diagnostics (`db:check`)](#7-database-health-diagnostics-dbcheck)
- [8. Team & Production Deployment Best Practices](#8-team--production-deployment-best-practices)

---

## 1. Quick Command Cheat Sheet

All commands can be executed from the `backend/` directory or directly using `node`:

| Command | Shorthand (from `backend/`) | Direct Node / Windows Command | Description |
| :--- | :--- | :--- | :--- |
| **Interactive Console** | `npm run db` | `node database/scripts/menu.js` or double-click `db.bat` | **Interactive Terminal Console** (All-in-one menu) |
| **Health Diagnostic** | `npm run db:check` | `node database/scripts/check_db.js` | Displays ping latency, row counts, table sizes |
| **Apply Migrations** | `npm run db:migrate` | `node database/scripts/migrate.js up` | Applies all pending SQL migrations forward |
| **Rollback Migration** | `npm run db:migrate:down` | `node database/scripts/migrate.js down` | Rolls back the most recently applied migration |
| **Migration Status** | `npm run db:migrate:status` | `node database/scripts/migrate.js status` | Shows which migrations are applied vs pending |
| **Create Migration** | `npm run db:create-migration <name>` | `node database/scripts/create_migration.js <name>` | Generates a new versioned template file |
| **Optimize & Defrag** | `npm run db:optimize` | `node database/scripts/optimize.js` | Runs `ANALYZE` and `OPTIMIZE` across all tables |
| **Integrity Audit** | `npm run db:verify` | `node database/scripts/verify_integrity.js` | Audits foreign keys, orphans, and data sanity |
| **Export JSON Fixtures**| `npm run db:fixtures:export` | `node database/scripts/export_fixtures.js` | Dumps each table as JSON file into `database/fixtures/` |
| **Import JSON Fixtures**| `npm run db:fixtures:import` | `node database/scripts/import_fixtures.js` | Loads JSON files from `database/fixtures/` into MySQL |
| **Sanitized Export** | `npm run db:anonymize` | `node database/scripts/anonymize.js` | PII-masked dump for safe QA & dev sharing |
| **Create SQL Backup** | `npm run db:backup` | `node database/scripts/backup.js` | Full schema + data dump to `database/backups/` |
| **Restore SQL Backup** | `npm run db:restore [file]` | `node database/scripts/restore.js [file]` | Restores DB from latest or specified backup |
| **Seed Initial Data** | `npm run db:seed` | `node database/scripts/seed.js` | Populates demo MEP users, projects, POs, tasks |
| **Full DB Reset** | `npm run db:reset` | `node database/scripts/reset.js` | Drops DB, runs all migrations, and seeds data |

---

## 2. Directory Structure

```
database/
├── schema.sql                         # Reference DDL schema
├── seed.sql                           # Reference seed dataset
├── migrations/                        # Version-controlled migration files
│   ├── 001_initial_schema.sql         # Base 8 core tables + rollback
│   ├── 002_add_indexes_and_audit.sql  # Composite indexes & soft-deletes
│   ├── 003_equipment_telemetry.sql    # Chillers, AHUs, Sensors & Telemetry
│   └── 004_user_roles_and_permissions.sql # RBAC roles & permissions
├── backups/                           # Directory for timestamped SQL dumps
│   └── .gitkeep
└── scripts/                           # Production automation CLI scripts
    ├── db_config.js                   # Connection pooling & env loader
    ├── migrate.js                     # Migration runner (up/down/status)
    ├── create_migration.js            # Generator for new migrations
    ├── seed.js                        # Seeder script with count verification
    ├── reset.js                       # Full DB drop + migrate + seed
    ├── backup.js                      # Pure Node.js platform-independent dumper
    ├── restore.js                     # Automated restore engine
    └── check_db.js                    # Database health & table metrics
```

---

## 3. Migration System

### How Migrations Work
1. When you run migrations, the runner verifies that database `kelvin_mech_db` exists and initializes a tracking table:
   ```sql
   CREATE TABLE IF NOT EXISTS `schema_migrations` (
     `version` VARCHAR(150) NOT NULL PRIMARY KEY,
     `name` VARCHAR(255) NOT NULL,
     `applied_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   );
   ```
2. Each migration file contains two clearly delimited sections:
   - `-- Up`: DDL queries executed when migrating forward.
   - `-- Down`: DDL queries executed when rolling back.
3. The runner checks which files have not been applied yet, executes the `-- Up` section in alphabetical order, and records the applied version into `schema_migrations`.

---

### Applying Migrations (`db:migrate`)

Run from `backend/`:
```bash
npm run db:migrate
```

**Output Example:**
```text
========================================================
📦 Running Database Migrations (UP) -> kelvin_mech_db
========================================================
⏳ Applying: 001_initial_schema.sql...
✅ Applied:  001_initial_schema.sql (94ms)
⏳ Applying: 002_add_indexes_and_audit.sql...
✅ Applied:  002_add_indexes_and_audit.sql (1055ms)
⏳ Applying: 003_equipment_telemetry.sql...
✅ Applied:  003_equipment_telemetry.sql (215ms)
⏳ Applying: 004_user_roles_and_permissions.sql...
✅ Applied:  004_user_roles_and_permissions.sql (134ms)
🎉 Successfully applied 4 migration(s).
```

---

### Rolling Back Migrations (`db:migrate:down`)

If an update needs to be reversed safely:
```bash
npm run db:migrate:down
```

**Output Example:**
```text
========================================================
⏪ Rolling Back Last Migration (DOWN) -> kelvin_mech_db
========================================================
⏳ Rolling back: 004_user_roles_and_permissions.sql...
✅ Rolled back: 004_user_roles_and_permissions.sql (84ms)
```

---

### Checking Migration Status (`db:migrate:status`)

View which migrations have been applied to your database and which are pending:
```bash
npm run db:migrate:status
```

**Output Example:**
```text
========================================================
📋 Migration Status -> kelvin_mech_db
========================================================
  [APPLIED]  001_initial_schema.sql              (at: 12/10/2026, 5:28:05 pm)
  [APPLIED]  002_add_indexes_and_audit.sql       (at: 12/10/2026, 5:28:06 pm)
  [APPLIED]  003_equipment_telemetry.sql         (at: 12/10/2026, 5:28:07 pm)
  [APPLIED]  004_user_roles_and_permissions.sql  (at: 12/10/2026, 5:28:24 pm)
========================================================
Total: 4 | Applied: 4 | Pending: 0
```

---

### Creating New Migrations (`db:create-migration`)

To add a new database table or alter existing columns:
```bash
npm run db:create-migration add_vendor_ratings
```

This automatically generates the next numbered file:
`database/migrations/005_add_vendor_ratings.sql`

```sql
-- ============================================================================
-- Migration: 005_add_vendor_ratings
-- Created At: 2026-10-12T12:00:00.000Z
-- ============================================================================

-- Up
ALTER TABLE `approvals` ADD COLUMN `vendor_rating` DECIMAL(2,1) DEFAULT 4.5;

-- Down
ALTER TABLE `approvals` DROP COLUMN `vendor_rating`;
```

---

## 4. Seed Data Script (`db:seed`)

Populates all demo MEP projects, users, PO approvals, CRM follow-ups, and activity logs:
```bash
npm run db:seed
```

**Output Example:**
```text
========================================================
🌱 Seeding Initial Data -> kelvin_mech_db
========================================================
Inserting seed records for Users, Projects, Tasks, Approvals, Follow-ups...
✅ Seed data applied successfully (18ms)!
--------------------------------------------------------
📊 Current Record Summary:
  - users           : 4 records
  - projects        : 5 records
  - tasks           : 5 records
  - follow_ups      : 6 records
  - approvals       : 4 records
  - enquiries       : 4 records
  - reminders       : 5 records
  - activity_logs   : 5 records
========================================================
```

---

## 5. Complete Database Reset (`db:reset`)

When setting up a clean developer environment or testing the application from scratch:
```bash
npm run db:reset
```
*Drops `kelvin_mech_db`, creates a fresh database, executes all migrations forward, and populates seed data.*

---

## 6. Backup & Restore System

Our backup engine is **100% pure Node.js**; it works on Windows, Linux, and macOS without requiring `mysqldump` in your system `PATH`.

### Creating a Backup (`db:backup`)
```bash
npm run db:backup
```

**Output:**
```text
========================================================
💾 Starting Database Backup -> kelvin_mech_db
========================================================
Found 13 tables to dump.
  Exporting table: activity_logs...
  Exporting table: approvals...
  ...
✅ Backup successfully created!
📁 File: database/backups/backup_kelvin_mech_db_20261012_115939.sql
📦 Size: 25.88 KB
========================================================
```

### Restoring from Backup (`db:restore`)

1. **Restore from the latest backup automatically**:
   ```bash
   npm run db:restore
   ```
2. **Or restore from a specific backup file**:
   ```bash
   node database/scripts/restore.js database/backups/backup_kelvin_mech_db_20261012_115939.sql
   ```

---

## 7. Database Health Diagnostics (`db:check`)

Run this diagnostic command to inspect your local MySQL connection, ping latency, tables count, storage sizes, and applied migrations:

```bash
npm run db:check
```

**Output Example:**
```text
========================================================
🔍 Kelvin Mech — MySQL Database Health & Status Check
========================================================
🔌 Host:            localhost:3306
👤 User:            root
🗄️ Database:        kelvin_mech_db
⚡ MySQL Version:   8.0.44
⏱️ Ping Latency:    31 ms
--------------------------------------------------------
📊 Tables Overview:
  • activity_logs             :     5 rows |    32.0 KB (InnoDB)
  • approvals                 :     4 rows |    64.0 KB (InnoDB)
  • enquiries                 :     4 rows |    48.0 KB (InnoDB)
  • equipment                 :     0 rows |    64.0 KB (InnoDB)
  • follow_ups                :     6 rows |    48.0 KB (InnoDB)
  • projects                  :     5 rows |    32.0 KB (InnoDB)
  • reminders                 :     5 rows |    32.0 KB (InnoDB)
  • role_permissions          :     8 rows |    16.0 KB (InnoDB)
  • roles                     :     5 rows |    16.0 KB (InnoDB)
  • schema_migrations         :     4 rows |    16.0 KB (InnoDB)
  • tasks                     :     5 rows |    48.0 KB (InnoDB)
  • telemetry_readings        :     0 rows |    48.0 KB (InnoDB)
  • users                     :     4 rows |    48.0 KB (InnoDB)
--------------------------------------------------------
📁 Total Tables:     13
💾 Total Data Size:  512.00 KB
--------------------------------------------------------
🚀 Applied Migrations (4):
  ✓ 001_initial_schema (applied: 12/10/2026, 5:28:05 pm)
  ✓ 002_add_indexes_and_audit (applied: 12/10/2026, 5:28:06 pm)
  ✓ 003_equipment_telemetry (applied: 12/10/2026, 5:28:07 pm)
  ✓ 004_user_roles_and_permissions (applied: 12/10/2026, 5:28:24 pm)
========================================================
✅ Database is healthy and fully operational!
========================================================
```

---

## 8. Interactive Terminal Console (`npm run db` or `db.bat`)

If you don't want to remember separate command lines, simply launch the **Interactive Console**:
```bash
# Via npm
npm run db

# Or double-click db.bat in Windows Explorer
.\db.bat
```

You will see an all-in-one numbered menu:
```text
================================================================
       ❄️  KELVIN MECH — DATABASE OPERATIONS CONSOLE  ❄️        
================================================================
  [1]  🔍 Health Check & Diagnostics       (Table stats, sizes, ping)
  [2]  🚀 Run Migrations (Forward)         (Apply all pending DDLs)
  [3]  ⏪ Rollback Last Migration          (Undo most recent DDL)
  [4]  📋 Migration Status                 (View applied vs pending)
  [5]  ✨ Create New Migration             (Generate next DDL template)
  [6]  🌱 Seed Demo Data                   (Insert realistic MEP records)
  [7]  💾 Create SQL Backup                (Safe backup to backups/)
  [8]  ♻️ Restore Database                 (Restore from backup file)
  [9]  🛠️ Optimize & Defrag Tables         (ANALYZE & OPTIMIZE tables)
  [10] 🔎 Verify Data Integrity            (Check foreign keys & orphans)
  [11] 📤 Export to JSON Fixtures          (Export tables as .json files)
  [12] 📥 Import from JSON Fixtures        (Load .json fixtures into DB)
  [13] 🔒 Export Sanitized/Anonymized Dump (GDPR/PII masked export)
  [14] ⚠️ Full Database Reset              (Drop DB + Migrate + Seed)
  [0]  🚪 Exit Console
================================================================
👉 Select an option [0-14]: 
```

---

## 9. Table Optimization & Defragmentation (`db:optimize`)

Over time, INSERT and DELETE operations fragment MySQL InnoDB tablespaces, and key statistics become stale. Run this maintenance script periodically:

```bash
npm run db:optimize
```
- Executes `ANALYZE TABLE` to refresh query optimizer key distributions.
- Executes `CHECK TABLE` to test physical index integrity.
- Executes `OPTIMIZE TABLE` to defragment tablespace and reclaim free storage space.

---

## 10. Data Integrity & Consistency Audit (`db:verify`)

Runs automated business logic and relational integrity checks:

```bash
npm run db:verify
```
**Audits Performed:**
1. Verifies that all `tasks` are linked to active, existing `projects`.
2. Verifies that all `follow_ups` link to recognized contracts.
3. Ensures all PO `approvals` have positive numerical values and non-empty PO numbers.
4. Confirms all `projects.completion_pct` values are within valid bounds (0–100%).
5. Validates corporate email syntax across all user accounts.
6. Validates foreign keys on MEP `equipment` and `telemetry_readings`.

---

## 11. JSON Fixtures Export & Import (`db:fixtures`)

For mobile mock testing, Postman API testing, and database portable seeds:

### Export to JSON:
```bash
npm run db:fixtures:export
```
*Creates pretty-printed JSON files in `database/fixtures/` (`users.json`, `projects.json`, `approvals.json`, etc.).*

### Import from JSON:
```bash
npm run db:fixtures:import
```
*Safely loads records from `database/fixtures/*.json` back into your MySQL database.*

---

## 12. Sanitized & Anonymized Export (`db:anonymize`)

When sharing a database backup with outside freelancers, QA testers, or public environments, privacy regulations (GDPR / DPDP) require masking sensitive Personally Identifiable Information (PII):

```bash
npm run db:anonymize
```
- Masks engineer names (`Engineer 1`, `Engineer 2`).
- Masks phone numbers (`+91 98000 XXXXX`).
- Masks user emails (`engineer_X@kelvinmech.local`).
- Resets passwords to generic development hashes.
- Dumps sanitized SQL to `database/backups/sanitized_kelvin_mech_db_<timestamp>.sql`.

---

## 13. Team & Production Deployment Best Practices

1. **Never edit an already-applied migration file**:
   - In production or shared team branches, create a new numbered migration (`db:create-migration`) to add or alter columns.
2. **Always include a `-- Down` rollback block**:
   - Every migration must be reversible to protect against broken production releases.
3. **Automate in CI/CD**:
   - In your deployment workflow, run `npm run db:migrate` before restarting the Node.js API server.
4. **Regular Automated Backups**:
   - Schedule `npm run db:backup` via a daily cron task or Windows Task Scheduler.

