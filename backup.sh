#!/bin/bash
set -o pipefail
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
tools="../../smith-sync"

[[ $(whoami) = "root" ]] || exec sudo "$0" "$@"

cd $_sdir
./check-if-active-disk.sh || exit 1

echo "Calculating the btrbk configuration file"
./update-btrbk-conf.sh || exit 2

conf="config/btrbk.conf"
logs_dir="$_sdir/logs"
mkdir -p $logs_dir
tf="$logs_dir/$(date +'%Y%m%dT%H%M').log"
echo "Starting backup process..."
$tools/btrbk -c $conf.calculated clean
$tools/btrbk -c $conf.calculated dryrun | grep '[*][*][*] /' | while read -r out; do
    notify-send -u critical "NON-INCREMENTAL BACKUP WARNING ($(basename $_sdir))" "$out"
done
$tools/btrbk -c $conf.calculated --progress -v ${1:-run} | tee $tf
[[ $? -eq 0 ]] || exit $?
grep '^!!!' -q $tf && exit 1

# Check again if there is non-incremental backup warning (there shouldn't be)
$tools/btrbk -c $conf.calculated dryrun | grep '[*][*][*] /' | while read -r out; do
    notify-send -u critical "Something wrong in ($(basename $_sdir))" "There can not be a NON-INCREMENTAL BACKUP after a successful backup."
    exit 1
done


echo "Backup is successful"
exit 0
