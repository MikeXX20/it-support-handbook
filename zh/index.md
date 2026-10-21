---
title: 首页
home: true
description: IT 支持、Linux 与 MySQL 命令速查、故障排查和学习练习。
---

# IT 支持手册

整理 IT 支持工作与学习中常用的命令、排查步骤和练习。Linux 示例使用 GNU/Linux 工具；MySQL 文档以 8.4 为基准。

## 快速开始

- [五分钟快速检查]({{ '/zh/docs/quick-check.html' | relative_url }}) — 收集主机和数据库的基本信息，再选择对应的排查指南。
- [四周学习路线]({{ '/zh/learning/roadmap.html' | relative_url }}) — 建议的学习顺序与练习任务。

## IT 支持

| 指南 | 内容 |
| --- | --- |
| [支持工作流程]({{ '/zh/docs/it-support/workflow.html' | relative_url }}) | 问题范围、证据、变更、验证与交接 |
| [事件记录模板]({{ '/zh/templates/incident.html' | relative_url }}) | 影响、时间线、检查结果与下一步 |

## Linux

| 指南 | 内容 |
| --- | --- |
| [命令速查]({{ '/zh/docs/linux/commands.html' | relative_url }}) | 系统信息、进程、内存、磁盘、权限与服务 |
| [故障排查]({{ '/zh/docs/linux/troubleshooting.html' | relative_url }}) | 服务失败、磁盘已满、主机变慢、权限与 SSH |
| [网络排查]({{ '/zh/docs/linux/networking.html' | relative_url }}) | DNS、路由、TCP 端口、TLS 与 HTTP |

## MySQL

| 指南 | 内容 |
| --- | --- |
| [命令速查]({{ '/zh/docs/mysql/commands.html' | relative_url }}) | 连接、会话、事务、锁与执行计划 |
| [故障排查]({{ '/zh/docs/mysql/troubleshooting.html' | relative_url }}) | 连接错误、身份验证、连接上限与慢查询 |
| [备份与恢复]({{ '/zh/docs/mysql/backup-and-restore.html' | relative_url }}) | 备份范围、导出与恢复练习、结果核对 |

## 实验练习

- [Linux 实验]({{ '/zh/labs/linux-basics.html' | relative_url }}) — 文件、权限、进程与模拟交接记录。
- [MySQL 实验]({{ '/zh/labs/mysql-basics.html' | relative_url }}) — 使用示例工单练习查询、事务、锁等待与恢复。

实验请使用可丢弃的环境。指南中分别标明观察命令与变更操作。

## 参考资料

- [官方资料与兼容性]({{ '/zh/docs/sources.html' | relative_url }})
- [验证记录]({{ '/zh/docs/validation.html' | relative_url }})
