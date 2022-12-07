#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

today=$1
lastdate=$2
steps=$3
ogcm=$4

echo
echo " +++ Starting script to run roms many days +++"
echo

while [ $today -le $lastdate ]; do
    echo " ... running forecast for day $today"

    ./run_forecast.sh $today 1 $ogcm 3 > roms+${ogcm}_${today}.log
    wait
    ./run_forecast.sh $today 1 $ogcm 4 > roms+${ogcm}_${today}.log
    wait
    ./run_forecast.sh $today 1 $ogcm 5 > roms+${ogcm}_${today}.log
    wait


    today=$(date --date="$today + 1 day" +%Y%m%d)
done	

echo
echo " +++ End of script +++"
echo

#
#  the end
#
