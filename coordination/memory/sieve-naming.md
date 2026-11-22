---
name: sieve-naming
description: Our automated tactic screen is called the "sieve" (service sieve.sh, hand-in role "siever", brief SIEVER.md) to avoid confusion with upstream's "sweeper" role
metadata:
  type: project
---

Named 2026-11-22 at the user's request. Upstream's `sweeper` (prompts/sweeper.md) is a reasoning agent that closes out one file's hard tail; ours is a mechanical tactic screen over every sorry.
- Service: `.agent/sweeptools/sieve.sh` (formerly "autosweep"), docs SIEVE.md, state in sieve/ (hits.tsv, swept.tsv, res/), worktree .agent/wt/sieve, status.sh section `== sieve`.
- Hand-in agent: "siever" (SIEVER.md, Sonnet medium), launched on READY/HINT lines.
- Low-level tools keep old names: sweep.py, lean/Sweep*.lean.txt, res1–res4; "sweep4" was the first one-off sieve run.
- Yield so far is low (e.g. #4035 via the unfold pass). Old `lake env lean` results are archived in sieve/old-envlean/.
- shortlist.py caveats: "paper: no proof" only means no PROOF before the next item, and paper:SHORT over-fires on "This follows…".
Related: [[low-hanging-sweep]], [[claims-notes-attribution]].
