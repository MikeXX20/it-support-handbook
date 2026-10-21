---
title: "Validation notes"
---

# Validation notes

This file records concrete checks rather than promising compatibility with every environment. The documented MySQL baseline is 8.4; runtime checks must name the actual server used.

## Initial edition — 2026-10-21

| Check | Result |
| --- | --- |
| Local Markdown navigation | 42 local links resolve; fenced code blocks are balanced |
| Shell examples | 19 Bash code blocks pass `bash -n` syntax checks |
| Disposable MySQL setup | MySQL Community Server **9.4.0**, separate temporary data directory and Unix socket, networking disabled |
| Sample database | 3 agents, 8 tickets, and the documented open-ticket counts verified |
| Repeated setup | A second seed import fails on the existing database and leaves the original rows unchanged |
| Diagnostic SQL | The reusable health checklist and six SQL blocks from the quick-check/command guides execute successfully |
| Transaction exercise | The update is visible within the transaction and rollback restores the original status |
| Lock-wait exercise | Two sessions produce an observable row-lock wait; releasing the blocker allows progress; both updates are rolled back |
| Query-plan exercise | The documented EXPLAIN and index inspection execute successfully |
| Backup/restore exercise | The documented dump options produce a dump that restores to a separate schema; every sample row in both tables matches |

The MySQL 8.4 documentation was used to review the examples, but **8.4 was not runtime-tested**. Linux commands were reviewed and their shell syntax checked; this macOS validation environment did not execute the Linux/systemd runbooks. Real systems may differ in packages, privileges, instrumentation, workload, and configuration.

## Simplified Chinese edition — 2026-10-21

The Chinese edition translates all 14 guides plus the home page and provides a Chinese repository README. All **30 fenced code blocks** in translated guides match the English originals exactly, and both editions share the executable SQL files. Across the repository, **88 local Markdown links** resolve and code fences are balanced. Locale/configuration YAML parses successfully, and the updated browser script passes `node --check`. These are documentation and site checks; the database exercises were not rerun for translation.

## Chinese beginner annotations — 2026-10-22

Added Chinese explanations to all 30 Chinese guide code blocks and both shared SQL files. Removing full-line comments leaves every executable line unchanged. All 19 annotated Bash blocks pass `bash -n`; SQL comments use `-- `, and shell continuation groups remain intact. Database exercises were not rerun for this comment-only update.
