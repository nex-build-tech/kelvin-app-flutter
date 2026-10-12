-- ============================================================================
-- Kelvin Mech Operations Platform — MySQL Database Schema
-- Database: kelvin_mech_db
-- Compatibility: MySQL 8.0+ / MariaDB 10.5+
-- ============================================================================

CREATE DATABASE IF NOT EXISTS `kelvin_mech_db`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `kelvin_mech_db`;

-- 1. Users Table
CREATE TABLE IF NOT EXISTS `users` (
  `id` VARCHAR(50) NOT NULL PRIMARY KEY,
  `name` VARCHAR(150) NOT NULL,
  `email` VARCHAR(150) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `role` VARCHAR(100) NOT NULL,
  `phone` VARCHAR(50) DEFAULT NULL,
  `department` VARCHAR(100) DEFAULT NULL,
  `avatar_url` VARCHAR(255) DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_user_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Projects Table (MEP & HVAC Construction Sites)
CREATE TABLE IF NOT EXISTS `projects` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(200) NOT NULL,
  `completion_pct` DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  `status` ENUM('onTrack', 'delayed', 'atRisk', 'critical') NOT NULL DEFAULT 'onTrack',
  `phase` VARCHAR(100) NOT NULL DEFAULT 'Execution',
  `contract_value` VARCHAR(50) NOT NULL,
  `client_name` VARCHAR(150) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_project_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Tasks Checklist Table
CREATE TABLE IF NOT EXISTS `tasks` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL,
  `project_name` VARCHAR(200) NOT NULL,
  `priority` ENUM('high', 'medium', 'low') NOT NULL DEFAULT 'medium',
  `due_date` DATETIME NOT NULL,
  `is_done` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_task_done` (`is_done`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Follow-ups CRM Table (Client & Vendor Communications)
CREATE TABLE IF NOT EXISTS `follow_ups` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `contact_name` VARCHAR(150) NOT NULL,
  `company` VARCHAR(150) NOT NULL,
  `topic` VARCHAR(255) NOT NULL,
  `phone` VARCHAR(50) NOT NULL,
  `project_name` VARCHAR(200) NOT NULL,
  `due_date` DATETIME NOT NULL,
  `status` ENUM('overdue', 'dueToday', 'upcoming') NOT NULL DEFAULT 'upcoming',
  `channel` ENUM('whatsapp', 'call', 'email') NOT NULL DEFAULT 'call',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_followup_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Purchase Order (PO) Approvals Table
CREATE TABLE IF NOT EXISTS `approvals` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `po_number` VARCHAR(50) NOT NULL UNIQUE,
  `vendor_name` VARCHAR(200) NOT NULL,
  `item_description` TEXT NOT NULL,
  `amount_str` VARCHAR(50) NOT NULL,
  `amount_in_lakhs` DECIMAL(10,2) NOT NULL,
  `days_pending` INT NOT NULL DEFAULT 0,
  `urgency` ENUM('high', 'medium', 'low') NOT NULL DEFAULT 'medium',
  `status` ENUM('pending', 'approved', 'rejected') NOT NULL DEFAULT 'pending',
  `requested_by` VARCHAR(150) NOT NULL,
  `signoff_note` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_approval_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Enquiries Table (Inbound Leads)
CREATE TABLE IF NOT EXISTS `enquiries` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `ref_number` VARCHAR(50) NOT NULL UNIQUE,
  `client_name` VARCHAR(150) NOT NULL,
  `scope_summary` TEXT NOT NULL,
  `estimated_value` VARCHAR(50) NOT NULL,
  `source_channel` ENUM('whatsapp', 'email', 'phone', 'walkin') NOT NULL DEFAULT 'whatsapp',
  `status` ENUM('newLead', 'estimating', 'sent', 'converted') NOT NULL DEFAULT 'newLead',
  `assigned_to` VARCHAR(150) DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_enquiry_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. Operational Reminders Table
CREATE TABLE IF NOT EXISTS `reminders` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL,
  `scheduled_time` DATETIME NOT NULL,
  `reminder_type` ENUM('approval', 'followup', 'meeting', 'task') NOT NULL DEFAULT 'task',
  `priority` ENUM('high', 'medium', 'low') NOT NULL DEFAULT 'medium',
  `repeat_frequency` ENUM('none', 'daily', 'weekly', 'monthly') NOT NULL DEFAULT 'none',
  `is_done` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_reminder_done` (`is_done`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. Activity Logs Stream Table
CREATE TABLE IF NOT EXISTS `activity_logs` (
  `id` VARCHAR(50) NOT NULL PRIMARY KEY,
  `icon_emoji` VARCHAR(20) NOT NULL,
  `event_text` TEXT NOT NULL,
  `color_tag` VARCHAR(30) NOT NULL DEFAULT 'primary',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_activity_time` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
