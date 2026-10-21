---
title: "网络排查：域名 → 路由 → 端口 → 协议"
---

# 网络排查：域名 → 路由 → 端口 → 协议

代码阅读：`#` 开头是 Shell 注释，`--` 开头是 SQL 注释，无需单独输入。Bash 代码在 Linux 终端执行，SQL 在已连接的 MySQL 客户端执行。按章节说明阅读，先替换示例目标；标有“实验”的写操作仅在练习环境运行。

仅对获准的目标进行连通性测试。替换为实际主机和端口；`example.com` 与 `db.example.com` 是文档占位符。

## 1. 本地配置

**观察**

```bash
# 简要列出网卡、状态和 IP 地址；-br 为简洁格式，核对预期地址是否存在。
ip -br address
# 显示路由表；default 是默认路由，检查目标网络是否有对应路径。
ip route
# 显示网卡收发包、错误和丢包计数；-s 为统计，比较两次采样而非只看累计值。
ip -s link
```

确认预期网卡、地址、路由和异常错误计数。链路处于 up 状态不代表端到端可达。使用 NetworkManager 的系统可补充查看 `nmcli device status`，但并非所有系统都提供它。

## 2. 名称解析

**观察**

```bash
# 按系统名称解析规则查主机地址，可能参考 hosts 和 DNS；域名须换成获准目标。
getent ahosts example.com
# 查询域名的 IPv4（A）记录；看状态码与 ANSWER，域名须替换。
dig example.com A
# 查询域名的 IPv6（AAAA）记录；可与 IPv4 路径分别比较。
dig example.com AAAA
```

`getent` 遵循系统名称服务配置，`dig` 查询 DNS。两者结果不同可能由 hosts 文件、分离 DNS、缓存、搜索域或应用自有解析方式导致。`dig` 是可选工具，许多 Debian 系统的软件包名为 `dnsutils`，RHEL 系统为 `bind-utils`。

将解析地址与预期目标比较。只有一条路径失败时，分别测试 IPv4 和 IPv6。不要未经验证就更换组织的 DNS 服务器。

## 3. 路由与传输

**观察 / 连通性探测 — 替换目标。**

```bash
# 显示系统去往该 IP 会选的路由、网卡和源地址；不会证明远端可达，示例 IP 须替换。
ip route get 192.0.2.10
# 向目标发 3 个 ICMP 探测包后停止；-c 是次数。无回复也可能是 ICMP 被过滤。
ping -c 3 192.0.2.10
# 尝试连接目标的 3306 TCP 端口；-v 显示详情，-z 只探测，-w 3 设置超时参数。
# 先用 nc -h 确认本机参数支持情况；连接成功不代表 MySQL 登录成功，域名和端口须替换。
nc -vz -w 3 db.example.com 3306
```

`192.0.2.10` 是保留的示例地址，不是可达的测试主机。`nc` 参数因实现而异，先查看 `nc -h`。Ping 失败可能只是 ICMP 被过滤。TCP 连接成功只证明套接字接受连接，不代表数据库身份验证或查询可用。

在服务器上检查实际监听地址和端口：

```bash
# 列出正在监听的 TCP 套接字；-l 只看监听，-n 不解析名称，-t 只看 TCP。
ss -lnt
# 在监听 TCP 列表上增加进程信息；-p 显示所属进程，权限不足时可能看不到详情。
ss -lntp
```

进程详情可能需要提权。仅绑定 `127.0.0.1` 的服务不会监听服务器外部接口。超时可能发生在路径的多个位置；“connection refused”可能表示没有监听者，也可能是显式拒绝。单个结果不足以确定责任组件。

## 4. 应用协议

**观察 / HTTP 探测 — 使用获准、轻量的健康检查 URL。**

```bash
# 请求 HTTP 响应头而不下载正文；连接超时 3 秒，整个操作最多 10 秒。URL 须换成获准的健康检查地址。
# 查看状态码与 TLS 错误；端点不支持 HEAD 时，应改用应用规定的检查方式。
curl --head --connect-timeout 3 --max-time 10 https://example.com/
```

并非所有端点都支持 HEAD。必要时使用应用文档规定的健康请求。`401`/`403` 属于身份验证或授权响应；代理产生的 `502`/`504` 提示应检查上游路径。HTTP 成功也可能没有覆盖用户失败的具体功能。

TLS 失败时，检查主机名、证书有效期与证书链、客户端信任及系统时间。不要通过关闭证书校验来掩盖错误。MySQL 问题继续参考[连接检查](../mysql/commands.md)。

来源：[ss 手册](https://man7.org/linux/man-pages/man8/ss.8.html)、[Red Hat 网络指南](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html-single/configuring_and_managing_networking/index)，以及本机 `man ip`、`man getent`、`man dig`、`man nc` 和 `man curl`。
