#!/bin/bash
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source

[[ $(whoami) = "root" ]] || exec sudo "$0" "$@"

cd $_sdir
./check-if-active-disk.sh || exit 1

s=0
while sleep $s; do
    s=3
    ../../smith-sync/multistrap-helpers/install-to-disk/attach-disk.sh config/config.sh && break
done
