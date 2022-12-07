#!/bin/bash
#
	today=$1
	stn=$2

	case $stn in
	     rs4)
             lat=-32.25
	     lon=-52.10
	     #lat=-8.3931
	     #lon=-34.9600
	     ;;
             rj4)
	     lat=-22.95
	     lon=-43.15
	     ;;
             *)
	     echo; echo " ... wrong station name, exiting \!\!\!"
	     echo; exit
	esac


	inpdir="$HOME/operational/forecast/store"
	inpfile="$inpdir/$today/ww3_sli_atl0.500_${today}.nc"
	outfile="ww3_${stn}_${today}.nc"

	ncks -v hs $inpfile tmp
	ncks -d time,0,23 -d longitude,$lon -d latitude,$lat tmp $outfile
	rm tmp

#
#   the end
#
