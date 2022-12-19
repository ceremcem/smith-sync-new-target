# Change while creating a new target: 

1. Create config/config.sh
2. Create config/btrbk.conf
3. Modify config/config.sh till the `format-btrfs-swap-lvm-luks.sh` step.
4. Disable "incremental strict" directive for the first time
5. Run ./auto.sh


# If this is an external hard disk

Start plug-and-backup service by:

`./poll.sh`


# Testing the backup 

1. Create a VirtualBox machine that uses the target disk (run `./create-vmdk-from-config.sh`).
2. `./test-in-virtualbox.sh` 
