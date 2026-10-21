---
title: "Primary sources and compatibility"
---

# Primary sources and compatibility

Use these sources to check details for the exact software version in front of you. Commands in this handbook are original short examples, not a replacement for vendor documentation.

## Linux

- [systemctl manual](https://www.freedesktop.org/software/systemd/man/latest/systemctl.html)
- [journalctl manual](https://www.freedesktop.org/software/systemd/man/latest/journalctl.html)
- [ss manual, maintained with the Linux manual pages](https://man7.org/linux/man-pages/man8/ss.8.html)
- [Red Hat Enterprise Linux 9 networking guide](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html-single/configuring_and_managing_networking/index)
- Installed manual pages: `man ip`, `man free`, `man vmstat`, `man ps`, `man df`, `man du`, `man namei`, `man getent`, `man dig`, `man nc`, `man curl`.

The latest upstream systemd manual may describe options absent from an older distribution. Prefer the installed manual for local compatibility.

## MySQL 8.4

- [Reference manual](https://dev.mysql.com/doc/refman/8.4/en/)
- [Tutorial](https://dev.mysql.com/doc/refman/8.4/en/tutorial.html)
- [mysql client options](https://dev.mysql.com/doc/refman/8.4/en/mysql-command-options.html)
- [Connection verification and account matching](https://dev.mysql.com/doc/refman/8.4/en/connection-access.html)
- [SHOW STATUS](https://dev.mysql.com/doc/refman/8.4/en/show-status.html)
- [Performance Schema processlist](https://dev.mysql.com/doc/refman/8.4/en/performance-schema-processlist-table.html)
- [InnoDB row-lock waits](https://dev.mysql.com/doc/refman/8.4/en/sys-innodb-lock-waits.html)
- [Metadata-lock waits](https://dev.mysql.com/doc/refman/8.4/en/sys-schema-table-lock-waits.html)
- [EXPLAIN](https://dev.mysql.com/doc/refman/8.4/en/using-explain.html)
- [mysqldump](https://dev.mysql.com/doc/refman/8.4/en/mysqldump.html)
- [Backup policy](https://dev.mysql.com/doc/refman/8.4/en/backup-policy.html)

Review date: **2026-10-21**. Version-specific runtime verification, when performed, is recorded in [validation notes](validation.md).
