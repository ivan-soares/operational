#!/bin/bash
#

	today=$1
	ndays=$2
	nn=1

	yr=${today:0:4}
	mm=${today:4:2}
	dd=${today:6:2}

        echo
        echo " +++ Starting code to check files  +++"
        echo


	rdomain01='npo0.08_07e'
	rdomain02='npo0.0267_01c'

	wdomain01='pac1.00'
	wdomain02='npo0.33'

	oper="$HOME/oper/pacific_npo_2gr/forecast"


	while [ $nn -le $ndays ]; do

		echo; echo " ... extracting files for day $yr/$mm/$dd "; echo

		tomorrow=`find_tomorrow.sh $yr $mm $dd`
		y1=${tomorrow:0:4}
		m1=${tomorrow:4:2}
		d1=${tomorrow:6:2}
		tomorrow2=`find_tomorrow.sh $y1 $m1 $d1`

		day1="$oper/d-storage/$today"
		day2="$oper/d-storage/$tomorrow"

                #echo; echo " ... gfs   "; echo ; ncks -h -d time,8,  $day1/gfs_${today}.nc    $day2/gfs_${tomorrow}.nc

		echo; echo " ... hycom "; echo ; ncks -h -d time,4,  $day1/glby_npo0.08_${today}.nc   $day2/glby_npo0.08_${tomorrow}.nc
                #echo; echo " ... nemo  "; echo ; ncks -h -d time,4,  $day1/nemo_npo0.08_${today}.nc   $day2/nemo_npo0.08_${tomorrow}.nc

                echo; echo " ... roms his 1 "; echo ; ncks -h -d ocean_time,24,   $day1/roms_his_${rdomain01}_${today}_glby.nc  $day2/roms_his_${rdomain01}_${tomorrow}_glby.nc
                echo; echo " ... roms his 2 "; echo ; ncks -h -d ocean_time,24,   $day1/roms_his_${rdomain02}_${today}_glby.nc  $day2/roms_his_${rdomain02}_${tomorrow}_glby.nc

                echo; echo " ... roms rst 1 "; echo ; ncks -h -d ocean_time,1,   $day1/roms_rst_${rdomain01}_${tomorrow}_glby.nc   $day2/roms_rst_${rdomain01}_${tomorrow2}_glby.nc
                echo; echo " ... roms rst 2 "; echo ; ncks -h -d ocean_time,1,   $day1/roms_rst_${rdomain02}_${tomorrow}_glby.nc   $day2/roms_rst_${rdomain02}_${tomorrow2}_glby.nc


                #echo; echo " ... ww3 noaa  "; echo ; ncks -h -d time,8,   $day1/noaa_ww3_npo0.25_${today}.nc

		#echo; echo " ... cmems sla  "; echo ; ncks -h -d time,8,   $day1/cmems_sla_vels_atl0.25_${today}.nc

		echo; echo

		today=`find_tomorrow.sh $yr $mm $dd`
		yr=${today:0:4}
		mm=${today:4:2}
		dd=${today:6:2}

		nn=$(($nn+1))

	done


	echo
	echo " +++ END of code "
	echo

##################################  *** the end *** ############################################################
#
