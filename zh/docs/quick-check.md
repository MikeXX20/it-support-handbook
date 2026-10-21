---
title: "五分钟快速检查"
---

# 五分钟快速检查

代码阅读：`#` 开头是 Shell 注释，`--` 开头是 SQL 注释，无需单独输入。Bash 代码在 Linux 终端执行，SQL 在已连接的 MySQL 客户端执行。按章节说明阅读，先替换示例目标；标有“实验”的写操作仅在练习环境运行。

先记录目标主机或服务、影响范围、时间与时区、准确症状，以及最近一次已知变更。可使用[事件记录模板](../templates/incident.md)。

## Linux：先收集基本信息

**观察 — 按症状选择检查项，不要把所有命令盲目执行一遍。**

```bash
# 显示带时区偏移的当前时间；-I 使用 ISO 格式，s 精确到秒，方便对齐日志时间。
date -Is
# 显示当前主机名；先确认自己连的是要排查的机器。
hostname
# 显示开机时长、登录用户数和最近 1/5/15 分钟平均负载；负载不是 CPU 百分比。
uptime
# 查看各文件系统空间；-h 用易读单位，-T 显示类型；重点看 Use% 和 Mounted on。
df -hT
# 查看 inode 使用量；IUse% 接近 100% 时，可能有空间却无法新建文件。
df -i
# 查看内存与交换空间；-h 使用易读单位，重点看 available，不要只看 free。
free -h
# 列出失败的 systemd 单元；--no-pager 直接输出，不进入翻页界面。
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
# 查看 nginx 服务状态；--full 不截断文字。把 nginx 换成实际服务名，关注 Active 和报错。
systemctl status nginx --no-pager --full
# 读取 nginx 最近 15 分钟的日志，最多 100 条；-u 指定服务，-n 限制条数。服务名须替换。
journalctl -u nginx --since '-15 min' -n 100 --no-pager
# 列出正在监听的 TCP 套接字；-l 只看监听，-n 不解析名称，-t 只看 TCP。
ss -lnt
```

`nginx` 只是示例，并不表示系统已安装它。使用 MySQL 服务前，先确认单元名是 `mysql` 还是 `mysqld`。权限不足、工具缺失与检查结果正常是三种不同情况。

## MySQL：先收集基本信息

使用团队认可的连接方式，参见[连接示例](mysql/commands.md)。在已连接的 MySQL 客户端中执行：

**观察**

```sql
-- 查询服务器当前时间、主机名和 MySQL 版本；AS 给结果列起易读名称，不会修改数据。
SELECT NOW() AS server_time, @@hostname AS server_host, VERSION() AS version;
-- USER() 是客户端提供的用户与来源，CURRENT_USER() 是实际匹配的认证账户，两者可能不同。
SELECT USER() AS connection_identity, CURRENT_USER() AS matched_account;
-- 读取服务器级运行状态；WHERE ... IN 只保留下一行列出的指标。
SHOW GLOBAL STATUS WHERE Variable_name IN
  -- 列表中的指标分别表示运行秒数、当前连接数、非睡眠线程数、历史最高连接数、失败连接尝试数。
  -- 分号结束本条 SQL；累计值需间隔采样才能判断当前变化。
  ('Uptime','Threads_connected','Threads_running','Max_used_connections','Aborted_connects');
-- 查看连接上限与两种只读设置；用于了解配置背景，不是修改配置或完整权限检查。
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
