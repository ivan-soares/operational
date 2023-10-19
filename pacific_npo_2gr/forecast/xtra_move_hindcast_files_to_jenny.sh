#!/bin/bash
#

	echo
	echo " +++ Move HINDCAST files to storage JENNY +++ "
	echo

	set -o nounset
	set -o errexit
	set -o pipefail

	today=$1
	yr=${today:0:4}
	mm=${today:4:2}
	dd=${today:6:2}

	yesterday=`find_yesterday.sh $yr $mm $dd`

####################### FILE NAMES

	here=$PWD
	sto1="$here/d-storage/$today"
	sto2="$here/d-storage/$yesterday"
	jenny="$HOME/storage-jenny/operational/${today}/hindcast"

	wind="$sto2/gfs_${yesterday}.nc"

	roms1="$sto2/roms_zlevs_jenny_npo0.08_07e_${yesterday}_glby.nc"
	roms2="$sto2/roms_zlevs_jenny_npo0.0267_01c_${yesterday}_glby.nc"

	ogcm1="$sto2/glby_zlevs_jenny_npo0.08_07e_${yesterday}.nc"
	ogcm2="$sto2/nemo_zlevs_jenny_npo0.08_07e_${yesterday}.nc"

	wave1="$sto2/ww3_his_npo0.33_${yesterday}.nc"
	wave2="$sto2/noaa_ww3_npo0.25_${yesterday}.nc"

	sat="$sto2/cmems_sla_vels_npo0.25_${yesterday}.nc"
	mld="$sto2/mld_npo0.08_07e_${yesterday}.nc"

	####### files in the storage

	swind="$jenny/Wind_Models/gfs_${today}.nc"
	swave1="$jenny/Wave_Models/ww3_toc_${today}.nc"
	swave2="$jenny/Wave_Models/ww3_noaa_${today}.nc"

	sroms1="$jenny/Regional_Ocean_Models/roms+hycom_${today}_1.nc"
	sroms2="$jenny/Regional_Ocean_Models/roms+hycom_${today}_1.nc"

	sogcm1="$jenny/Regional_Ocean_Models/hycom_${today}.nc"
	sogcm2="$jenny/Regional_Ocean_Models/nemo_${today}.nc"

	smld="$jenny/Regional_Ocean_Models/mld+langmuir_${today}.nc"
	ssat="$jenny/Regional_Ocean_Models/sat_sla+vel_${today}.nc"


###################### LOOP TRHOUGH FILES

	names_in=($roms1 $roms2 $ogcm1 $ogcm2 $wave1 $wave2 $wind $mld $sat)
	names_out=($sroms1 $sroms2 $sogcm1 $sogcm2 $swave1 $swave2 $swind $smld $ssat) 
	ndat=(24 24 4 4 24 24 8 4 0)

	for n in 0 1 2 3 4 5 6 7 8; do

		echo 
		echo " ==> doing file  ${names_in[n]}"
		echo

		if [ -e ${names_in[n]} ]; then
			ntimes=`ncdump -h ${names_in[n]} | grep "UNLIMITED" | \
			awk '{print $6}' | sed -e 's/(//g'`
			echo " ... ntimes $ntimes, ndat ${ndat[n]}"; echo
			if [ $ntimes -ge ${ndat[n]} ]; then 

				echo
				echo " ... the files is OK, will move it to storage"
				echo

				ncks -h -d time,0,${ndat[n]} ${names_in[n]} hindcast.nc; wait
				mv hindcast.nc ${names_out[n]}; wait
			fi

		fi
		if [ -e hindcast.nc ]; then rm hindcast.nc; fi
	done

	echo
	echo " +++ END of Script +++"
	echo


############################## the end

