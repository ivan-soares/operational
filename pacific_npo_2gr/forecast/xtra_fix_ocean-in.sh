#!/bin/bash
#
	today=$1

	yr=${today:0:4}
	mm=${today:4:2}
	dd=${today:6:2}

	echo
	echo " ... starting new expt "
	echo " ... today is $yr/$mm/$dd"
	echo

	here=`pwd`
	inpdir="$here/d-outputs/temporary/roms_in"
	outdir="$here/d-outputs/temporary/roms_out"

	romsin="$here/d-codes/roms/roms_brz0.05.in" 

	ndays=1
	nsecs=60
	nfast=30

	nhis=`  echo      3 $nsecs | awk '{print $1*3600/$2}'`
	nrst=`  echo     24 $nsecs | awk '{print $1*3600/$2}'`
	nsteps=`echo $ndays $nsecs | awk '{print $1*24*3600/$2}'`

	nsecs="${nsecs}.0d0"

	##### FIX .IN FILE

	sed -e "s|INPUTS|$inpdir|g" \
	    -e "s|OUTPUTS|$outdir|g" \
	    $romsin >& tmp1

cat > tmp2 << EOF

	DT == $nsecs 
	NTIMES == $nsteps 
	NDTFAST == $nfast 
	NRREC == $nrrec 
	NHIS == $nhis 
        NRST == $nrst 

        Vtransform == $vtrans     
        Vstretching == $vstret
        THETA_S == $thetas
        THETA_B == $thetab
        TCLINE == $tcline

	DSTART = $dstart                    ! days
        TIDE_START = $tidestart             ! days
        TIME_REF = $timeref 

        TNUDG == 2*0.0d0                    ! days
        ZNUDG == 0.0d0                      ! days
        M2NUDG == 0.0d0                     ! days
        M3NUDG == 0.0d0                     ! days

        OBCFAC == 0.0d0                     ! nondimensional

        LuvSponge == F                      ! horizontal momentum
        LtracerSponge == F F                ! temperature, salinity, inert  

        LuvSrc == F                         ! horizontal momentum transport
        LwSrc == F                          ! volume vertical influx
        LtracerSrc == F F                   ! temperature, salinity, inert

        LsshCLM == F                        ! sea-surface height
        Lm2CLM == F                         ! 2D momentum
        Lm3CLM == F                         ! 3D momentum
        LtracerCLM == F F                   ! temperature, salinity, inert

        LnudgeM2CLM == F                    ! 2D momentum
        LnudgeM3CLM == F                    ! 3D momentum
        LnudgeTCLM == F F                   ! temperature, salinity, inert

        TNU2 == 0.0d0  0.0d0                ! m2/s
        TNU4 == 2*0.0d0                     ! m4/s
        VISC2 == 5.0d0                      ! m2/s
        VISC4 == 0.0d0                      ! m4/s
	
!       Open Boundary Conditions

	LBC(isFsur) ==  Cha Cha Cha Cha ! free surface 
	LBC(isUbar) ==  Fla Fla Fla Fla ! 2D U-momentum 
	LBC(isVbar) ==  Fla Fla Fla Fla ! 2D V-momentum
	LBC(isUvel) ==  Rad Rad Rad Rad ! 3D U-momentum
	LBC(isVvel) ==  Rad Rad Rad Rad ! 3D V-momentum 
	LBC(isMtke) ==  Gra Gra Gra Gra ! mixing TKE  
	LBC(isTvar) ==  RadNud RadNud RadNud RadNud RadNud RadNud RadNud RadNud ! temperature salinity 

EOF

	cat tmp1 tmp2 >& roms.in

	echo
	echo " ... end of expt"
	echo
	
	
	
	### time step and duration of experiment

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
	#	        -1 STARTS FROM LAST TIME AVAILABEL IN RESTARTFILE
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
#
#
