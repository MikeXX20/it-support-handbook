---
title: "Four-week learning path"
---

# Four-week learning path

Use 30–45 minutes per session, four sessions a week. Progress by demonstrating a task and explaining the evidence, not by memorizing command flags.

## Week 1 — Linux foundations

- Identify distribution, user/groups, filesystem layout, and mount points.
- Explain file versus directory permissions and test them in [the Linux lab](../labs/linux-basics.md).
- Read CPU, available memory, load, disk-byte, and inode observations.
- Find a service's status and a bounded journal excerpt.

**Checkpoint:** explain “disk space available but cannot create a file” using both inode and permission hypotheses. Show which observations distinguish them.

## Week 2 — Networks and support practice

- Trace a request from DNS to route, TCP port, TLS, and application response.
- Explain why ping success does not prove a website or database works.
- Compare a failing case with a known-good case without changing both at once.
- Write an incident ticket with impact, timeline, evidence, hypothesis, and next action.

**Checkpoint:** diagnose a simulated connection failure with [the networking guide](../docs/linux/networking.md) and produce [a handover](../templates/incident.md).

## Week 3 — MySQL and SQL basics

- Identify the server, connection method, authenticated account, and database.
- Practice SELECT, WHERE, ORDER BY, LIMIT, GROUP BY, and JOIN in [the MySQL lab](../labs/mysql-basics.md).
- Explain transaction commit/rollback and why an open transaction can block another session.
- Inspect ordinary EXPLAIN and relate a predicate to an index.

**Checkpoint:** return open tickets grouped by priority, join each ticket to its owner, and explain a lock wait using two sessions.

## Week 4 — Practical database operations

- Collect a small health snapshot and separate cumulative counters from current work.
- Distinguish authentication, connection capacity, row locks, and metadata locks.
- Complete [the backup/restore drill](../docs/mysql/backup-and-restore.md) in a disposable database.
- Write one original runbook with a symptom, evidence, interpretation, next step, and verification.

**Checkpoint:** demonstrate a successful restore and explain its RPO/RTO limitations. Present a concise escalation packet for a slow-query incident.

## Keep a learning log

For each exercise record: prediction, command/query, observed result, explanation, and what you would check next. Keep real work evidence private. Revisit one exercise a week without looking at the answer first.

## Self-check questions

1. How are load average and CPU utilization different?
2. Why can `df` and `du` disagree?
3. What would make `getent` and `dig` disagree?
4. What does an accepted TCP connection prove, and what remains untested?
5. How do MySQL `USER()` and `CURRENT_USER()` differ?
6. How could a sleeping MySQL session still affect another request?
7. Why is a lifetime statement total insufficient to diagnose one slow minute?
8. What must be verified before treating a dump as a usable backup?

Use the linked guides to explain an answer and design a small test for it.
