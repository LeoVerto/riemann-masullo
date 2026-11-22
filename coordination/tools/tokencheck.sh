#!/usr/bin/env bash
# Startup check: the sandbox GitHub token must be a CLASSIC token with scopes repo, workflow, read:org.
# A fine-grained PAT (no X-OAuth-Scopes header) gets 403 on upstream comments/PRs and cannot push workflow files to the fork.
# Exit 0 = OK; 1 = missing scopes / fine-grained; 2 = auth failure. Prints one line.
REQUIRED="repo workflow read:org"
rm -rf ~/.cache/gh   # gh caches API responses (incl. 401s) for 24 h
hdr=$(timeout 30 gh api -i user 2>&1) || { echo "TOKEN FAIL: gh api user failed: $(echo "$hdr" | grep -m1 -iE 'HTTP|message' | cut -c1-120)"; exit 2; }
login=$(echo "$hdr" | sed -n 's/.*"login": *"\([^"]*\)".*/\1/p' | head -1)
scopes=$(echo "$hdr" | grep -i '^x-oauth-scopes:' | cut -d: -f2- | tr -d ' \r')
exp=$(echo "$hdr" | grep -i '^github-authentication-token-expiration:' | cut -d: -f2- | sed 's/^ *//;s/\r//')
if [ -z "$scopes" ]; then echo "TOKEN FAIL: $login has no X-OAuth-Scopes (fine-grained PAT?); need a classic token with: $REQUIRED"; exit 1; fi
missing=""; for s in $REQUIRED; do echo ",$scopes," | grep -q ",$s," || missing="$missing $s"; done
if [ -n "$missing" ]; then echo "TOKEN FAIL: $login missing scopes:$missing (has: $scopes)"; exit 1; fi
echo "TOKEN OK: $login scopes=$scopes expires=${exp:-never}"
