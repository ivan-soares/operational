#!/usr/bin/env bash
#

####    Script to download HNCODA data from ncss.hycom.org

       #====================================================================================
       echo >> $log ; cd $tmpdir; dr=`pwd`
       echo ; echo " ==> HERE I am @ $dr for step 03: download OGCM $ogcm data <=="; echo
       now=$(date "+%Y/%m/%d %T"); echo " ... starting download of OGCM $ogcm at $now" >> $log
       #====================================================================================

       outfile="${ogcm}_${domain_ogcm}_${today}.nc"

       echo
       echo " ... today is ${yr}-${mm}-${dd}, ogcm is $ogcm"
       echo " ... will download $ndays day(s), with interval of $dh hours "
       echo " ... will save outputs in file $outfile"
       echo

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

         echo " ... This is try n. $nt to download ogcm file"; echo

         if [ "$ogcm" == "nemo" ]; then

             nbytes='141708912'

              #for (( n=1; n<=2; n+=1)); do
              #       echo " ... downloading ${n}th day, date $yr/$mm/$dd"
              #       # will download files named nemo_yr-mm-dd.nc 
              #       # which we rename as nemo_${today}-120000Z.nc
              #       get_nemo_3dinst_one_day.sh $md $wesn_ogcm '$ASD45ui'; wait
              #       ##mv nemo_${yr}-${mm}-${dd}.nc nemo_${md}-120000Z.nc
              #       md=`find_tomorrow.sh $yr $mm $dd`; yr=${md:0:4}; mm=${md:4:2}; dd=${md:6:2}
              #done

	      for (( n=1; n<=$ndays; n+=1)); do
                     echo " ... downloading ${n}th day, date $yr/$mm/$dd"
                     # will download files named nemo_yr-mm-dd.nc 
                     # which we rename as nemo_${today}-120000Z.nc
                     get_nemo_one_day.sh $md $wesn_ogcm '$ASD45ui'; wait
                     #mv nemo_${yr}-${mm}-${dd}.nc nemo_${md}-120000Z.nc
                     md=`find_tomorrow.sh $yr $mm $dd`; yr=${md:0:4}; mm=${md:4:2}; dd=${md:6:2}
              done

              echo
              # get an extra day
              get_nemo_one_day.sh $md $wesn_ogcm '$ASD45ui'; wait
              #mv nemo_${yr}-${mm}-${dd}.nc nemo_${md}-120000Z.nc

	      ##### don't need this anymore because script get_nemo_3dinst_one_day.sh will get nemo at 00:00, 06:00, 12:00 & 18:00
              # get one day before day 01, compute the average to obtain the initial file at 00:00
              # get rid of yesterday's file
              get_nemo_one_day.sh $yesterday $wesn_ogcm '$ASD45ui'
              #mv nemo_${today}-120000Z.nc nemo_${yesterday}-120000Z.nc
              cdo -s -w ensmean ${ogcm}_${yesterday}-120000Z.nc ${ogcm}_${today}-120000Z.nc tmp1
              ncap2 -O -h -s "time=time+12." tmp1 ${ogcm}_${today}-000000Z.nc
              rm tmp* ${ogcm}_${yesterday}-120000Z.nc

         elif [ "$ogcm" == "glbv" -o "$ogcm" == "glbu" -o "$ogcm" == "glby" ]; then

              nbytes='4512861203'
              nbytes='1327250771'

              for (( n=1; n<=$ndays; n+=1)); do
                     echo " ... downloading ${n}th day, date $yr/$mm/$dd"
                     # will download files named glbv_${mdate}-${hh}0000Z.nc
                     if [ $today -ge $(date --date='5 days ago' +%Y%m%d) ]; then
                            #get_hycom_latest.sh $md $nh $dh $ogcm $wesn_ogcm
                            get_hycom_glby_expt093_v3.sh $md $nh $dh $ogcm $wesn_ogcm
                     else
                            get_hycom_glby_expt093_v2.sh $md $nh $dh $ogcm $wesn_ogcm
                     fi
                     cdo -s -w mergetime ${ogcm}_${md}-*.nc ${ogcm}_${md}.nc; rm ${ogcm}_${md}-*.nc
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

         fi

         #### combine the files in one clim file
         if [ -f $outfile ]; then rm $outfile ; fi
         echo " ... merge downloaded files into file $outfile"
         cdo -s -w mergetime ${ogcm}_20*.nc tmp1
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

         ## script check_nemo.sh will create a file named check_status
         check_nemo.sh $outfile $nbytes $log
         check=`cat check_status`
         rm check_status
         if [ $check == 0 ]; then
              echo " ... %%%%%% Downloaded file is OK \!\! %%%%%%"
              break
         fi
         let nt=$nt+1
       done

       echo 
       echo " ... move file to storage "
       echo

       mv $outfile $stodir/$today/.


       #====================================================================================
       echo ; echo " ==> FINISHED downloading OGCM for ROMS <=="; echo
       now=$(date "+%Y/%m/%d %T"); echo " ... finished download at $now" >> $log
       #====================================================================================

       cd ${__dir}

################################## *** the end *** ###########################################
