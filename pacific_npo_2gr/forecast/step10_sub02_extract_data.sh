#!/bin/bash
#

	echo; echo " ... reading file $romsfile"
	#ncks -d depth,0 -d lon,$lo1,$lo2 -d lat,$la1,$la2 $romsfile $out1
	ncks -d s_rho,29 -d xi_rho,$i1,$i2 -d eta_rho,$j1,$j2 $romsfile $out1

	echo; echo " ... reading file $sat1file"
	ncks -d longitude,$lo1,$lo2 -d latitude,$la1,$la2 $sat1file $out2
								       
	echo; echo " ... reading file $ogcmfile"
	if [ $ogcm == 'glby' ]; then
	     ncks -d depth,0 -d lon,$lo1,$lo2 -d lat,$la1,$la2 $ogcmfile $out3
	     troms=12
	     togcm=2
	elif [ $ogcm == 'nemo' ]; then
	     ncks -d depth,0 -d longitude,$lo1,$lo2 -d latitude,$la1,$la2 $ogcmfile $out3
	     troms=12
	     togcm=0
	fi



#
#   the end
#
