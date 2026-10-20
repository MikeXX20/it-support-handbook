-- OBSERVE ONLY: MySQL 8.4 baseline; verify target and approved privileges first.
-- Use an existing approved connection, e.g. mysql [connection options] < this-file.sql.
-- Some statements require Performance Schema/sys visibility or PROCESS privilege.
-- Results can contain private host, account, schema, or query information.
-- No configuration changes, session termination, table writes, or filesystem writes.

SELECT NOW() AS server_time, @@hostname AS server_host, VERSION() AS server_version;
SELECT USER() AS connection_identity, CURRENT_USER() AS matched_account;

SHOW GLOBAL STATUS WHERE Variable_name IN
  ('Uptime','Threads_connected','Threads_running','Max_used_connections','Aborted_connects');
SHOW GLOBAL VARIABLES WHERE Variable_name IN
  ('max_connections','read_only','super_read_only','performance_schema');

SELECT ID, USER, HOST, DB, COMMAND, TIME, STATE,
       LEFT(INFO,160) AS statement_sample
FROM performance_schema.processlist
ORDER BY TIME DESC LIMIT 20;

SELECT trx_id, trx_state, trx_started, trx_mysql_thread_id,
       trx_rows_locked, trx_rows_modified
FROM information_schema.innodb_trx
ORDER BY trx_started LIMIT 20;

SELECT waiting_pid, blocking_pid, wait_age, locked_table,
       LEFT(waiting_query,160) AS waiting_statement
FROM sys.innodb_lock_waits
LIMIT 20;

SELECT object_schema, object_name, waiting_pid, blocking_pid,
       waiting_query_secs, LEFT(waiting_query,160) AS waiting_statement
FROM sys.schema_table_lock_waits
LIMIT 20;

SELECT SCHEMA_NAME, LEFT(DIGEST_TEXT,160) AS statement_pattern,
       COUNT_STAR AS executions,
       ROUND(SUM_TIMER_WAIT / 1000000000000,2) AS total_seconds,
       SUM_ROWS_EXAMINED, SUM_ROWS_SENT
FROM performance_schema.events_statements_summary_by_digest
WHERE SCHEMA_NAME IS NOT NULL
ORDER BY SUM_TIMER_WAIT DESC LIMIT 10;
