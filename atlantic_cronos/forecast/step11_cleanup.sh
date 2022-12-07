#!/usr/bin/env bash
#

#====================================================================================
cd $tmpdir; dr=`pwd`
echo ; echo " ==> HERE I am for step 11: cleanup & close forecast cycle <=="; echo
now=$(date "+%F %T"); echo " ... cleanup at $now" >> $log
#====================================================================================

echo
echo " ... today is ${yr}-${mm}-${dd}"
echo

set -o allexport
source ${__root}/config/azure_credentials.sh
set +o allexport

# Function definitions
extract_first_day(){
    filepath="$1"
    timedim=${2:-time}

    # Get the initial and end dates in file using cdo showtimestamp and awk to print the first and last entries
    timespan=( $(cdo -s -w showtimestamp $filepath | awk '{print $1;print $NF;}') )

    # Get the time difference between the two dates
    ndays=$(( ($(date --date="${timespan[1]}" +%s) - $(date --date="${timespan[0]}" +%s))/86400 ))

    # If the difference is greater than one day, extract the first day
    if [[ $ndays -gt 1 ]]; then
        firstday=$(date --date="${timespan[0]}+0000" +%FT00:00:00)
        nextday=$(date --date="${firstday}+0000 + 1 day" +%FT%T)
        echo " "
        echo "${filepath} has ${ndays} days of records. Extracting the first day."
        ncks -O -d ${timedim},"${firstday}","${nextday}" "${filepath}" "tmp.nc"
        status=$?
        [[ $status -eq 0 ]] && mv "tmp.nc" ${filepath}
        echo " "
        return $status
    fi
}

upload_to_adsl2(){
    filepath="$1"
    blobpath="$2"

    # Upload to azure
    fileExists=$(az storage blob exists \
        --container-name ofs-archive \
        --name "${blobpath}" --query exists)
    if ! $fileExists; then
        echo "Sending file $filepath to ADSL2"
        az storage blob upload \
            --no-progress \
            --container-name ofs-archive \
            --file "${filepath}" \
            --name "${blobpath}"
    else
        echo "Blob $blobpath already exists"
    fi
}

# Get all d-storage directories for dates before 2 days ago
maxdate=$(date --date="${today} - 2 days" +%Y%m%d)
dates=( $(find "$stodir/" -mindepth 1 -type d -regex '.*/[0-9]+' -printf '%P\n' | awk "{if (\$1 < $maxdate) print \$1}") )

for date in "${dates[@]}"; do

    dateafter=$(date --date="$date + 1 day" +%Y%m%d)

    # Compressing log files
    echo "Compressing log files"
    gzip "${stodir}/${date}"/*.log ||:
    mv -f "${stodir}/${date}"/*.log.gz "${logdir}" ||:

    # Removing unnecessary files
    find "${stodir}/${date}/" -name 'simcosta*' | xargs -I{} bash -c 'rm -f {} && echo Removed file: {}'

    filenames=( \
        "gfs_brz0.50_${date}.nc" \
        "gfs_glo0.50_${date}.nc" \
        "cmems_sla_vels_atl0.25_${date}.nc" \
        "cmems_multiobs_atl0.25_${date}.nc" \
        "noaa_ww3_brz0.50_${date}.nc" \
        "ww3_rst_atl0.500_${dateafter}.000000" \
        "ww3_rst_sao0.125_${dateafter}.000000" \
        "ww3_rst_bca0.025_${dateafter}.000000" \
        "input_bry_brz0.05_01g_${date}_nemo.nc" \
        "input_clm_brz0.05_01g_${date}_nemo.nc" \
        "roms_zlevs_brz0.05_01g_${date}_nemo.nc" \
        "input_bry_brz0.05_01g_${date}_glby.nc" \
        "input_clm_brz0.05_01g_${date}_glby.nc" \
        "roms_zlevs_brz0.05_01g_${date}_glby.nc" \
    )
    for filename in ${filenames[@]}; do
        filepath="${stodir}/${date}/${filename}"
        [[ ! -f $filepath ]] && continue
        rm -f "${filepath}" && echo "Removed file: ${filepath}"
    done

    # Sending first day of important files to Azure

    # GFS forcing files
    filenames=( \
        "gfs_${date}.nc" \
    )
    for filename in ${filenames[@]}; do
        filepath="${stodir}/${date}/${filename}"
        [[ ! -f $filepath ]] && continue
        blobpath="archive/gfs/${date}/${filename}"
        extract_first_day "${filepath}"
        upload_to_adsl2 "${filepath}" "${blobpath}"
        rm -f "${filepath}" && echo "Removed file: ${filepath}"
    done

    # NEMO files used on IC and BC
    filenames=( \
        "nemo_brz0.08_${date}.nc" \
    )
    for filename in ${filenames[@]}; do
        filepath="${stodir}/${date}/${filename}"
        [[ ! -f $filepath ]] && continue
        blobpath="archive/nemo/${date}/${filename}"
        extract_first_day "${filepath}"
        upload_to_adsl2 "${filepath}" "${blobpath}"
        rm -f "${filepath}" && echo "Removed file: ${filepath}"
    done

    # HYCOM files used on IC and BC
    filenames=( \
        "glby_brz0.08_${date}.nc" \
    )
    for filename in ${filenames[@]}; do
        filepath="${stodir}/${date}/${filename}"
        [[ ! -f $filepath ]] && continue
        blobpath="archive/glby/${date}/${filename}"
        extract_first_day "${filepath}"
        upload_to_adsl2 "${filepath}" "${blobpath}"
        rm -f "${filepath}" && echo "Removed file: ${filepath}"
    done

    # WW3 models' results
    filenames=( \
        "ww3_his_atl0.500_${date}.nc" \
        "ww3_his_sao0.125_${date}.nc" \
        "ww3_his_bca0.025_${date}.nc" \
    )
    for filename in ${filenames[@]}; do
        filepath="${stodir}/${date}/${filename}"
        [[ ! -f $filepath ]] && continue
        blobpath="archive/ww3/${date}/${filename}"
        extract_first_day "${filepath}"
        upload_to_adsl2 "${filepath}" "${blobpath}"
        rm -f "${filepath}" && echo "Removed file: ${filepath}"
    done

    # ROMS models' results
    filenames=( \
        "roms_his_brz0.05_01g_${date}_nemo.nc" \
        "roms_avg_brz0.05_01g_${date}_nemo.nc" \
        "roms_rst_brz0.05_01g_${dateafter}_nemo.nc" \
        "roms_his_brz0.05_01g_${date}_glby.nc" \
        "roms_avg_brz0.05_01g_${date}_glby.nc" \
        "roms_rst_brz0.05_01g_${dateafter}_glby.nc" \
    )
    for filename in ${filenames[@]}; do
        filepath="${stodir}/${date}/${filename}"
        [[ ! -f $filepath ]] && continue
        blobpath="archive/roms/${date}/${filename}"
        extract_first_day "${filepath}" ocean_time
        upload_to_adsl2 "${filepath}" "${blobpath}"
        rm -f "${filepath}" && echo "Removed file: ${filepath}"
    done

    # Try to remove the directory
    rmdir ${stodir}/${date} ||:
done

#====================================================================================
echo ; echo " ==> FINISHED cleanup & closed forecast cycle <=="; echo
now=$(date "+%Y/%m/%d %T"); echo " ... finished cleanup at $now" >> $log
#====================================================================================

#### the end
