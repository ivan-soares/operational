#!/bin/bash
#

        echo
        echo " +++ Starting routine to compute MLD & LANGMUIR +++"
        echo

	nx=601
	ny=376
	nz=17

	today='20210719'

	yr=${today:0:4}
	mm=${today:4:2}
	dd=${today:6:2}

	here="$HOME/oper/pacific_npo_2gr/forecast"

	romsfile="$here/d-storage/$today/roms_zlevs_mld_npo0.08_07e_20210719_glby.nc"
	glbyfile="$here/d-storage/$today/glby_zlevs_mld_npo0.08_07e_20210719.nc"
	nemofile="$here/d-storage/$today/nemo_zlevs_mld_npo0.08_07e_20210719.nc"
	mldfile="$here/d-storage/$today/mld_npo0.08_07e_20210719.nc"

        echo " ... dimensions are : nx = $nx, ny = $ny, nz = $nz" ; echo

        sed -e "s/YYYY-MM-DD/${yr}-${mm}-${dd}/g"\
        -e "s/NLON/$nx/g" -e "s/NLAT/$ny/g" -e "s/NDEP/$nz/g" \
        $here/d-interp/mld_langmuir_YYYY-MM-DD_hrs.cdf >& cdf.cdf
        ncgen -k4 cdf.cdf -o $mldfile
        rm cdf.cdf

        python $here/d-interp/compute_mld.py $romsfile $glbyfile $nemofile $mldfile

        echo
        echo " +++ End of routine to compute MLD & LANGMUIR +++"
        echo


###     the end
