#!/bin/bash
#

	today=$1
	nopt=$2

	echo
	echo " +++ Script to do what I say +++"
	echo

	yr=${today:0:4}
	mm=${today:4:2}
	dd=${today:6:2}

	echo " ... the date is ${yr}-${mm}-${dd}"; echo

	if [ $nopt == 1 ]; then
		echo
		echo " ... will do oper 1"
		echo
	elif [ $nopt == 2 ]; then
		while true; do
		echo
		read -p  " ... R U sure (y/n) ?" yn
		echo
		case $yn in 
			[yY] ) echo " .. OK, will do it ";
				break;;
			[nN] ) echo " .. exiting ";
				exit;;
			* ) echo " .. invalid choice";;
		esac
		done
	fi

	echo
	echo " +++ End of Script +++"
	echo
