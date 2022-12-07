#!/usr/bin/env bash
#

####    Script to download CMEMS SLA & Geostr. Velocities
####    will download a file named "sla_allsat_${wesn}_${yr}-${mm}-${dd}.nc"

       #====================================================================================
       cd $tmpdir; dr=`pwd`
       echo ; echo " ==> HERE I am @ $dr for step 09: download CMEMS SLA & Vels <=="; echo
       now=$(date "+%Y/%m/%d %T"); echo " ... download CMEMS SLA & Vels at $now" >> $log
       #====================================================================================   

        echo
        echo " ... today is ${yr}-${mm}-${dd}"
        echo " ... will store outputs in folder $stodir"
        echo

        outfile="cmems_sla_vels_atl0.25_${today}.nc"

        get_cmems_sla.sh $today $wesn_sla $product
        mv sla_allsat_*_${yr}-${mm}-${dd}.nc $outfile
        mv $outfile $stodir/$today/.

        outfile="cmems_multiobs_atl0.25_${today}.nc"

	get_cmems_multiobs.sh $today $wesn_sla
	mv multiobs_*_${yr}-${mm}-${dd}.nc $outfile
        mv $outfile $stodir/$today/.

       #====================================================================================
       echo ; echo " ==> FINISHED downloading CMEMS <=="; echo
       now=$(date "+%Y/%m/%d %T"); echo " ... finished downaloading at $now" >> $log
       #====================================================================================

       cd ${__dir}

#### the end
