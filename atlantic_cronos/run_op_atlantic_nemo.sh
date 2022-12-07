#!/usr/bin/env bash

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
opdir=${__dir}/forecast
logdir=$opdir/d-outputs/logfiles

today=$(date +%Y%m%d)

# This will download GFS and create the main log file
${opdir}/run_forecast.sh today 7 nemo 1 2 |& tee -a op_nemo_${today}.log

# Now we run the two jobs below for ROMS and WW3
${opdir}/run_forecast.sh today 7 nemo 3 4 5 |& tee -a op_nemo_${today}_roms.log &
${opdir}/run_forecast.sh today 7 nemo 6 7 |& tee -a op_nemo_${today}_ww3.log &

# Together with ROMS and WW3 we can download observations from yesterday: SLA and MultiOBS
${opdir}/run_forecast.sh yesterday 1 nemo 9 |& tee -a op_nemo_${today}.log

# Together with ROMS and WW3 we can download observations from yesterday: SIMCOSTA
${opdir}/run_forecast.sh yesterday 1 nemo 8 |& tee -a op_nemo_${today}.log

# Wait until everything up to step 9 is complete (steps 5 and 7 should be done before 9)
wait

# Send output of steps 3-7 to the main log file
cat op_nemo_${today}_roms.log >> op_nemo_${today}.log
cat op_nemo_${today}_ww3.log  >> op_nemo_${today}.log
rm -f op_nemo_${today}_roms.log op_nemo_${today}_ww3.log

# Finally run step 10
${opdir}/run_forecast.sh today 1 nemo 10 |& tee -a op_nemo_${today}.log

# Moving log files from $HOME to d-outputs 
mv op_nemo_${today}.log $logdir/