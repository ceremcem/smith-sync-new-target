#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
set -eu

# pass "--date 20201227T0009" if you want to restore from an old snapshot
cd $_sdir
./check-if-active-disk.sh || exit 1

sudo ../../smith-sync/assemble-bootable-system.sh \
    -c ./config/config.sh \
    --from snapshots/erik3/ \
    --boot-backup boot.backup \
    "$@"
