#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
set -eu

cd $_sdir
./check-if-active-disk.sh || exit 1

./attach.sh

sudo ../../smith-sync/assemble-bootable-system.sh \
    -c ./config/config.sh \
    --boot-backup boot.backup \
    --install-grub \
    --dont-touch-rootfs
