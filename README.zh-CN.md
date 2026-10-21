# IT 支持实用手册

[English](README.md) | **简体中文**

面向日常工作的 Linux 与 MySQL 参考手册，结合小型实验，理解命令背后的排查思路。

**在线阅读：[中文手册](https://mikexx20.github.io/it-support-handbook/zh/)**

**确认症状 → 收集证据 → 解释结果 → 选择下一步 → 验证恢复。**

## 从这里开始

| 目标 | 入口 |
| --- | --- |
| 现在遇到故障 | [五分钟快速检查](zh/docs/quick-check.md) |
| 清楚地处理工单 | [IT 支持工作流程](zh/docs/it-support/workflow.md) |
| 编写事件更新或交接 | [事件与工单模板](zh/templates/incident.md) |
| 查询 Linux 命令 | [Linux 命令速查](zh/docs/linux/commands.md) |
| 排查 Linux 故障 | [Linux 故障排查](zh/docs/linux/troubleshooting.md) |
| 诊断 DNS、端口、SSH 或 HTTP | [网络排查](zh/docs/linux/networking.md) |
| 检查 MySQL 连接和负载 | [MySQL 命令速查](zh/docs/mysql/commands.md) |
| 执行有限范围的 SQL 健康检查 | [SQL 检查清单](sql/mysql-health-check.sql) |
| 排查 MySQL 错误与阻塞 | [MySQL 故障排查](zh/docs/mysql/troubleshooting.md) |
| 练习备份与恢复 | [备份与恢复](zh/docs/mysql/backup-and-restore.md) |
| 循序渐进学习 | [四周学习路线](zh/learning/roadmap.md) |
| 动手实践 | [Linux 实验](zh/labs/linux-basics.md) · [MySQL 实验](zh/labs/mysql-basics.md) |

## 使用方式

- **工作时：** 从快速检查进入对应流程。变更前先收集少量、有明确时间范围的观测。
- **学习时：** 按学习路线练习，在私有笔记中记录预测、结果和解释。
- **复制命令前：** 将路径、主机、服务名和数据库名替换为目标值。命令是独立示例，不是从头到尾自动执行的脚本。

### 适用范围与约定

Linux 示例面向使用 systemd 的发行版，如 Ubuntu/Debian、RHEL/Rocky/AlmaLinux。GNU 工具与已安装软件包因环境而异；容器、WSL、macOS 可能需要其他命令。MySQL 以 **8.4 参考手册**为文档基准，不适用于直接替代 MariaDB 指南。先确认服务器版本。

命令标记为**观察**、**变更**或**仅限实验**。观察也可能消耗资源或展示敏感日志、查询内容。只操作获准支持的系统，将证据保存在认可的私有位置。公开示例不含真实凭据、客户数据或内网地址。

诊断步骤不要求重启服务、修改数据库配置、结束会话或删除数据。这些操作应结合事件及团队变更流程单独决定。中英文版共用可执行 SQL 文件，避免实验逻辑产生分歧。

## 学习目标

解释服务为何不可达，区分 CPU、内存与存储压力，区分数据库认证与传输失败，识别锁等待，并在可丢弃环境中演示成功恢复。

## 维护

[贡献指南（英文）](CONTRIBUTING.md)说明如何补充有用的排查流程。[官方资料](zh/docs/sources.md)提供一手文档链接；若本机参数与上游最新文档不同，优先参考发行版安装的手册。[验证记录](zh/docs/validation.md)明确实际测试版本与限制。
