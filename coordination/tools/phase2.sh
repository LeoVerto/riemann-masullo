#!/usr/bin/env bash
# Wait for pass 1 (xargs pid $1), refresh the sweep worktree to origin/main, re-sweep changed
# files with the cheap tactics, then run the exact? pass on every file with a sorry.
set -u
T=/mnt/faststorage/math/riemann-masullo/.agent/sweeptools; WT=/mnt/faststorage/math/riemann-masullo/.agent/wt/sweep
while kill -0 $1 2>/dev/null; do sleep 15; done
cd $WT
[ -z "$(git status --porcelain | grep -v '^?? RiemannMasullo/Sweep')" ] || { echo "sweep worktree dirty"; git status --short; exit 1; }
old=$(git rev-parse HEAD)
git -C /mnt/faststorage/math/riemann-masullo fetch -q origin
git checkout -q --detach origin/main
new=$(git rev-parse HEAD); echo "refreshed $old -> $new"
lake build 2>&1 | tail -2
lake build RiemannMasullo.Sweep RiemannMasullo.Sweep2 2>&1 | tail -1
git diff --name-only $old $new -- RiemannMasullo | while read f; do rm -f "$T/res1/$(echo $f | tr / _).json"; done
echo "$new" > $T/swept_commit
PAR=4 $T/run_sweep.sh $T/res1
grep -rlw --include=*.lean sorry RiemannMasullo | grep -v External | sort > $T/all_files.txt
PAR=${PAR2:-2} $T/run_list.sh $T/res2 $T/all_files.txt --exact --timeout 5400
echo phase2 done
