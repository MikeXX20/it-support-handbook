---
title: "MySQL 备份与恢复演练"
---

# MySQL 备份与恢复演练

明确 **RPO**（最多可丢失多少近期数据）与 **RTO**（恢复最多可耗时多久）。导出完成不代表恢复一定成功。真实备份应放在认可的备份系统中，绝不能提交到此仓库。

## 工作备份前的准备

确认数据库名称、存储引擎、预期大小、服务器与客户端兼容性、权限、DDL 活动及恢复目标。与服务负责人评估 I/O 和存储影响，以及备份的安全与保留要求。

`mysqldump --single-transaction` 为事务型 InnoDB 表提供一致性快照，不能保证正在变化的非事务表一致。并发 DDL 可能使导出失效。普通逻辑导出并非完整的按时间点恢复方案；还需要二进制日志覆盖及经过验证的恢复流程。

## 仅限实验：导出练习数据库

先创建[练习数据库](../../labs/mysql-basics.md)。使用可丢弃的 MySQL 服务器及有权导出该库的账户。将下面作为 Bash 代码块运行；它会创建名称唯一、权限受限的本地文件。

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

把本地主机和端口替换为实验服务器的实际值。这里有意只导出一个实验库，不使用 `--databases`，以便恢复到另一个数据库。它不包含服务器全局配置、账户与权限、存储程序和事件；真实备份策略必须明确覆盖所需对象。`--set-gtid-purged=OFF` 是本演练的选择，不是通用复制配置建议。

## 仅限实验：恢复到单独的空数据库

继续使用同一个 Shell，确保 `dump_file` 仍有值。仅在 `mysqldump` 成功后继续，并先确认导出范围。

```bash
mysql --host=127.0.0.1 --port=3306 --user=root --password \
  -e 'CREATE DATABASE it_support_restore CHARACTER SET utf8mb4;'
mysql --host=127.0.0.1 --port=3306 --user=root --password \
  it_support_restore < "$dump_file"
mysql --host=127.0.0.1 --port=3306 --user=root --password \
  -e 'SELECT COUNT(*) AS tickets FROM it_support_restore.tickets;'
```

若恢复数据库已存在，应停止并换用新的可丢弃目标。真实工作负载还要匹配字符集、排序规则及其他结构要求。验证表、行数、代表性字段值、键以及真实应用操作。记录恢复耗时与缺失对象；仅行数一致不能证明数据完整。

未修改的种子数据有 **8 条工单**。如果有意修改了实验数据，应与修改后的源库比较。清理是独立实验操作：完成后只删除本次练习的两个数据库和准确的导出文件。

来源：[备份策略](https://dev.mysql.com/doc/refman/8.4/en/backup-policy.html)及 [mysqldump 参数与限制](https://dev.mysql.com/doc/refman/8.4/en/mysqldump.html)。
