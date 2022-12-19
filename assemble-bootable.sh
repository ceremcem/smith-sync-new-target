#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
set -eu

# pass "--date 20201227T0009" if you want to restore from an old snapshot
cd $_sdir
source "config/config.sh"
actual_root_mntpoint=$(./get_root_mntpoint.sh)
if [[ $actual_root_mntpoint == $root_mnt ]]; then 
    echo "This disk seems to be the active one. Using targets/rootfs instead. Exiting."
    exit 1
fi

sudo ../../smith-sync/assemble-bootable-system.sh \
    -c ./config/config.sh \
    --from snapshots/erik3/ \
    --boot-backup boot.backup \
    "$@"
