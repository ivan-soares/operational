#!/bin/bash

	today=20200102
	ndays=30
	nn=1

	yr=${today:0:4}
	mm=${today:4:2}
	dd=${today:6:2}

	tomorrow=`find_tomorrow.sh $yr $mm $dd`


	echo
	echo " +++ Starting script to run roms many days +++"
	echo

	inpdir="$HOME/data/operational/atlantic/hindcast_shortTerm/d-storage/"

	while [ $nn -le $ndays ]; do

	    echo " ... running hindcast for day $today"

	    if [ ! -e d-storage/$today ]; then mkdir d-storage/$today ; fi

	    cp $inpdir/$today/gfs_brz0.50_${today}.nc d-storage/$today/. ; wait
	    cp $inpdir/$today/input_*_brz0.05_01g_${today}_glby.nc d-storage/$today/. ; wait

	    ./run_hindcast.sh $today 'glby' 15 ; wait

	    rm d-storage/$today/gfs_brz0.50_${today}.nc ; wait
	    rm d-storage/$today/input_*_brz0.05_01g_${today}_glby.nc ; wait
	    rm d-storage/$today/roms_avg_brz0.05_01g_${today}_glby.nc; wait
	    rm d-storage/$today/roms_zlevs_brz0.05_01g_${today}_glby.nc; wait

	    #if [ ! -e $inpdir/d-storage/$today ]; then mkdir $inpdir/d-storage/$today ; fi
	    #mv d-storage/$today/roms_his_brz0.05_01g_${today}_glby.nc $inpdir/d-storage/$today/.
	    #mv d-storage/$today/roms_rst_brz0.05_01g_${tomorrow}_glby.nc $inpdir/d-storage/$today/.
	    #mv d-storage/$today/roms_${today}_glby.log $inpdir/d-storage/$today/.

	    today=`find_tomorrow.sh $yr $mm $dd`
	    yr=${today:0:4}
	    mm=${today:4:2}
	    dd=${today:6:2}
	    tomorrow=`find_tomorrow.sh $yr $mm $dd`

	    let nn=$nn+1

	done	

	echo
	echo " +++ End of script +++"
	echo

#
#  the end
#
