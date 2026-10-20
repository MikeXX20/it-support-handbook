# Linux command reference

These are individual **Observe** examples for a Linux shell. Some tools are optional packages; additional access may be needed for other users' processes and system logs.

## Identity and environment

| Command | Meaning / interpretation |
| --- | --- |
| `cat /etc/os-release` | Distribution and release; use it to select the right vendor guide |
| `uname -r` | Running kernel; installed package version may differ |
| `hostname` | Host identity; compare with the intended target |
| `id` | Current UID and groups; group changes may need a new login |
| `date -Is` | Timestamp with offset for correlating logs |
| `uptime` | Uptime and load averages; load is not CPU utilization |
| `nproc` | Processing units available to the current process |

## CPU, memory, and processes

```bash
free -h
vmstat 1 5
ps -eo pid,ppid,user,stat,%cpu,%mem,comm --sort=-%cpu | head -n 16
ps -eo pid,ppid,user,stat,%cpu,%mem,comm --sort=-%mem | head -n 16
```

Use `available` memory rather than treating Linux cache as wasted RAM. In `vmstat`, the first report summarizes time since boot; later reports reflect the interval. Sustained `si`/`so` suggests swapping. Interpret `wa` together with storage and workload evidence; no universal threshold proves a fault.

`ps %CPU` is not the same as an instantaneous sample. Process state `D` indicates uninterruptible sleep, often associated with I/O. Compare symptoms over time before blaming a single process.

## Filesystems and permissions

```bash
df -hT /var
df -i /var
findmnt -T /var
lsblk -f
ls -ld /var /var/log
namei -l /var/log/nginx/access.log
```

Check the mount containing the actual failing path. A filesystem can run out of inodes while bytes remain available. Directory traversal requires execute permission on every parent; file permissions alone may not explain access failures. ACLs and SELinux/AppArmor can impose additional controls.

**Observe — scoped scan; may create significant I/O on a busy filesystem.**

```bash
du -xhd1 /var/log 2>/dev/null | sort -h
```

Stay on the selected filesystem with `-x`. Hidden permission errors mean the result may be incomplete. Use approved elevated access when needed rather than interpreting an incomplete scan as empty storage. Do not truncate active application logs as an automatic fix.

## Services and recent logs

```bash
systemctl list-unit-files --type=service --no-pager
systemctl --failed --no-pager
systemctl status nginx --no-pager --full
systemctl cat nginx
journalctl -u nginx --since '-15 min' -n 100 --no-pager
journalctl -k -b -p warning -n 80 --no-pager
```

Replace `nginx` with the identified unit. `systemctl cat` reveals unit files and overrides; it can contain private configuration. A successful `status` check confirms a process state, not application correctness. Service status commands can return nonzero when a unit is inactive or failed; that is useful evidence.

## Package and service differences

| Purpose | Ubuntu / Debian | RHEL / Rocky / AlmaLinux |
| --- | --- | --- |
| Inspect installed packages | `dpkg-query -W` | `rpm -qa` |
| Typical SSH unit; confirm locally | `ssh.service` | `sshd.service` |
| Possible MySQL unit; confirm locally | `mysql.service` | `mysqld.service` |

Package names, firewall tools, and logging differ by installation. Do not copy service changes between distributions without checking the target.

Sources: [systemctl](https://www.freedesktop.org/software/systemd/man/latest/systemctl.html), [journalctl](https://www.freedesktop.org/software/systemd/man/latest/journalctl.html), and the installed `man free`, `man vmstat`, `man ps`, `man df`, `man du`, and `man namei` pages.
