#!/bin/bash
#

        set -o nounset
        set -o errexit
        set -o pipefail

	today=$1
	iopt=$2

	echo
	echo " +++ Starting script to copy files to storage +++ "
	echo

	echo " ... ... iopt = 1: check local files."
        echo " ... ... iopt = 2: check storage files."
	echo " ... ... iopt = 3: copy day 1 to storage."
	echo " ... ... iopt = 4: cleanup local files."
	echo
	echo	

        yr=${today:0:4}
        mm=${today:4:2}
        dd=${today:6:2}

	yesterday=`find_yesterday.sh $yr $mm $dd`
	tomorrow=`find_tomorrow.sh $yr $mm $dd`

 ################################# dir & file names

	d1="$HOME/operational/pacific_npo_2gr/forecast/d-storage/$today"
	d2="$HOME/storage_at01/environment/atmos_gfs/gfsanl_glo0.25_2023_03h"
	d3="$HOME/storage_at01/environment/ocean_nemo/nemo_npo0.08_06h"
	d4="$HOME/storage_at02/roms_clim/toc/npo0.08/nemo/trunk_oper"

        gfs="gfs_${today}.nc"
	gfs2="gfs_npo0.25_${today}.nc"

        glby="glby_npo0.08_${today}.nc"
        glby2="glby_npo_${today}.nc"

        nemo="nemo_npo0.08_${today}.nc"
	nemo2="nemo_npo_${today}.nc"

	roms_bry="input_bry_npo0.08_07e_${today}_nemo.nc"
	roms_clm="input_clm_npo0.08_07e_${today}_nemo.nc"



############################### check files

	if [ $iopt == 1 ]; then

		echo
		echo
		echo " --> Cheking local files for day $yr-$mm-$dd "
		echo
		echo

		f1="$d1/$gfs"
		f2="$d1/$nemo"
		f3="$d1/$roms_bry"
		f4="$d1/$roms_clm"

		./xtra_check_file.sh $f1
                ./xtra_check_file.sh $f2
                ./xtra_check_file.sh $f3
                ./xtra_check_file.sh $f4

		echo; echo

	elif [ $iopt == 2 ]; then

                echo
                echo
                echo " --> Cheking files in storage for day $yr-$mm-$dd"
                echo
                echo

                f1="$d2/$gfs"
                f2="$d3/$nemo2"
                f3="$d4/$roms_bry"
                f4="$d4/$roms_clm"

		./xtra_check_file.sh $f1
		./xtra_check_file.sh $f2
		./xtra_check_file.sh $f3
		./xtra_check_file.sh $f4

		echo; echo

	elif [ $iopt == 3 ]; then

		echo
		echo
		echo " --> Copy files to storage for day $yr-$mm-$dd"
		echo
		echo

		echo; echo " ... GFS"; echo
		ncks -d time,0,8 $d1/$gfs $d2/$gfs

		echo; echo " ... NEMO"; echo
                ncks -d time,0,4 $d1/$nemo $d3/$nemo2

		echo; echo " ... BRY"; echo
                ncks -d bry_time,0,3 $d1/$roms_bry $d4/$roms_bry

		echo; echo " ... CLM"; echo
                ncks -d ocean_time,0,3 $d1/$roms_clm $d4/$roms_clm

		echo; echo

        elif [ $iopt == 4 ]; then

                echo
                echo
                echo " --> Cleanup local files for day $yr-$mm-$dd"
                echo
                echo

                echo; echo " ... GFS"; echo
                rm $d1/$gfs
		rm $d1/$gfs2

                echo; echo " ... NEMO"; echo
                rm $d1/$nemo

                echo; echo " ... BRY"; echo
                rm $d1/$roms_bry 

                echo; echo " ... CLM"; echo
                rm $d1/$roms_clm 

                echo; echo


	fi





	echo
	echo " +++ End of script +++ "
	echo

