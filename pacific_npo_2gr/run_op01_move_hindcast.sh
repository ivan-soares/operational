#!/usr/bin/env bash

. $HOME/.bashrc

opdir=${HOME}/operational/pacific_npo_2gr/forecast
today=`date +%Y%m%d`

cd ${opdir}

# move hindcast data to storage jenny
${opdir}/xtra_move_hindcast_files_to_jenny.sh $today |& tee -a ${opdir}/logfile_${today}.log01a

yesterday=`date  --date="2 days ago" +%Y%m%d`

# move hindcast data to storage roms
${opdir}/xtra_move_hindcast_files_to_storage.sh $yesterday |& tee -a ${opdir}/logfile_${today}.log01b

### the end


