#!/bin/bash
#
        if [ -e $ww3wind ]; then
              echo; echo " ... accessing windfile $ww3wind for ww3"; echo
              ln -s $ww3wind ${wind}_${today}.nc
       else
               echo; echo " ... didnt find windfile $ww3wind, exiting ..."
               echo; exit
       fi

       for d in $domain_ww3; do
             ini=$(echo "$ww3ini" | sed "s/DOMAIN/${d}/")
             if [ -e $ini ]; then
                   echo; echo " ... accessing restartfile $ini for ww3"; echo
                   ln -s $ini
             else
                   echo; echo " ... didnt find restartfile $ini, will start from rest"
                   echo; #exit
             fi
       done

       echo; echo " ... copy WW3 grid files from folder $ww3_grddir"; echo

       for d in $domain_ww3; do
            for mod in depth mask meta obstr; do
                echo " ... copy $ww3_grddir/${d}.${mod}"
                cp $ww3_grddir/${d}.${mod} .
            done
        done

       echo; echo " ... copy WW3 .inp files from folder $ww3_inpdir"; echo

       for mod in grid multi prnc strt; do
           echo " ... copy file $ww3_inpdir/ww3_${mod}.*"
           cp $ww3_inpdir/ww3_${mod}.* .
       done

#
#  the end
#
