---
title: "MySQL 实验：工单、事务与锁"
---

# MySQL 实验：工单、事务与锁

代码阅读：`#` 开头是 Shell 注释，`--` 开头是 SQL 注释，无需单独输入。Bash 代码在 Linux 终端执行，SQL 在已连接的 MySQL 客户端执行。按章节说明阅读，先替换示例目标；标有“实验”的写操作仅在练习环境运行。

使用自己控制的可丢弃 MySQL 实例。初始化会创建 **`it_support_lab`** 并写入示例数据。若数据库已存在，会有意失败，避免覆盖之前的练习。

## 初始化

**仅限实验 — 在仓库根目录运行；根据实验服务器修改主机与端口。**

```bash
# 在仓库根目录执行：连接本地实验实例，读取 labs/mysql-seed.sql 来创建练习库及示例表。
# < 表示从文件读取 SQL；该命令会写数据，仅用于可丢弃实例，数据库已存在时不要加 --force 强行继续。
mysql --host=127.0.0.1 --port=3306 --user=root --password < labs/mysql-seed.sql
```

中英文版共用 [mysql-seed.sql](../../labs/mysql-seed.sql)，不需要重复导入。用相同连接参数打开交互客户端并选择 `it_support_lab`。不要将真实密码写在命令参数中。这里使用 root 仅为了创建可丢弃练习；工作检查应使用获准的支持账户。

示例字段保留英文：`open` 为待处理，`in_progress` 为处理中，`closed` 为已关闭；`high`、`medium`、`low` 分别表示高、中、低优先级。

## 练习 1：查询工单队列

**观察**

```sql
-- 选择练习数据库；后续不带库名前缀的表名会在此库中查找。
USE it_support_lab;
-- 统计工单表行数，并把结果列命名为 ticket_count；原始种子数据预期为 8。
SELECT COUNT(*) AS ticket_count FROM tickets;
-- 查询待处理工单的编号、主题与优先级，按编号升序；WHERE 筛选，不会删除其他记录。
SELECT id, subject, priority FROM tickets WHERE status = 'open' ORDER BY id;
-- 准备返回优先级和每组工单数；AS open_count 给统计列命名。
SELECT priority, COUNT(*) AS open_count
-- 从工单表仅取 open 记录，按优先级分组计数，再排序；原始数据为 high 2、medium 1、low 1。
FROM tickets WHERE status = 'open' GROUP BY priority ORDER BY priority;
-- 选择工单编号、主题与负责人姓名；t、a 是下一行定义的表别名。
SELECT t.id, t.subject, a.name AS owner
-- 按负责人 ID 关联工单和人员表；LEFT JOIN 保留无人负责的工单，负责人列此时为 NULL，最后按工单编号排序。
FROM tickets AS t LEFT JOIN agents AS a ON a.id = t.owner_id ORDER BY t.id;
```

原始数据预期为 **8 条工单、4 条待处理，其中高优先级 2 条、中优先级 1 条、低优先级 1 条**。最后一个查询使用 LEFT JOIN，因此保留未分配负责人记录。试着改写为只返回已分配工单，并解释差异。

## 练习 2：预测回滚结果

**仅限实验 — 事务写入会回滚。**

```sql
-- 开始事务；后面的修改先不提交，实验结束必须在当前会话执行 ROLLBACK 回滚。
START TRANSACTION;
-- 【修改实验数据】仅把编号 1 的工单状态改为 closed；WHERE 限定目标，不能省略。
UPDATE tickets SET status = 'closed' WHERE id = 1;
-- 读取编号 1 的工单状态；在当前事务修改后应为 closed，回滚后应恢复 open。
SELECT id, status FROM tickets WHERE id = 1;
-- 回滚当前会话未提交的事务修改并释放相关锁；本实验用它恢复原始状态。
ROLLBACK;
-- 读取编号 1 的工单状态；在当前事务修改后应为 closed，回滚后应恢复 open。
SELECT id, status FROM tickets WHERE id = 1;
```

预期：事务内为 `closed`，回滚后恢复为 `open`。执行前先解释另一个连接会看到什么。

## 练习 3：观察行锁等待

在同一实验实例上打开两个交互会话，都选择 `it_support_lab`。

**仅限实验 — 会话 A**

```sql
-- 开始事务；后面的修改先不提交，实验结束必须在当前会话执行 ROLLBACK 回滚。
START TRANSACTION;
-- 【会话 A 修改实验数据】将工单 1 的优先级改为 medium，事务未结束时持有相关行锁。
UPDATE tickets SET priority = 'medium' WHERE id = 1;
```

保持 A 打开。**仅限实验 — 会话 B**

```sql
-- 【修改当前实验会话】把 InnoDB 行锁等待超时设为 30 秒；SESSION 只影响当前连接。
SET SESSION innodb_lock_wait_timeout = 30;
-- 开始事务；后面的修改先不提交，实验结束必须在当前会话执行 ROLLBACK 回滚。
START TRANSACTION;
-- 【会话 B 修改实验数据】尝试改同一行；会话 A 未释放行锁时会等待，最终仍需回滚 B。
UPDATE tickets SET priority = 'low' WHERE id = 1;
```

B 会等待 A 的行锁。B 等待时，用 A 按[命令指南](../docs/mysql/commands.md)查询 `sys.innodb_lock_waits`。可见性充分时，应能看到等待者与阻塞者。在 A 执行 `ROLLBACK;` 释放锁。B 完成后，也在 B 执行 `ROLLBACK;`。即使 B 超时，仍应显式回滚 B 的事务。

两边回滚完成前保持会话打开。关闭中断的实验会话会使其未提交事务回滚，但回滚完成可能耗时。本练习无需使用 `KILL`。

## 练习 4：查看执行计划

**观察**

```sql
-- 查看这条 SELECT 的预估执行计划，不是执行查询并测量实际耗时；下一行仍是此 SQL 的一部分。
EXPLAIN SELECT id, subject FROM tickets
-- 只考虑同时为待处理和高优先级的记录；AND 要求两个条件都满足，分号结束 EXPLAIN。
WHERE status = 'open' AND priority = 'high';
-- 查看工单表已有索引；存在索引不代表优化器一定选择它，小表可能使用全表扫描。
SHOW INDEX FROM tickets;
```

虽然存在 `(status, priority)` 索引，优化器仍可能对这张小表选择全表扫描。解释为什么存在索引不代表必须使用它。不要从 8 行样本推断性能提升。

## 练习 5：恢复并记录

完成[备份演练](../docs/mysql/backup-and-restore.md)，恢复到另一个空数据库并核对示例结果。记录源与目标版本、结果数量、耗时和差异。

需要重置时，创建新实例，或确认名称后有意删除本次练习数据库。种子脚本不包含自动重置或删除命令。

来源：[MySQL 教程](https://dev.mysql.com/doc/refman/8.4/en/tutorial.html)与 [EXPLAIN](https://dev.mysql.com/doc/refman/8.4/en/using-explain.html)。
