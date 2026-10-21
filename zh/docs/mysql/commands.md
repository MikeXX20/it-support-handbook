---
title: "MySQL 命令速查"
---

# MySQL 命令速查

代码阅读：`#` 开头是 Shell 注释，`--` 开头是 SQL 注释，无需单独输入。Bash 代码在 Linux 终端执行，SQL 在已连接的 MySQL 客户端执行。按章节说明阅读，先替换示例目标；标有“实验”的写操作仅在练习环境运行。

基准为 MySQL 8.4。先确认 `VERSION()` 和权限；托管服务、旧版 MySQL 与 MariaDB 可能不同。以下为**观察**操作，但元数据查询仍有开销，也可能暴露查询内容。

## 明确连接方式

**Shell — 远程工作示例；将所有连接参数替换为获准的值。**

```bash
# 启动 mysql 客户端；指定主机、端口及支持账户，--password 提示输入密码；示例值须替换。
# 行尾反斜杠表示接下一行，不要删除它，也不要在它后面加注释。
# 续行参数：连接超时 5 秒；校验证书及主机名；使用指定 CA 文件。CA 路径须替换。
mysql --host=db.example.com --port=3306 --user=support --password \
  --connect-timeout=5 --ssl-mode=VERIFY_IDENTITY --ssl-ca=/path/to/ca.pem
```

`--password` 会提示输入密码，不要把真实密码直接附在命令后。使用认可的 CA 和主机名。本地套接字与 TCP 是不同的连接路径；专门测试 TCP 时使用 `--protocol=TCP`。MySQL 客户端内的 `\s` 可显示会话与连接信息。

使用团队认可、仅具备必要可见性的支持账户。`SHOW GRANTS;` 展示账户权限；诊断查询被拒绝时，不要自动增加权限。

## 身份、连接与限制

```sql
-- 查看服务器时间、主机、版本和监听端口；@@ 用于读取系统变量。
SELECT NOW(), @@hostname, VERSION(), @@port;
-- USER() 是客户端提供的用户与来源，CURRENT_USER() 是实际匹配的认证账户，两者可能不同。
SELECT USER() AS connection_identity, CURRENT_USER() AS matched_account;
-- 显示当前账户的授权，确认有哪些访问权限；此语句不会新增权限。
SHOW GRANTS;
-- 读取服务器级运行状态；WHERE ... IN 只保留下一行列出的指标。
SHOW GLOBAL STATUS WHERE Variable_name IN
  -- 列表中的指标分别表示运行秒数、当前连接数、非睡眠线程数、历史最高连接数、失败连接尝试数。
  -- 分号结束本条 SQL；累计值需间隔采样才能判断当前变化。
  ('Uptime','Threads_connected','Threads_running','Max_used_connections','Aborted_connects');
-- 读取服务器级配置值，并用下一行的名称列表筛选；只读取，不修改配置。
SHOW GLOBAL VARIABLES WHERE Variable_name IN
  -- 列表中的配置分别表示连接上限、只读设置、更严格的只读设置，以及是否启用 Performance Schema。
  -- 只读设置有权限例外，不能单靠它们判断某个账户一定无法写入。
  ('max_connections','read_only','super_read_only','performance_schema');
```

`USER()` 描述客户端提供的身份和来源，`CURRENT_USER()` 表示身份验证实际匹配的账户。对比已连接会话数、配置容量与应用连接池。`Max_used_connections` 是历史峰值，不是当前连接数。

计数器覆盖一段服务器运行时间，也可能被重置。记录两次采样及时间间隔以判断趋势。只读配置可能仍允许特权账户写入；这些变量提供上下文，并非完整权限检查。

## 会话与事务

```sql
-- 选择会话 ID、用户、来源、数据库、命令、当前状态时长和状态；LEFT(INFO,160) 仅截取语句前 160 个字符。
SELECT ID, USER, HOST, DB, COMMAND, TIME, STATE, LEFT(INFO,160) AS statement_sample
-- 从 Performance Schema 的会话列表读取；可见范围取决于权限和采集配置。
FROM performance_schema.processlist
-- 按当前状态持续时间降序排列，只取最多 20 条；DESC 为从大到小，TIME 不一定是整个请求耗时。
ORDER BY TIME DESC LIMIT 20;

-- 选择事务 ID、状态、开始时间及所属 MySQL 会话 ID，便于关联事务和连接。
SELECT trx_id, trx_state, trx_started, trx_mysql_thread_id,
       -- 继续选择锁定行数、已修改行数及截短的当前事务语句；空闲事务也可能持有锁。
       trx_rows_locked, trx_rows_modified, LEFT(trx_query,160) AS statement_sample
-- 从 InnoDB 事务信息中读取当前事务；没有足够权限时可能无法完整查看。
FROM information_schema.innodb_trx
-- 按开始时间升序，先列最早开始的事务；最多 20 条，未写 ASC 时默认升序。
ORDER BY trx_started LIMIT 20;
```

完整会话可见性取决于权限和 Performance Schema 配置。`TIME` 是处于当前状态的时长，不一定是语句的总生命周期。空闲连接也可能持有未结束的事务；判断无害或终止会话前，应检查事务状态。

## 行锁与元数据锁

