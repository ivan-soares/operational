#!/bin/bash
#
	ls -1 step* >& list

	while read line; do
		sed -e 's/step00_setup/hindcast_setup/g' $line >& tmp
		mv tmp $line
	done < list
#
#   the end
#
