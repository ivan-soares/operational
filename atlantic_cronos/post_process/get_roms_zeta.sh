#!/bin/bash
#
	today=$1
	stn=$2

	case $stn in
	     ilha-bela)
		lat=-23.7735
		lon=-45.3547
		;;
	     pecem)
		lat=-3.531
		lon=-38.793
		eta_rho=531
		xi_rho=264
		;;
	     suape)
		lat=-9.393
		lon=-34.96
		eta_rho=433
		xi_rho=343
		;;
	     *)
		echo; echo ' ... wrong domain name, exiting !!'
	        echo; exit
	esac

        inpdir="$HOME/operational/atlantic/forecast/d-storage"
	inpfile="$inpdir/$today/roms_brz0.05_01g_${today}_glby_zlevs.nc"
	outfile="roms_tide_${stn}_${today}.nc"

	echo; echo " ... doing tide file $outfile"; echo	

	cdo select,name=zeta          $inpfile tmp1.nc
	#ncks -d eta_rho,$eta_rho -d xi_rho,$xi_rho tmp1.nc $outfile
	ncks -d lat,$eta_rho -d lon,$xi_rho   tmp1.nc $outfile
        rm tmp*

#
#   the end
#

