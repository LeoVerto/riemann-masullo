#!/usr/bin/env bash
# Watchdog for the low-hanging-fruit campaign.
#  - If no Claude transcript under the project dir has changed for $STALE seconds, the session is
#    assumed to be out of tokens: every issue in claims.txt that has no open PR by LeoVerto is
#    released ("Releasing" comment, which the upstream Claims workflow acts on).
#  - Then it probes the API every $PROBE seconds; when a probe succeeds it resumes the session
#    (claude --resume <id>) with a continuation prompt. Only one resume runs at a time.
# Run:  nohup /home/agent/sweeptools/watchdog.sh >/home/agent/sweeptools/watchdog.log 2>&1 &
set -u
T=/home/agent/sweeptools
PROJ=/home/agent/.claude/projects/-home-user-git-riemann-masullo
REPO=/home/user/git/riemann-masullo
SESSION=${SESSION:-ff69c771-f0e3-4605-a699-65a30fd82b57}
STALE=${STALE:-1200}; RESUME_AFTER=${RESUME_AFTER:-7200}; PROBE=${PROBE:-900}
UP=mccorvie/riemann-masullo
touch "$T/claims.txt"
log() { echo "$(date -Is) $*"; }

# Only Claude transcripts (this session and its subagents) count as activity: background services
# (warm base, sweep) keep running when the agents are halted.
newest() { find "$PROJ" -name '*.jsonl' -printf '%T@\n' 2>/dev/null | sort -n | tail -1 | cut -d. -f1; }

release_claims() {
  local open n
  open=$(gh pr list --repo $UP --author LeoVerto --state open --json body --jq '.[].body' 2>/dev/null)
  for n in $(sort -u "$T/claims.txt"); do
    if grep -qiE "(closes|fixes|resolves) #$n\b" <<<"$open"; then continue; fi
    log "releasing #$n"
    gh issue comment "$n" --repo $UP --body "Releasing: the session working on this ran out of budget before handing in. It may be picked up again later." >/dev/null && \
      sed -i "/^$n\$/d" "$T/claims.txt"
  done
}

released=0
while true; do
  now=$(date +%s); last=$(newest); idle=$(( now - ${last:-0} ))
  if [ "$idle" -lt "$STALE" ]; then released=0; sleep 120; continue; fi
  if [ $released = 0 ]; then log "idle ${idle}s: releasing claims"; release_claims; released=1; fi
  if [ "$idle" -lt "$RESUME_AFTER" ]; then sleep 120; continue; fi
  if [ -e "$T/resume.lock" ] && kill -0 "$(cat "$T/resume.lock")" 2>/dev/null; then sleep "$PROBE"; continue; fi
  if [ -e "$T/no-resume" ]; then sleep "$PROBE"; continue; fi
  if timeout 120 claude -p "Reply with the single word ok." 2>/dev/null | grep -qi ok; then
    log "API available again: resuming session $SESSION"
    ( cd "$REPO" && timeout 36000 claude --dangerously-skip-permissions --resume "$SESSION" -p \
      "The session was interrupted (likely out of tokens) and a watchdog resumed it. Continue the low-hanging-fruit campaign as before: read the memory note low-hanging-sweep, check /home/agent/sweeptools/ (claims.txt, results), check open LeoVerto PRs upstream, re-claim and continue. Keep the main session lean and delegate to subagents." \
      >>"$T/resume.log" 2>&1 ) &
    echo $! >"$T/resume.lock"
    released=0
  else
    log "probe failed; API not available yet"
  fi
  sleep "$PROBE"
done
