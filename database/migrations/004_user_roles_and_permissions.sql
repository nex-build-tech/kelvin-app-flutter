-- ============================================================================
-- Migration: 004_user_roles_and_permissions
-- Description: Role-based access control (RBAC) tables and permission catalog
-- ============================================================================

-- Up
CREATE TABLE IF NOT EXISTS `roles` (
  `id` VARCHAR(50) NOT NULL PRIMARY KEY,
  `title` VARCHAR(100) NOT NULL,
  `description` VARCHAR(255) DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `role_permissions` (
  `role_id` VARCHAR(50) NOT NULL,
  `permission` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`role_id`, `permission`),
  CONSTRAINT `fk_perm_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert standard MEP roles
INSERT IGNORE INTO `roles` (`id`, `title`, `description`) VALUES
  ('procurement_mgr', 'Procurement Manager', 'Manages PO approvals, vendor follow-ups, quotes'),
  ('project_mgr', 'Project Manager', 'Oversees MEP construction sites, milestones, and tasks'),
  ('lead_architect', 'Lead Architect / Admin', 'Full system administration, architecture design, clearances'),
  ('site_engineer', 'Site Engineer', 'Field inspections, daily checklist reporting, equipment readings'),
  ('viewer', 'Viewer', 'Read-only access to dashboards and status');

-- Insert default permissions
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission`) VALUES
  ('lead_architect', 'manage_all'),
  ('procurement_mgr', 'approve_po'),
  ('procurement_mgr', 'reject_po'),
  ('procurement_mgr', 'manage_vendors'),
  ('project_mgr', 'update_projects'),
  ('project_mgr', 'assign_tasks'),
  ('site_engineer', 'toggle_tasks'),
  ('site_engineer', 'log_telemetry');

-- Down
DROP TABLE IF EXISTS `role_permissions`;
DROP TABLE IF EXISTS `roles`;
