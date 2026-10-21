---
title: "Linux troubleshooting runbooks"
---

# Linux troubleshooting runbooks

Each runbook starts with observations. Any restart, deletion, permission change, or resource reconfiguration is a separate **Change** decision.

## Service is down

1. Confirm the service/unit name and incident time.
2. Inspect `systemctl status SERVICE --no-pager --full` and `journalctl -u SERVICE --since '-15 min' -n 100 --no-pager`.
3. Compare the first relevant error with recent config/deployment changes. Inspect dependencies and sockets.
4. If the application provides a documented configuration validator, use the correct command for that application/version before a change.
5. Once recovery is approved, verify the actual request path, not only the service's process state.

Repeated restart attempts can overwrite useful context or repeat a failure. Capture the error first.

## Filesystem is full

1. Run `df -hT /affected/path` and `df -i /affected/path`.
2. Confirm the mount with `findmnt -T /affected/path`.
3. Inspect one relevant directory at a time with a scoped `du` scan; account for permissions and I/O cost.
4. If `df` and `du` disagree, consider deleted-but-open files, files hidden under a mount, reserved space, and filesystem-specific accounting. `lsof +L1` can help identify open unlinked files when installed and permitted.
5. Ask the application owner about retention, rotation, and recovery. Never remove database data files to free space.

Verify free bytes/inodes, successful writes, and application recovery after an approved cleanup or capacity change.

## Host feels slow

Compare `uptime`, `nproc`, `free -h`, `vmstat 1 5`, and the process summaries in [commands](commands.md). If installed, `iostat -xz 1 5` adds a storage sample; its first report is normally since boot.

| Evidence | Investigate next |
| --- | --- |
| Sustained runnable queue and busy CPU | CPU-heavy workload, concurrency, CPU limits |
| Swap activity and low available memory | Memory growth, container limits, workload peak |
| I/O waits or many `D`-state processes | Storage latency, mount health, remote storage |
| Only one application slow | Its dependencies, workload, locks, and request latency |

Avoid diagnosing from one screenshot. Record the sampling interval, normal baseline, and whether the observation matches the incident time.

## Permission denied

Check `id`, `ls -l` on the file, and `namei -l /full/path`. Where relevant inspect `getfacl /full/path`, `ls -lZ /full/path`, `getenforce`, and recent security-denial logs with approved access.

Determine which account the failing service actually uses. Fix the specific ownership, group, ACL, service policy, or security policy only after confirming the cause. Broad permissions such as `chmod -R 777` are not a diagnostic step.

## SSH fails

Use [network troubleshooting](networking.md) to separate DNS, TCP reachability, authentication, and server-side policy. `ssh -v USER@HOST` can provide a short client trace; redact host details and identity paths before sharing.

Do not bypass host-key verification to suppress an unexpected key change. Verify the host identity through your team's trusted channel.

## Escalation packet

Include target and time, impact, exact failing operation, short relevant logs, results of a few targeted checks, recent changes, and your current hypothesis. Use [the template](../../templates/incident.md).

Sources: [systemd tools](https://www.freedesktop.org/software/systemd/man/latest/systemctl.html), [journal filtering](https://www.freedesktop.org/software/systemd/man/latest/journalctl.html), [Red Hat networking](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html-single/configuring_and_managing_networking/index), and installed manual pages for the named tools.
