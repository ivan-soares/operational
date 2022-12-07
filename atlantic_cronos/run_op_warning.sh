#!/usr/bin/env bash

today=`date +%Y%m%d`

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__root="$(cd "$(realpath "${__dir}/../../")" && pwd)"
operdir="${__root}/operational/atlantic/forecast"

export store_dir="${operdir}/d-storage/${today}"

# Check outputs
${operdir}/cronos_warning_system.sh $today



# END