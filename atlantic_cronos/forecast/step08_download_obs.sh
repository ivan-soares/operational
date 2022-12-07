#!/usr/bin/env bash
#

#  script to download NOAA WW3 data

       #====================================================================================
       echo >> $log ; cd $tmpdir; dr=`pwd`
       echo ; echo " ==> HERE I am @ $dr for step 08: download NOAA & SIMCOSTA <=="; echo
       now=$(date "+%Y/%m/%d %T"); echo " ... download observations at $now" >> $log
       #====================================================================================

       date1=$(date -d ${yr}-${mm}-${dd} +%s)

       echo
       echo " ... today is ${yr}/${mm}/${dd} , numdate is $date1"
       echo " ... will store outputs in folder $stodir"
       echo
       
       ### download NOAA global ww3

       outfile="noaa_ww3_brz0.50_${today}.nc"

       get_ww3_one_day+forecast.sh $today $nhrs $dh_noaa $wesn_ww3         
       cdo mergetime ww3_noaa_*.nc  $outfile
       mv $outfile $stodir/$today/.
       mv ww3_noaa_20*.nc $trunk/.

       ### download SIMCOSTA dados oceanicos
       ### will downlod a file named "simcosta_ocean_station_YYYY-MM-DD.csv"
       ### rs4=14, rj4=12, rj2=2


       for buoy in 14 12; do
	   case $buoy in
	        14)
		station="rs4"
		;;
		12)
		station="rj4"
		;;
		2)
		station="rj2"
		;;
		*)
		exit
           esac

           get_simcosta_ocean.sh ${yr}-${mm}-${dd} $station $buoy
           buoyfile="simcosta_ocean_${station}_${yr}-${mm}-${dd}"
           rm -rf ${buoyfile}.dat
           echo "# SIMCOSTA Buoy $buoy Station $station" >& ${buoyfile}.dat
           echo "# year month day hour minute seconds vars" >> ${buoyfile}.dat

           while read line; do
	         year=`echo $line | sed -e 's/,/ /g' | awk '{print $1}'`
	         if [ $year == 2020 ]; then
	              y2=`echo $line | sed -e 's/,/ /g' -e 's/NULL/0.00/g' | awk '{if($1 == 2020) printf "%4.4d", $1}'`
	              m2=`echo $line | sed -e 's/,/ /g' -e 's/NULL/0.00/g' | awk '{if($1 == 2020) printf "%2.2d", $2}'`
	              d2=`echo $line | sed -e 's/,/ /g' -e 's/NULL/0.00/g' | awk '{if($1 == 2020) printf "%2.2d", $3}'`
	              date2=$(date -d ${y2}-${m2}-${d2} +%s)
	              if [ $date2 -ge $date1 ]; then
	                   echo " ... date = $date2 , yy-mm-dd = ${y2}-${m2}-${d2}"
	                   echo $line | sed -e 's/,/ /g' -e 's/NULL/0.00/g' >> ${buoyfile}.dat
	              fi
	         fi
	   done < ${buoyfile}.csv
           mv ${buoyfile}.dat $stodir/$today/.
       done

       ### download SIMCOSTA maregrafos
       ### will downlod a file named "simcosta_mare_station_YYYY-MM-DD.csv"

       for buoy in 2675 2677 2673; do
	   case $buoy in
                2675)
                station="ilha_bela"
		;;
	        2677)
	        station="suape"
		;;
	        2673)
		station="pecem"
		;;
	        *)
		exit
           esac
       
	   get_simcosta_mare.sh ${yr}-${mm}-${dd} $station $buoy
           buoyfile="simcosta_mare_${station}_${yr}-${mm}-${dd}"
	   rm -rf ${buoyfile}.dat
	   echo "# SIMCOSTA Buoy $buoy Station $station" >& ${buoyfile}.dat
	   echo "# year month day hour minute seconds sea-level(cm)" >> ${buoyfile}.dat

           while read line; do
             year=`echo $line | sed -e 's/,/ /g' | awk '{print $1}'`
             if [ $year == 2020 ]; then
                  y2=`echo $line | sed -e 's/,/ /g' -e 's/NULL/0.00/g' | awk '{if($1 == 2020) printf "%4.4d", $1}'`
                  m2=`echo $line | sed -e 's/,/ /g' -e 's/NULL/0.00/g' | awk '{if($1 == 2020) printf "%2.2d", $2}'`
                  d2=`echo $line | sed -e 's/,/ /g' -e 's/NULL/0.00/g' | awk '{if($1 == 2020) printf "%2.2d", $3}'`
                  date2=$(date -d ${y2}-${m2}-${d2} +%s)
                  if [ $date2 -ge $date1 ]; then
                     echo " ... date = $date2 , yy-mm-dd = ${y2}-${m2}-${d2}"
		     echo $line | sed -e 's/,/ /g' -e 's/NULL/0.00/g' >> ${buoyfile}.dat
                  fi
             fi
           done < ${buoyfile}.csv

           mv ${buoyfile}.dat $stodir/$today/.
       done

       #====================================================================================
       echo ; echo " ==> FINISHED downloading NOAA & SIMCOSTA <=="; echo
       now=$(date "+%Y/%m/%d %T"); echo " ... finished downloading obs at $now" >> $log
       #====================================================================================

       cd ${__dir}

################################# *** the end *** ################################################

