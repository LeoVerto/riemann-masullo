#!/usr/bin/env bash
# run_sweep.sh <outdir> [extra sweep.py args]   -- sweeps every file with a sorry, 4 at a time
WT=/home/agent/wt/sweep; OUT=$1; shift; mkdir -p "$OUT"
cd $WT
grep -rlw --include=*.lean sorry RiemannMasullo | grep -v External | sort |
  xargs -P ${PAR:-4} -I{} sh -c 'f={}; o='"$OUT"'/$(echo $f | tr / _).json; [ -s $o ] || python3 /home/agent/sweeptools/sweep.py '"$WT"' $f $o '"$*"
