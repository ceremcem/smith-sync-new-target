#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

$_sdir/../../smith-sync/multistrap-helpers/install-to-disk/create-vmdk.sh -c $_sdir/config/config.sh
if [[ $? -eq 0 ]]; then 
    echo "VMDK file is created:"
    ls -l $_sdir/config/*.vmdk
fi