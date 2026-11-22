---
name: riemann-masullo-sandbox-quirks
description: Sandbox facts for riemann-masullo (lake lean, Lake cache, RAM, gh cache, time zones) live in the HANDOVER; key ones here as reminders
metadata:
  type: reference
---

Kept in HANDOVER "Environment", "Lessons" and the header: use `lake lean`, never `lake env lean`; never drop `LAKE_RESTORE_ARTIFACTS`; "Too many open files" on index modules; RAM is the limit (20 GB since 2026-11-22 ~20:30Z, was 16; memguard); `gh` caches 401s (`tokencheck.sh` clears it); the shell is CET, the cron tool UTC; services run at nice 19; sandbox name `riemann-masullo-faststorage`; `rm` with a variable path prompts the user even in bypass ("Dangerous rm operation not ruled out"), so agents use `S/probe.sh` (HUNTER.md "Builds and processes").

**How to apply:** read the HANDOVER sections before relying on a number from memory. Related: [[state-in-dot-agent]], [[github-token-scope]].
