#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ $(whoami) = "root" ]] || exec sudo "$0" "$@"
set -eu

source $_sdir/config/config.sh
cd $_sdir
./check-if-active-disk.sh || exit 1

hd="$lvm_name"

do_detach(){
    ./detach.sh
    notify-send -u critical "$hd is unmounted."
}

suspend_lock_file=/tmp/cca-suspend.defer.$hd
disable_cca_suspend(){
    if $defer_cca_suspend; then
        msg="* INFO: Disabled cca-suspend."
        echo "$msg"; notify-send -u critical "$msg"
        touch $suspend_lock_file
    fi
}

enable_cca_suspend(){
    if $defer_cca_suspend; then
        msg="* INFO: Enabled cca-suspend."
        echo "$msg"; notify-send -u critical "$msg"
        [[ -f $suspend_lock_file ]] && rm $suspend_lock_file
    fi
}

tflag="/tmp/take-snapshot.last-run.txt" # timestamp file
_flag="/tmp/$hd-auto.last-run.txt"

[[ "${1:-}" == "--force" ]] && echo "-1" > $_flag
[[ -f $tflag ]] || echo 0 > $tflag
[[ -f $_flag ]] || echo 0 > $_flag
if [[ "$(cat $_flag)" -lt "$(cat $tflag)" ]]; then
    echo "${hd}'s last run is stale, backing up."
else
    echo "Not running ${hd} backup as it should be already backed up."
    exit 0
fi

[[ "${1:-}" == "--prevent-suspend" ]] && defer_cca_suspend=true


# Print generated config
./update-btrbk-conf.sh
while read key value; do
    case $key in
        snapshot_dir|volume|subvolume|target)
            declare $key=$value
            ;;
    esac
done < $_sdir/config/btrbk.conf

source_snapshots="$volume/$snapshot_dir"
target_snapshots="$target"

echo "source: $source_snapshots"
echo "target: $target_snapshots"

disable_cca_suspend

t0=$EPOCHSECONDS

if $take_new_snapshot_before_backup; then 
    notify-send "Taking a new rootfs snapshot"
    ../rootfs/take-snapshot.sh
fi


on_kill(){
    s=2
    echo "In order to kill, press Ctrl+C within $s seconds. $@"
    sleep $s
}

# ignore those signals:
if $ignore_kill_signal; then 
    trap -- on_kill SIGTERM SIGHUP SIGINT
fi
trap 'enable_cca_suspend' EXIT

#if sudo -u $SUDO_USER vboxmanage showvminfo "$hd-testing"  | grep -q "running (since"; then
#    echo "Not backing up $hd" "$hd-testing is running."
#    exit 1
#fi
notify-send "Backing up to $hd."
t0=$EPOCHSECONDS
./attach.sh

mkdir -p "$target_snapshots"

notify-send "Transferring data to $hd."
if ! time ./backup.sh; then
    notify-send -u critical "ERROR: $hd backup" "Something went wrong. Check console."
    do_detach
    exit 1
fi

# Backup is successful, keep the latest snapshot
echo "Backup is successful."
../../smith-sync/mark-not-delete-latest.sh $hd ../rootfs/exclude $target_snapshots

echo "Assembling the bootable subvolume on target:"
if ! ./assemble-bootable.sh --refresh --full; then
    echo
    echo "-------------------------------------------------------"
    echo "Something went wrong while assembling the bootable copy."
    echo "$hd is left attached. Please manually handle the problem."
    echo "-------------------------------------------------------"
    echo
    notify-send -u critical "ERROR: $hd backup" "Something went wrong. Check console."
    exit 2
fi

echo $EPOCHSECONDS > $_flag

t1=$EPOCHSECONDS
duration=`date -d@$(($t1 - $t0)) -u +%H:%M:%S`
echo "$hd data transfer completed." "Duration: ${duration}."

$detach_after_backup && do_detach # visual notification is displayed within the function
