# Linux lab: files, permissions, processes, and evidence

Use a disposable Linux VM or a Linux learning environment you control. The examples need a GNU/Linux shell; do not run service experiments on a work server. No root access is required for the file exercises.

## 1. Identify the environment

**Observe**

```bash
cat /etc/os-release
id
pwd
date -Is
```

Write down the distribution, effective user, working directory, and timezone offset. Predict which commands would differ on macOS or a minimal container.

## 2. Create a small practice directory

**Lab only — creates files in a new temporary directory. Keep using the same shell.**

```bash
lab_dir=$(mktemp -d "${TMPDIR:-/tmp}/it-support-linux.XXXXXX")
printf 'Lab directory: %s\n' "$lab_dir"
mkdir "$lab_dir/notes"
printf '2026-01-01 example service healthy\n' > "$lab_dir/notes/service.log"
chmod 640 "$lab_dir/notes/service.log"
ls -ld "$lab_dir" "$lab_dir/notes"
ls -l "$lab_dir/notes/service.log"
```

Explain the meaning of `640`. Predict who could read the file, then account for the permissions of every parent directory. The temporary directory is normally private to its owner, so file group permissions alone do not give another user access.

## 3. Search and measure

**Observe**

```bash
grep -n 'healthy' "$lab_dir/notes/service.log"
wc -l "$lab_dir/notes/service.log"
du -sh "$lab_dir"
df -h "$lab_dir"
df -i "$lab_dir"
```

Expected: one matching line and a one-line file. Explain why file size, directory disk usage, and whole-filesystem capacity are different measurements.

## 4. Observe a process

**Lab only — starts a short-lived process in this shell.**

```bash
sleep 30 &
lab_pid=$!
ps -p "$lab_pid" -o pid,ppid,stat,comm
wait "$lab_pid"
```

The process should be `sleep` until it exits naturally. What does its state tell you? What happens if you inspect the PID after it exits? Do not experiment by terminating unrelated processes.

## 5. Write the handover

Use [the incident template](../templates/incident.md) to record a simulated “permission denied” incident. Describe a hypothesis and the evidence needed to distinguish file permissions from directory traversal permissions. Delete only your printed temporary practice directory when done; preserve any notes you want to keep.
