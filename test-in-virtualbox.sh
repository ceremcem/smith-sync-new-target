#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
set -eu -o pipefail
[[ $(whoami) = "root" ]] || exec sudo "$0" "$@"

cd $_sdir
source "config/config.sh"
actual_root_mntpoint=$(./get_root_mntpoint.sh)
if [[ $actual_root_mntpoint == $root_mnt ]]; then 
    echo "This disk seems to be the active one. Using targets/rootfs instead. Exiting."
    exit 1
fi


"$_sdir/detach.sh" || true
sudo -u $SUDO_USER VBoxManage startvm "$lvm_name-testing"

