#!/bin/bash
#

	today=$1
	ndays=$2
	nn=1

	yr=${today:0:4}
	mm=${today:4:2}
	dd=${today:6:2}

	tomorrow=`find_tomorrow.sh $yr $mm $dd`

        echo
        echo " +++ Starting code to fix GFS files  +++"
        echo



	sto="$HOME/oper/pacific_npo_2gr/forecast/d-storage"
	cdo="cdo -s --no_warnings showtimestamp "
	#cdo="ls -alh "

	while [ $nn -le $ndays ]; do

		echo; echo " ... fixing GFS files for $yr/$mm/$dd "; echo

		gfs="d-storage/$today/gfs_${today}.nc"

		ncks -h -d ocean_time,3 d-storage/$today/input_clm_npo0.08_07e_${today}_glby.nc last.nc
		ncap2 -h -O -s "ocean_time=ocean_time+86400" last.nc input.nc
		ncrcat -h d-storage/$today/input_clm_npo0.08_07e_${today}_glby.nc input.nc input_clm_npo0.08_07e_${today}_glby.nc
		rm last.nc input.nc

                ncks -h -d bry_time,3 d-storage/$today/input_bry_npo0.08_07e_${today}_glby.nc last.nc
		ncap2 -h -O -s "bry_time=bry_time+86400" last.nc input.nc
                ncrcat d-storage/$today/input_bry_npo0.08_07e_${today}_glby.nc input.nc input_bry_npo0.08_07e_${today}_glby.nc
                rm last.nc input.nc


	        #mv gfs_${domain_wind}_${today}.nc   ${sto}/${today}/
        	#mv gfs_${domain_wind2}_${today}.nc   ${sto}/${today}/


		echo; echo

		today=`find_tomorrow.sh $yr $mm $dd`
		yr=${today:0:4}
		mm=${today:4:2}
		dd=${today:6:2}

        	tomorrow=`find_tomorrow.sh $yr $mm $dd`

		nn=$(($nn+1))

	done


	echo
	echo " +++ END of code "
	echo

##################################  *** the end *** ############################################################
#
