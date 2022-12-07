#!/bin/bash
#

        echo
        echo " +++ Starting routine to compute MLD & LANGMUIR +++"
        echo


	pdir="$HOME/operational/pacific_npo_2gr/forecast/d-storage/$today"

	romsfile="$pdir/roms_zlevs_mld_npo0.08_07e_${today}_glby.nc"
	glbyfile="$pdir/glby_zlevs_mld_npo0.08_07e_${today}.nc"
	nemofile="$pdir/nemo_zlevs_mld_npo0.08_07e_${today}.nc"
	wavefile="$pdir/ww3_his_npo0.33_${today}.nc"
	mldfile="$pdir/mld_npo0.08_07e_${today}.nc"

	cdo="cdo -s --no_warnings"

        echo " ... dimensions are : nx = $nx, ny = $ny, nz = $nz_mld" ; echo

        sed -e "s/YYYY-MM-DD/${yr}-${mm}-${dd}/g"\
        -e "s/NLON/$nx/g" -e "s/NLAT/$ny/g" -e "s/NDEP/$nz_mld/g" \
        $here/d-interp/mld_langmuir_YYYY-MM-DD_hrs.cdf >& cdf.cdf
        ncgen -k4 cdf.cdf -o $mldfile
        rm cdf.cdf

	##### MLD

        python $here/d-interp/compute_mld.py $romsfile $glbyfile $nemofile $mldfile $ndays

	### LANGMUIR

	### interp wave model to the resolution of ROMS

	echo " ... remap WAVES horiz."; echo

	rm -f tmp*
	ncks -h -v  uuss,vuss,uwnd,vwnd,dpt,MAPSTA $wavefile tmp1.nc

        rm -rf grid.nc weights.nc
        cp $here/d-interp/grid_r_jenny.nc grid.nc
        $cdo genbil,grid.nc             tmp1.nc  weights.nc
        $cdo remap,grid.nc,weights.nc   tmp1.nc  tmp2.nc
        rm weights.nc grid.nc

	python $here/d-interp/compute_langmuir_mac_williams.py tmp2.nc $mldfile
	rm tmp*

        echo
        echo " +++ End of routine to compute MLD & LANGMUIR +++"
        echo


###     the end
