#!/usr/bin/env bash

. $HOME/.bashrc

opdir=${HOME}/operational/pacific_npo_2gr/forecast
today=`date +%Y%m%d`

cd ${opdir}

# download nemo
${opdir}/run_forecast.sh ${today} 7 nemo24 3 |& tee -a ${opdir}/logfile_${today}.log02

# rename file
mv $opdir/d-storage/$today/nemo24_npo0.08_$today.nc $opdir/d-storage/$today/nemo_npo0.08_$today.nc

### the end


