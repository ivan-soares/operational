#!/bin/bash
#
	today=$1
	stn=$2

	case $stn in
	     suape)
             lat=-8.3
	     lon=-34.85
	     #lat=-8.3931
	     #lon=-34.9600
	     ;;
             pecem)
	     lat=-3.5311
	     lon=-38.7931
	     ;;
             *)
	     echo; echo " ... wrong station name, exiting \!\!\!"
	     echo; exit
	esac


	inpdir=`pwd`
	inpfile="$inpdir/$today/roms_brz0.05_01g_${today}_glby_zlevs.nc"
	outfile="roms_zeta_${today}_${stn}.nc"

	ncks -v zeta $inpfile tmp
	ncks -d lon,$lon -d lat,$lat tmp $outfile
	rm tmp

#
#   the end
#
