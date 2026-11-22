---
name: critical-path-workstream
description: Opus prover workstream in riemann-masullo - since 2026-11-22 07:30Z any open unclaimed issue (no cone ranking); brief, results and what the cone mapping found
metadata:
  type: project
---

Started 2026-11-21 ~17:00Z at the user's request: an Opus mapper built an "anchored cone" of sorries behind the paper's endgame, and one Opus prover worked per issue. Files: `.agent/sweeptools/critical/` (CRITICAL_PROVER.md brief, QUEUE.md candidate routes, BLOCKERS.md, graph.tsv, status.txt results).

**Current rule (user, 2026-11-22 ~07:30Z):** "The cone doesn't matter at this point ... Just pick any open issue for Opus." An Opus prover takes any open, unclaimed proof issue (not gap/refutation/ERRATA/paper-gap, not sweep-held). No remapping. A fresh Opus hunter is the last resort for an Opus slot, after escalation and our prior work ([[quick-wins-mode]]). Launch: "Read S/critical/CRITICAL_PROVER.md and follow it. Your issue is #<n>. Your model tag <M> is Claude Opus 5.5, default effort." Use model opus with no effort override, worktree wt/crit-<n>, branch crit/<n>.

Findings:
- Main.lean's own cone is empty (it imports only Statements). **Never raise this upstream** (BLOCKERS §0): the user says Main.lean integration is wave 4 or later, by the project coordinator's choice.
- Results: #3660 (#1223), #3681 (#1906), #3823 (#1219), #3978 (#1902), #3993 (#1885), #4021 (#2663), #4375 (#3484 split), #5045 (#1526). #2526 was in progress at the 11:32Z halt (plan SPLIT, notes released).
- A prover that finishes with a warm cache may take ONE related issue via SendMessage (it worked for #1885 after #1902). Then retire it.
- `scripts/agent.sh` is unusable here: it assumes the integrator's layout and pushes to origin.

Related: [[low-hanging-sweep]], [[quick-wins-mode]], [[coordinator-only]].
