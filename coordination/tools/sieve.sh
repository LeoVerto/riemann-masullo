#!/usr/bin/env bash
# sieve service wrapper: restarts the python loop if it dies. See SIEVE.md.
cd /mnt/faststorage/math/riemann-masullo/.agent/sweeptools || exit 1
echo $$ > sieve/wrapper.pid
while true; do nice -n 10 python3 sieve.py; echo "sieve.py exited $?, restart in 60s"; sleep 60; done
