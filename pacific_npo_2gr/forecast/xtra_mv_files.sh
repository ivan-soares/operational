#!/bin/bash
#
	today=20210201
	ndays=89
	nn=1

	echo
	echo " +++ Starting bash script to move files to storage +++"
	echo

	inpdir="$HOME/oper/pacific_npo/forecast/d-storage"
	gfsdir="$HOME/new_storage/environment/gfsanl_glo0.50_2021_03h"
        glbydir="$HOME/new_storage/environment/hncoda_glby_npo0.08_167W117W-15N47N_06h"
	nemodir="$HOME/new_storage/environment/nemo_npo0.08_167W117W-15N47N_24h"


	yr=${today:0:4}
	mm=${today:4:2}
	dd=${today:6:2}

	mdate=${today}

	while [ $nn -le $ndays ]; do

		echo " ... today is $mdate"

		gfs="$inpdir/$mdate/gfs_$mdate.nc"
		nemo="$inpdir/$mdate/nemo_npo0.08_$mdate.nc"
		glby="$inpdir/$mdate/glby_npo0.08_$mdate.nc"


		#if [ -e $gfs ]; then mv $gfs $gfsdir/. ; else echo " ... didnt find gfs file"; fi
                if [ -e $nemo ]; then mv $nemo $nemodir/nemo_npo_$mdate.nc ; else echo " ... didnt find nemo file"; fi
                #if [ -e $glby ]; then mv $glby $glbydir/glby_npo_$mdate.nc ; else echo " ... didnt find glby file"; fi


		mdate=`find_tomorrow.sh $yr $mm $dd`

		yr=${mdate:0:4}
		mm=${mdate:4:2}
		dd=${mdate:6:2}

		let nn=$nn+1

	done

        echo
        echo " +++ End of Script +++"
        echo

###  the end

	
