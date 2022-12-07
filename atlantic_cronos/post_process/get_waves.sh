#!/bin/bash
#
	today=$1
	stn=$2
	
	case $stn in
	     rs4)
		grd='sao0.125'     
		lat="-32.2454"
		lon="-52.0954"
		i=66
		j=48
		;;
	     rj4)
		grd='bca0.025'     
		lat="-22.9717"
		lon="-43.1503"
		i=211
		j=95
		;;
	     rj4s)
	        grd='sao0.125'
	        lat="-23.1250"
	        lon="-42.8750"
	        i=137
	        j=119
	        ;;
	     rj2)
                grd='bca0.025'
		lat=xx.xx
		lon=xx.xx
		i=xx
		j=xx
		;;
	     *)
		echo; echo ' ... wrong domain name, exiting !!'
	        echo; exit
	esac

        #inpdir="$HOME/operational/atlantic/forecast/d-outputs/storage"
	inpdir="$HOME/operational/forecast/store"
	inpfile="$inpdir/$today/ww3_sli_${grd}_${today}.nc"
	outfile="ww3_${stn}_${today}.nc"

	echo; echo " ... doing tide file $outfile"; echo	

	cdo select,name=hs                        $inpfile tmp1.nc
	ncks -d time,0,23 -d latitude,$j    -d longitude,$i     tmp1.nc $outfile
	#ncks -d latitude,$lat -d longitude,$lon   tmp1.nc $outfile
        rm tmp*

#
#   the end
#

