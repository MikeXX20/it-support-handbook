# IT Support Handbook

Practical Linux and MySQL references for the working day, with small labs for learning the reasoning behind the commands.

**Find the symptom → collect evidence → interpret it → choose the next check → verify recovery.**

## Start here

| Your goal | Open |
| --- | --- |
| Something is broken right now | [Five-minute quick check](docs/quick-check.md) |
| Handle a ticket clearly | [IT support workflow](docs/it-support/workflow.md) |
| Write an incident update | [Ticket and handover template](templates/incident.md) |
| Look up a Linux command | [Linux command reference](docs/linux/commands.md) |
| Investigate a Linux failure | [Linux troubleshooting](docs/linux/troubleshooting.md) |
| Diagnose DNS, ports, SSH, or HTTP | [Network troubleshooting](docs/linux/networking.md) |
| Check MySQL connections and workload | [MySQL command reference](docs/mysql/commands.md) |
| Run a bounded SQL health check | [SQL checklist](sql/mysql-health-check.sql) |
| Investigate MySQL errors or blocking | [MySQL troubleshooting](docs/mysql/troubleshooting.md) |
| Practice backup and recovery | [Backup and restore](docs/mysql/backup-and-restore.md) |
| Build skills step by step | [Four-week learning path](learning/roadmap.md) |
| Learn by doing | [Linux lab](labs/linux-basics.md) · [MySQL lab](labs/mysql-basics.md) |

## How to use this repository

- **At work:** start with the quick check, then follow the relevant runbook. Capture a short time-bounded observation before changing anything.
- **For study:** follow the learning path and keep a private notebook of your predictions, results, and explanations.
- **Before copying a command:** replace example paths, hosts, service names, and database names with the intended target. Commands are examples, not a script to run from top to bottom.

### Scope and assumptions

Linux examples target systemd-based distributions such as Ubuntu/Debian and RHEL/Rocky/AlmaLinux. GNU tools and installed packages vary; containers, WSL, and macOS may need different commands. MySQL examples use the **MySQL 8.4 reference manual** as their baseline; they are not MariaDB instructions. Confirm the server version first.

Command blocks are marked **Observe**, **Change**, or **Lab only**. Observation can still consume resources and expose sensitive logs or query text. Run only on systems you are authorized to support; keep collected evidence in approved private storage. Public examples contain no real credentials, customer data, or internal addresses.

No diagnostic here requires restarting a service, changing database settings, killing sessions, or deleting data. Those actions need a separate decision based on the incident and your team's change process.

## Learning outcomes

You should be able to explain why a service is unreachable, distinguish CPU/memory/storage pressure, separate database authentication from transport failures, recognize lock waits, and demonstrate a successful restore in a disposable environment.

## Maintenance

[Contributing](CONTRIBUTING.md) explains how to add a useful runbook. [Sources](docs/sources.md) links to primary documentation. Prefer your distribution's installed manual when its options differ from the latest upstream documentation.
