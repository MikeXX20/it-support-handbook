-- LAB ONLY. Creates a new exercise schema and sample rows.
-- Deliberately no IF NOT EXISTS, DROP, or overwrite behavior.
-- Run with the normal mysql batch client; do not add --force.
CREATE DATABASE it_support_lab CHARACTER SET utf8mb4;
USE it_support_lab;

CREATE TABLE agents (
  id INT PRIMARY KEY,
  name VARCHAR(80) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE tickets (
  id INT PRIMARY KEY,
  subject VARCHAR(160) NOT NULL,
  status ENUM('open','in_progress','closed') NOT NULL,
  priority ENUM('low','medium','high') NOT NULL,
  owner_id INT NULL,
  created_at DATETIME NOT NULL,
  CONSTRAINT fk_ticket_owner FOREIGN KEY (owner_id) REFERENCES agents(id),
  INDEX idx_status_priority (status, priority)
) ENGINE=InnoDB;

INSERT INTO agents (id, name) VALUES
  (1, 'Alex'), (2, 'Sam'), (3, 'Taylor');

INSERT INTO tickets (id, subject, status, priority, owner_id, created_at) VALUES
  (1, 'Cannot connect to database', 'open', 'high', 1, '2026-01-01 09:00:00'),
  (2, 'Disk usage alert', 'open', 'high', 2, '2026-01-01 09:10:00'),
  (3, 'New account request', 'open', 'medium', 3, '2026-01-01 09:20:00'),
  (4, 'Documentation correction', 'open', 'low', NULL, '2026-01-01 09:30:00'),
  (5, 'Slow internal website', 'in_progress', 'medium', 1, '2026-01-01 09:40:00'),
  (6, 'Printer offline', 'closed', 'low', 2, '2026-01-01 09:50:00'),
  (7, 'Backup restore drill', 'closed', 'high', 3, '2026-01-01 10:00:00'),
  (8, 'SSH access review', 'in_progress', 'medium', 1, '2026-01-01 10:10:00');
