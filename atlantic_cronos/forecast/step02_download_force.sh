#!/usr/bin/env bash
#

####    Script to download GFS

       ntry=3
       nbytes='112298488'
       gfsfile="gfs_$today.nc"

       #====================================================================================
       echo >> $log ; cd $tmpdir; dr=`pwd`
       echo ; echo " ==> HERE I am @ $dr for step 02: download GFS data <=="; echo
       now=$(date "+%Y/%m/%d %T"); echo " ... starting download of GFS at $now" >> $log
       #====================================================================================

       echo
       echo " ... today is ${yr}-${mm}-${dd}"
       echo " ... will download $nhrs hours"
       echo " ... will store downloaded files in folder $stodir"
       echo

       # will download a file named gfs_$today.nc

       n=1

       while [ $n -le $ntry ]; do
              get_gfs_nomads_oneday+forecast.sh $today $nhrs
              # script check_gfs.sh will create a file named check_status
              check_gfs.sh $gfsfile $nbytes $log
              check=`cat check_status`
              rm check_status

              if [ $check == 0 ]; then
                 echo " ... %%%%%% Downloaded file is OK \!\! %%%%%%"
                 break
              fi

              let n=$n+1
       done


       # create a force file for WW3
       fix_gfs_nomads4ww3.sh gfs_$today.nc gfs_${domain_wind}_$today.nc $today

       # create a force file for ROMS
       fix_gfs_nomads4roms.sh gfs_$today.nc gfs_${domain_wind2}_$today.nc $today $wesn_gfs

       mv gfs_${today}.nc                 ${stodir}/${today}/
       mv gfs_${domain_wind}_${today}.nc   ${stodir}/${today}/
       mv gfs_${domain_wind2}_${today}.nc   ${stodir}/${today}/

       #====================================================================================
       echo ; echo " ==> FINISHED downloading GFS <=="; echo
       now=$(date "+%Y/%m/%d %T"); echo " ... finished download at $now" >> $log
       #====================================================================================

       cd ${__dir}

################################## *** the end *** ##############################################

