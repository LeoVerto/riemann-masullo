---
name: cpu-cheap-tokens-scarce
description: In riemann-masullo campaigns CPU time is cheap and tokens are the bottleneck; trade compute for tokens everywhere
metadata:
  type: feedback
---

The user, 2026-11-22: "CPU time is cheap, tokens are the bottleneck".

**Why:** the usage window (tokens) has repeatedly limited the campaign; the machine sits idle between agent turns.

**How to apply:**
- Prefer automated discovery over agent reasoning: run the tactic sweeps (sweep.py, `exact?`, aesop chains) broadly, with generous timeouts, over every new or timed-out file, and give agents only the hits and leads.
- Agents wait on builds with one background `until`-loop or `build.sh`, not with repeated polling turns; long builds are fine.
- Briefs tell agents to try cheap automation (`exact?`, `apply?`, `aesop`, `simp?`, `fun_prop`, `positivity`) under `timeout` before thinking hard, and to keep their tool output short (tail, grep) since output costs tokens.
- Coordinator: script the checks (status.sh) rather than reading raw data; fewer, sparser wake-ups.
- The limit on parallel CPU work is RAM (memguard, 15 GB), not cost.

Related: [[coordinator-only]], [[subagent-resume-cost]], [[low-hanging-sweep]].
