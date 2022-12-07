#!/bin/bash
#

        echo
        echo " +++ Move HINDCAST files to storage JENNY +++ "
        echo

        set -o nounset
        set -o errexit
        set -o pipefail

	today=$1
	ogcm='glby'

	here=`pwd`

	source forecast_setup.sh

	sto1="$here/d-storage/$today"
        sto2="$here/d-storage/$yesterday"

	##################################### MAKE TODAY'S DIR IN STORAGE JENNY

        source step11_sub00_check_jenny_dirs.sh
	cd $here


        #################################### EXTRACT DAY 1 FOR HINDCAST DIR

        echo ; echo " ... extract DAY 1 from files in $sto2 to dir $jenny  "; echo

	roms1="roms_zlevs_jenny_npo0.08_07e_${yesterday}_glby.nc"
	roms2="roms_zlevs_jenny_npo0.0267_01c_${yesterday}_glby.nc"
	ogcm1="glby_zlevs_jenny_npo0.08_07e_${yesterday}.nc"
	ogcm2="nemo_zlevs_jenny_npo0.08_07e_${yesterday}.nc"

	wave1="ww3_his_npo0.33_${yesterday}.nc"
	wave2="noaa_ww3_npo0.25_${yesterday}.nc"

	sat="cmems_sla_vels_atl0.25_${yesterday}.nc"
	mld="mld_npo0.08_07e_${yesterday}.nc"

        outsat="sat_sla+vel_${today}.nc"
        outmld="mld+langmuir_${today}.nc"

        #################  WAVE MODELS: both TOC WW3 and NOAA WW3 are hourly

	if [ -e hindcast.nc ]; then 
		echo " ... file hindcast.nc exists, I am removing it !!!"; echo
		rm hindcast.nc
	fi

        echo; echo " ... WAVE models "; echo

        ncks -h -d time,0,24 $sto2/$wave1  hindcast.nc ; wait ; mv hindcast.nc $jenny/hindcast/Wave_Models/ww3_toc_${today}.nc; wait
	if [ -e hindcast.nc ]; then rm hindcast.nc; fi

        ncks -h -d time,0,24 $sto2/$wave2  hindcast.nc ; wait ; mv hindcast.nc $jenny/hindcast/Wave_Models/ww3_noaa_${today}.nc; wait
        if [ -e hindcast.nc ]; then rm hindcast.nc; fi

        #################  WIND MODEL: GFS is 3 hourly

        echo ; echo " ... WIND models "; echo

        ncks -h -d time,0,8 $sto2/gfs_${yesterday}.nc hindcast.nc ; wait ; mv hindcast.nc $jenny/hindcast/Wind_Models/gfs_${today}.nc; wait
        if [ -e hindcast.nc ]; then rm hindcast.nc; fi


        ##################  OCEAN MODELS: ROMS is hourly, HYCOM is 6 hourly, NEMO is 6 hourly

        echo; echo " ... OCEAN models"; echo

        ncks -h -d time,0,24 $sto2/$roms1 hindcast.nc ; wait ; mv hindcast.nc $jenny/hindcast/Regional_Ocean_Models/roms+hycom_${today}_1.nc; wait
        if [ -e hindcast.nc ]; then rm hindcast.nc; fi

        ncks -h -d time,0,24 $sto2/$roms2 hindcast.nc ; wait ; mv hindcast.nc $jenny/hindcast/Regional_Ocean_Models/roms+hycom_${today}_2.nc; wait
        if [ -e hindcast.nc ]; then rm hindcast.nc; fi

        ncks -h -d time,0,4  $sto2/$ogcm1 hindcast.nc ; wait ; mv hindcast.nc $jenny/hindcast/Regional_Ocean_Models/hycom_${today}.nc; wait
        if [ -e hindcast.nc ]; then rm hindcast.nc; fi

        ncks -h -d time,0,4  $sto2/$ogcm2 hindcast.nc ; wait ; mv hindcast.nc $jenny/hindcast/Regional_Ocean_Models/nemo_${today}.nc; wait
        if [ -e hindcast.nc ]; then rm hindcast.nc; fi

	ncks -h -d time,0,4  $sto2/$mld hindcast.nc ; wait ; mv hindcast.nc $jenny/hindcast/Regional_Ocean_Models/mld+langmuir_${today}.nc; wait
	if [ -e hindcast.nc ]; then rm hindcast.nc; fi

	cp $sto2/$sat hindcast.nc ; wait ; mv hindcast.nc $jenny/hindcast/Regional_Ocean_Models/sat_sla+vel_${today}.nc; wait
        if [ -e hindcast.nc ]; then rm hindcast.nc; fi
	

	### the end

