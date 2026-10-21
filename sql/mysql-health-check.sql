-- OBSERVE ONLY: MySQL 8.4 baseline; verify target and approved privileges first.
-- Use an existing approved connection, e.g. mysql [connection options] < this-file.sql.
-- Some statements require Performance Schema/sys visibility or PROCESS privilege.
-- Results can contain private host, account, schema, or query information.
-- No configuration changes, session termination, table writes, or filesystem writes.

-- 查询服务器当前时间、主机名与版本；AS 后面是显示用的列名，先确认连对了服务器。
SELECT NOW() AS server_time, @@hostname AS server_host, VERSION() AS server_version;
-- USER() 是客户端提供的用户与来源，CURRENT_USER() 是实际匹配的认证账户，两者可能不同。
SELECT USER() AS connection_identity, CURRENT_USER() AS matched_account;

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

-- 先选择会话 ID、用户、来源、数据库、命令、当前状态持续秒数与状态；逗号表示字段列表还没结束。
SELECT ID, USER, HOST, DB, COMMAND, TIME, STATE,
       -- 把当前语句截到前 160 个字符并命名为 statement_sample；结果仍可能有敏感内容。
       LEFT(INFO,160) AS statement_sample
-- 从 Performance Schema 的会话列表读取；可见范围取决于权限和采集配置。
FROM performance_schema.processlist
-- 按当前状态持续时间降序排列，只取最多 20 条；DESC 为从大到小，TIME 不一定是整个请求耗时。
ORDER BY TIME DESC LIMIT 20;

-- 选择事务 ID、状态、开始时间及所属 MySQL 会话 ID，便于关联事务和连接。
SELECT trx_id, trx_state, trx_started, trx_mysql_thread_id,
       -- 继续选择事务锁定行数与已修改行数；这些字段辅助判断事务影响范围。
       trx_rows_locked, trx_rows_modified
-- 从 InnoDB 事务信息中读取当前事务；没有足够权限时可能无法完整查看。
FROM information_schema.innodb_trx
-- 按开始时间升序，先列最早开始的事务；最多 20 条，未写 ASC 时默认升序。
ORDER BY trx_started LIMIT 20;

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
