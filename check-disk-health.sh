#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ $(whoami) = "root" ]] || exec sudo "$0" "$@"
set -eu

source $_sdir/config/config.sh

disk="/dev/disk/by-id/$wwn"

set -x
smartctl -a $disk | less
