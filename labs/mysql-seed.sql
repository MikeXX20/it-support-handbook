-- LAB ONLY. Creates a new exercise schema and sample rows.
-- Deliberately no IF NOT EXISTS, DROP, or overwrite behavior.
-- Run with the normal mysql batch client; do not add --force.
-- 【仅限实验，创建数据库】新建支持 utf8mb4 的练习库；已存在就报错，避免覆盖旧练习。
CREATE DATABASE it_support_lab CHARACTER SET utf8mb4;
-- 选择练习数据库；后续不带库名前缀的表名会在此库中查找。
USE it_support_lab;

-- 【仅限实验，创建表】建立支持人员表，括号内每行定义一个字段。
CREATE TABLE agents (
  -- 定义整数编号为主键；主键不能重复或为 NULL，行尾逗号表示后面还有字段。
  id INT PRIMARY KEY,
  -- 定义最长 80 个字符的姓名，NOT NULL 禁止 SQL 空值；不等于禁止空字符串。
  name VARCHAR(80) NOT NULL
-- 结束建表语句并使用 InnoDB 引擎，本练习依靠它的事务和行锁行为。
) ENGINE=InnoDB;

-- 【仅限实验，创建表】建立工单表，下面依次定义字段、外键及索引。
CREATE TABLE tickets (
  -- 定义整数编号为主键；主键不能重复或为 NULL，行尾逗号表示后面还有字段。
  id INT PRIMARY KEY,
  -- 主题最长 160 个字符且不能为 NULL。
  subject VARCHAR(160) NOT NULL,
  -- 状态只允许 open（待处理）、in_progress（处理中）、closed（已关闭），且不能为空值。
  status ENUM('open','in_progress','closed') NOT NULL,
  -- 优先级只允许 low（低）、medium（中）、high（高），且不能为 NULL。
  priority ENUM('low','medium','high') NOT NULL,
  -- 负责人编号为整数，允许 NULL，表示尚未分配负责人。
  owner_id INT NULL,
  -- 创建时间使用 DATETIME 且不能为 NULL；此类型本身不保存时区信息。
  created_at DATETIME NOT NULL,
  -- 建立外键：非 NULL 的负责人编号必须对应 agents 表中存在的编号。
  CONSTRAINT fk_ticket_owner FOREIGN KEY (owner_id) REFERENCES agents(id),
  -- 建立以 status、priority 为顺序的联合索引；帮助演示执行计划，不保证每次查询都用到它。
  INDEX idx_status_priority (status, priority)
-- 结束建表语句并使用 InnoDB 引擎，本练习依靠它的事务和行锁行为。
) ENGINE=InnoDB;

-- 【仅限实验，写入数据】为人员表指定编号和姓名两列；下面每对括号是一行记录。
INSERT INTO agents (id, name) VALUES
  -- 插入三位虚构支持人员；逗号分隔行，分号结束本次插入。
  (1, 'Alex'), (2, 'Sam'), (3, 'Taylor');

-- 【仅限实验，写入数据】按括号里的字段顺序插入 8 条工单；下面每个括号是一条记录。
INSERT INTO tickets (id, subject, status, priority, owner_id, created_at) VALUES
  -- 工单 1：无法连接数据库，待处理、高优先级，负责人 1，最后一列为示例创建时间。
  (1, 'Cannot connect to database', 'open', 'high', 1, '2026-01-01 09:00:00'),
  -- 工单 2：磁盘占用告警，待处理、高优先级，负责人 2。
  (2, 'Disk usage alert', 'open', 'high', 2, '2026-01-01 09:10:00'),
  -- 工单 3：新账户申请，待处理、中优先级，负责人 3。
  (3, 'New account request', 'open', 'medium', 3, '2026-01-01 09:20:00'),
  -- 工单 4：文档修正，待处理、低优先级；NULL 表示没有分配负责人。
  (4, 'Documentation correction', 'open', 'low', NULL, '2026-01-01 09:30:00'),
  -- 工单 5：内部网站缓慢，处理中、中优先级，负责人 1。
  (5, 'Slow internal website', 'in_progress', 'medium', 1, '2026-01-01 09:40:00'),
  -- 工单 6：打印机离线，已关闭、低优先级，负责人 2。
  (6, 'Printer offline', 'closed', 'low', 2, '2026-01-01 09:50:00'),
  -- 工单 7：备份恢复演练，已关闭、高优先级，负责人 3。
  (7, 'Backup restore drill', 'closed', 'high', 3, '2026-01-01 10:00:00'),
  -- 工单 8：SSH 访问审查，处理中、中优先级，负责人 1；分号结束这次批量插入。
  (8, 'SSH access review', 'in_progress', 'medium', 1, '2026-01-01 10:10:00');
