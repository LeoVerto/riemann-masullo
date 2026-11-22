---
name: cpu-cheap-tokens-scarce
description: User rule - CPU time is cheap, tokens are the bottleneck; automate before reasoning
metadata:
  type: feedback
---

The user, 2026-11-22: "CPU time is cheap, tokens are the bottleneck".

**Why:** the usage window has repeatedly limited the campaign while the machine sat idle.

**How to apply:** prefer scripts and services (sieve, shortlist, status.sh, prior.sh, resumable.sh) over agent reasoning, give agents only hits and leads, keep tool output short, and keep wake-ups sparse. Agents wait as HUNTER.md "Builds and processes" says. RAM, not cost, limits parallel CPU work. Related: [[coordinator-only]], [[subagent-resume-cost]].
