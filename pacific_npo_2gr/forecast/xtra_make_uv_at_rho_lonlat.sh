#!/bin/bash
#

	today=$1

	yr=${today:0:4}
	mm=${today:4:2}
	dd=${today:6:2}

        echo
        echo " +++ Starting code to compute u/v at rho lon/lat  +++"
        echo

	domain01="npo0.08_07e"
	domain02="npo0.0267_01c"

	ddir="$HOME/operational/pacific_npo_2gr/forecast/d-storage/$today"
	file01="$ddir/roms_his_${domain01}_${today}_glby.nc"
	file02="$ddir/roms_his_${domain02}_${today}_glby.nc"

   for  infile in $file01 $file02 ; do


	echo " ... working on file $infile"; echo

	out="${infile}.new"

	if [ -e tmp1 ]; then rm tmp1; fi

	# add new vars
	ncap2 -O -h -s "u_eastward=temp"  -s "v_northward=temp" \
		       $infile tmp1


	for var in u_eastward v_northward; do

		#delete all attributes of new vars
		ncatted -h -O -a ,$var,d,,                         tmp1
		
		# add att time and lon lat
		ncatted -h -O -a time,$var,c,c,"ocean_time"  \
			      -a coordinates,$var,c,c,"lon_rho lat_rho"    tmp1

		#add attribute units to all
		ncatted -h -O -a units,$var,c,c,"meter second-1" tmp1

	done

	#add attribute longname to all
        ncatted -h -O -a long_name,u_eastward,c,c,"eastward momentum component at RHO-points" \
	              -a long_name,v_northward,c,c,"northward momentum component at RHO-points"  tmp1

	echo " will mv tmp1 to $out"

   done	

	echo
	echo " +++ END of code "
	echo

##################################  *** the end *** ############################################################
#
