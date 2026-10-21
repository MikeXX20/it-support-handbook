---
title: "MySQL 备份与恢复演练"
---

# MySQL 备份与恢复演练

代码阅读：`#` 开头是 Shell 注释，`--` 开头是 SQL 注释，无需单独输入。Bash 代码在 Linux 终端执行，SQL 在已连接的 MySQL 客户端执行。按章节说明阅读，先替换示例目标；标有“实验”的写操作仅在练习环境运行。

明确 **RPO**（最多可丢失多少近期数据）与 **RTO**（恢复最多可耗时多久）。导出完成不代表恢复一定成功。真实备份应放在认可的备份系统中，绝不能提交到此仓库。

## 工作备份前的准备

确认数据库名称、存储引擎、预期大小、服务器与客户端兼容性、权限、DDL 活动及恢复目标。与服务负责人评估 I/O 和存储影响，以及备份的安全与保留要求。

`mysqldump --single-transaction` 为事务型 InnoDB 表提供一致性快照，不能保证正在变化的非事务表一致。并发 DDL 可能使导出失效。普通逻辑导出并非完整的按时间点恢复方案；还需要二进制日志覆盖及经过验证的恢复流程。

## 仅限实验：导出练习数据库

先创建[练习数据库](../../labs/mysql-basics.md)。使用可丢弃的 MySQL 服务器及有权导出该库的账户。将下面作为 Bash 代码块运行；它会创建名称唯一、权限受限的本地文件。

```bash
# 让后续新建文件默认不向同组和其他用户开放，减少实验导出被别人读取的机会。
umask 077
# 创建唯一临时文件，并把路径保存到 dump_file；$(...) 把命令输出作为变量值。
dump_file=$(mktemp "${TMPDIR:-/tmp}/it-support-lab.XXXXXX")
# 尝试导出实验库；--host/--port/--user 指定实验连接，--password 交互输入密码。
# if 根据导出命令的退出状态决定走成功还是失败分支；行尾反斜杠表示下一行仍属于本条命令。
# 续行参数：为 InnoDB 建一致性快照、逐行读取结果、不导出表空间信息、不写入 GTID_PURGED 设置。
# 这些选项不等于完整生产备份策略，特别是并发 DDL 与非事务表需要另行评估。
# 指定只导出 it_support_lab；> 把导出内容写入临时文件，then 开始成功分支。
if mysqldump --host=127.0.0.1 --port=3306 --user=root --password \
  --single-transaction --quick --no-tablespaces --set-gtid-purged=OFF \
  it_support_lab > "$dump_file"; then
  # 导出成功时打印文件路径；成功提示仍不等于恢复已验证。
  printf 'Completed dump: %s\n' "$dump_file"
# 如果 mysqldump 返回失败，进入下面的失败分支。
else
  # 打印失败提示与不完整文件的路径；>&2 将提示写到标准错误输出。
  printf 'Dump failed; treat this file as incomplete: %s\n' "$dump_file" >&2
# 结束 if 条件分支。
fi
```

把本地主机和端口替换为实验服务器的实际值。这里有意只导出一个实验库，不使用 `--databases`，以便恢复到另一个数据库。它不包含服务器全局配置、账户与权限、存储程序和事件；真实备份策略必须明确覆盖所需对象。`--set-gtid-purged=OFF` 是本演练的选择，不是通用复制配置建议。

## 仅限实验：恢复到单独的空数据库

继续使用同一个 Shell，确保 `dump_file` 仍有值。仅在 `mysqldump` 成功后继续，并先确认导出范围。

```bash
# 连接本地实验服务器；主机、端口须对应可丢弃实例，root 仅用于本实验，密码交互输入。
# 行尾反斜杠表示下面一行仍属于本条 mysql 命令。
# -e 执行引号里的 SQL：创建使用 utf8mb4 的恢复库；已存在时应停止，不要覆盖旧库。
mysql --host=127.0.0.1 --port=3306 --user=root --password \
  -e 'CREATE DATABASE it_support_restore CHARACTER SET utf8mb4;'
# 连接本地实验服务器；主机、端口须对应可丢弃实例，root 仅用于本实验，密码交互输入。
# 行尾反斜杠表示下面一行仍属于本条 mysql 命令。
# 选择恢复库；< 把此前成功生成的导出文件作为输入执行。此操作写入实验数据库。
mysql --host=127.0.0.1 --port=3306 --user=root --password \
  it_support_restore < "$dump_file"
# 连接本地实验服务器；主机、端口须对应可丢弃实例，root 仅用于本实验，密码交互输入。
# 行尾反斜杠表示下面一行仍属于本条 mysql 命令。
# 执行行数查询，tickets 是结果列名；原始数据预期为 8，但核对行数还不能证明内容完全一致。
mysql --host=127.0.0.1 --port=3306 --user=root --password \
  -e 'SELECT COUNT(*) AS tickets FROM it_support_restore.tickets;'
```

若恢复数据库已存在，应停止并换用新的可丢弃目标。真实工作负载还要匹配字符集、排序规则及其他结构要求。验证表、行数、代表性字段值、键以及真实应用操作。记录恢复耗时与缺失对象；仅行数一致不能证明数据完整。

未修改的种子数据有 **8 条工单**。如果有意修改了实验数据，应与修改后的源库比较。清理是独立实验操作：完成后只删除本次练习的两个数据库和准确的导出文件。

来源：[备份策略](https://dev.mysql.com/doc/refman/8.4/en/backup-policy.html)及 [mysqldump 参数与限制](https://dev.mysql.com/doc/refman/8.4/en/mysqldump.html)。
