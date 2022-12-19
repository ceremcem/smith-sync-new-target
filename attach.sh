#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source

[[ $(whoami) = "root" ]] || { sudo $0 "$@"; exit 0; }

cd $_sdir
source "config/config.sh"
actual_root_mntpoint=$(./get_root_mntpoint.sh)
if [[ $actual_root_mntpoint == $root_mnt ]]; then 
    echo "This disk seems to be the active one. Using targets/rootfs instead. Exiting."
    exit 1
fi

s=0
while sleep $s; do
    s=3
    ../../smith-sync/multistrap-helpers/install-to-disk/attach-disk.sh config/config.sh && break
done
