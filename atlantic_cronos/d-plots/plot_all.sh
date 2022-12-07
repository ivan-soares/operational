#!/bin/bash
#
        echo
        echo " ... starting routine to plot surface vector maps ... "
        echo

        today=$1
        pdate="${today}_18h"

        f1="../d-storage/$today/cmems_sla_vels_atl0.25_${today}.nc"
	f2="../d-storage/$today/glby_brz0.08_${today}.nc"  #input_clm_brz0.05_01g_20211128_glby.nc
        f3="../d-storage/$today/nemo_brz0.08_${today}.nc"  #input_clm_brz0.05_01g_20211128_nemo.nc
        f4="../d-storage/$today/roms_his_brz0.05_01g_${today}_glby.nc"
        f5="../d-storage/$today/roms_his_brz0.05_01g_${today}_nemo.nc"

        echo " ... plotting CMEMS Multiobs file $f1"; echo
        python3 plot_cmems_sla.py $f1 $pdate 0 1

        echo " ... plotting HYCOM file $f2"; echo
        python3 plot_glby.py $f2 $pdate 0 glby 4 6

        echo " ... plotting NEMO file $f3"; echo
        python3 plot_nemo.py $f3 $pdate 0 nemo 3 6

        #echo " ... plotting ROMS file $f2"; echo
        #python3 plot_roms.py $f4 $pdate 18 glby 4 6

        echo " ... plotting ROMS file $f3"; echo
        python3 plot_roms.py $f5 $pdate 18 nemo 4 6

        echo
        echo " ... end of routine ..."
        echo



#
#     the end
#

