#!/bin/bash
#
	#### S11

	today=$1
	ogcm=$2
	here=$3
	log=$4

	source $here/forecast_setup.sh # will load dir names and other infe

	#====================================================================================
	echo ; now=$(date "+%Y/%m/%d %T"); echo >> $log
	echo " ... starting cleanup of temporary files at $now" >> $log; echo >> $log
	echo " ==> $now HERE I am for step 11: cleanup & close forecast cycle <=="; echo
	#====================================================================================

	echo
	echo " ... today is ${yr}-${mm}-${dd}"
	echo

	#stodir="$HOME/oper/atlantic/forecast/d-storage"   ### stodir was defined in forecast_setup

	arcdir="$HOME/remote/cronos/archive"

	echo " ... will move files to $arcdir" 
	echo


	yesterday1=`find_yesterday.sh $yy $mm $dd`
	y1=${yesterday1:0:4}
	m1=${yesterday1:4:2}
	d1=${yesterday1:6:2}
	#
	yesterday2=`find_yesterday.sh $y1 $m1 $d1`
	y2=${yesterday2:0:4}
	m2=${yesterday2:4:2}
	d2=${yesterday2:6:2}
#
#     sto=$stodir/$today
#     sto2=$stodir/$yesterday1
#     hindcast="$here/../hindcast_1d/$yesterday2"
#
#     echo " ... will move files in $stod2 to $hindcast"
#     echo " ... will clean temporary dir $tmpdir"
#     echo
#
#     if [ -e $hindcast ]; then
#           echo " ... dir $hindcast exists, will use it"
#     else
#           echo " ... dir $hindcast doesnt exist, will create it"
#           mkdir $hindcast
#     fi
#
#     ### make links to latest files
#
#     rm -f $stodir/latest
#     ln -s $stodir/$today $stodir/latest
#
#     echo " ... creating hard links to FTP folder"
#     sudo ln $sto/roms_his*nc /shared/home/oceanpact/ftp/ROMS/
#     sudo ln $sto/ww3_his*nc /shared/home/oceanpact/ftp/WW3/
#     sudo chown -R oceanpact: /shared/home/oceanpact/ftp
#     sudo chmod -R a-w /shared/home/oceanpact/ftp/ROMS/
#     sudo chmod -R a-w /shared/home/oceanpact/ftp/WW3/
#
#     ### move old files to hindcast folder
#
#     ### history files storage interval:
#     ### roms hourly
#     ### ww3  hourly
#     ### noaa 3-hourly
#     ### glby 6-hourly
#     ### nemo daily
#     ### gfs  3-hourly
#
#     ### restart files:
#     ### roms+nemo: daily
#     ### roms+glby: daily
#     ### ww3+gfs: daily
#
#     romshis="roms_his_${domain}_${version}_${yesterday1}_${ogcm}.nc"
#     romsrst="roms_rst_${domain}_${version}_${yesterday1}_${ogcm}.nc"
#     romsavg="roms_avg_${domain}_${version}_${yesterday1}_${ogcm}.nc"
#
#     ncks -d ocean_time,0,24 $sto2/$romshis $hindcast/$romshis
#     ncks -d ocean_time,0,1  $sto2/$romsrst $hindcast/$romsrst
#     ncks -d ocean_time,0    $sto2/$romsavg $hindcast/$romsavg
#
#     romszlev="roms_zlevs_${domain}_${version}_${yesterday1}_${ogcm}.nc"
#
#     mv $sto2/$romszlev $hindcast/.
#
#     ndate=$tomorrow
#     yn=${ndate:0:4}
#     mn=${ndate:4:2}
#     dn=${ndate:6:2}
#
#     n=1
#     let nndays=$ndays-1
#
#     while [ $n -le $nndays ]; do
#	     romszlev="roms_zlevs_${domain}_${version}_${ndate}_${ogcm}.nc"
#	     rm $romszlev
#	     ndate=`find_tomorrow.sh $yn $mn $dn`
#	     yn=${ndate:0:4}
#	     mn=${ndate:4:2}
#	     dn=${ndate:6:2}
#	     let n=$n+1
#     done
#

	find $stodir -name 'gfs_*' -mtime +2 -exec mv {} $arcdir/gfs/ \;
	find $stodir -name 'nemo*' -mtime +2 -exec mv {} $arcdir/nemo/ \;
	find $stodir -name 'glb*' -mtime +2 -exec mv {}  $arcdir/hncoda/ \;

	find $stodir -name 'roms_his*' -mtime +3 -exec mv {} $arcdir/roms/ \;
	find $stodir -name 'roms_rst*' -mtime +3 -exec mv {} $arcdir/roms/ \;

	find $stodir -name 'ww3_his*' -mtime +2 -exec mv {} $arcdir/ww3/ \;
	find $stodir -name 'ww3_rst*' -mtime +2 -exec mv {} $arcdir/ww3/ \;

	find $stodir -name 'roms_zlev*' -mtime +2 -exec rm {} \;
	find $stodir -name 'roms_avg*' -mtime +2 -exec rm {} \;
	find $stodir -name 'input*.nc' -mtime +2 -exec rm {} \;
	#find $stodir -name 'gfs*.nc' -mtime +3 -exec rm {} \;
	#find $stodir -name 'nemo*.nc' -mtime +3 -exec rm {} \;
	#find $stodir -name 'glb*.nc' -mtime +3 -exec rm {} \;

	#====================================================================================
	echo ; now=$(date "+%Y/%m/%d %T"); echo >> $log
	echo " ... finished cleanup at $now" >> $log; echo >> $log
	echo ; echo " ==> $now FINISHED cleanup & closed forecast cycle <=="; echo
	#====================================================================================

#### the end
