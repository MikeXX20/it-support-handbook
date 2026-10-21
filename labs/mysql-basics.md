---
title: "MySQL lab: support tickets, transactions, and locks"
---

# MySQL lab: support tickets, transactions, and locks

Use a disposable MySQL instance you control. The setup creates **`it_support_lab`** and writes sample data. It intentionally fails if that database already exists, rather than overwriting an earlier exercise.

## Setup

**Lab only — from the repository root; adjust the host/port for your disposable server.**

```bash
mysql --host=127.0.0.1 --port=3306 --user=root --password < labs/mysql-seed.sql
```

Open an interactive client using the same connection details and select `it_support_lab`. Keep real passwords out of shell arguments. Root is shown only for creating this disposable exercise; ordinary work checks should use an approved support account.

## Exercise 1 — Query the ticket queue

**Observe**

```sql
USE it_support_lab;
SELECT COUNT(*) AS ticket_count FROM tickets;
SELECT id, subject, priority FROM tickets WHERE status = 'open' ORDER BY id;
SELECT priority, COUNT(*) AS open_count
FROM tickets WHERE status = 'open' GROUP BY priority ORDER BY priority;
SELECT t.id, t.subject, a.name AS owner
FROM tickets AS t LEFT JOIN agents AS a ON a.id = t.owner_id ORDER BY t.id;
```

Expected untouched seed: **8 tickets**, **4 open**, and **2 open high / 1 open medium / 1 open low**. The last query preserves the unassigned ticket because it uses LEFT JOIN. Write an alternative query that returns only assigned tickets and explain the difference.

## Exercise 2 — Predict rollback

**Lab only — transaction writes are rolled back.**

```sql
START TRANSACTION;
UPDATE tickets SET status = 'closed' WHERE id = 1;
SELECT id, status FROM tickets WHERE id = 1;
ROLLBACK;
SELECT id, status FROM tickets WHERE id = 1;
```

Expected: `closed` inside the transaction, then `open` after rollback. Try explaining what another connection sees before running the experiment.

## Exercise 3 — See a row-lock wait

Open two interactive sessions on the same disposable instance. Both use `it_support_lab`.

**Lab only — Session A**

```sql
START TRANSACTION;
UPDATE tickets SET priority = 'medium' WHERE id = 1;
```

Leave A open. **Lab only — Session B**

```sql
SET SESSION innodb_lock_wait_timeout = 30;
START TRANSACTION;
UPDATE tickets SET priority = 'low' WHERE id = 1;
```

B waits for A's row lock. While B waits, use A to query `sys.innodb_lock_waits` as shown in [the command guide](../docs/mysql/commands.md). With sufficient visibility, expect a waiter and a blocker. Run `ROLLBACK;` in A to release its lock. Once B completes, run `ROLLBACK;` in B too. If B times out, still explicitly roll back B's transaction.

Keep both sessions open until each rollback is complete. Closing an interrupted lab session causes its uncommitted transaction to roll back, but rollback completion can take time. No `KILL` is needed for this exercise.

## Exercise 4 — Look at a query plan

**Observe**

```sql
EXPLAIN SELECT id, subject FROM tickets
WHERE status = 'open' AND priority = 'high';
SHOW INDEX FROM tickets;
```

There is an index on `(status, priority)`, but the optimizer can choose a table scan for this tiny table. Explain why an index's existence does not force its use. Do not invent a performance improvement from a sample of eight rows.

## Exercise 5 — Restore and report

Follow [the backup drill](../docs/mysql/backup-and-restore.md), restore into a different empty schema, and verify the sample results. Record source/target versions, result counts, elapsed time, and any differences.

Reset by creating a new disposable instance, or intentionally removing only the exercise schemas after confirming their names. The seed does not contain an automatic reset or deletion command.

Source: [MySQL tutorial](https://dev.mysql.com/doc/refman/8.4/en/tutorial.html) and [EXPLAIN](https://dev.mysql.com/doc/refman/8.4/en/using-explain.html).
