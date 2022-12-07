#!/bin/bash
#
	infile=$1

	# global GFS files with resolution of 0.5 x 0.5 deg shall have the following size
	nlon=720
	nlat=361


        # check for Not-a-Number
	isnan=`cdo -s -w -info $infile | grep "nan"`

	if [ -z "$isnan" ]; then
		check01=0
	else
		check01=1
	fi

	# check the size of matrix: nlon & nlat
	nx=`cdo -s -w griddes $infile | grep xsize | awk '{print $3}'`
	ny=`cdo -s -w griddes $infile | grep ysize | awk '{print $3}'`

	check02=0
	if [ $nx != $nlon -o $ny != $nlat ]; then
		check02=1
	fi

	# check for espurios values
	# GFS global files have 0 miss values becaue it is global
	# so, if nmin of miss values iz not zero the files is corrupted
	# also, if nmax is equal gridsize, it is also corrupted
	npts=`cdo -s -w griddes $infile | grep gridsize | awk '{print $3}'`
	nmin=`cdo -s -w info $infile |  awk '{print $7}' | sort -nk1 | awk 'NR==1'`
	nmax=`cdo -s -w info $infile |  awk '{print $7}' | sort -nk1 | awk 'END{print}'`

	check03=0
	if [ $nmin != 0 -o $nmax == $npts ]; then
		check03=1
	fi

	echo ${check01}${check02}${check03}

#
#   the end
#
