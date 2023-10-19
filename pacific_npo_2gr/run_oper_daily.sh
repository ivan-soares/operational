#!/usr/bin/env bash

. $HOME/.bashrc

opdir=${HOME}/operational/pacific_npo_2gr/forecast
today=`date +%Y%m%d`

cd ${opdir}

# clean temporary dir., download GFS, GLBy, NEMO & run ROMS
${opdir}/run_forecast.sh ${today} 1 nemo 12345 |& tee -a ${opdir}/logfile_${today}.log

# clean temporary dir., download GLBy
#${opdir}/run_forecast.sh ${today} 7 glby 13 |& tee -a ${opdir}/logfile_${today}.log2
