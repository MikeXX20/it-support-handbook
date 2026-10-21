---
title: "MySQL 实验：工单、事务与锁"
---

# MySQL 实验：工单、事务与锁

使用自己控制的可丢弃 MySQL 实例。初始化会创建 **`it_support_lab`** 并写入示例数据。若数据库已存在，会有意失败，避免覆盖之前的练习。

## 初始化

**仅限实验 — 在仓库根目录运行；根据实验服务器修改主机与端口。**

```bash
mysql --host=127.0.0.1 --port=3306 --user=root --password < labs/mysql-seed.sql
```

中英文版共用 [mysql-seed.sql](../../labs/mysql-seed.sql)，不需要重复导入。用相同连接参数打开交互客户端并选择 `it_support_lab`。不要将真实密码写在命令参数中。这里使用 root 仅为了创建可丢弃练习；工作检查应使用获准的支持账户。

示例字段保留英文：`open` 为待处理，`in_progress` 为处理中，`closed` 为已关闭；`high`、`medium`、`low` 分别表示高、中、低优先级。

## 练习 1：查询工单队列

**观察**

```sql
USE it_support_lab;
SELECT COUNT(*) AS ticket_count FROM tickets;
SELECT id, subject, priority FROM tickets WHERE status = 'open' ORDER BY id;
SELECT priority, COUNT(*) AS open_count
FROM tickets WHERE status = 'open' GROUP BY priority ORDER BY priority;
SELECT t.id, t.subject, a.name AS owner
FROM tickets AS t LEFT JOIN agents AS a ON a.id = t.owner_id ORDER BY t.id;
```

原始数据预期为 **8 条工单、4 条待处理，其中高优先级 2 条、中优先级 1 条、低优先级 1 条**。最后一个查询使用 LEFT JOIN，因此保留未分配负责人记录。试着改写为只返回已分配工单，并解释差异。

## 练习 2：预测回滚结果

**仅限实验 — 事务写入会回滚。**

```sql
START TRANSACTION;
UPDATE tickets SET status = 'closed' WHERE id = 1;
SELECT id, status FROM tickets WHERE id = 1;
ROLLBACK;
SELECT id, status FROM tickets WHERE id = 1;
```

预期：事务内为 `closed`，回滚后恢复为 `open`。执行前先解释另一个连接会看到什么。

## 练习 3：观察行锁等待

在同一实验实例上打开两个交互会话，都选择 `it_support_lab`。

**仅限实验 — 会话 A**

```sql
START TRANSACTION;
UPDATE tickets SET priority = 'medium' WHERE id = 1;
```

保持 A 打开。**仅限实验 — 会话 B**

```sql
SET SESSION innodb_lock_wait_timeout = 30;
START TRANSACTION;
UPDATE tickets SET priority = 'low' WHERE id = 1;
```

B 会等待 A 的行锁。B 等待时，用 A 按[命令指南](../docs/mysql/commands.md)查询 `sys.innodb_lock_waits`。可见性充分时，应能看到等待者与阻塞者。在 A 执行 `ROLLBACK;` 释放锁。B 完成后，也在 B 执行 `ROLLBACK;`。即使 B 超时，仍应显式回滚 B 的事务。

两边回滚完成前保持会话打开。关闭中断的实验会话会使其未提交事务回滚，但回滚完成可能耗时。本练习无需使用 `KILL`。

## 练习 4：查看执行计划

**观察**

```sql
EXPLAIN SELECT id, subject FROM tickets
WHERE status = 'open' AND priority = 'high';
SHOW INDEX FROM tickets;
```

虽然存在 `(status, priority)` 索引，优化器仍可能对这张小表选择全表扫描。解释为什么存在索引不代表必须使用它。不要从 8 行样本推断性能提升。

## 练习 5：恢复并记录

完成[备份演练](../docs/mysql/backup-and-restore.md)，恢复到另一个空数据库并核对示例结果。记录源与目标版本、结果数量、耗时和差异。

需要重置时，创建新实例，或确认名称后有意删除本次练习数据库。种子脚本不包含自动重置或删除命令。

来源：[MySQL 教程](https://dev.mysql.com/doc/refman/8.4/en/tutorial.html)与 [EXPLAIN](https://dev.mysql.com/doc/refman/8.4/en/using-explain.html)。
