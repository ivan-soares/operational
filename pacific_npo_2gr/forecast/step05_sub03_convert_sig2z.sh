#!/bin/bash
#

	domainname="${domain_roms}_${version}"
	domainname2="${domain_roms2}_${version2}"
	mdate=$today

################## *** convert outputs from sigma to z levels *** #############################################


	##### larger grid

	echo; echo " ... interp ROMS $domainname to z levels " ; echo

	inpfile="$stodir/$today/roms_his_${domainname}_${today}_${ogcm}.nc"
	outfile="$stodir/$today/roms_zlevs_${domainname}_${today}_${ogcm}.nc"

	depth_sig="$here/d-interp/depths_sig_${domain_roms}.nc"
	depth_z="$here/d-interp//depths_jenny_${domain_roms}.nc"

	vars="zeta,u_eastward,v_northward,temp,salt"

	nx=`ncdump -h $depth_z | grep "lon ="   | awk '{print $3}'`
	ny=`ncdump -h $depth_z | grep "lat ="   | awk '{print $3}'`
	nz=`ncdump -h $depth_z | grep "level =" | awk '{print $3}'`
    
	echo ; echo " ... doing file $outfile" ; echo

	sed -e "s/YYYY-MM-DD/${yr}-${mm}-${dd}/g"\
	-e "s/NLON/$nx/g" -e "s/NLAT/$ny/g" -e "s/NDEP/$nz/g" \
	$here/d-interp/roms_YYYY-MM-DD_hrs.cdf >& cdf.cdf

	ncgen -k4 cdf.cdf -o $outfile
	rm cdf.cdf

	cdo="cdo -s --no_warnings"
	$cdo  select,name=$vars $inpfile tmp1.nc
	$cdo  intlevel3d,$depth_sig      tmp1.nc   $depth_z  tmp2.nc
	#$cdo  intlevelx3d,$depth_sig    tmp1.nc   $depth_z  tmp2.nc
	ncrename -v u_eastward,u -v v_northward,v tmp2.nc

	python $here/d-interp/write_roms_file.py tmp2.nc $outfile

	mv $outfile $stodir/$today/.

	##### smaller grid


        echo; echo " ... interp ROMS $domainname2 to z levels " ; echo

        inpfile="$stodir/$today/roms_his_${domainname2}_${today}_${ogcm}.nc"
        outfile="$stodir/$today/roms_zlevs_${domainname2}_${today}_${ogcm}.nc"

        depth_sig="$here/d-interp/depths_sig_${domain_roms2}.nc"
        depth_z="$here/d-interp//depths_jenny_${domain_roms2}.nc"

        vars="zeta,u_eastward,v_northward,temp,salt"

        nx=`ncdump -h $depth_z | grep "lon ="   | awk '{print $3}'`
        ny=`ncdump -h $depth_z | grep "lat ="   | awk '{print $3}'`
        nz=`ncdump -h $depth_z | grep "layer =" | awk '{print $3}'`
     
        echo ; echo " ... doing file $outfile" ; echo

        sed -e "s/YYYY-MM-DD/${yr}-${mm}-${dd}/g"\
        -e "s/NLON/$nx/g" -e "s/NLAT/$ny/g" -e "s/NDEP/$nz/g" \
        $here/d-interp/roms_YYYY-MM-DD_hrs.cdf >& cdf.cdf

        ncgen -k4 cdf.cdf -o $outfile
        rm cdf.cdf

	rm tmp*

        cdo="cdo -s --no_warnings"
        $cdo  select,name=$vars $inpfile tmp1.nc
        $cdo  intlevel3d,$depth_sig      tmp1.nc   $depth_z  tmp2.nc
        #$cdo  intlevelx3d,$depth_sig    tmp1.nc   $depth_z  tmp2.nc
        ncrename -v u_eastward,u -v v_northward,v tmp2.nc

        python $here/d-interp/write_roms_file.py tmp2.nc $outfile


	mv $outfile $stodir/$today/.

	#done

	echo " ... end of vertical interp from sigma to z coord "

##################################  *** the end *** ############################################################
#
