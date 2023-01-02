#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
set -u
[[ $(whoami) = "root" ]] || exec sudo "$0" "$@"
cd $_sdir

period=0
while sleep $period; do
    ./auto.sh
    period="1m"
done
