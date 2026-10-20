# MySQL command reference

Baseline: MySQL 8.4. Confirm `VERSION()` and privileges first; managed services, older MySQL releases, and MariaDB can differ. The checks below are **Observe** operations, but metadata queries still have a cost and may disclose query text.

## Connect deliberately

**Shell — remote work example; replace every connection value with the approved one.**

```bash
mysql --host=db.example.com --port=3306 --user=support --password \
  --connect-timeout=5 --ssl-mode=VERIFY_IDENTITY --ssl-ca=/path/to/ca.pem
```

`--password` prompts; do not append a real password to the command. Use the approved CA and hostname. Local socket access is a different connection path from TCP; use `--protocol=TCP` when specifically testing TCP. In the MySQL client, `\s` displays session/connection information.

Use an approved support account with the minimum required visibility. `SHOW GRANTS;` shows its grants; do not automatically grant more access after a diagnostic query is denied.

## Identity, connections, and limits

```sql
SELECT NOW(), @@hostname, VERSION(), @@port;
SELECT USER() AS connection_identity, CURRENT_USER() AS matched_account;
SHOW GRANTS;
SHOW GLOBAL STATUS WHERE Variable_name IN
  ('Uptime','Threads_connected','Threads_running','Max_used_connections','Aborted_connects');
SHOW GLOBAL VARIABLES WHERE Variable_name IN
  ('max_connections','read_only','super_read_only','performance_schema');
```

`USER()` describes the client-supplied identity and origin; `CURRENT_USER()` identifies the account matched for authentication. Compare connected sessions with configured capacity and the application pool. `Max_used_connections` is a high-water value, not the current number.

Counters cover a period of server activity and can reset. Record two samples and elapsed time to identify a trend. A server configured read-only may still have privileged exceptions; these variables are context, not a complete authorization check.

## Sessions and transactions

```sql
SELECT ID, USER, HOST, DB, COMMAND, TIME, STATE, LEFT(INFO,160) AS statement_sample
FROM performance_schema.processlist
ORDER BY TIME DESC LIMIT 20;

SELECT trx_id, trx_state, trx_started, trx_mysql_thread_id,
       trx_rows_locked, trx_rows_modified, LEFT(trx_query,160) AS statement_sample
FROM information_schema.innodb_trx
ORDER BY trx_started LIMIT 20;
```

Full session visibility depends on permissions and Performance Schema configuration. `TIME` measures the time in the current state, not universally the statement's total lifetime. An idle connection may have an open transaction; inspect transaction state before deciding it is harmless or terminating it.

## Row locks versus metadata locks

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

The first view concerns InnoDB row-lock waits; the second helps investigate metadata locks such as DDL waiting for a transaction. `sys` views depend on underlying instrumentation and access. An empty result is not proof of no locking if visibility is incomplete. Identify the owning application before any session termination; rollback may itself take time.

## Expensive statement patterns

```sql
SELECT SCHEMA_NAME, LEFT(DIGEST_TEXT,160) AS statement_pattern,
       COUNT_STAR AS executions,
       ROUND(SUM_TIMER_WAIT / 1000000000000,2) AS total_seconds,
       SUM_ROWS_EXAMINED, SUM_ROWS_SENT
FROM performance_schema.events_statements_summary_by_digest
WHERE SCHEMA_NAME IS NOT NULL
ORDER BY SUM_TIMER_WAIT DESC LIMIT 10;
```

These are cumulative patterns, not individual requests from a particular minute. Compare samples with the incident window and the workload. Normalized statements can still reveal private schema or business information.

For a known query, start with ordinary `EXPLAIN SELECT ...` after selecting the correct schema. `EXPLAIN ANALYZE` executes the statement being analyzed; use it only when that workload is authorized. Do not run it against an unknown expensive production query just to gather a plan.

## Storage estimate

```sql
SELECT table_schema,
       ROUND(SUM(data_length + index_length)/1024/1024,1) AS estimated_mb
FROM information_schema.tables
WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
GROUP BY table_schema
ORDER BY estimated_mb DESC LIMIT 20;
```

These are metadata estimates. They do not account for every filesystem consumer, including logs and shared storage structures. Large catalogs can make metadata scans expensive. Compare with host or managed-service storage metrics.

The reusable [SQL checklist](../../sql/mysql-health-check.sql) collects a subset of these checks. It can stop on a permission error; do not use `--force` to disguise failures.

Sources: [client options](https://dev.mysql.com/doc/refman/8.4/en/mysql-command-options.html), [connection verification](https://dev.mysql.com/doc/refman/8.4/en/connection-access.html), [SHOW STATUS](https://dev.mysql.com/doc/refman/8.4/en/show-status.html), [processlist](https://dev.mysql.com/doc/refman/8.4/en/performance-schema-processlist-table.html), [row-lock waits](https://dev.mysql.com/doc/refman/8.4/en/sys-innodb-lock-waits.html), [metadata-lock waits](https://dev.mysql.com/doc/refman/8.4/en/sys-schema-table-lock-waits.html), [EXPLAIN overview](https://dev.mysql.com/doc/refman/8.4/en/using-explain.html), and [EXPLAIN ANALYZE behavior](https://dev.mysql.com/doc/refman/8.4/en/explain.html).
