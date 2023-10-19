#!/bin/bash

	infile=$1

	echo
	echo " ... checking file $infile"
	echo

	if [ -e $infile ]; then
		echo " ... file $infile exists !!" ; echo
		ncdump -h $infile | grep -h4 "dimensions"
	else
		echo " ... file $infile was NOT found !!"
	fi


####    the end
