#!/usr/bin/env bash

. $HOME/.bashrc

opdir=${HOME}/operational/pacific_npo_2gr/forecast
today=`date +%Y%m%d`

cd ${opdir}

# download satellite SLA
${opdir}/run_forecast.sh ${today} 7 glby 9 |& tee -a ${opdir}/logfile_${today}.log05a

# interp data to zlevs
#${opdir}/run_forecast.sh ${today} 7 glby 1
${opdir}/run_forecast.sh ${today} 7 glby 11 |& tee -a ${opdir}/logfile_${today}.log05b

# move files to jenny
${opdir}/xtra_move_forecast_to_jenny.sh $today 2 |& tee -a ${opdir}/logfile_${today}.log05c
${opdir}/xtra_move_forecast_to_jenny.sh $today 3 |& tee -a ${opdir}/logfile_${today}.log05d



### the end


