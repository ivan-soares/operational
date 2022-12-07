#!/usr/bin/env bash

       ### need NX and NY again, for the ocean.in file
       ni=`ncdump -h $romsgrd | grep "xi_rho = " | awk '{print $3-2}'`
       nj=`ncdump -h $romsgrd | grep "eta_rho = " | awk '{print $3-2}'`
       nk=$nsig

       ### find dstart: will read a file named 'today' & write a file named 'dstart'
       rm -rf dstart
       echo $today >& today
       python $pythdir/find_dstart.py
       rm today

       dstart=`cat dstart`
       rm dstart
       tidestart="0.0d0"
       timeref="${reftime}.0d0"

###################### *** print simulation info *** ####################################

       echo
       echo " ... prepare ocean.in file for $mytitle "
       echo " ... will use the time ref $timeref "
       echo

##################### *** set storage intervals *** #####################################

       nrst=$((24*3600/$nsecs))
       nsta=$((1*3600/$nsecs))
       nflt=$((1*3600/$nsecs))
       nhis=$(($roms_his_dh*3600/$nsecs))
       navg=$((24*3600/$nsecs))
       ndia=$((24*3600/$nsecs))

###################### *** fix the ocean.in file *** #####################################


       sed -e "s|INPUTS|$inpdir|g" -e "s|OUTPUTS|$outdir|g" \
           $roms_codedir/roms_brz0.05.in >& ocean_${expt}.in

       ### title & varinfo

       sed -i "/ TITLE = /    c\  TITLE = $mytitle "      ocean_${expt}.in
       sed -i "/ VARNAME = /  c\  VARNAME = $varinfo "    ocean_${expt}.in
       sed -i "/ MyAppCPP = / c\  MyAppCPP = $appflag "   ocean_${expt}.in

       ### time stepping

       sed -i "/ DT == /      c\  DT == $dt "             ocean_${expt}.in
       sed -i "/ NHIS == /    c\  NHIS == $nhis "         ocean_${expt}.in
       sed -i "/ NRST == /    c\  NRST == $nrst "         ocean_${expt}.in
       sed -i "/ NAVG == /    c\  NAVG == $navg "         ocean_${expt}.in
       sed -i "/ NDIA == /    c\  NDIA == $ndia "         ocean_${expt}.in
       sed -i "/ NSTA == /    c\  NSTA == $nsta "         ocean_${expt}.in
       sed -i "/ NFLT == /    c\  NFLT == $nflt "         ocean_${expt}.in
       sed -i "/ NRREC == /   c\  NRREC == $nrrec "       ocean_${expt}.in
       sed -i "/ NTIMES == /  c\  NTIMES == $nsteps "     ocean_${expt}.in
       sed -i "/ NDTFAST == / c\  NDTFAST == $nfast "     ocean_${expt}.in

       ### sigma parameters

       sed -i "/ TCLINE == /      c\  TCLINE == $tcline "        ocean_${expt}.in
       sed -i "/ THETA_S == /     c\  THETA_S == $thetas "       ocean_${expt}.in
       sed -i "/ THETA_B == /     c\  THETA_B == $thetab "       ocean_${expt}.in
       sed -i "/ Vtransform == /  c\  Vtransform == $vtrans "    ocean_${expt}.in
       sed -i "/ Vstretching == / c\  Vstretching == $vstret "   ocean_${expt}.in
 
       ### tide start and time referrence

       sed -i "/ DSTART = /     c\  DSTART = $dstart         ! days " ocean_${expt}.in
       sed -i "/ TIDE_START = / c\  TIDE_START = $tidestart  ! days " ocean_${expt}.in
       sed -i "/ TIME_REF = /   c\  TIME_REF = $timeref "             ocean_${expt}.in

       ### LcycleRST    Logical switch (T/F) used to recycle time records in output
       ### If TRUE,  only the latest two re-start are saved

       sed -i "/ LcycleRST == /  c\  LcycleRST == F         ! T/F " ocean_${expt}.in

       ### Chapman OBC factor

       sed -i "/ OBCFAC == /c\ OBCFAC == ${obcfac}d0  ! nondimensional " ocean_${expt}.in

       ### river sources 

       sed -i "/ LwSrc == /      c\ LwSrc == T         ! volume vertical influx "        ocean_${expt}.in
       sed -i "/ LuvSrc == /     c\ LuvSrc ==  F       ! horizontal momentum transport " ocean_${expt}.in
       sed -i "/ LtracerSrc == / c\ LtracerSrc == T T  ! temperature, salinity, inert  " ocean_${expt}.in

       ### nudging coeffs

       sed -i "/ TNUDG == / c\ TNUDG == 2*${tnudg}d0 ! days " ocean_${expt}.in
       sed -i "/ ZNUDG == / c\ ZNUDG == ${znudg}d0   ! days " ocean_${expt}.in
       sed -i "/ M2NUDG == /c\ M2NUDG == ${znudg}d0  ! days " ocean_${expt}.in
       sed -i "/ M3NUDG == /c\ M3NUDG == ${tnudg}d0  ! days " ocean_${expt}.in

       ### OBCs

       #sed -i " / LBC(isUvel) == /c\ LBC(isUvel) ==  RadNud  RadNud  RadNud  RadNud     ! 3D U-momentum"  ocean_${expt}.in
       #sed -i " / LBC(isVvel) == /c\ LBC(isVvel) ==  RadNud  RadNud  RadNud  RadNud     ! 3D V-momentum"  ocean_${expt}.in

       ### LBC(isUvel) ==   Rad     Rad     Rad     Rad         ! 3D U-momentum
       ### LBC(isVvel) ==   Rad     Rad     Rad     Rad         ! 3D V-momentum

       ### nudging to climatology

       #sed -i "/ LsshCLM == / c\ LsshCLM == T "  ocean_${expt}.in
       #sed -i "/ Lm2CLM == /  c\  Lm2CLM == T "  ocean_${expt}.in
       #sed -i "/ Lm3CLM == /  c\  Lm3CLM == T "  ocean_${expt}.in
       #sed -i "/ LtracerCLM == / c\ LtracerCLM == T T " ocean_${expt}.in

       #sed -i "/ LnudgeM2CLM == / c\ LnudgeM2CLM == T " ocean_${expt}.in
       #sed -i "/ LnudgeM3CLM == / c\ LnudgeM3CLM == T " ocean_${expt}.in
       #sed -i "/ LnudgeTCLM == / c\ LnudgeTCLM == T T " ocean_${expt}.in

       ### variables controling time step and duration of expt

       ### NTIMES       Total number of timesteps in current run.  If 3D configuration,
       #                NTIMES is the total of baroclinic timesteps.  If only 2D
       #                configuration, NTIMES is the total of barotropic timesteps.
       #
       ### DT           TimeStep size in seconds.  If 3D configuration, DT is the
       #                size of the baroclinic timestep.  If only 2D configuration,
       #                DT is the size of the barotropic timestep.
       #
       # NDTFAST      Number of barotropic timesteps between each baroclinic time
       #                step. If only 2D configuration, NDTFAST should be unity since
       #                there is no need to split timestepping.

       ### variables controling RESTART

       ### LDEFOUT      Logical switch (T/F) used to create new output files when
       #                initializing from a re-start file, abs(NRREC) > 0.  If TRUE
       #                and applicable, a new HISTORY, QUICKSAVE, AVERAGE, DIAGNOSTIC
       #                and STATIONS files are created during the initialization

       ### NRREC        Switch to indicate re-start from a previous solution.
       #                0 STARTS NEW SOLUTION
       #               -1 STARTS FROM LAST TIME AVAILABEL IN RESTARTFILE
       #                1 STARTS FROM THE FIRST TIME AVAILABLE IN RESTARTFILE
       
       ### variables controling output

       ### NHIS  Number of timesteps between writing fields into the HISTORY
       ### NAVG  Number of timesteps between writing time-averaged data
       ### NQCK  Number of timesteps between writing fields into QUICKSAVE file
       ### NRST  Number of timesteps between the writing of re-start fields.
       ### NSTA  Number of timesteps between writing data into STATIONS file.
       ### NFLT  Number of timesteps between writing data into FLOATS file.
       ### NINFO Number of timesteps between the print of single line information
       ### NDIA  Number of timesteps between writing time-averaged diagnostics

       #### I AM NOT USING FLOATS, STATIONS, QUICK, AVG, DIA 

       ### Output tangent linear and adjoint model parameters.

       ### NTLM  Number of timesteps between writing fields into tangent linear model file.
       ### NADJ  Number of timesteps between writing fields into the adjoint model file.
       ### NSFF  Number of timesteps between 4DVAR adjustment of surface forcing fluxes.
       ### NOBC  Number of timesteps between 4DVAR adjustment of open boundary fields.


#
################################# the end ############################################################
#
