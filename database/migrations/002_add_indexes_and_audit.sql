-- ============================================================================
-- Migration: 002_add_indexes_and_audit
-- Description: Composite performance indexes and soft-delete audit columns
-- ============================================================================

-- Up
ALTER TABLE `tasks`
  ADD INDEX `idx_tasks_project_done` (`project_name`, `is_done`),
  ADD COLUMN `deleted_at` DATETIME DEFAULT NULL;

ALTER TABLE `follow_ups`
  ADD INDEX `idx_followups_due_status` (`due_date`, `status`),
  ADD COLUMN `deleted_at` DATETIME DEFAULT NULL;

ALTER TABLE `approvals`
  ADD INDEX `idx_approvals_urgency_status` (`urgency`, `status`),
  ADD COLUMN `deleted_at` DATETIME DEFAULT NULL;

ALTER TABLE `projects`
  ADD COLUMN `deleted_at` DATETIME DEFAULT NULL;

-- Down
ALTER TABLE `tasks`
  DROP INDEX `idx_tasks_project_done`,
  DROP COLUMN `deleted_at`;

ALTER TABLE `follow_ups`
  DROP INDEX `idx_followups_due_status`,
  DROP COLUMN `deleted_at`;

ALTER TABLE `approvals`
  DROP INDEX `idx_approvals_urgency_status`,
  DROP COLUMN `deleted_at`;

ALTER TABLE `projects`
  DROP COLUMN `deleted_at`;
