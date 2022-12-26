_script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# Follow the multistrap-helpers/install-to-disk/README.md

# Phase 1/2
#---------------------------------------------------------------------
# Identify your disk (like UUID of a partition). Get this value from
# ./get-disk-info.sh /dev/sdX:
wwn="ata-WDC_WD10JPLX-00MBPT0_JR1000BN2EUYPE"

# Give a name to your LVM volumes. This is usually same as your
# installation name (eg. mysystem)
lvm_name="masa"

# Define swap_size and make sure that the RAM can fit into the swap area
swap_size="16G"

# Define boot_size (default: 1G)
boot_size="1100M"

# Phase 2/2
#---------------------------------------------------------------------
# Assign below variables *after* partitioning the disk
# (format-btrfs-swap-lvm-luks.sh... step)
# use ./get-disk-info.sh /dev/sdX again to identify the UUID's:
boot_part='UUID=835dcce0-12fb-4cee-9904-3d2f38b5533a'
crypt_part='UUID=357ef4cc-c6a2-4626-bbe9-52e1a99e3e84'

# OPTIONAL: Define your crypt_key path:
crypt_key="$(cat $_script_dir/keypath)"

# Mount options for attach script and boot configuration generation:
mount_opts="rw,noatime"

# Backup behavior
detach_after_backup=true
defer_cca_suspend=true
ignore_kill_signal=false
take_new_snapshot_before_backup=true

# you probably won't need to change those:
crypt_dev_name=${lvm_name}_crypt
root_lvm=${lvm_name}-root
swap_lvm=${lvm_name}-swap
subvol=${subvol:-rootfs}

root_dev=/dev/mapper/${root_lvm}
swap_dev=/dev/mapper/${swap_lvm}
root_mnt="/mnt/$root_lvm"