```sql
-- 选择等待会话 ID、阻塞会话 ID、等待时长与被锁的表；先区分谁在等、谁在阻塞。
SELECT waiting_pid, blocking_pid, wait_age, locked_table,
       -- 截取等待语句前 160 个字符，便于定位受影响操作；分享前仍需脱敏。
       LEFT(waiting_query,160) AS waiting_statement
-- 从 sys 的 InnoDB 行锁等待视图读取；空结果不能排除可见性不足。
FROM sys.innodb_lock_waits
-- 只返回最多 20 条，避免一次输出过多；没有 ORDER BY 时不保证行的顺序。
LIMIT 20;

-- 选择数据库、表名、等待和阻塞会话 ID，用于定位元数据锁等待。
SELECT object_schema, object_name, waiting_pid, blocking_pid,
       -- 继续选择等待查询的耗时秒数和截短语句；元数据锁等待不同于普通行锁等待。
       waiting_query_secs, LEFT(waiting_query,160) AS waiting_statement
-- 读取表的元数据锁等待视图，常用于排查 DDL 等待事务等情况。
FROM sys.schema_table_lock_waits
-- 只返回最多 20 条，避免一次输出过多；没有 ORDER BY 时不保证行的顺序。
LIMIT 20;
```

第一个视图用于 InnoDB 行锁等待，第二个辅助排查元数据锁，例如 DDL 等待某个事务。`sys` 视图依赖底层采集与访问权限。可见性不足时，空结果不能证明没有锁等待。结束任何会话前确认所属应用；回滚本身也可能耗时。

## 开销较大的语句模式

```sql
-- 选择数据库名和截短的规范化语句模式；这里聚合的是相似语句，不是某一次请求。
SELECT SCHEMA_NAME, LEFT(DIGEST_TEXT,160) AS statement_pattern,
       -- 读取该语句模式累计执行次数，并把结果列命名为 executions。
       COUNT_STAR AS executions,
       -- 将累计耗时从皮秒换算为秒，再保留两位小数；这是累计时间，不是单次延迟。
       ROUND(SUM_TIMER_WAIT / 1000000000000,2) AS total_seconds,
       -- 读取累计检查行数与返回行数；结合时间窗口比较，不能仅凭总量判断本次故障。
       SUM_ROWS_EXAMINED, SUM_ROWS_SENT
-- 从按语句摘要汇总的 Performance Schema 表读取累计统计。
FROM performance_schema.events_statements_summary_by_digest
-- 只保留有关联数据库名的记录；IS NOT NULL 表示该字段不是 SQL 空值。
WHERE SCHEMA_NAME IS NOT NULL
-- 按累计总耗时从高到低，最多取 10 个语句模式；累计最高不等于当前事件的根因。
ORDER BY SUM_TIMER_WAIT DESC LIMIT 10;
```

这些是累计语句模式，不是特定一分钟内的独立请求。结合事件时间窗口和工作负载比较采样。规范化语句仍可能泄露私有表结构或业务信息。

已知查询应先选择正确数据库，再使用普通 `EXPLAIN SELECT ...`。`EXPLAIN ANALYZE` 会实际执行被分析语句，只有该负载获得授权时才能使用。不要为了获取执行计划而在生产环境执行未知的昂贵查询。

## 存储估算

```sql
-- 选择表所属数据库名；下面继续计算该数据库的估算容量。
SELECT table_schema,
       -- 相加数据与索引长度，汇总后换算为 MiB（1024² 字节）并保留一位小数；列名为 estimated_mb。
       ROUND(SUM(data_length + index_length)/1024/1024,1) AS estimated_mb
-- 从表的元数据读取容量估算；不是对磁盘上所有文件的完整统计。
FROM information_schema.tables
-- 排除四个系统数据库，保留其他数据库；NOT IN 表示不在给定名单中。
WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
-- 按数据库名分组，使 SUM 为每个数据库分别汇总。
GROUP BY table_schema
-- 按容量估算从大到小排列，最多 20 个数据库；日志等文件还需另查。
ORDER BY estimated_mb DESC LIMIT 20;
```

这里是元数据估算，无法覆盖日志、共享存储结构等所有磁盘占用。大型目录上的元数据扫描可能昂贵，应与主机或托管服务的存储指标对比。

可复用的 [SQL 检查清单](../../../sql/mysql-health-check.sql)汇总了其中一部分检查。遇到权限错误时可能停止，不要使用 `--force` 掩盖失败。

来源：[客户端参数](https://dev.mysql.com/doc/refman/8.4/en/mysql-command-options.html)、[连接验证](https://dev.mysql.com/doc/refman/8.4/en/connection-access.html)、[SHOW STATUS](https://dev.mysql.com/doc/refman/8.4/en/show-status.html)、[processlist](https://dev.mysql.com/doc/refman/8.4/en/performance-schema-processlist-table.html)、[行锁等待](https://dev.mysql.com/doc/refman/8.4/en/sys-innodb-lock-waits.html)、[元数据锁等待](https://dev.mysql.com/doc/refman/8.4/en/sys-schema-table-lock-waits.html)、[EXPLAIN 概览](https://dev.mysql.com/doc/refman/8.4/en/using-explain.html)与 [EXPLAIN ANALYZE 行为](https://dev.mysql.com/doc/refman/8.4/en/explain.html)。
