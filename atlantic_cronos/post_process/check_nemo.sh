#!/bin/bash
#
	infile=$1

	### nlon and nlat of NEMO downloaded files shall be:
	nlon=349
	nlat=505

	### check for nan in NEMO files is not applicable. The nemo files always have nans

	check01=0

        # check for Not-a-Number
	#isnan=`cdo -s -w -info $infile | grep "nan"`

	#if [ -z "$isnan" ]; then
	#	check01=0
	#else
	#	check01=1
	#fi

	# check the size of matrix: nlon & nlat
	nx=`cdo -s -w griddes $infile | grep xsize | awk '{print $3}'`
	ny=`cdo -s -w griddes $infile | grep ysize | awk '{print $3}'`

	check02=0
	if [ $nx != $nlon -o $ny != $nlat ]; then
		check02=1
	fi

	# check for espurios values
	# if the number of miss is either zero or equal to the gridsize
	# then the file is corrupted
	npts=`cdo -s -w griddes $infile | grep gridsize | awk '{print $3}'`
	nmin=`cdo -s -w info $infile |  awk '{print $7}' | sort -nk1 | awk 'NR==1'`
	nmax=`cdo -s -w info $infile |  awk '{print $7}' | sort -nk1 | awk 'END{print}'`

	check03=0
	if [ $nmin == 0 -o $nmax == $npts ]; then
		check03=1
	fi

	echo ${check01}${check02}${check03}

#
#   the end
#
