#!/bin/bash
#

        ###### check existence of directories !!!!!

	echo; echo " +++ Checking directory tree in storage JENNY +++"; echo


        if [ -e $jenny ]; then

             echo " ... dir $jenny exists, will use it"; echo
             cd $jenny; echo " ... here I am @ dir $PWD"; echo

             ##### sub-dir forecast

             if [ -e forecast ]; then

                echo " ... dir forecast exists, will use it"; echo 
                cd $jenny/forecast; echo " ... here I am @ dir $PWD"; echo

                if [ ! -e Regional_Ocean_Models ]; then mkdir Regional_Ocean_Models ; fi
                if [ ! -e Wave_Models ]; then mkdir Wave_Models ; fi
                if [ ! -e Wind_Models ]; then mkdir Wind_Models ; fi

             else

                echo " ... dir forecast doesnt exists, will create it"; echo 

                mkdir $jenny/forecast
                mkdir $jenny/forecast/Regional_Ocean_Models
                mkdir $jenny/forecast/Wave_Models
                mkdir $jenny/forecast/Wind_Models

             fi

             ##### go back to dir $jenny and test sub-dir hindcast

             cd $jenny; echo " ... going back to dir $PWD"; echo

             if [ -e hindcast ]; then

                echo " ... dir hindcast exists, will use it"; echo
                cd $jenny/hindcast; echo " ... here I am @ dir $PWD"; echo 

                if [ ! -e Regional_Ocean_Models ]; then mkdir Regional_Ocean_Models ; fi
                if [ ! -e Wave_Models ]; then mkdir Wave_Models ; fi
                if [ ! -e Wind_Models ]; then mkdir Wind_Models ; fi

             else

                echo " ... dir hindcast doesnt exists, will create it"; echo

                mkdir $jenny/hindcast
                mkdir $jenny/hindcast/Regional_Ocean_Models
                mkdir $jenny/hindcast/Wave_Models
                mkdir $jenny/hindcast/Wind_Models

             fi

        else

             ##### dirs don't exist, will create them all !!!!!

             echo " ... dir $jenny doesnt exist, will create it"; echo

             mkdir $jenny

             mkdir $jenny/forecast
             mkdir $jenny/forecast/Regional_Ocean_Models
             mkdir $jenny/forecast/Wave_Models
             mkdir $jenny/forecast/Wind_Models

             mkdir $jenny/hindcast
             mkdir $jenny/hindcast/Regional_Ocean_Models
             mkdir $jenny/hindcast/Wave_Models
             mkdir $jenny/hindcast/Wind_Models

        fi

        ################# go back to tmpdir

        cd $tmpdir; echo " ... going back to dir $PWD"; echo




### the end
