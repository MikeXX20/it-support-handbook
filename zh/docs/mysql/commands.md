---
title: "MySQL 命令速查"
---

# MySQL 命令速查

基准为 MySQL 8.4。先确认 `VERSION()` 和权限；托管服务、旧版 MySQL 与 MariaDB 可能不同。以下为**观察**操作，但元数据查询仍有开销，也可能暴露查询内容。

## 明确连接方式

**Shell — 远程工作示例；将所有连接参数替换为获准的值。**

```bash
mysql --host=db.example.com --port=3306 --user=support --password \
  --connect-timeout=5 --ssl-mode=VERIFY_IDENTITY --ssl-ca=/path/to/ca.pem
```

`--password` 会提示输入密码，不要把真实密码直接附在命令后。使用认可的 CA 和主机名。本地套接字与 TCP 是不同的连接路径；专门测试 TCP 时使用 `--protocol=TCP`。MySQL 客户端内的 `\s` 可显示会话与连接信息。

使用团队认可、仅具备必要可见性的支持账户。`SHOW GRANTS;` 展示账户权限；诊断查询被拒绝时，不要自动增加权限。

## 身份、连接与限制

```sql
SELECT NOW(), @@hostname, VERSION(), @@port;
SELECT USER() AS connection_identity, CURRENT_USER() AS matched_account;
SHOW GRANTS;
SHOW GLOBAL STATUS WHERE Variable_name IN
  ('Uptime','Threads_connected','Threads_running','Max_used_connections','Aborted_connects');
SHOW GLOBAL VARIABLES WHERE Variable_name IN
  ('max_connections','read_only','super_read_only','performance_schema');
```

`USER()` 描述客户端提供的身份和来源，`CURRENT_USER()` 表示身份验证实际匹配的账户。对比已连接会话数、配置容量与应用连接池。`Max_used_connections` 是历史峰值，不是当前连接数。

计数器覆盖一段服务器运行时间，也可能被重置。记录两次采样及时间间隔以判断趋势。只读配置可能仍允许特权账户写入；这些变量提供上下文，并非完整权限检查。

## 会话与事务

```sql
SELECT ID, USER, HOST, DB, COMMAND, TIME, STATE, LEFT(INFO,160) AS statement_sample
FROM performance_schema.processlist
ORDER BY TIME DESC LIMIT 20;

SELECT trx_id, trx_state, trx_started, trx_mysql_thread_id,
       trx_rows_locked, trx_rows_modified, LEFT(trx_query,160) AS statement_sample
FROM information_schema.innodb_trx
ORDER BY trx_started LIMIT 20;
```

完整会话可见性取决于权限和 Performance Schema 配置。`TIME` 是处于当前状态的时长，不一定是语句的总生命周期。空闲连接也可能持有未结束的事务；判断无害或终止会话前，应检查事务状态。

## 行锁与元数据锁

```sql
SELECT waiting_pid, blocking_pid, wait_age, locked_table,
       LEFT(waiting_query,160) AS waiting_statement
FROM sys.innodb_lock_waits
LIMIT 20;

SELECT object_schema, object_name, waiting_pid, blocking_pid,
       waiting_query_secs, LEFT(waiting_query,160) AS waiting_statement
FROM sys.schema_table_lock_waits
LIMIT 20;
```

第一个视图用于 InnoDB 行锁等待，第二个辅助排查元数据锁，例如 DDL 等待某个事务。`sys` 视图依赖底层采集与访问权限。可见性不足时，空结果不能证明没有锁等待。结束任何会话前确认所属应用；回滚本身也可能耗时。

## 开销较大的语句模式

```sql
SELECT SCHEMA_NAME, LEFT(DIGEST_TEXT,160) AS statement_pattern,
       COUNT_STAR AS executions,
       ROUND(SUM_TIMER_WAIT / 1000000000000,2) AS total_seconds,
       SUM_ROWS_EXAMINED, SUM_ROWS_SENT
FROM performance_schema.events_statements_summary_by_digest
WHERE SCHEMA_NAME IS NOT NULL
ORDER BY SUM_TIMER_WAIT DESC LIMIT 10;
```

这些是累计语句模式，不是特定一分钟内的独立请求。结合事件时间窗口和工作负载比较采样。规范化语句仍可能泄露私有表结构或业务信息。

已知查询应先选择正确数据库，再使用普通 `EXPLAIN SELECT ...`。`EXPLAIN ANALYZE` 会实际执行被分析语句，只有该负载获得授权时才能使用。不要为了获取执行计划而在生产环境执行未知的昂贵查询。

## 存储估算

```sql
SELECT table_schema,
       ROUND(SUM(data_length + index_length)/1024/1024,1) AS estimated_mb
FROM information_schema.tables
WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
GROUP BY table_schema
ORDER BY estimated_mb DESC LIMIT 20;
```

这里是元数据估算，无法覆盖日志、共享存储结构等所有磁盘占用。大型目录上的元数据扫描可能昂贵，应与主机或托管服务的存储指标对比。

可复用的 [SQL 检查清单](../../../sql/mysql-health-check.sql)汇总了其中一部分检查。遇到权限错误时可能停止，不要使用 `--force` 掩盖失败。

来源：[客户端参数](https://dev.mysql.com/doc/refman/8.4/en/mysql-command-options.html)、[连接验证](https://dev.mysql.com/doc/refman/8.4/en/connection-access.html)、[SHOW STATUS](https://dev.mysql.com/doc/refman/8.4/en/show-status.html)、[processlist](https://dev.mysql.com/doc/refman/8.4/en/performance-schema-processlist-table.html)、[行锁等待](https://dev.mysql.com/doc/refman/8.4/en/sys-innodb-lock-waits.html)、[元数据锁等待](https://dev.mysql.com/doc/refman/8.4/en/sys-schema-table-lock-waits.html)、[EXPLAIN 概览](https://dev.mysql.com/doc/refman/8.4/en/using-explain.html)与 [EXPLAIN ANALYZE 行为](https://dev.mysql.com/doc/refman/8.4/en/explain.html)。
