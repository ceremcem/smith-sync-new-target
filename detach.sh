#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source

[[ $(whoami) = "root" ]] || { sudo $0 "$@"; exit 0; }

cd $_sdir
./check-if-active-disk.sh || exit 1

../../smith-sync/multistrap-helpers/install-to-disk/detach-disk.sh config/config.sh
