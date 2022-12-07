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

	oper="$HOME/operational/pacific_npo_2gr/forecast"
	cdo="cdo -s --no_warnings showtimestamp "
	#cdo="ls -alh "

	while [ $nn -le $ndays ]; do

		echo; echo " ... checking FORECAST files for $yr/$mm/$dd "; echo

		tomorrow=`find_tomorrow.sh $yr $mm $dd`

		ddir="$oper/d-storage/$today"

                echo; echo " ... gfs   "; echo ; $cdo  $ddir/gfs_${today}.nc
		echo; echo " ... hycom "; echo ; $cdo  $ddir/glby_npo0.08_$today.nc
                echo; echo " ... nemo  "; echo ; $cdo  $ddir/nemo_npo0.08_$today.nc

                echo; echo " ... roms his 1 "; echo ; $cdo  $ddir/roms_his_${rdomain01}_${today}_glby.nc
                echo; echo " ... roms his 2 "; echo ; $cdo  $ddir/roms_his_${rdomain02}_${today}_glby.nc

                echo; echo " ... roms rst 1 "; echo ; $cdo  $ddir/roms_rst_${rdomain01}_${tomorrow}_glby.nc
                echo; echo " ... roms rst 2 "; echo ; $cdo  $ddir/roms_rst_${rdomain02}_${tomorrow}_glby.nc

		echo; echo " ... ww3 his 1 "; echo ; $cdo  $ddir/ww3_his_${wdomain01}_${today}.nc
                echo; echo " ... ww3 his 2 "; echo ; $cdo  $ddir/ww3_his_${wdomain02}_${today}.nc

                echo; echo " ... ww3 rst 1 "; echo ; $cdo  $ddir/ww3_out_rst_${tomorrow}.000000.${wdomain01}
                echo; echo " ... ww3 rst 2 "; echo ; $cdo  $ddir/ww3_out_rst_${tomorrow}.000000.${wdomain02}

                echo; echo " ... ww3 noaa  "; echo ; $cdo  $ddir/noaa_ww3_npo0.25_${today}.nc

		echo; echo " ... cmems sla  "; echo ; $cdo  $ddir/cmems_sla_vels_atl0.25_${today}.nc

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
