---
title: "Linux 实验：文件、权限、进程与证据"
---

# Linux 实验：文件、权限、进程与证据

使用可丢弃的 Linux 虚拟机或自己控制的学习环境。示例需要 GNU/Linux Shell；不要在工作服务器上进行服务实验。文件练习无需 root 权限。

## 1. 识别环境

**观察**

```bash
cat /etc/os-release
id
pwd
date -Is
```

记录发行版、当前有效用户、工作目录与时区偏移。预测哪些命令在 macOS 或精简容器上会不同。

## 2. 创建小型练习目录

**仅限实验 — 在新临时目录中创建文件；后续继续使用同一个 Shell。**

```bash
lab_dir=$(mktemp -d "${TMPDIR:-/tmp}/it-support-linux.XXXXXX")
printf 'Lab directory: %s\n' "$lab_dir"
mkdir "$lab_dir/notes"
printf '2026-01-01 example service healthy\n' > "$lab_dir/notes/service.log"
chmod 640 "$lab_dir/notes/service.log"
ls -ld "$lab_dir" "$lab_dir/notes"
ls -l "$lab_dir/notes/service.log"
```

解释 `640` 的含义。预测谁能读取文件，再检查每一级父目录的权限。临时目录通常仅对所有者开放，因此仅有文件组权限不代表其他用户能够访问。

## 3. 搜索与测量

**观察**

```bash
grep -n 'healthy' "$lab_dir/notes/service.log"
wc -l "$lab_dir/notes/service.log"
du -sh "$lab_dir"
df -h "$lab_dir"
df -i "$lab_dir"
```

预期结果：匹配一行，文件总共一行。解释为什么文件大小、目录磁盘占用和整个文件系统容量是不同指标。

## 4. 观察进程

**仅限实验 — 在当前 Shell 中启动短时进程。**

```bash
sleep 30 &
lab_pid=$!
ps -p "$lab_pid" -o pid,ppid,stat,comm
wait "$lab_pid"
```

进程自然退出前应为 `sleep`。状态说明什么？退出后再次查询该 PID 会怎样？不要通过终止无关进程来实验。

## 5. 编写交接记录

用[事件模板](../templates/incident.md)记录模拟的“权限拒绝”事件。写出假设及所需证据，区分文件权限与目录遍历权限。完成后只删除命令打印出的本次临时目录，并保留需要的笔记。
