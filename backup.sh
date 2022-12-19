#!/bin/bash
set -o pipefail
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
tools="../../smith-sync"

[[ $(whoami) = "root" ]] || exec sudo "$0" "$@"

cd $_sdir
source "config/config.sh"
actual_root_mntpoint=$(./get_root_mntpoint.sh)
if [[ $actual_root_mntpoint == $root_mnt ]]; then 
    echo "This disk seems to be the active one. Using targets/rootfs instead. Exiting."
    exit 1
fi

echo "Calculating the btrbk configuration file"
./update-btrbk-conf.sh

conf="config/btrbk.conf"
logs_dir="$_sdir/logs"
mkdir -p $logs_dir
tf="$logs_dir/$(date +'%Y%m%dT%H%M').log"
echo "Starting backup process..."
$tools/btrbk -c $conf.calculated clean
$tools/btrbk -c $conf.calculated --progress -v ${1:-run} | tee $tf
[[ $? -eq 0 ]] || exit $?
grep '^!!!' -q $tf && exit 1

echo "Backup is successful"
exit 0
