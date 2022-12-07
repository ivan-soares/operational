#!/bin/bash
#

        for year in `seq 2011 2016`; do
            echo moving files of year $year
            mv results_${year}/out_grd.grd1 ~/TOC_STORAGE_2/CPD-waves/CPD-WW3_NPO_Ivan/binary_files/out_grd_${year}.grd1; wait
            mv results_${year}/out_grd.grd2 ~/TOC_STORAGE_2/CPD-waves/CPD-WW3_NPO_Ivan/binary_files/out_grd_${year}.grd2; wait
        done 

