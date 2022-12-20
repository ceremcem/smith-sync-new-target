#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

set -eu
cd $_sdir
source "config/config.sh"
actual_root_mntpoint=$(./get_root_mntpoint.sh)
if [[ $actual_root_mntpoint == $root_mnt ]]; then 
    echo "This disk seems to be the active one. Use targets/rootfs instead. Exiting."
    exit 1
fi
exit 0

