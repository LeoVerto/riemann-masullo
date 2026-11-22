---
name: paper-findings-opus
description: Paper findings are checked by one Fable evaluator (was Opus) before they are raised upstream
metadata:
  type: feedback
---

The user, 2026-11-22 ~16:00Z: "Paper findings should be evaluated by Opus and then raised."; ~21:40Z: "I'd prefer for findings to be run by fable instead of opus" (supersedes the model choice); later: refutations too — "I trust it to make the call on whether a finding is refutable", with my recommendations accepted (post the finding first, an Opus escalator writes the Lean from the Fable's sketch) and "take refutation issues too".

**Why:** unchecked findings upstream would cost the integrator time and our credibility.

**How to apply:** agents write `Finding:` lines and never post them; refutable ones become `refute` rows (FINDINGS.md, HUNTER.md "Refutations"); FINDINGS.md (type `findings-evaluator`) and HOURLY.md step 9. Posting confirmed findings is a standing exception to asking first (HANDOVER "Upstream posting"). Related: [[read-docs-origin-main]], [[collaborative-not-race]].
