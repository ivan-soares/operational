#!/bin/bash

	today=20221106
	ndays=10
	nn=1

	yr=${today:0:4}
	mm=${today:4:2}
	dd=${today:6:2}

	#sleep 900s

	echo
	echo " +++ Starting script to run roms many days +++"
	echo

	while [ $nn -le $ndays ]; do

	    echo " ... running forecast for day $today"

	    if [ ! -e d-storage/$today ]; then mkdir d-storage/$today ; fi

	    ./run_forecast.sh $today 1 nemo 15 >& logfile_$today.log; wait 

	    today=`find_tomorrow.sh $yr $mm $dd`
	    yr=${today:0:4}
	    mm=${today:4:2}
	    dd=${today:6:2}

	    let nn=$nn+1

	done	

	#./run_forecast.sh $today 7 'glby' 1; wait
	#./run_forecast.sh $today 7 'glby' 5; wait

	echo
	echo " +++ End of script +++"
	echo

#
#  the end
#
