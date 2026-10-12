-- ============================================================================
-- Kelvin Mech Operations Platform — MySQL Seed Data
-- Database: kelvin_mech_db
-- ============================================================================

USE `kelvin_mech_db`;

-- 1. Seed Users (Demo Team Members)
INSERT INTO `users` (`id`, `name`, `email`, `password`, `role`, `phone`, `department`) VALUES
('u_suresh', 'Suresh Iyer', 'suresh@kelvinmech.com', 'kelvin123', 'Procurement Manager', '+91 98201 23456', 'MEP Procurement'),
('u_priya', 'Priya Shah', 'priya@kelvinmech.com', 'kelvin123', 'Project Manager', '+91 98202 34567', 'MEP Operations'),
('u_admin', 'Sachin G', 'admin@kelvinmech.com', 'admin123', 'Admin / Architect', '+91 98203 45678', 'Engineering & Architecture'),
('u_demo', 'Demo User', 'demo@kelvinmech.com', 'demo', 'Viewer', '+91 98204 56789', 'Field Operations')
ON DUPLICATE KEY UPDATE `name`=VALUES(`name`), `role`=VALUES(`role`);

-- 2. Seed Projects
INSERT INTO `projects` (`id`, `name`, `completion_pct`, `status`, `phase`, `contract_value`, `client_name`) VALUES
(1, 'Airport Terminal T3', 62.00, 'onTrack', 'Execution', '₹4.2 Cr', 'GMR Airports'),
(2, 'ABC Corporate Tower', 41.00, 'delayed', 'Ducting & Piping', '₹2.8 Cr', 'DLF Limited'),
(3, 'Metro Station 4A', 78.00, 'onTrack', 'Testing & Commissioning', '₹1.5 Cr', 'DMRC / MMRDA'),
(4, 'City Care Hospital', 23.00, 'critical', 'Basement AHU Installation', '₹3.6 Cr', 'Max Healthcare'),
(5, 'DLF Cybercity Phase 2', 89.00, 'onTrack', 'Final Handover', '₹5.1 Cr', 'DLF Infra')
ON DUPLICATE KEY UPDATE `completion_pct`=VALUES(`completion_pct`), `status`=VALUES(`status`);

-- 3. Seed Checklist Tasks
INSERT INTO `tasks` (`id`, `title`, `project_name`, `priority`, `due_date`, `is_done`) VALUES
(1, 'Verify chill water pipe pressure test report', 'Airport Terminal T3', 'high', NOW() + INTERVAL 2 HOUR, 0),
(2, 'Inspect duct insulation — 3rd floor AHU room', 'ABC Corporate Tower', 'medium', NOW() + INTERVAL 5 HOUR, 0),
(3, 'Sign off VRF outdoor unit delivery at site gate', 'Metro Station 4A', 'high', NOW() - INTERVAL 1 DAY, 0),
(4, 'Check fire damper integration with BMS panel', 'City Care Hospital', 'high', NOW() - INTERVAL 2 DAY, 0),
(5, 'Review contractor safety checklist for terrace work', 'DLF Cybercity Phase 2', 'low', NOW() + INTERVAL 1 DAY, 0)
ON DUPLICATE KEY UPDATE `title`=VALUES(`title`);

-- 4. Seed Follow-ups (CRM)
INSERT INTO `follow_ups` (`id`, `contact_name`, `company`, `topic`, `phone`, `project_name`, `due_date`, `status`, `channel`) VALUES
(1, 'Vikram Malhotra', 'Blue Star HVAC Ltd', 'VRF Condenser delivery delay — need revised dispatch date', '+91 98765 43210', 'Airport Terminal T3', NOW() - INTERVAL 2 DAY, 'overdue', 'call'),
(2, 'Ananya Sen', 'DLF Projects', 'Quotation revision for Phase 2 ducting insulation', '+91 87654 32109', 'ABC Corporate Tower', NOW() - INTERVAL 1 DAY, 'overdue', 'whatsapp'),
(3, 'Rajesh Kulkarni', 'Voltas Commercial', 'AHU warranty certificate and commissioning sign-off', '+91 76543 21098', 'Metro Station 4A', NOW() + INTERVAL 3 HOUR, 'dueToday', 'call'),
(4, 'Dr. Mehra', 'City Care Hospital', 'Payment clearance for milestone 2 — Chiller supply', '+91 65432 10987', 'City Care Hospital', NOW() + INTERVAL 6 HOUR, 'dueToday', 'email'),
(5, 'Amitabh Joshi', 'Schneider Electric', 'BMS gateway configuration — confirm site visit', '+91 54321 09876', 'Airport Terminal T3', NOW() + INTERVAL 2 DAY, 'upcoming', 'call'),
(6, 'Kavitha Nair', 'Armacell India', 'Insulation rolls dispatch confirmation', '+91 43210 98765', 'ABC Corporate Tower', NOW() + INTERVAL 3 DAY, 'upcoming', 'email')
ON DUPLICATE KEY UPDATE `topic`=VALUES(`topic`), `status`=VALUES(`status`);

