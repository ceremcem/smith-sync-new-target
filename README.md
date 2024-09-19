# Change while creating a new target: 

1. cp -a ./config{-example,}
2. Modify config/config.sh till the `# ...format-btrfs-swap-lvm-luks.sh...` step.
3. Run ./auto.sh


## If this is an external hard disk

Start plug-and-backup service by:

`./poll.sh`

## If this is an internal hard disk

Start periodic backups by: 

`./poll-attached.sh`

# Testing the backup 

1. Create a VirtualBox machine that uses the target disk (run `./create-vmdk-from-config.sh`).
2. `./test-in-virtualbox.sh` 

# Reformat partitions and restart the backup

1. `../../smith-sync/multistrap-helpers/install-to-disk/format-btrfs-swap-lvm-luks.sh --use-existing-partitions ./config/config.sh`
2. Reassign `UUID=...` (see config file comments)
3. Reassign LUKS key (`assign-key-to-luks.sh`)
4. `./poll-attached.sh` # or `./auto` 