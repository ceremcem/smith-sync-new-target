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
if sudo -u $SUDO_USER VBoxManage list runningvms | grep -q "$test_vm_name"; then
    echo "This disk seems to be booted in VirtualBox VM."
    echo "We can't proceed in order to prevent disk corruption."
    sudo -u $SUDO_USER VBoxManage showvminfo "$test_vm_name" | grep -i state
    exit 2
fi
exit 0