-- 5. Seed PO Approvals
INSERT INTO `approvals` (`id`, `po_number`, `vendor_name`, `item_description`, `amount_str`, `amount_in_lakhs`, `days_pending`, `urgency`, `status`, `requested_by`) VALUES
(1, 'PO-2024-090', 'Daikin India Ltd', 'VRF Units ×8 — Metro Station 4A', '₹29.1L', 29.10, 5, 'high', 'pending', 'Priya S'),
(2, 'PO-2024-092', 'Carrier HVAC India', 'AHU Chillers ×2 — ABC Corporate Tower', '₹45.0L', 45.00, 3, 'medium', 'pending', 'Kavya N'),
(3, 'PO-2024-094', 'ABB India Pvt Ltd', 'LT Panel Set — Airport Terminal T3', '₹9.6L', 9.60, 2, 'medium', 'pending', 'Suresh I'),
(4, 'PO-2024-097', 'Danfoss Industries', 'Motorized Control Valves ×24 — Hospital', '₹4.8L', 4.80, 1, 'low', 'pending', 'Sachin G')
ON DUPLICATE KEY UPDATE `amount_in_lakhs`=VALUES(`amount_in_lakhs`), `status`=VALUES(`status`);

-- 6. Seed Inbound Enquiries
INSERT INTO `enquiries` (`id`, `ref_number`, `client_name`, `scope_summary`, `estimated_value`, `source_channel`, `status`, `assigned_to`) VALUES
(1, 'ENQ-455', 'GMR Hyderabad Cargo', 'Ventilation & Exhaust system for cargo warehouse (12,000 sq ft)', '₹85L', 'whatsapp', 'newLead', 'Suresh Iyer'),
(2, 'ENQ-454', 'Prestige Tech Park', 'Chiller plant revamping & energy audit (3x 400 TR chillers)', '₹1.4 Cr', 'email', 'estimating', 'Priya Shah'),
(3, 'ENQ-452', 'L&T Metro Infra', 'Basement ventilation fans ×16 with acoustic silencers', '₹38L', 'phone', 'sent', 'Sachin G'),
(4, 'ENQ-449', 'Phoenix Mills Ltd', 'Retail Mall VRF expansion — Phase 3 (80 indoor units)', '₹2.1 Cr', 'walkin', 'converted', 'Suresh Iyer')
ON DUPLICATE KEY UPDATE `scope_summary`=VALUES(`scope_summary`), `status`=VALUES(`status`);

-- 7. Seed Reminders
INSERT INTO `reminders` (`id`, `title`, `scheduled_time`, `reminder_type`, `priority`, `repeat_frequency`, `is_done`) VALUES
(1, 'Follow-up with Daikin for dispatch note', NOW() + INTERVAL 2 HOUR, 'followup', 'high', 'none', 0),
(2, 'Approve pending Carrier PO for ABC Tower', NOW() + INTERVAL 4 HOUR, 'approval', 'high', 'none', 0),
(3, 'Weekly site coordination meeting with GMR team', NOW() + INTERVAL 6 HOUR, 'meeting', 'medium', 'weekly', 0),
(4, 'Submit revised MEP billing for DLF Cybercity', NOW() + INTERVAL 1 DAY, 'task', 'medium', 'none', 0),
(5, 'Review Metro Station progress %', NOW() + INTERVAL 2 DAY, 'task', 'low', 'none', 0)
ON DUPLICATE KEY UPDATE `title`=VALUES(`title`);

-- 8. Seed Activity Logs
INSERT INTO `activity_logs` (`id`, `icon_emoji`, `event_text`, `color_tag`, `created_at`) VALUES
('act_1', '✅', 'PO-2024-089 approved — ₹18.5L Daikin', 'success', NOW() - INTERVAL 10 MINUTE),
('act_2', '🚨', 'SLA BREACH — Copper Pipes 5 days overdue', 'danger', NOW() - INTERVAL 30 MINUTE),
('act_3', '📥', 'New enquiry — Greenfield Developers (WhatsApp)', 'primary', NOW() - INTERVAL 2 HOUR),
('act_4', '⚠️', 'City Hospital timeline revised — 2 week delay', 'warning', NOW() - INTERVAL 4 HOUR),
('act_5', '📦', 'PO-2024-092 Voltas — delivery confirmed at Airport T3', 'primary', NOW() - INTERVAL 6 HOUR)
ON DUPLICATE KEY UPDATE `event_text`=VALUES(`event_text`);
