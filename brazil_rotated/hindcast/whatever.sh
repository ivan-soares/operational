#!/bin/bash
#
	tide_ramp='yes'
	user_nudge='yes'
	avg_flag='yes'


	roms_exec="romsM"

	if [ $tide_ramp == 'yes' ]; then roms_exec="${roms_exec}_tide_with_ramp"; else roms_exec="${roms_exec}_tide_no_ramp"; fi

	if [ $user_nudge == 'yes' ]; then roms_exec="${roms_exec}_nudge_by_user"; else roms_exec="${roms_exec}_ananudge"; fi

	if [ $avg_flag == 'no' ]; then roms_exec="${roms_exec}_no_avg"; fi

	echo; echo " ... ROMS executable code $roms_exec"; echo

#
#   the end
#
