---
title: "Linux 命令速查"
---

# Linux 命令速查

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
free -h
vmstat 1 5
ps -eo pid,ppid,user,stat,%cpu,%mem,comm --sort=-%cpu | head -n 16
ps -eo pid,ppid,user,stat,%cpu,%mem,comm --sort=-%mem | head -n 16
```

关注 `available` 内存，不要把 Linux 缓存当作浪费。`vmstat` 的首次输出反映开机以来的情况，后续输出反映采样间隔。持续的 `si`/`so` 表示换页活动。结合存储与工作负载解释 `wa`；不存在能单独证明故障的通用阈值。

`ps %CPU` 不等于瞬时采样。状态 `D` 表示不可中断睡眠，常与 I/O 有关。应观察一段时间内的症状，再判断某个进程是否有问题。

## 文件系统与权限

```bash
df -hT /var
df -i /var
findmnt -T /var
lsblk -f
ls -ld /var /var/log
namei -l /var/log/nginx/access.log
```

检查实际故障路径所在的挂载点。即使剩余字节足够，inode 也可能耗尽。遍历目录要求每一级父目录都有执行权限；仅看文件权限不足以解释所有访问失败。ACL 与 SELinux/AppArmor 也可能施加额外限制。

**观察 — 限定扫描范围；繁忙文件系统上可能产生明显 I/O。**

```bash
du -xhd1 /var/log 2>/dev/null | sort -h
```

`-x` 将扫描限制在当前文件系统。隐藏的权限错误意味着统计可能不完整。需要时使用获批的提权方式，不要把不完整扫描当作目录为空。不要自动截断正在使用的应用日志。

## 服务与近期日志

```bash
systemctl list-unit-files --type=service --no-pager
systemctl --failed --no-pager
systemctl status nginx --no-pager --full
systemctl cat nginx
journalctl -u nginx --since '-15 min' -n 100 --no-pager
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
