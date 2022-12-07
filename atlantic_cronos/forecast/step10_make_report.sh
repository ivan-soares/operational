#!/bin/bash
#

      #====================================================================================
      #                        THIS SCRIPT RUNS USING YESTERDAY RESULTS
      #====================================================================================


      #====================================================================================
      echo >> $log; cd $tmpdir; dr=`pwd`; now=$(date "+%Y/%m/%d %T")
      echo " ... starting script to make report of forecast at $now" >> $log
      echo ; echo " ==> $now HERE I am @ $dr for step 10: make report <=="; echo
      #====================================================================================

      yr=${yesterday:0:4}
      mm=${yesterday:4:2}
      dd=${yesterday:6:2}

      # Storage and report dir.
      sto="$stodir/$yesterday"
      rpt="$report/$yesterday"

      # Getting the information for the AREAs and POINTs to be subseted.
      # Exported in FORECAST_SETUP.sh
      IFS=',' read -ra SHORT <<< "$shrt_name"
      IFS=',' read -ra LONG <<< "$lng_name"
      IFS=',' read -ra PLN <<< "$Plon"
      IFS=',' read -ra PLT <<< "$Plat"
      IFS=',' read -ra A_W <<< "$AW"
      IFS=',' read -ra A_E <<< "$AE"
      IFS=',' read -ra A_S <<< "$AS"
      IFS=',' read -ra A_N <<< "$AN"
      IFS=',' read -ra BDR <<< "$bdr_pos"


      echo
      echo " ... yesterday is ${yesterday}"
      echo
      echo " ... will make a report and store at $rpt"
      echo

      if [ -e $rpt ]; then
            echo; echo " ... dir $rpt exists, will use it"; echo
      else
            echo; echo " ... dir $rpt doesnt exist, will create it"; echo
            mkdir $rpt
      fi

      declare -a OGCM=("nemo" "glby")

      for ogcm in "${OGCM[@]}"; do
            echo
            echo " >>>>> Creating report files and figures for ${ogcm^^}"
            echo

            # Files to be used
            romsfile="$sto/roms_his_${domain_roms}_${version}_${yesterday}_${ogcm}.nc"
            ogcmfile="$sto/${ogcm}_brz0.08_${yesterday}.nc"
            sat1file="$sto/cmems_sla_vels_atl0.25_${yesterday}.nc"


            echo
            echo " >>>>> Subsetting Areas and Points Determined"
            echo 
            for ii in ${!SHORT[@]};do
                  python $__dir/step10_sub01_extract_area.py $romsfile $sat1file \
                                                                       ${PLN[ii]}\
                                                                       ${PLT[ii]}\
                                                                       ${A_W[ii]}\
                                                                       ${A_E[ii]}\
                                                                       ${A_S[ii]}\
                                                                       ${A_N[ii]}\
                                                                       ${SHORT[ii]}
            done

    
            #
            # ----------------------- Converting SIGMA2Z coord.
            #
            ogcmfile="$stodir/$yesterday/roms_zlevs_brz0.05_01g_${yesterday}_${ogcm}.nc"
            if [ ! -s $ogcmfile ]; then
                  echo " +++ $ogcmfile doesn't exist or is empty. I will create it with xtra_convert_sig2z.sh"
                  source $__dir/xtra_convert_sig2z.sh
            else
                  echo " >>>>> $ogcmfile exist and will be copied to ${tmpdir}"
                  cp ${ogcmfile} ${tmpdir}
            fi

    
           echo
           echo " ... Creating and moving transect netcdf files for ${ogcm^^}"
           echo
           #
           # --------------------- Slicing Vertical Transect Across-shore
           #
           # The position of extract_across_shore.sh has to be rethought.
           source ${__root}/atlantic/post_process/extract_across_shore.sh 1

       done #(nemo and glby)

      echo
      echo " +++ Running Python Script to create transects +++ "
      echo
      python $__dir/step10_sub04_transects.py


      # Copying the logo.
      cp ${__root}/scripts/latex/logo_oceanpact.png .


      for ii in ${!SHORT[@]}; do
            echo
            echo " +++ Running Python Script to surface maps: "${LONG[ii]}" +++ "
            echo
            python $__dir/step10_sub05_sfc_cur.py ${SHORT[ii]} ${BDR[ii]} "${LONG[ii]}"

            echo 
            echo " +++ Running Python Script to Sea State Fig +++"
            python $__dir/step10_sub06_slide_bull2.py ${SHORT[ii]} "${LONG[ii]}" ${BDR[ii]} 

            echo
            echo " +++ Runing Latex and creating the Report's pdf file +++ "
            echo
            bash ${__root}/scripts/latex/bsh2latex.sh ${SHORT[ii]} "${LONG[ii]}"
            
            # BULLETIN 1: Compilling to PDF
            pdflatex -interaction=nonstopmode bulletin_${SHORT[ii]}.tex
            pdflatex -interaction=nonstopmode bulletin_template_${SHORT[ii]}.tex

            # BULLETIN 2: Renaming file to include the date related with and to place bulleting to d-report
            mv bulletin_${SHORT[ii]}.pdf $rpt/bulletin_${SHORT[ii]}_${yesterday}.pdf  ||:
            mv bulletin_template_${SHORT[ii]}.pdf $rpt/bulletin_template_${SHORT[ii]}_${yesterday}.pdf ||:
            
      done
      
      # TRANSECTS: copying the files to compile bellow.
      cp ${__root}/scripts/latex/{bulletin_transects.tex,transects.tex,logo_oceanpact.png} .

      # BULLETING TRANSECTS: Compilling PDF for transects only.
      pdflatex -interaction=nonstopmode bulletin_transects.tex
      mv bulletin_transects.pdf $rpt/bulletin_transects_${yesterday}.pdf ||:


      #====================================================================================
      now=$(date "+%Y/%m/%d %T")
      echo " ... finished report at $now" >> $log
      echo ; echo " ==> $now FINISHED making report <=="; echo
      #====================================================================================


      #####################################################################################
      #                                         END
      #####################################################################################
