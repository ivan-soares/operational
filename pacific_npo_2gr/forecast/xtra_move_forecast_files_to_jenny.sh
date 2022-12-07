#!/bin/bash
#

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

		echo; echo " ... move WAVE models files to JENNY "; echo

		cp $sto/$outwave1  $jenny/forecast/Wave_Models/ww3_toc_${today}.nc
		cp $sto/$outwave2  $jenny/forecast/Wave_Models/ww3_noaa_${today}.nc

		#################  WIND MODEL

		echo " ... WIND models "; echo

		gfs_vars="UGRD_10maboveground,VGRD_10maboveground,TCDC_entireatmosphere,TMP_2maboveground,PRMSL_meansealevel"
		ncks -h -v $gfs_vars $sto/gfs_${today}.nc ff.nc ; wait ; mv ff.nc $jenny/forecast/Wind_Models/gfs_${today}.nc; wait


	elif [ $iopt == 2 ]; then

		##################  OCEAN MODELS: HYCOM + ROMS

		echo; echo " ... move ROMS + HYCOM to JENNY"; echo

	        cp $sto/$outroms1a    $jenny/forecast/Regional_Ocean_Models/roms+hycom_${today}_1.nc
	        cp $sto/$outroms2a    $jenny/forecast/Regional_Ocean_Models/roms+hycom_${today}_2.nc
	        cp $sto/$outogcm1a    $jenny/forecast/Regional_Ocean_Models/hycom_${today}.nc

        elif [ $iopt == 3 ]; then

                ##################  OCEAN MODELS: NEMO + SAT + MLD

                echo; echo " ... move NEMO, SAT + MLD files to JENNY"; echo

	        cp $sto/$outogcm2a    $jenny/forecast/Regional_Ocean_Models/nemo_${today}.nc

		#### satellite data will not go FORECAST dir

		cp $satfile     $jenny/forecast/Regional_Ocean_Models/$outsat
	
		### MLD & LANGMUIR

		cp $mldfile     $jenny/forecast/Regional_Ocean_Models/$outmld

	fi

        echo
        echo " +++ END of Move FORECAST files +++"
        echo

### the end

