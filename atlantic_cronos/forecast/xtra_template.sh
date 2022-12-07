#!/bin/bash
#
	today=20210109
	ndays=7
	nn=1

	echo
	echo " +++ Starting script to do what I say +++"
	echo

	mdate=$today

	yr=${today:0:4}
	mm=${today:4:2}
	dd=${today:6:2}

	inpdir="~/whatever"
        outdir="~/whatever"

	while [ $nn -le $ndays ]; do

		 echo " ...  today is $today"

		 ### do what i say

		 mdate=`find_tomorrow.sh $yr $mm $dd`

		 yr=${mdate:0:4}
		 mm=${mdate:4:2}
		 dd=${mdate:6:2}

		 let nn=$nn+1

	done

	echo
	echo " +++ End of script"
	echo


#
#   the end
#
