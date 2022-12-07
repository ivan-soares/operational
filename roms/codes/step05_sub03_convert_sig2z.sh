#!/bin/bash
#

	domainname="${domain_roms}_${version}"

################## *** convert outputs from sigma to z levels *** #############################################

	echo " ... interp ROMS output from sigma to z coord "

	inpfile="$stodir/$today/roms_his_${domainname}_${today}_${ogcm}.nc"

	depth_sig="${__dir}/d-interp/glby2sig/depths_sig_rho.nc"
	depth_z="${__dir}/d-interp/glby2sig/depths_z_rho.nc"

	vars="zeta,u_eastward,v_northward,temp,salt"

	n1=0
	n2=23

	mdate=$today

	outfile="roms_zlevs_${domainname}_${mdate}_${ogcm}.nc"
	echo " ... doing file $outfile"

	sed -e "s/YYYY-MM-DD/${yr}-${mm}-${dd}/g" ${__dir}/d-interp/sig2z/roms_YYYY-MM-DD_hrs.cdf >& cdf.cdf
	ncgen -k4 cdf.cdf -o $outfile
	rm cdf.cdf

	tmpfile="roms_${dd}.nc"
	ncks -d ocean_time,$n1,$n2 $inpfile $tmpfile

	cdo="cdo -s -w"
	$cdo select,name=$vars $tmpfile tmp1.nc
	$cdo  intlevel3d,$depth_z       tmp1.nc $depth_sig tmp2.nc
	ncrename -v u_eastward,u -v v_northward,v tmp2.nc

	python ${__dir}/d-interp/sig2z/write_roms_file.py tmp2.nc $outfile

	rm tmp*.nc $tmpfile

	mv $outfile $stodir/$today/.

	echo " ... end of vertical interp from sigma to z coord "

##################################  *** the end *** ############################################################
#
