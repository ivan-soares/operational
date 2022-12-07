#!/bin/bash
#
        #### S112

        today=$1
        ogcm=$2
        here=$3
        log=$4

        source $here/forecast_setup.sh # will load dir names and other info

        #====================================================================================
        echo >> $log; cd $tmpdir; dr=$PWD; now=$(date "+%Y/%m/%d %T")
        echo " ... starting script to move files at $now" >> $log
        echo ; echo " ==> $now HERE I am @ $dr for step 12: move files <=="; echo
        #====================================================================================

        jenny="$HOME/storage-jenny/operational/$today"
	sto1="$stodir/$today"
        sto2="$stodir/$yesterday"

	##################################### MAKE TODAY'S DIR IN STORAGE JENNY

        source step12_sub01_check_jenny_dirs.sh
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

	#ncks -h -d time,0,4  $sto2/$mld   f05.nc ; wait ; mv f05.nc $jenny/hindcast/Regional_Ocean_Models/mld+langmuir_${today}.nc

	cp $sto2/$sat $jenny/hindcast/Regional_Ocean_Models/sat_sla+vel_${today}.nc
	


        echo
        echo " +++ Move FORECAST files to storage JENNY +++"
        echo

        set -o nounset
        set -o errexit
        set -o pipefail

        today=$1
	iopt=$2

        ogcm='glby'

        here=`pwd`

        source forecast_setup.sh
        sto="$here/d-storage/$today"

        ##################################### MAKE TODAY'S DIR IN STORAGE JENNY

        source step11_sub00_check_jenny_dirs.sh
        cd $here

	if [ $iopt == 1 ]; then

		#################  WAVE MODELS

		echo; echo " ... WAVE models "; echo

		cp $sto/$outwave1  $jenny/forecast/Wave_Models/ww3_toc_${today}.nc
		cp $sto/$outwave2  $jenny/forecast/Wave_Models/ww3_noaa_${today}.nc

		#################  WIND MODEL

		echo " ... WIND models "; echo

		gfs_vars="UGRD_10maboveground,VGRD_10maboveground,TCDC_entireatmosphere,TMP_2maboveground,PRMSL_meansealevel"
		ncks -h -v $gfs_vars $sto/gfs_${today}.nc ff.nc ; wait ; mv ff.nc $jenny/forecast/Wind_Models/gfs_${today}.nc; wait


	elif [ $iopt == 2 ]; then

		##################  OCEAN MODELS + MLD + SATELLITE

		echo; echo " ... OCEAN models"; echo

	        cp $sto/$outroms1a    $jenny/forecast/Regional_Ocean_Models/roms+hycom_${today}_1.nc
	        cp $sto/$outroms2a    $jenny/forecast/Regional_Ocean_Models/roms+hycom_${today}_2.nc
	        cp $sto/$outogcm1a    $jenny/forecast/Regional_Ocean_Models/hycom_${today}.nc
	        cp $sto/$outogcm2a    $jenny/forecast/Regional_Ocean_Models/nemo_${today}.nc

		#### satellite data will not go FORECAST dir

		cp $satfile     $jenny/forecast/Regional_Ocean_Models/$outsat
	
		### MLD & LANGMUIR

		cp $mldfile     $jenny/forecast/Regional_Ocean_Models/$outmld

	fi

### the end

