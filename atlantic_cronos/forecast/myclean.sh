#/bin/bash
#

     stodir="$HOME/operational/atlantic/forecast/d-storage"

     find $stodir -name 'gfs_*' -mtime +3 -exec mv {} ~/remote/cronos/archive/gfs/ \;
     find $stodir -name 'nemo*' -mtime +3 -exec mv {} ~/remote/cronos/archive/nemo/ \;
     find $stodir -name 'glb*' -mtime +3 -exec mv {} ~/remote/cronos/archive/hncoda/ \;

     find $stodir -name 'roms_his_brz*nc' -mtime +3 -exec mv {} ~/remote/cronos/archive/roms/ \;
     find $stodir -name 'roms_rst_brz*nc' -mtime +3 -exec mv {} ~/remote/cronos/archive/roms/ \;

     find $stodir -name 'ww3_his_brz*nc' -mtime +3 -exec mv {} ~/remote/cronos/archive/ww3/ \;
     find $stodir -name 'ww3_rst_brz*nc' -mtime +3 -exec mv {} ~/remote/cronos/archive/ww3/ \;

     #find $stodir -name 'ww3_out*' -mtime +7 -exec rm {} \;
     find $stodir -name 'input*.nc' -mtime +3 -exec rm {} \;
     #find $stodir -name 'gfs*.nc' -mtime +7 -exec rm {} \;
     #find $stodir -name 'nemo*.nc' -mtime +7 -exec rm {} \;
     #find $stodir -name 'glb*.nc' -mtime +7 -exec rm {} \;

# the end
