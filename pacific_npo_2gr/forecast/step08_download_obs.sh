#!/bin/bash
#

        #### S08

	today=$1
	ogcm=$2
	here=$3
	log=$4

	source $here/forecast_setup.sh # will load dir names and other info

	#====================================================================================
	echo ; cd $tmpdir; dr=`pwd`; now=$(date "+%Y/%m/%d %T"); echo >> $log
	echo " ... starting download of NOAA WW3 & buoys at $now" >> $log; echo >> $log
	echo " ==> $now HERE I am @ $dr for step 08: download NOAA WW3 & buoys <=="; echo
	#====================================================================================

	date1=$(date -d ${yr}-${mm}-${dd} +%s)

	echo
	echo " ... today is ${yr}/${mm}/${dd} , numdate is $date1"
	echo " ... will download $nhrs_ww3 hrs, every $dh_noaa hrs"
	echo " ... will store outputs in folder $stodir"
	echo

	### download NOAA global ww3

	outfile="noaa_ww3_npo0.25_${today}.nc"

	get_ww3_one_day+forecast.sh $yr $mm $dd $nhrs_ww3 $dh_noaa $wesn_ww3         
	mv ww3_${yr}-${mm}-${dd}.nc  $outfile
	mv $outfile $stodir/$today/.

	### download NOAA Buoys

	URL="https://www.ndbc.noaa.gov/data/5day2/BBBBB_5day.txt"

	for buoy in 46002 46006 46059 46213 46214 51000; do
	   case $buoy in
		46213 | 46214)
		station="coastal"
		;;
		46002 | 46006 | 46059)
		station="oceanic"
		;;
		51000)
		station="hawaii"
		;;
		*)
		echo  " ... Wrong domain name, exiting ..."
		exit 1
	   esac

	   echo
	   echo " ... downloading Buoy $buoy, station type $station"
	   echo

	   url=${URL/BBBBB/$buoy}
	   wget $url

	   grep "#YY"          ${buoy}_5day.txt >& $stodir/$today/noaa_buoy_${buoy}_5day_${today}.dat
	   grep "#yr"          ${buoy}_5day.txt >> $stodir/$today/noaa_buoy_${buoy}_5day_${today}.dat
	   grep "$yy $mm $dd"  ${buoy}_5day.txt >> $stodir/$today/noaa_buoy_${buoy}_5day_${today}.dat

	done

	#====================================================================================
	echo ; now=$(date "+%Y/%m/%d %T"); echo >> $log
	echo " ... finished downloading at $now" >> $log; echo >> $log
	echo " ==> $now FINISHED downloading NOAA WW3 & buoys <=="; echo
	#====================================================================================

	cd $here

################################# *** the end *** ################################################

