#!/bin/bash
#

	nx=601
	ny=376
	nz_mld=17

	today=$1

	yr=${today:0:4}
	mm=${today:4:2}
	dd=${today:6:2}

	here=`pwd`

	source step11_sub02_interp_mld_langmuir.sh

###     the end
