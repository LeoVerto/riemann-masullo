#!/usr/bin/env bash
# Claude subscription usage for the coordinator (replaces `usg`, whose rustls client does not trust
# the sandbox proxy CA). Plain curl: ~/.claude/.credentials.json holds a SENTINEL token that the
# sandbox proxy swaps for the real one on api.anthropic.com, so nothing secret is read or printed here.
# Prints one line:  USAGE 5h=95% (resets in 12m) 7d=22% (resets in 11h03m)  [WARN ...]
# Exit 0 = ok, 1 = above $USAGE_WARN (default 85) in either window, 2 = could not read usage.
# usage.sh --json prints the raw API reply instead.
WARN=${USAGE_WARN:-85}
CRED=${CLAUDE_CREDENTIALS:-$HOME/.claude/.credentials.json}
tok=$(python3 -I -c 'import json,sys;print(json.load(open(sys.argv[1]))["claudeAiOauth"]["accessToken"])' "$CRED" 2>/dev/null) \
  || { echo "USAGE FAIL: no access token in $CRED"; exit 2; }
# token goes via a curl config on stdin, not argv, so it never shows up in `ps`
body=$(printf 'header = "Authorization: Bearer %s"\n' "$tok" |
  curl -sS -m 30 -K - -w '\n%{http_code}' -H 'anthropic-beta: oauth-2025-04-20' \
    https://api.anthropic.com/api/oauth/usage 2>&1) || { echo "USAGE FAIL: curl: $(echo "$body" | tail -1 | cut -c1-120)"; exit 2; }
code=${body##*$'\n'}; body=${body%$'\n'*}
[ "$code" = 200 ] || { echo "USAGE FAIL: HTTP $code $(echo "$body" | head -c 120)"; exit 2; }
[ "${1:-}" = --json ] && { echo "$body"; exit 0; }
python3 -I -c '
import json,sys,datetime as dt
d=json.loads(sys.argv[1]); warn=float(sys.argv[2]); now=dt.datetime.now(dt.timezone.utc)
out=[]; hot=[]
for key,lab in (("five_hour","5h"),("seven_day","7d")):
    w=d.get(key)
    if not w or w.get("utilization") is None: out.append(lab+"=n/a"); continue
    u=w["utilization"]; r=dt.datetime.fromisoformat(w["resets_at"]); m=int((r-now).total_seconds()//60)
    when="window already reset (stale)" if m<0 else ("resets in %dm"%m if m<60 else "resets in %dh%02dm"%(m//60,m%60))
    out.append("%s=%.0f%% (%s)"%(lab,u,when))
    if u>=warn and m>=0: hot.append(lab)
print("USAGE "+" ".join(out)+("  WARN "+"/".join(hot)+" >= %.0f%%"%warn if hot else ""))
sys.exit(1 if hot else 0)
' "$body" "$WARN"
