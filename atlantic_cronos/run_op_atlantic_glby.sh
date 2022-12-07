#!/usr/bin/env bash

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
opdir=${__dir}/forecast
logdir=$opdir/d-outputs/logfiles

today=$(date +%Y%m%d)

# Cleanup and archive
${opdir}/run_forecast.sh today 6 glby 11 |& tee -a op_archive_${today}.log &

# Run ROMS
${opdir}/run_forecast.sh today 6 glby 3 4 5 |& tee -a op_glby_${today}.log

# Moving log files from $HOME to d-outputs 
mv op_archive_${today}.log $logdir/
mv op_glby_${today}.log $logdir/