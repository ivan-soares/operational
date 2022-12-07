#!/bin/bash
#
	#### S11

	today=$1
	
	here=$PWD

	yr=${today:0:4}
	mm=${today:4:2}
	dd=${today:6:2}

	#====================================================================================
	dr=$PWD; now=$(date "+%Y/%m/%d %T")
	echo ; echo " ==> $now HERE I am @ $dr to move files to storage <=="; echo
	#====================================================================================

	storage="$HOME/storage_at01/environment/atmos_gfs/gfsanl_glo0.25_2022_03h"

	echo
	echo " ... today is ${yr}-${mm}-${dd}"
	echo " ... will move files to storage $storage"
	echo

        ################ set file names !!!!!!!

        windfile="d-storage/$today/gfs_${today}.nc"

	################ select first day !!!!!!!

	ncks -d time,0,8 $windfile $storage/gfs_${today}.nc

	#====================================================================================
	now=$(date "+%Y/%m/%d %T")
	echo " ==> $now FINISHED post processing files <=="; echo
	#====================================================================================

	cd $here

#### the end
