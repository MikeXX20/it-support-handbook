---
title: "MySQL troubleshooting"
---

# MySQL troubleshooting

Start with the exact error, target host/port, connection method, server version, incident time, and application impact. Check [connection and SQL references](commands.md) before applying changes.

| Symptom | First distinction | Useful next check |
| --- | --- | --- |
| `ERROR 2002` local connection failure | Socket path, service state, or local transport | Compare the configured socket and an intentional TCP test |
| `ERROR 2003` cannot connect to server | Target, listener, transport path | Check DNS, route, listening address, and port |
| `ERROR 1045` access denied | Account matching/authentication | Verify user, origin, authentication method, credential source, and TLS requirements |
| `ERROR 1044` database access denied | Connected account lacks required access | Compare matched account and approved grants |
| `ERROR 1040` too many connections | Connection capacity exhausted | Compare current sessions, running work, application pools, and server limit |
| `ERROR 1205` lock wait timeout | Blocking or other lock wait needs investigation | Identify waiters/blockers and transaction age |
| `ERROR 1213` deadlock | Conflicting transaction ordering | Capture relevant deadlock evidence and application retry behavior |
| Slow response without a connection error | Query, lock, resource, or network latency | Correlate application timing, server workload, plans, and host metrics |

The error code narrows the search; it is not a complete root-cause diagnosis.

## Cannot connect

Confirm the application's actual target, port, and transport. A local Unix socket connection and a TCP connection can behave differently. On self-managed Linux, confirm whether the service unit is `mysql`, `mysqld`, or another name. On a managed service, use its status/metrics and network controls instead of assuming shell access.

Use [network troubleshooting](../linux/networking.md) to test each layer. If transport works but authentication fails, check the matched account and configuration with an authorized administrator. Do not resolve an account mismatch by opening access to every host or disabling TLS checks.

## Too many connections

Compare `Threads_connected`, `Threads_running`, `Max_used_connections`, and `max_connections`. Inspect session age and app connection-pool configuration. Look for connection leaks, an unusual deployment/retry surge, or sessions blocked by long transactions.

Raising the server limit can increase memory pressure and hide a pool problem. Capture the evidence and involve the app/database owner before changing capacity or ending sessions.

## Query is slow or blocked

1. Identify a specific affected request and its time window.
2. Check active sessions and long InnoDB transactions.
3. Distinguish row-lock waits from metadata-lock waits using the two `sys` views.
4. Compare statement digest totals over an interval; do not assume the highest lifetime total caused this incident.
5. Review ordinary `EXPLAIN` for the known query and representative parameters. A table scan can be correct for a small table.
6. Compare CPU, available memory, I/O, storage capacity, and app/network timing.

With sufficient privileges, `SHOW ENGINE INNODB STATUS\G` can reveal the latest detected deadlock and other engine information. It is a snapshot, may contain sensitive statements, and may no longer describe the incident you are investigating.

If a transaction owns a blocker, determine its business operation and rollback consequences. Never copy an automatically generated `KILL` recommendation into production without that decision.

## Data recovery request

Establish the recovery point and acceptable downtime. Verify backup coverage and restore in an isolated target before changing the real database. Follow [backup and restore](backup-and-restore.md), and involve the service owner if a live restore or point-in-time recovery is needed.

Escalate with [a short incident record](../../templates/incident.md), including what is known, what is still uncertain, and the next requested action.

Sources: [MySQL connection verification](https://dev.mysql.com/doc/refman/8.4/en/connection-access.html), [processlist](https://dev.mysql.com/doc/refman/8.4/en/performance-schema-processlist-table.html), [lock waits](https://dev.mysql.com/doc/refman/8.4/en/sys-innodb-lock-waits.html), and [EXPLAIN](https://dev.mysql.com/doc/refman/8.4/en/using-explain.html).
