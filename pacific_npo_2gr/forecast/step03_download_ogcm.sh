#!/bin/bash
#

####    Script to download HNCODA data from ncss.hycom.org

	today=$1
	ogcm=$2
	here=$3
	log=$4

	source $here/forecast_setup.sh # will load dir names and other info

	#====================================================================================
	echo ; cd $tmpdir; dr=`pwd`; now=$(date "+%Y/%m/%d %T"); echo >> $log
	echo " ... starting download of OGCM $ogcm at $now" >> $log; echo >> $log
	echo " ==> $now HERE I am @ $dr for step 03: download ogcm $ogcm data <=="; echo
	#====================================================================================

	outfile="${ogcm}_${domain_ogcm}_${today}.nc"

	echo
	echo " ... today is ${yr}-${mm}-${dd}, ogcm is $ogcm"
	echo " ... will download $ndays day(s), with interval of $dh hours "
	echo " ... will save outputs in file $outfile"
	echo

	#####################################################################################

	##### NOW we check if the file already exists and is OK
	#####
	##### this may not be the first time we try to download it today
	#####

	infile="$here/d-storage/${today}/$outfile"

	if [ -f "${infile}" ];then

                if [ -s "${infile}" ]; then

                        echo
                        echo " ... File ${infile} exists and is not empty."
                        echo

                        echo " ... Check first time step"
                        echo

			cdo="cdo -s --no_warnings showtimestamp "
			firstday=`$cdo $infile | awk '{print $1}'`
			firstday2="${yr}-${mm}-${dd}T00:00:00"

                        if [ "$firtday" != "$firstday2" ]; then

                                echo
                                echo " ... the firt time step $firstday is not $firstday2." 
				echo " ... try downloading it again !!!"
                                echo

                        else
                                echo
                                echo " ... the first time step $firstday2 is OK." 
				echo 
				echo " ... now we check # of time steps"
                                echo

                                nsteps=`ncdump -h $infile | grep "UNLIMITED" | \
					sed -e 's|(| |g' | awk '{print $6}'`

                                echo
                                echo " ... the file has $nsteps time steps"
                                echo


				echo
                                echo " ... Dowloaded file is OK, no need to download it again." 
				echo
				echo " ... Exiting now !!!"
                                echo
                                exit
                                echo

                        fi


                else
                        echo
                        echo " ... File ${infile} exists but is empty. Try downloading it again !!!"
                        echo
                        echo
                fi
        else
                echo
                echo " ... File ${infile} does not exist. Will download it !!!"
                echo
                echo
        fi

        #####################################################################################

	nt=1
	ntry=3

	while [ $nt -le $ntry ]; do

		md=$today      
		yr=${today:0:4}
		mm=${today:4:2}
		dd=${today:6:2}

		yesterday=`find_yesterday.sh $yr $mm $dd`
		y1=${yesterday:0:4}
		m1=${yesterday:4:2}
		d1=${yesterday:6:2} 

		tomorrow=`find_tomorrow.sh $yr $mm $dd`
                y2=${tomorrow:0:4}
                m2=${tomorrow:4:2}
                d2=${tomorrow:6:2}

		tomorrow2=`find_tomorrow.sh $y2 $m2 $d2`
		y22=${tomorrow2:0:4}
                m22=${tomorrow2:4:2}
                d22=${tomorrow2:6:2}

		echo " ... This is try n. $nt to download ogcm file"; echo

		if [ "$ogcm" == "nemo" ]; then

		    echo; echo " ... downloading nemo"; echo

		    if [ $ndays -eq 1 ]; then

			 get_nemo_one_day_06h.sh $today $wesn_ogcm
                         get_nemo_one_hour_06h.sh $tomorrow $wesn_ogcm 

		    elif [ $ndays -eq 2 ]; then	 
 
			 get_nemo_one_day_06h.sh $today $wesn_ogcm
                         get_nemo_one_day_06h.sh $tomorrow $wesn_ogcm
			 get_nemo_one_hour_06h.sh $tomorrow2 $wesn_ogcm

		    elif [ $ndays -gt 2 ]; then  

                         get_nemo_one_day_06h.sh $today $wesn_ogcm
                         get_nemo_one_day_06h.sh $tomorrow $wesn_ogcm

			 for (( n=3; n<=$ndays; n+=1)); do
                               get_nemo_one_day_24h.sh $tomorrow2 $wesn_ogcm
			       tomorrow2=`find_tomorrow.sh $y22 $m22 $d22`
			       y22=${tomorrow2:0:4}
			       m22=${tomorrow2:4:2}
			       d22=${tomorrow2:6:2}
		         done
		   
		    else

			echo; echo " ... this is not a valid option, exiting"; echo
	    	        exit; echo
		    fi


                elif [ "$ogcm" == "nemo24" ]; then

                        for (( n=1; n<=$ndays; n+=1)); do
                             # will download files named nemo_${today}.nc
                             get_nemo_one_day_24h.sh $md $wesn_ogcm
                             md=`find_tomorrow.sh $yr $mm $dd`; yr=${md:0:4}; mm=${md:4:2}; dd=${md:6:2}
                        done

                        echo
                        # get an extra day
                        get_nemo_one_day_24h.sh $md $wesn_ogcm

                        # get one day before day 01, compute the average to obtain the initial file at 00:00
                        # get rid of yesterday's file
                        get_nemo_one_day_24h.sh $yesterday $wesn_ogcm

                        cdo -s --no_warnings ensmean nemo_${yesterday}.nc nemo_${today}.nc tmp1
                        ncap2 -O -h -s "time=time+12." tmp1 nemo_${today}.nc
                        rm tmp* nemo_${yesterday}.nc

		elif [ "$ogcm" == "glbv" -o "$ogcm" == "glbu" -o "$ogcm" == "glby" ]; then

			for (( n=1; n<=$ndays; n+=1)); do
			     echo " ... downloading ${n}th day, date $yr/$mm/$dd"
			     # will download files named glbv_${mdate}-${hh}0000Z.nc
			     if [ $today -ge $(date --date='5 days ago' +%Y%m%d) ]; then
				    #get_hycom_latest.sh $md $nh $dh $ogcm $wesn_ogcm
				    get_hycom_glby_expt093_v3.sh $md $nh $dh $ogcm $wesn_ogcm
			     else
				    get_hycom_glby_expt093_v2.sh $md $nh $dh $ogcm $wesn_ogcm
			     fi
			     cdo -s --no_warnings mergetime ${ogcm}_${md}-*.nc ${ogcm}_${md}.nc; mv ${ogcm}_${md}-*.nc $trunk/.
			     md=`find_tomorrow.sh $yr $mm $dd`; yr=${md:0:4}; mm=${md:4:2}; dd=${md:6:2}
			done

			# the last hour is hour 0 of next day
			echo ; echo " ... downloading 0 hour of day $yr/$mm/$dd"; echo
			if [ $today -ge $(date --date='5 days ago' +%Y%m%d) ]; then
			     #get_hycom_latest.sh $md 0 $dh $ogcm $wesn_ogcm
			     get_hycom_glby_expt093_v3.sh $md $nh $dh $ogcm $wesn_ogcm
			else
			     get_hycom_glby_expt093_v2.sh $md 0 $dh $ogcm $wesn_ogcm
			fi
			mv ${ogcm}_${md}-000000Z.nc ${ogcm}_${md}.nc

		else

			echo
			echo " ... ogcm type $ogcm is not valid here, exiting !!!"
			exit
			echo

		fi

		#### combine the files in one clim file
	
		echo " ... merge downloaded files into file $outfile"
		if [ $ogcm == 'nemo24' ]; then ogcm='nemo'; fi
		outfile="${ogcm}_${domain_ogcm}_${today}.nc"
		if [ -f $outfile ]; then rm $outfile; fi
		
		cdo -s --no_warnings mergetime ${ogcm}_20*.nc tmp1
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

		#check=`$here/xtra_check_nemo.sh $today | grep " _ " | wc -l`

		## check procedure will create a file named check_status

		check=0
		#check_ogcm.sh $outfile $ndat $log
		#check=`cat check_status`
		#rm check_status

		echo; echo " ... after check procedure check status is $check"; echo

		if [ $check == 0 ]; then
			echo " ... %%%%%% Downloaded file is OK !! %%%%%%"
			break
		fi
		let nt=$nt+1
		
		#### sleep for 10 minutes before trying download again
		sleep 600s

	done

	echo 
	echo " ... move file to storage "
	echo

	mv $outfile $stodir/$today/.

	#====================================================================================
	echo ; now=$(date "+%Y/%m/%d %T"); echo >> $log
	echo " ... finished download of ogcm at $now" >> $log; echo >> $log
	echo " ==> $now FINISHED downloading OGCM $ogcm for ROMS <=="; echo
	#====================================================================================

	cd $here

################################## *** the end *** ###########################################
