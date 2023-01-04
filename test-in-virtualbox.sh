#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
set -eu -o pipefail
[[ $(whoami) = "root" ]] || exec sudo "$0" "$@"

cd $_sdir
./check-if-active-disk.sh || exit 1
source ./config/config.sh

./detach.sh || true
sudo -u $SUDO_USER VBoxManage startvm "$test_vm_name"

