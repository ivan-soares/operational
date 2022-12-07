#!/bin/bash
#

        #### S09

	today=$1
	ogcm=$2
	here=$3
	log=$4

	source $here/forecast_setup.sh # will load dir names and other info

	#====================================================================================
	echo ; cd $tmpdir; dr=`pwd`; now=$(date "+%Y/%m/%d %T"); echo >> $log
	echo " ... starting download of CMEMS SLA + Vels at $now" >> $log; echo >> $log
	echo " ==> $now HERE I am @ $dr for step 09: download CMEMS SLA + Geostr Vels <=="; echo
	#====================================================================================   

	echo
	echo " ... today is ${yr}-${mm}-${dd}"
	echo " ... will store outputs in folder $stodir"
	echo

	west=`echo $wesn_sla | awk '{print $1}'`
        east=`echo $wesn_sla | awk '{print $2}'`
        south=`echo $wesn_sla | awk '{print $3}'`
        north=`echo $wesn_sla | awk '{print $4}'`

        if (( $(echo "$west  < 0.0" |bc -l) )); then W='W'; else W='E'; fi
        if (( $(echo "$east  > 0.0" |bc -l) )); then E='E'; else E='W'; fi
        if (( $(echo "$south < 0.0" |bc -l) )); then S='S'; else S='N'; fi
        if (( $(echo "$north > 0.0" |bc -l) )); then N='N'; else N='S'; fi

        w=`echo $west  | awk '{print int(sqrt($1*$1))}'`
        e=`echo $east  | awk '{print int(sqrt($1*$1))}'`
        s=`echo $south | awk '{print int(sqrt($1*$1))}'`
        n=`echo $north | awk '{print int(sqrt($1*$1))}'`

        wesn="$w$W$e$E-$s$S$n$N"

	outfile="cmems_sla_vels_atl0.25_${today}.nc"

	get_cmems_sla.sh $today $wesn_sla $product
	mv sla_allsat_*_${yr}-${mm}-${dd}.nc $outfile
	mv $outfile $stodir/$today/.

        yy=${yesterday:0:4}
        my=${yesterday:4:2}
        dy=${yesterday:6:2}

        inpfile="multiobs_${wesn}_${yy}-${my}-${dy}.nc"
        outfile="cmems_multiobs_npo0.25_${yesterday}.nc"

        get_cmems_multiobs.sh $yesterday $wesn_sla
        mv $inpfile $stodir/$yesterday/$outfile

	#====================================================================================
	echo ; now=$(date "+%Y/%m/%d %T"); echo >> $log
	echo " ... finished downloading at $now" >> $log; echo >> $log
	echo " ==> $now FINISHED downloading CMEMS SLA + Geostr Vels <=="; echo
	#====================================================================================

	cd $here

#### the end
