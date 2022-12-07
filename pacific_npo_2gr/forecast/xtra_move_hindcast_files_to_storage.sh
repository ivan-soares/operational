#!/bin/bash
#
	today=$1

	echo
	echo " +++ Starting script to make today's file +++ "
	echo


        yr=${today:0:4}
        mm=${today:4:2}
        dd=${today:6:2}

	yesterday=`find_yesterday.sh $yr $mm $dd`
	tomorrow=`find_tomorrow.sh $yr $mm $dd`

 ################################# dir & file names

	d1="$HOME/operational/pacific_npo_2gr/forecast/d-storage/$today"
	d2="$HOME/storage_at01/environment/atmos_gfs/gfsanl_glo0.25_2022_03h"
	d3="$HOME/storage_at01/environment/ocean_nemo/nemo_npo0.08_06h"

        gfs="gfs_${today}.nc"

        glby="glby_npo0.08_${today}.nc"
        nemo="nemo_npo0.08_${today}.nc"

############################### check dir

	if [ -d $d2 ]; then 
		echo " ... dir $d2 exists, will use it !!" ; echo
	else
		echo " ... dir $d2 DOESN'T exist, exiting !!" ; echo
		echo; exit
	fi

	if [ -d $d3 ]; then
                echo " ... dir $d3 exists, will use it !!" ; echo
        else
                echo " ... dir $d3 DOESN'T exist, exiting !!" ; echo
                echo; exit
        fi

################################ extract first day of forecast files and write on hindcast dir

	echo " ... moving GFS file "; echo

	if [ -e $d1/$gfs ]; then ncks -h -d time,0,9 $d1/$gfs $d2/$gfs; else echo " ... dind't find $gfs !!! "; fi


	echo " ... moving OGCMs "; echo

	if [ -e $d1/$nemo ]; then ncks -h -d time,0,4 $d3/$nemo $d2/$nemo; else echo " ... dind't find $nemo !!! "; fi



	echo
	echo " +++ End of script +++ "
	echo

