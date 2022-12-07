#!/bin/bash
#

	today=$1
	ndays=1
	nn=1

	yr=${today:0:4}
	mm=${today:4:2}
	dd=${today:6:2}

        echo
        echo " +++ Starting code to check files in storage JENNY +++"
        echo

	jenny="$HOME/storage-jenny/operational"
	cdo="cdo -s --no_warnings showtimestamp "
	#cdo="ls -alh "

	while [ $nn -le $ndays ]; do

		echo; echo; echo; echo " ##############################  checking FORECAST files in folder $jenny/$today/forecast/ "; echo

		f1="$jenny/$today/forecast/Regional_Ocean_Models"
		f2="$jenny/$today/forecast/Wave_Models"
                f3="$jenny/$today/forecast/Wind_Models"

		echo; echo " ... hycom "; echo ; $cdo  $f1/hycom_$today.nc
                echo; echo " ... nemo "; echo ; $cdo  $f1/nemo_$today.nc
                echo; echo " ... roms "; echo ; $cdo  $f1/roms+hycom_${today}_1.nc
                echo; echo " ... roms "; echo ; $cdo  $f1/roms+hycom_${today}_2.nc

		echo; echo " ... ww3 toc "; echo ; $cdo  $f2/ww3_toc_${today}.nc
                echo; echo " ... ww3 noaa "; echo ; $cdo  $f2/ww3_noaa_${today}.nc

                echo; echo " ... gfs "; echo ; $cdo  $f3/gfs_${today}.nc


                echo; echo; echo; echo " ##############################  checking HINDCAST files in folder $jenny/$today/hindcast/ "; echo

                f1="$jenny/$today/hindcast/Regional_Ocean_Models"
                f2="$jenny/$today/hindcast/Wave_Models"
                f3="$jenny/$today/hindcast/Wind_Models"

                echo; echo " ... hycom "; echo ; $cdo  $f1/hycom_$today.nc
                echo; echo " ... nemo "; echo ; $cdo  $f1/nemo_$today.nc
                echo; echo " ... roms "; echo ; $cdo  $f1/roms+hycom_${today}_1.nc
                echo; echo " ... roms "; echo ; $cdo  $f1/roms+hycom_${today}_2.nc
                echo; echo " ... sla "; echo ; $cdo  $f1//sat_sla+vel_${today}.nc

                echo; echo " ... ww3 toc "; echo ; $cdo  $f2/ww3_toc_${today}.nc
                echo; echo " ... ww3 noaa "; echo ; $cdo  $f2/ww3_noaa_${today}.nc

                echo; echo " ... gfs "; echo ; $cdo  $f3/gfs_${today}.nc




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
