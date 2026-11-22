#!/usr/bin/env bash
# prior.sh <issue>: list our earlier work on an issue, to build on instead of starting over.
# Notes (live and released), reports, saved patches, queue/status/lead lines, local commits and
# worktrees that mention the issue number or its declaration. Upstream `Releasing` comments are not
# included: read them with `gh issue view <n> --repo mccorvie/riemann-masullo --comments`.
set -u
S=/mnt/faststorage/math/riemann-masullo/.agent/sweeptools; R=${S%/.agent/sweeptools}
n=${1:?usage: prior.sh <issue>}
decl=$(awk -F'\t' -v n="$n" '$1==n {sub(/.*::/, "", $3); print $3; exit}' "$S/issues.tsv")
[ -n "$decl" ] || decl=$(awk -F'\t' -v n="$n" 'FNR==1 {ok = ($3=="decl" && $4=="issue")}
  ok && $4==n {print $3; exit}' "$S"/shortlist/*.tsv)
pat="#$n\\b|\\b$n\\b${decl:+|\\b$decl\\b}"
echo "#$n ${decl:-?}"
[ -s "$S/notes/$n.md" ] && echo "notes:    notes/$n.md"
for f in "$S"/notes/released/"$n"-*.md; do [ -e "$f" ] && echo "released: ${f#$S/}"; done
grep -lsE "$pat" "$S"/notes/report-*.md "$S"/notes/reports-done/*.md | sed "s|^$S/|report:   |"
[ -n "$decl" ] && grep -lsw -- "$decl" "$S"/patches/* | sed "s|^$S/|patch:    |"
for f in escalations.txt critical/status.txt leads.txt findings.txt; do
  grep -sE "^$n\\b" "$S/$f" | sed "s|^|$f: |" | cut -c1-200
done
git -C "$R" log --all --oneline -E --grep="$pat" 2>/dev/null | head -5 | sed 's/^/commit:   /'
for w in "$R"/.agent/wt/*-"$n"; do [ -d "$w" ] && echo "worktree: ${w#$R/}"; done
exit 0
