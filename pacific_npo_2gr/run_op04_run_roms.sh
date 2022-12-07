#!/usr/bin/env bash

. $HOME/.bashrc

opdir=${HOME}/operational/pacific_npo_2gr/forecast
today=`date +%Y%m%d`

cd ${opdir}

# download GLBy, make input files, run ROMS
${opdir}/run_forecast.sh ${today} 7 glby 134 |& tee -a ${opdir}/logfile_${today}.log04

### the end


