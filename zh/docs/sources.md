---
title: "官方资料与兼容性"
---

# 官方资料与兼容性

通过以下资料核对当前软件版本的具体行为。本手册提供简短原创示例，不能代替厂商文档。以下官方链接多数为英文。

## Linux

- [systemctl 手册](https://www.freedesktop.org/software/systemd/man/latest/systemctl.html)
- [journalctl 手册](https://www.freedesktop.org/software/systemd/man/latest/journalctl.html)
- [ss 手册（Linux man-pages）](https://man7.org/linux/man-pages/man8/ss.8.html)
- [Red Hat Enterprise Linux 9 网络指南](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html-single/configuring_and_managing_networking/index)
- 本机手册：`man ip`、`man free`、`man vmstat`、`man ps`、`man df`、`man du`、`man namei`、`man getent`、`man dig`、`man nc`、`man curl`。

最新版 systemd 文档可能包含旧发行版没有的参数。判断本机兼容性时优先查阅已安装手册。

## MySQL 8.4

- [参考手册](https://dev.mysql.com/doc/refman/8.4/en/)
- [入门教程](https://dev.mysql.com/doc/refman/8.4/en/tutorial.html)
- [mysql 客户端参数](https://dev.mysql.com/doc/refman/8.4/en/mysql-command-options.html)
- [连接验证与账户匹配](https://dev.mysql.com/doc/refman/8.4/en/connection-access.html)
- [SHOW STATUS](https://dev.mysql.com/doc/refman/8.4/en/show-status.html)
- [Performance Schema processlist](https://dev.mysql.com/doc/refman/8.4/en/performance-schema-processlist-table.html)
- [InnoDB 行锁等待](https://dev.mysql.com/doc/refman/8.4/en/sys-innodb-lock-waits.html)
- [元数据锁等待](https://dev.mysql.com/doc/refman/8.4/en/sys-schema-table-lock-waits.html)
- [EXPLAIN](https://dev.mysql.com/doc/refman/8.4/en/using-explain.html)
- [mysqldump](https://dev.mysql.com/doc/refman/8.4/en/mysqldump.html)
- [备份策略](https://dev.mysql.com/doc/refman/8.4/en/backup-policy.html)

资料审阅日期：**2026-10-21**。具体运行验证及所用版本见[验证记录](validation.md)。
