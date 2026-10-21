---
title: "Linux 故障排查"
---

# Linux 故障排查

每个流程都从观察开始。重启、删除、权限调整或资源重新配置，都需要单独作出**变更**决定。

## 服务无法运行

1. 确认服务单元名和事件时间。
2. 查看 `systemctl status SERVICE --no-pager --full` 与 `journalctl -u SERVICE --since '-15 min' -n 100 --no-pager`。
3. 将首条相关错误与近期配置或部署变更对比，检查依赖和套接字。
4. 如果应用有文档规定的配置校验工具，在变更前使用该应用和版本对应的命令。
5. 恢复获批后，验证真实请求路径，而不只是服务进程状态。

重复重启可能覆盖有用上下文或再次触发失败。先记录错误。

## 文件系统已满

1. 执行 `df -hT /affected/path` 和 `df -i /affected/path`。
2. 使用 `findmnt -T /affected/path` 确认挂载点。
3. 每次只对一个相关目录进行限定范围的 `du` 扫描，考虑权限与 I/O 成本。
4. 若 `df` 与 `du` 不一致，考虑已删除但仍打开的文件、被挂载点遮挡的文件、预留空间，以及文件系统统计方式。有工具和权限时，可用 `lsof +L1` 查找已取消链接但仍打开的文件。
5. 与应用负责人确认保留、轮转和恢复策略。绝不能通过删除数据库数据文件释放空间。

获批清理或扩容后，验证可用字节、inode、实际写入和应用恢复情况。

## 主机变慢

对比 `uptime`、`nproc`、`free -h`、`vmstat 1 5` 及[命令速查](commands.md)中的进程汇总。若已安装，`iostat -xz 1 5` 可补充存储采样；首次报告通常统计开机以来的数据。

| 证据 | 下一步排查 |
| --- | --- |
| 持续较长的可运行队列且 CPU 繁忙 | CPU 密集型工作、并发、CPU 限制 |
| 换页活动且可用内存不足 | 内存增长、容器限制、负载高峰 |
| I/O 等待或大量 `D` 状态进程 | 存储延迟、挂载健康、远程存储 |
| 仅单个应用慢 | 应用依赖、工作负载、锁及请求延迟 |

不要根据一张截图下结论。记录采样间隔、正常基线，以及观测是否对应事件时间。

## 权限拒绝

查看 `id`、文件的 `ls -l` 和 `namei -l /full/path`。需要时，在获批权限下查看 `getfacl /full/path`、`ls -lZ /full/path`、`getenforce` 及近期安全拒绝日志。

确认失败服务实际使用的账户。查明原因后，再修正具体的所有者、组、ACL、服务策略或安全策略。`chmod -R 777` 这类宽泛授权不是诊断步骤。

## SSH 失败

使用[网络排查](networking.md)区分 DNS、TCP 可达性、身份验证和服务器策略。`ssh -v USER@HOST` 可提供简短客户端跟踪；分享前去除主机详情与身份文件路径。

不要为了隐藏主机密钥意外变化而跳过校验。通过团队可信渠道确认主机身份。

## 升级处理时携带的信息

包括目标与时间、影响、准确失败操作、少量相关日志、针对性检查结果、近期变更及当前假设。可使用[模板](../../templates/incident.md)。

来源：[systemd 工具](https://www.freedesktop.org/software/systemd/man/latest/systemctl.html)、[日志过滤](https://www.freedesktop.org/software/systemd/man/latest/journalctl.html)、[Red Hat 网络指南](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html-single/configuring_and_managing_networking/index)及相关工具的本机手册。
