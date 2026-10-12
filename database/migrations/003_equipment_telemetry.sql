-- ============================================================================
-- Migration: 003_equipment_telemetry
-- Description: Equipment assets (Chillers, AHUs, VRFs) and telemetry metrics
-- ============================================================================

-- Up
CREATE TABLE IF NOT EXISTS `equipment` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `project_id` INT DEFAULT NULL,
  `tag_name` VARCHAR(100) NOT NULL,
  `equipment_type` ENUM('Chiller', 'AHU', 'VRF', 'CoolingTower', 'Pump', 'DuctSensor') NOT NULL,
  `serial_number` VARCHAR(100) DEFAULT NULL,
  `model_number` VARCHAR(100) DEFAULT NULL,
  `manufacturer` VARCHAR(100) DEFAULT NULL,
  `status` ENUM('operational', 'maintenance_due', 'fault', 'offline') NOT NULL DEFAULT 'operational',
  `health_score` INT NOT NULL DEFAULT 100,
  `installed_date` DATE DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_equipment_type` (`equipment_type`),
  INDEX `idx_equipment_status` (`status`),
  CONSTRAINT `fk_equipment_project` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `telemetry_readings` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `equipment_id` INT NOT NULL,
  `metric_name` VARCHAR(100) NOT NULL,
  `metric_value` DECIMAL(10,2) NOT NULL,
  `unit` VARCHAR(30) NOT NULL,
  `recorded_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_telemetry_eq_metric` (`equipment_id`, `metric_name`),
  INDEX `idx_telemetry_time` (`recorded_at`),
  CONSTRAINT `fk_telemetry_equipment` FOREIGN KEY (`equipment_id`) REFERENCES `equipment` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Down
DROP TABLE IF EXISTS `telemetry_readings`;
DROP TABLE IF EXISTS `equipment`;
