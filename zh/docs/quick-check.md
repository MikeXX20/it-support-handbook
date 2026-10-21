---
title: "五分钟快速检查"
---

# 五分钟快速检查

先记录目标主机或服务、影响范围、时间与时区、准确症状，以及最近一次已知变更。可使用[事件记录模板](../templates/incident.md)。

## Linux：先收集基本信息

**观察 — 按症状选择检查项，不要把所有命令盲目执行一遍。**

```bash
date -Is
hostname
uptime
df -hT
df -i
free -h
systemctl --failed --no-pager
```

| 观察结果 | 可能说明什么 | 下一步 |
| --- | --- | --- |
| 文件系统接近满载 | 即使其他挂载点有空间，当前路径的写入仍可能失败 | 检查故障路径所在的挂载点与 inode 使用量 |
| inode 耗尽 | 大量小文件可能阻止新建文件 | 确认所属应用及保留策略 |
| 可用内存不足且持续换页 | 可能存在内存压力 | 检查进程并采样 `vmstat` |
| 负载较高 | 可运行或不可中断任务较多；负载不是 CPU 百分比 | 对比 CPU 活动、I/O 等待、进程状态和 vCPU 数量 |
| 单元处于 failed 状态 | 服务或依赖需要排查 | 查看状态及近期日志 |

**观察 — 替换成实际的服务单元名称。**

```bash
systemctl status nginx --no-pager --full
journalctl -u nginx --since '-15 min' -n 100 --no-pager
ss -lnt
```

`nginx` 只是示例，并不表示系统已安装它。使用 MySQL 服务前，先确认单元名是 `mysql` 还是 `mysqld`。权限不足、工具缺失与检查结果正常是三种不同情况。

## MySQL：先收集基本信息

使用团队认可的连接方式，参见[连接示例](mysql/commands.md)。在已连接的 MySQL 客户端中执行：

**观察**

```sql
SELECT NOW() AS server_time, @@hostname AS server_host, VERSION() AS version;
SELECT USER() AS connection_identity, CURRENT_USER() AS matched_account;
SHOW GLOBAL STATUS WHERE Variable_name IN
  ('Uptime','Threads_connected','Threads_running','Max_used_connections','Aborted_connects');
SHOW GLOBAL VARIABLES WHERE Variable_name IN ('max_connections','read_only','super_read_only');
```

间隔一段时间采样两次，并记录间隔。累计计数本身不能说明当前错误率。连接成功也不能证明应用具备正确权限或延迟符合要求。

## 按症状选择方向

| 症状 | 指南 |
| --- | --- |
| 服务停止、磁盘已满、负载高、权限拒绝 | [Linux 故障排查](linux/troubleshooting.md) |
| 超时、DNS 错误、SSH 失败、HTTP 错误 | [网络排查](linux/networking.md) |
| 访问被拒、连接过多、查询慢、阻塞 | [MySQL 故障排查](mysql/troubleshooting.md) |
| 需要恢复数据 | [备份与恢复](mysql/backup-and-restore.md) |

变更前记录证据、负责人、预期效果和回滚方案。变更后重新执行失败的用户操作及相关健康检查。
