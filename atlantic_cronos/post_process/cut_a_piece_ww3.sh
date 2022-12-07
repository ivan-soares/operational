#!/bin/bash
#
     today=$1
     stn=$2

     case $stn in
          rs4)
          grd='sao0.125'
          lat="-32.2454"
          lon="-52.0954"
          i1=65
	  i2=67
          j1=47
	  j2=49
          ;;
          rj4)
          grd='bca0.025'
          lat="-22.9717"
          lon="-43.1503"
          i1=210
	  i2=212
          j1=94
	  j2=96
          ;;
          rj4s)
          grd='sao0.125'
          lat="-23.1250"
          lon="-42.8750"
          i1=136
	  i2=138
          j1=118
	  j2=120
          ;;
          *)
          echo; echo ' ... wrong domain name, exiting !!'
          echo; exit
     esac


     infile="$HOME/operational/atlantic/forecast/d-outputs/storage/$today/ww3_his_${grd}_${today}.nc"
     outfile=ww3_${today}.nc

     ncks -v hs -d latitude,$j1,$j2 -d longitude,$i1,$i2 $infile $outfile
#
#  the end
#
