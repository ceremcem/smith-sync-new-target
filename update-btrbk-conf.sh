#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
set -eu

btrbk_conf="config/btrbk.conf"

cd "$_sdir"
[[ -d config ]] || { echo "Create ./config directory first."; exit 1; }
[[ -f config/config.sh ]] || { echo "Create ./config/config.sh file first."; exit 1; }
[[ -f "${btrbk_conf}.template" ]] || { echo "Create ${btrbk_conf}.template file first."; exit 1; }

source "config/config.sh"

./check-if-active-disk.sh || exit 1

actual_root_mntpoint=$(./get_root_mntpoint.sh)
echo "Detected root mnt point: $actual_root_mntpoint"

# Clear old output
rm "$btrbk_conf" "$btrbk_conf.calculated" || true

cat "${btrbk_conf}.template" \
    | sed -e "s|{{actual_rootfs_mountpoint}}|$actual_root_mntpoint|" \
    | sed -e "s|{{root_mnt}}|$root_mnt|" \
    | sed -e "s|{{lvm_name}}|$lvm_name|" \
     > $btrbk_conf

echo "$btrbk_conf is generated."

btrbk_calculated="$btrbk_conf.calculated"
echo "Generating $btrbk_calculated"
../../smith-sync/btrbk-gen-config $btrbk_conf > $btrbk_calculated

echo "$btrbk_calculated is generated."
echo "Done."
