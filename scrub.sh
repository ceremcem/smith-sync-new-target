#!/bin/bash
_sdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
set -eu
[[ $(whoami) = "root" ]] || exec sudo "$0" "$@"

. $_sdir/config/config.sh

SCRUB=../../scrub/scrub-mounted.sh

show_help(){
    cat <<HELP

    Starts scrubbing $root_dev

    $(basename $0)

HELP
}


# Parse command line arguments
# ---------------------------
# Initialize parameters
# ---------------------------
args_backup=("$@")
args=()
_count=1
while [ $# -gt 0 ]; do
    key="${1:-}"
    case $key in
        -h|-\?|--help|'')
            show_help    # Display a usage synopsis.
            exit
            ;;
        # --------------------------------------------------------
        # --------------------------------------------------------
        -*) # Handle unrecognized options
            help_die "Unknown option: $1"
            ;;
        *)  # Generate the new positional arguments: $arg1, $arg2, ... and ${args[@]}
            if [[ ! -z ${1:-} ]]; then
                declare arg$((_count++))="$1"
                args+=("$1")
            fi
            ;;
    esac
    [[ -z ${1:-} ]] && break || shift
done; set -- "${args_backup[@]}"
# Use $arg1 in place of $1, $arg2 in place of $2 and so on, 
# "$@" is in the original state,
# use ${args[@]} for new positional arguments  

cleanup(){
    btrfs scrub cancel $root_dev
    echo "Cancelled scrub on $root_dev"
    exit 0
}

trap cleanup SIGINT

$SCRUB --mark $root_dev
$SCRUB 2&>1 > /dev/null &
watch btrfs scrub status -d $root_dev
wait
