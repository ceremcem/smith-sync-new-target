#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
set -eu -o pipefail
[[ $(whoami) = "root" ]] || exec sudo "$0" "$@"

source $_sdir/config/config.sh

"$_sdir/detach.sh" || true
sudo -u $SUDO_USER VBoxManage startvm "$lvm_name-testing"

