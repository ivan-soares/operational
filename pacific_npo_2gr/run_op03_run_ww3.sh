#!/usr/bin/env bash

. $HOME/.bashrc

opdir=${HOME}/operational/pacific_npo_2gr/forecast
today=`date +%Y%m%d`

cd ${opdir}

# download GFS & run WW3
${opdir}/run_forecast.sh ${today} 7 glby 1267 |& tee -a ${opdir}/logfile_${today}.log03a

# download NOAA WW3
${opdir}/run_forecast.sh ${today} 7 glby 8 |& tee -a ${opdir}/logfile_${today}.log03b

# move files to storage jenny
${opdir}/xtra_move_forecast_files_to_jenny.sh $today 1 |& tee -a ${opdir}/logfile_${today}.log03c

### the end


