#!/bin/bash
#

####    Script to download HNCODA data from ncss.hycom.org

	today=$1
	ogcm=$2
	here=$3
	log=$4

        source $here/hindcast_setup.sh # will load dir names and other info

	#====================================================================================
	echo >> $log ; cd $tmpdir; dr=$PWD
	echo ; echo " ==> HERE I am @ $dr for step 03: download OGCM $ogcm data <=="; echo
	now=$(date "+%Y/%m/%d %T"); echo " ... starting download of OGCM $ogcm at $now" >> $log
	#====================================================================================

        outfile="${ogcm}_${domain_ogcm}_${today}.nc"

        echo
        echo " ... today is ${yr}-${mm}-${dd}, ogcm is $ogcm"
	echo " ... will download $ndays day(s), with interval of $dh hours "
        echo " ... will save outputs in file $outfile in dir  $stodir "
        echo

	yesterday=`find_yesterday.sh $yr $mm $dd`
	md=$today

  if [ "$ogcm" == "nemo" ]; then

	for (( n=1; n<=$ndays; n+=1)); do
		echo " ... downloading ${n}th day, date $yr/$mm/$dd"
		# will download files named nemo_${today}-120000Z.nc
		get_nemo_one_day.sh $md $wesn_ogcm '$ASD45ui'
		md=`find_tomorrow.sh $yr $mm $dd`; yr=${md:0:4}; mm=${md:4:2}; dd=${md:6:2}
	done

	echo
	# get an extra day
	get_nemo_one_day.sh $md $wesn_ogcm '$ASD45ui'

	# get one day before day 01, compute the average to obtain the initial file at 00:00
	# get rid of yesterday's file
	get_nemo_one_day.sh $yesterday $wesn_ogcm '$ASD45ui'
	cdo ensmean ${ogcm}_${yesterday}-120000Z.nc ${ogcm}_${today}-120000Z.nc tmp1
	ncap2 -O -h -s "time=time+12." tmp1 ${ogcm}_${today}-000000Z.nc
        rm tmp* ${ogcm}_${yesterday}-120000Z.nc

   elif [ "$ogcm" == "glbv" -o "$ogcm" == "glbu" -o "$ogcm" == "glby" ]; then

	for (( n=1; n<=$ndays; n+=1)); do
		echo " ... downloading ${n}th day, date $yr/$mm/$dd"
		# will download files named glbv_${mdate}-${hh}0000Z.nc
                get_hycom_glby_expt093_v2.sh $md $nh $dh $wesn_ogcm
		cdo mergetime ${ogcm}_${md}-*.nc ${ogcm}_${md}.nc; rm ${ogcm}_${md}-*.nc
		md=`find_tomorrow.sh $yr $mm $dd`; yr=${md:0:4}; mm=${md:4:2}; dd=${md:6:2}
	done

	# the last hour is hour 0 of next day
	echo ; echo " ... downloading 0 hour of day $yr/$mm/$dd"; echo
        get_hycom_glby_expt093_v2.sh $md 0 $dh $wesn_ogcm
	mv ${ogcm}_${md}-000000Z.nc ${ogcm}_${md}.nc

   fi

	#### combine the files in one clim file
	if [ -f $outfile ]; then rm $outfile ; fi
	echo " ... merge downloaded files into file $outfile"
	cdo mergetime ${ogcm}_20*.nc tmp1
	mv ${ogcm}_20*.nc $trunk/.

	#fix longitudes
	echo " ... fix longitudes"
	echo " ... include new attributes: _FillValue and missing values"
	#ncap2 to change longitudes to neg where they are > 180 is done in get_hycom_forecast.sh
	#ncap2 -O -s 'where(lon>180) lon=lon-360' $outfile tmp ; rm $outfile
	cdo -setmissval,NaN tmp1 tmp2
	cdo -setmissval,-9999. tmp2 $outfile
	rm tmp*

        echo 
        echo " ... check integrity of downloaded file "
	echo

	###whatever        


        echo 
        echo " ... move files to storage "
        echo

	mv $outfile $stodir/$today/.


	#====================================================================================
	echo ; echo " ==> FINISHED downloading OGCM for ROMS <=="; echo
	now=$(date "+%Y/%m/%d %T"); echo " ... finished download at $now" >> $log
	#====================================================================================

	cd $here

################################## *** the end *** ###########################################
