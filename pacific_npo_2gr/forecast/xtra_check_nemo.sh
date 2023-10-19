#!/bin/bash
#
	today=$1
	
	ogcm='nemo'
	domain='npo0.08'

	echo
	echo " +++ Starting script to check NEMO files +++"
	echo

	#ls -1 ${ogcm}_${domain}_${today}* >& list_of_files
        ls -1 d-storage/${today}*/${ogcm}_${domain}_${today}* >& list_of_files

	nfiles=`wc -l list_of_files`

	echo
	echo " ... the n. of files is $nfiles"
	echo

	cdo="cdo -s --no_warning"

	echo
	echo " %%% check n. of time steps"
	echo 

	while read line; do
		#echo " ... reading file $line"
		ncdump -h $line | grep "time = "
	done < list_of_files

	echo
	echo " %%% check files time stamp"
	echo 

	while read line; do
		#echo " ... reading file $line"
		$cdo showtimestamp $line | sed -e 's/T/ /g'i # | awk '{print $1, $2, $4, $6, $8, $9, $10}'
	done < list_of_files
	echo
        echo " %%% check files size"
        echo

        while read line; do
                #echo " ... reading file $line"
                ls -alh $line | sed -e 's/\//  /g'  | awk '{print $10,$5}'
        done < list_of_files

        echo
        echo " %%% check variables & variable dimensions"
        echo

        while read line; do
                #echo " ... reading file $line"
                nlon=`ncdump -h $line | grep "longitude = " | awk '{print $3}'`
		nlat=`ncdump -h $line | grep "latitude = "  | awk '{print $3}'`
		nvar=`ncdump -h $line | grep short | wc -l`
		nvar2=`ncdump -h $line | grep float | wc -l`
		let nvar=$nvar+$nvar2
		if [ "$nvar" -eq  "0" ]; then nvar=`ncdump -h $line | grep float | wc -l`; fi
	        echo " ... file: $line has $nlon lons, $nlat lats, $nvar vars" 
        done < list_of_files

	echo
	echo " %%% names of vars are: "
	echo

	file=`sed '1q;d' list_of_files`
	ncdump -h $file | grep short
	ncdump -h $file | grep float

	echo
        echo " %%% check for corrupted files "
        echo

	while read line; do
		if [ -e nemo.nc ]; then rm nemo.nc; fi
		echo; echo " ... file $line"; echo
		ncks -d longitude,300 -d latitude,180 -d depth,0 -d time,0 $line nemo.nc
		ncdump -t -v time $line | grep Error
		ncdump nemo.nc | grep " _ "
		rm nemo.nc
	done < list_of_files

	echo
        echo " ... the n. of files is $nfiles"
        echo

	echo
	echo " +++ End of Script +++"
	echo

#
#   the end
#


