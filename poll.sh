#!/bin/bash

# Usage:
#
#   $ sudo -s
#   # source $(basename $0)
#

_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ $(whoami) = "root" ]] || { sudo $0 "$@"; exit 0; }
cd $_sdir
hd="$lvm_name"
source ./config/config.sh
dev="/dev/disk/by-id/$wwn"

trap './detach.sh' EXIT

while :; do
    t0=
    t1=
    echo "Waiting for $hd to attach..."
    while sleep 1; do test -b "$dev" && break; done;

    _timeout=10
    ans=$(zenity --timeout $_timeout --question --text \
        "Backup to $hd? \n(timeout: ${_timeout}s)" \
        --ok-label="Do nothing" --extra-button "Scrub" --cancel-label="Backup*" --extra-button "Test (VM)" --width 200;)
    rc=$?
    if [[ "$ans" == "Scrub" ]]; then
        ./scrub.sh --dialog
        ./detach.sh
    elif [[ "$ans" == "Test (VM)" ]]; then
    	sudo -u $SUDO_USER ./test-in-virtualbox.sh
    elif [[ $rc -eq 0 ]]; then
        notify-send "Doing nothing."
        echo "Doing nothing due to user selection."
    else
        t0=$EPOCHSECONDS
        message="Started plug-n-backup for $hd"
        [[ $rc -eq 5 ]] && notify-send -u critical "$message" "`date`"
        echo "`date`: $message"
        ./auto.sh
        echo "---------------------------------"
        t1=$EPOCHSECONDS
        duration=`date -d@$(($t1 - $t0)) -u +%H:%M:%S`

        echo "Backup of $hd has been completed in $duration."
        notify-send -u critical "Backup of $hd has been completed" \
            "Duration: $duration"
    fi

    # Wait for disk to detach
    while sleep 1; do test -b "$dev" || break; done;
    echo "---------------------------------"
done
