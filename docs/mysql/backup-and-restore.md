# MySQL backup and restore: a learning drill

Know the **RPO** (how much recent data can be lost) and **RTO** (how long recovery may take). A completed dump is not evidence that recovery will succeed. Keep real backups in your approved backup system; never commit them to this repository.

## Before a work backup

Identify database names, storage engines, expected size, version/client compatibility, privileges, DDL activity, and the restore target. Assess I/O/storage impact and the backup's security/retention requirements with the service owner.

`mysqldump --single-transaction` provides a consistent snapshot for transactional InnoDB tables. It does not make changing nontransactional tables consistent. Concurrent DDL can invalidate the dump. A plain logical dump is not a complete point-in-time recovery strategy; binary-log coverage and a tested recovery procedure are separate requirements.

## Lab only: dump the practice schema

Create the [practice database](../../labs/mysql-basics.md) first. Use a disposable MySQL server and an account allowed to dump that schema. Run this as a Bash block; it creates a uniquely named local file with restrictive permissions.

```bash
umask 077
dump_file=$(mktemp "${TMPDIR:-/tmp}/it-support-lab.XXXXXX")
if mysqldump --host=127.0.0.1 --port=3306 --user=root --password \
  --single-transaction --quick --no-tablespaces --set-gtid-purged=OFF \
  it_support_lab > "$dump_file"; then
  printf 'Completed dump: %s\n' "$dump_file"
else
  printf 'Dump failed; treat this file as incomplete: %s\n' "$dump_file" >&2
fi
```

Replace the local host/port with your disposable server's connection values. This deliberately dumps one lab database without `--databases`, so the drill can restore into a different schema. It omits server-wide configuration, accounts/grants, routines, and events; a real backup policy must explicitly cover the objects it needs. `--set-gtid-purged=OFF` is a drill choice, not a universal replication recommendation.

## Lab only: restore into a separate empty schema

Use the same shell so `dump_file` is still set. Proceed only after `mysqldump` returned success, and inspect the dump's scope before restoring.

```bash
mysql --host=127.0.0.1 --port=3306 --user=root --password \
  -e 'CREATE DATABASE it_support_restore CHARACTER SET utf8mb4;'
mysql --host=127.0.0.1 --port=3306 --user=root --password \
  it_support_restore < "$dump_file"
mysql --host=127.0.0.1 --port=3306 --user=root --password \
  -e 'SELECT COUNT(*) AS tickets FROM it_support_restore.tickets;'
```

Stop if the restore schema already exists; use a fresh disposable target. Match character set/collation and other schema requirements for real workloads. Verify tables, row counts, representative values, keys, and a realistic application operation. Record elapsed recovery time and any missing objects; row counts alone do not prove data integrity.

The untouched seed has **8 tickets**. If you intentionally changed the lab data, compare with that changed source instead. Cleanup is a separate lab action: remove only the two exercise schemas and the specific generated dump when finished.

Sources: [backup policy](https://dev.mysql.com/doc/refman/8.4/en/backup-policy.html) and [mysqldump options and limitations](https://dev.mysql.com/doc/refman/8.4/en/mysqldump.html).
