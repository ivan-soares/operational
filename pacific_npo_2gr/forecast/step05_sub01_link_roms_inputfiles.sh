#!/bin/bash
#
        echo; echo " ... make links to ROMS input files"; echo

        if [ -e $romsgrd ]; then
           echo; echo " ... accessing ROMS grid file $romsgrd"; echo
           if [ -e roms_grd_1.nc ]; then rm roms_grd_1.nc; fi
           ln -s $romsgrd roms_grd_1.nc
        else
           echo; echo " ... didnt find ROMS grid file $romsgrd, exiting forecast cycle"
           echo; exit
        fi

        if [ -e $romsgrd2 ]; then
           echo; echo " ... accessing ROMS grid file $romsgrd2"; echo
           if [ -e roms_grd_2.nc ]; then rm roms_grd_2.nc; fi
           ln -s $romsgrd2 roms_grd_2.nc
        else
           echo; echo " ... didnt find ROMS grid file $romsgrd2, exiting forecast cycle"
           echo; exit
        fi

        if [ -e $romsngc ]; then
           echo; echo " ... accessing ROMS ngc file $romsngc"; echo
           if [ -e roms_ngc.nc ]; then rm roms_ngc.nc; fi
           ln -s $romsngc roms_ngc.nc
        else
           echo; echo " ... didnt find ROMS ngc file $romsngc, exiting forecast cycle"
           echo; exit
        fi


        if [ -e $romstid ]; then
           echo; echo " ... accessing ROMS tide file $romstid"; echo
           if [ -e roms_tid.nc ]; then rm roms_tid.nc; fi
           ln -s $romstid roms_tid.nc
        else
           echo; echo " ... didnt find ROMS tide file $romstid, exiting forecast cycle"
           echo; exit
        fi

	echo; echo " ... this implementation uses no rivers" ; echo

        #if [ -e $romsriv ]; then
        #   echo; echo " ... accessing ROMS river file $romsriv"; echo
        #   if [ -e roms_riv.nc ]; then rm roms_riv.nc; fi
        #   ln -s $romsriv roms_riv.nc
        #else
        #   echo; echo " ... didnt find ROMS river file $romsriv, exiting forecast cycle"
        #   echo; exit
        #fi

        if [ -e $romsnud ]; then
           echo; echo " ... accessing ROMS nudg file $romsnud"; echo
           if [ -e roms_nud.nc ]; then rm roms_nud.nc; fi
           ln -s $romsnud roms_nud.nc
        else
           echo; echo " ... didnt find ROMS nudg file $romsnud, exiting forecast cycle"
           echo; exit
        fi

        ### if a restart file is NOT found, the initial file will be the clm file
	### in this case nrrec and tidal_ramp have to be fixed accordingly !!!

        if [ -e $romsini ]; then
           echo; echo " ... accessing ROMS init file $romsini"; echo
           if [ -e roms_ini_1.nc ]; then rm roms_ini_1.nc; fi
           ln -s $romsini roms_ini_1.nc
        else
           echo; echo " ... didnt find ROMS init file $romsini"
           echo; echo " ... will use file $stodir/$today/$romsclm"; echo
	   if [ -e roms_ini_1.nc ]; then rm roms_ini_1.nc; fi
           ln -s $stodir/$today/$romsclm roms_ini_1.nc
	   ramp_flag='tide_with_ramp'
           nrrec=0
        fi

        if [ -e $romsini2 ]; then
           echo; echo " ... accessing ROMS init file $romsini2"; echo
           if [ -e roms_ini_2.nc ]; then rm roms_ini_2.nc; fi
           ln -s $romsini2 roms_ini_2.nc
        else
           echo; echo " ... didnt find ROMS init file $romsini2"
           echo; echo " ... will use file $stodir/$today/$romsclm2"; echo
           if [ -e roms_ini_2.nc ]; then rm roms_ini_2.nc; fi
           ln -s $stodir/$today/$romsclm2 roms_ini_2.nc
           #ramp_flag='tide_with_ramp' this flag applies to the larger grid only.
           nrrec2=0
        fi

        file=$stodir/$today/$romsclm

        if [ -e $file ]; then
           echo; echo " ... accessing ROMS clim file $file"; echo
           if [ -e roms_clm.nc ]; then rm roms_clm.nc; fi
           ln -s $file roms_clm.nc
        else
           echo; echo " ... didnt find ROMS clim file $file, exiting forecast cycle"
           echo; exit
        fi

        file=$stodir/$today/$romsbry

        if [ -e $file ]; then
           echo; echo " ... accessing ROMS bdry file $file"; echo
           if [ -e roms_bry.nc ]; then rm roms_bry.nc; fi
           ln -s $file roms_bry.nc
        else
           echo; echo " ... didnt find ROMS bdry file $file, exiting forecast cycle"
           echo; exit
        fi

	#### SST is in the forcing file roms_frc.nc

        #file=$stodir/$today/$romssst

        #if [ -e $file ]; then
        #   echo; echo " ... accessing ROMS surf file $file"; echo
        #   if [ -e roms_sst.nc ]; then rm roms_sst.nc; fi
        #   ln -s $file roms_sst.nc
        #else
        #   echo; echo " ... didnt find ROMS clim file $file, exiting forecast cycle"
        #   echo; exit
        #fi

        if [ -e $romsfrc ]; then
           echo; echo " ... accessing ROMS force file $romsfrc"; echo
           if [ -e roms_frc.nc ]; then rm roms_frc.nc; fi
           ln -s $romsfrc roms_frc.nc
        else
           echo; echo " ... didnt find ROMS force file $romsfrc, exiting forecast cycle"
           echo; exit
        fi

#
#  the end
#

