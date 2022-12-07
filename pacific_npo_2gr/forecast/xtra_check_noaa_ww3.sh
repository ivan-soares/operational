#!/bin/bash
#

#    script to run 7-day forecast

        set -o nounset
        set -o errexit
        set -o pipefail


####################################################################################################

        today=$1
        ndays=$2

	ogcm='glby'
	here=`pwd`
	log='log'

	noaa_ndat=137

        #### fix ndays in step00

        sed -i "/ndays=/ c\        ndays=$ndays "  forecast_setup.sh
	source forecast_setup.sh

        #### will check integrity of file named:
	operdir="$HOME/forecast/d-storage/${today}"
	outfile="$operdir/noaa_ww3_npo0.25_${today}.nc"

        echo 
        echo " ... check file $outfile, and if it is not OK download it again !!"
        echo

	nn=1
	ntry=5

	while [ $nn -le $ntry ]; do

		## check procedure will create a file named check_status

		check=0
		check_ogcm.sh $outfile $noaa_ndat $log
		check=`cat check_status`
		rm check_status

		echo; echo " ... after check procedure check status is $check"; echo

		if [ $check == 0 ]; then
			echo " ... %%%%%% Downloaded file is OK !! %%%%%%"
			break
		else
			echo " ... %%%%%% Downloaded file is NOT OK !! will download it again %%%%%%"
			./step08_download_obs.sh    $today $ogcm $here $log
		fi
		let nn=$nn+1

	done

        echo 
        echo " ... end of check integrity of file $outfile"
        echo


