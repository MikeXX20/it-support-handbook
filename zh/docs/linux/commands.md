---
title: "Linux 命令速查"
---

# Linux 命令速查

代码阅读：`#` 开头是 Shell 注释，`--` 开头是 SQL 注释，无需单独输入。Bash 代码在 Linux 终端执行，SQL 在已连接的 MySQL 客户端执行。按章节说明阅读，先替换示例目标；标有“实验”的写操作仅在练习环境运行。

以下是 Linux Shell 中独立使用的**观察**示例。部分工具需要另外安装；查看其他用户的进程与系统日志可能需要额外权限。

## 身份与环境

| 命令 | 含义与解释 |
| --- | --- |
| `cat /etc/os-release` | 发行版与版本，用于选择对应文档 |
| `uname -r` | 当前运行的内核，可能不同于已安装软件包版本 |
| `hostname` | 主机身份，核对是否为预期目标 |
| `id` | 当前 UID 和组；组变更可能需要重新登录 |
| `date -Is` | 带时区偏移的时间戳，便于关联日志 |
| `uptime` | 运行时长与平均负载；负载不是 CPU 利用率 |
| `nproc` | 当前进程可用的处理单元数量 |

## CPU、内存与进程

```bash
# 查看内存与交换空间；-h 使用易读单位，重点看 available，不要只看 free。
free -h
# 每隔 1 秒输出一次，共 5 次；首次通常是开机以来统计，后续关注 si/so 换页及 CPU 各列。
vmstat 1 5
# 列出进程 ID、父进程、用户、状态、CPU%、内存%及命令名，按 CPU% 从高到低排。
# | 将结果交给 head；-n 16 保留表头加最多 15 个进程。ps 的 CPU% 不是瞬时采样。
ps -eo pid,ppid,user,stat,%cpu,%mem,comm --sort=-%cpu | head -n 16
# 与上一条字段相同，改按内存占比从高到低排序；最多显示表头加 15 个进程。
ps -eo pid,ppid,user,stat,%cpu,%mem,comm --sort=-%mem | head -n 16
```

关注 `available` 内存，不要把 Linux 缓存当作浪费。`vmstat` 的首次输出反映开机以来的情况，后续输出反映采样间隔。持续的 `si`/`so` 表示换页活动。结合存储与工作负载解释 `wa`；不存在能单独证明故障的通用阈值。

`ps %CPU` 不等于瞬时采样。状态 `D` 表示不可中断睡眠，常与 I/O 有关。应观察一段时间内的症状，再判断某个进程是否有问题。

## 文件系统与权限

```bash
# 只检查 /var 所在文件系统的空间与类型；/var 是示例，替换为故障路径。
df -hT /var
# 查看 /var 所在文件系统的 inode；大量小文件可能先耗尽 inode。
df -i /var
# 找出 /var 实际位于哪个挂载点；-T 后面是要查的路径。
findmnt -T /var
# 列出块设备及文件系统信息；-f 补充类型、UUID、挂载点等，便于对应磁盘。
lsblk -f
# 显示这两个目录本身的权限、所有者和组；-l 为详细格式，-d 不展开目录内容。
ls -ld /var /var/log
# 逐级显示路径的目录与权限；检查是否某个父目录缺少通行所需的 x 权限。路径须替换。
namei -l /var/log/nginx/access.log
```

检查实际故障路径所在的挂载点。即使剩余字节足够，inode 也可能耗尽。遍历目录要求每一级父目录都有执行权限；仅看文件权限不足以解释所有访问失败。ACL 与 SELinux/AppArmor 也可能施加额外限制。

**观察 — 限定扫描范围；繁忙文件系统上可能产生明显 I/O。**

```bash
# 统计 /var/log 及一层子目录占用；-x 不跨文件系统，-h 用易读单位，-d1 限定深度。
# 2>/dev/null 隐藏错误，权限不足会导致漏算；| sort -h 按容量从小到大排序。此扫描会产生 I/O。
du -xhd1 /var/log 2>/dev/null | sort -h
```

`-x` 将扫描限制在当前文件系统。隐藏的权限错误意味着统计可能不完整。需要时使用获批的提权方式，不要把不完整扫描当作目录为空。不要自动截断正在使用的应用日志。

## 服务与近期日志

```bash
# 列出服务单元文件与启用状态；用于确认服务名，enabled 不等于当前正在运行。
systemctl list-unit-files --type=service --no-pager
# 列出失败的 systemd 单元；--no-pager 直接输出，不进入翻页界面。
systemctl --failed --no-pager
# 查看 nginx 服务状态；--full 不截断文字。把 nginx 换成实际服务名，关注 Active 和报错。
systemctl status nginx --no-pager --full
# 展示 nginx 的单元文件及覆盖配置；可查启动命令，但内容可能含私有配置。
systemctl cat nginx
# 读取 nginx 最近 15 分钟的日志，最多 100 条；-u 指定服务，-n 限制条数。服务名须替换。
journalctl -u nginx --since '-15 min' -n 100 --no-pager
# 查看本次开机的内核日志，取最近最多 80 条 warning 及更严重记录；-k 内核，-b 本次开机。
journalctl -k -b -p warning -n 80 --no-pager
```

把 `nginx` 替换为已确认的服务单元。`systemctl cat` 展示单元文件和覆盖项，可能包含私有配置。`status` 正常只说明进程状态，不代表应用功能正确。服务未运行或失败时，状态命令可能返回非零退出码，这是有用的证据。

## 软件包与服务差异

| 用途 | Ubuntu / Debian | RHEL / Rocky / AlmaLinux |
| --- | --- | --- |
| 查看已安装软件包 | `dpkg-query -W` | `rpm -qa` |
| 常见 SSH 单元，需本机确认 | `ssh.service` | `sshd.service` |
| 可能的 MySQL 单元，需本机确认 | `mysql.service` | `mysqld.service` |

软件包名、防火墙工具和日志方式因安装环境而异。跨发行版操作前应先核对目标环境。

来源：[systemctl](https://www.freedesktop.org/software/systemd/man/latest/systemctl.html)、[journalctl](https://www.freedesktop.org/software/systemd/man/latest/journalctl.html)，以及本机 `man free`、`man vmstat`、`man ps`、`man df`、`man du` 和 `man namei`。
