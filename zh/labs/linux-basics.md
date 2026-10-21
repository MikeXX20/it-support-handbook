---
title: "Linux 实验：文件、权限、进程与证据"
---

# Linux 实验：文件、权限、进程与证据

代码阅读：`#` 开头是 Shell 注释，`--` 开头是 SQL 注释，无需单独输入。Bash 代码在 Linux 终端执行，SQL 在已连接的 MySQL 客户端执行。按章节说明阅读，先替换示例目标；标有“实验”的写操作仅在练习环境运行。

使用可丢弃的 Linux 虚拟机或自己控制的学习环境。示例需要 GNU/Linux Shell；不要在工作服务器上进行服务实验。文件练习无需 root 权限。

## 1. 识别环境

**观察**

```bash
# 读取发行版信息；关注 NAME 和 VERSION_ID，选择对应系统的操作说明。
cat /etc/os-release
# 显示当前用户 UID、主组及附加组，用于判断正在以谁的身份操作。
id
# 显示当前工作目录；执行使用相对路径的命令前先确认位置。
pwd
# 显示带时区偏移的当前时间；-I 使用 ISO 格式，s 精确到秒，方便对齐日志时间。
date -Is
```

记录发行版、当前有效用户、工作目录与时区偏移。预测哪些命令在 macOS 或精简容器上会不同。

## 2. 创建小型练习目录

**仅限实验 — 在新临时目录中创建文件；后续继续使用同一个 Shell。**

```bash
# 创建唯一的临时练习目录并把路径存入 lab_dir；-d 创建目录。
# ${TMPDIR:-/tmp} 表示有 TMPDIR 就使用它，否则使用 /tmp；XXXXXX 会替换成随机字符。
lab_dir=$(mktemp -d "${TMPDIR:-/tmp}/it-support-linux.XXXXXX")
# 打印刚创建的练习目录；%s 代入路径，\n 换行。后续继续使用同一个 Shell，双引号保护路径。
printf 'Lab directory: %s\n' "$lab_dir"
# 仅在本次练习目录下创建 notes 子目录；$lab_dir 取变量里保存的路径。
mkdir "$lab_dir/notes"
# 把一行示例文字写入 service.log；> 会新建或覆盖目标文件，这里仅写实验文件。
printf '2026-01-01 example service healthy\n' > "$lab_dir/notes/service.log"
# 修改实验文件权限：所有者 6=读+写，同组 4=只读，其他人 0=无权限；父目录权限仍会影响访问。
chmod 640 "$lab_dir/notes/service.log"
# 查看练习目录和 notes 的权限；-d 只列目录本身，不列里面的文件。
ls -ld "$lab_dir" "$lab_dir/notes"
# 查看实验文件的权限、所有者、组和大小，核对是否为预期的 640。
ls -l "$lab_dir/notes/service.log"
```

解释 `640` 的含义。预测谁能读取文件，再检查每一级父目录的权限。临时目录通常仅对所有者开放，因此仅有文件组权限不代表其他用户能够访问。

## 3. 搜索与测量

**观察**

```bash
# 查找含 healthy 的行；-n 同时显示行号，原始示例应只匹配第 1 行。
grep -n 'healthy' "$lab_dir/notes/service.log"
# 统计文件的换行数；本练习写入一行带换行的文字，预期结果为 1。
wc -l "$lab_dir/notes/service.log"
# 统计练习目录占用；-s 只显示汇总，-h 使用易读单位。
du -sh "$lab_dir"
# 显示练习目录所在整个文件系统的容量，不是这个目录自身的大小。
df -h "$lab_dir"
# 显示练习目录所在文件系统的 inode 使用量，与剩余字节空间是不同指标。
df -i "$lab_dir"
```

预期结果：匹配一行，文件总共一行。解释为什么文件大小、目录磁盘占用和整个文件系统容量是不同指标。

## 4. 观察进程

**仅限实验 — 在当前 Shell 中启动短时进程。**

```bash
# 启动一个等待 30 秒的练习进程；& 使它在后台运行，终端可以继续输入命令。
sleep 30 &
# 把刚刚启动的后台进程 PID 保存到 lab_pid；$! 是上一后台任务的进程号。
lab_pid=$!
# 仅查看该练习进程；-p 选 PID，-o 指定进程号、父进程号、状态和命令名。
ps -p "$lab_pid" -o pid,ppid,stat,comm
# 等待该后台进程自然退出；只等待本次练习启动的进程。
wait "$lab_pid"
```

进程自然退出前应为 `sleep`。状态说明什么？退出后再次查询该 PID 会怎样？不要通过终止无关进程来实验。

## 5. 编写交接记录

用[事件模板](../templates/incident.md)记录模拟的“权限拒绝”事件。写出假设及所需证据，区分文件权限与目录遍历权限。完成后只删除命令打印出的本次临时目录，并保留需要的笔记。
