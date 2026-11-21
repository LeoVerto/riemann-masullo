#!/usr/bin/env bash
# run_list.sh <outdir> <listfile> [sweep.py args] -- sweep the files in listfile, PAR at a time
WT=${WT:-/home/agent/wt/sweep}; OUT=$1; LIST=$2; shift 2; mkdir -p "$OUT"; cd $WT
xargs -P ${PAR:-4} -I{} sh -c 'f={}; o='"$OUT"'/$(echo $f | tr / _).json; [ -s $o ] || python3 /home/agent/sweeptools/sweep.py '"$WT"' $f $o '"$*" < "$LIST"
