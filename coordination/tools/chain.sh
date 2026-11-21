#!/usr/bin/env bash
# wait for the given pids, then run the exact? pass on every remaining file
for p in "$@"; do while kill -0 $p 2>/dev/null; do sleep 15; done; done
T=/home/agent/sweeptools
cd /home/agent/wt/sweep && grep -rlw --include=*.lean sorry RiemannMasullo | grep -v External | grep -v Sweep | sort | grep -vxF -f $T/exact_now.txt > $T/all_files.txt
PAR=${PAR2:-1} $T/run_list.sh $T/res2 $T/all_files.txt --exact --timeout 5400
echo chain done
