# Five-minute quick check

Start a ticket with the target host/service, impact, time and timezone, exact symptom, and most recent known change. Use [the incident template](../templates/incident.md).

## Linux: first observations

**Observe — run the checks relevant to the symptom, not every command blindly.**

```bash
date -Is
hostname
uptime
df -hT
df -i
free -h
systemctl --failed --no-pager
```

| Observation | What it tells you | Next step |
| --- | --- | --- |
| Filesystem almost full | Writes may fail even while other mounts have space | Check the affected path's mount and inode usage |
| Inodes exhausted | Many small files can prevent new files | Identify the owning application and retention policy |
| Low available memory, sustained swap activity | Possible memory pressure | Inspect processes and sample `vmstat` |
| High load | Runnable or uninterruptible tasks; not a CPU percentage | Compare CPU activity, I/O wait, process states, and vCPU count |
| Failed unit | A service or dependency needs attention | Read its status and recent journal |

**Observe — substitute the actual unit name.**

```bash
systemctl status nginx --no-pager --full
journalctl -u nginx --since '-15 min' -n 100 --no-pager
ss -lnt
```

`nginx` is an example, not an installed-service assumption. Confirm MySQL's unit name (`mysql` or `mysqld`) before using it. Missing privileges and missing tools are different from a healthy result.

## MySQL: first observations

Use your approved connection method; see [connection examples](mysql/commands.md). In a connected MySQL client:

**Observe**

```sql
SELECT NOW() AS server_time, @@hostname AS server_host, VERSION() AS version;
SELECT USER() AS connection_identity, CURRENT_USER() AS matched_account;
SHOW GLOBAL STATUS WHERE Variable_name IN
  ('Uptime','Threads_connected','Threads_running','Max_used_connections','Aborted_connects');
SHOW GLOBAL VARIABLES WHERE Variable_name IN ('max_connections','read_only','super_read_only');
```

Record counters twice with elapsed time. A lifetime total by itself does not show the current error rate. A successful connection does not prove the application has correct grants or acceptable latency.

## Route by symptom

| Symptom | Guide |
| --- | --- |
| Service down, disk full, high load, permission denied | [Linux troubleshooting](linux/troubleshooting.md) |
| Timeout, DNS error, SSH failure, HTTP error | [Network troubleshooting](linux/networking.md) |
| Access denied, too many connections, slow queries, blocking | [MySQL troubleshooting](mysql/troubleshooting.md) |
| Need to recover data | [Backup and restore](mysql/backup-and-restore.md) |

Before a change, record the evidence, owner, expected effect, and rollback. Afterward, repeat the failed user operation and the relevant health check.
