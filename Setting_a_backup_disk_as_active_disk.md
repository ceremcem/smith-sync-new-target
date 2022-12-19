# Moving to a backup disk as active disk 

* Assemble an older snapshot if required: 

    ./assemble-bootable.sh --refresh --full --date $1

* Create missing directories (/var/tmp) within the new rootfs/ directory 

    _tmp=$restore_folder/var/tmp
    echo "Re-create $_tmp"
    sudo rmdir $_tmp \
        && sudo btrfs sub create $_tmp \
        && sudo chmod 1777 $_tmp

* Transfer files that are explicitly excluded from synchronization (all `tmp` directories)
* Transfer any readonly snapshots (FIXME: This should already be done within the synchronization process)

    If you are creating a temporary rootfs, handle the missing snapshots manually: 

        /usr/bin/diff <( btrfs-ls --relative $current_rootfs_path ) <( btrfs-ls --relative $new_rootfs_path )

* Reboot with the new disk
1. ../rootfs/update-config.sh
2. Update `config/btrbk.conf` files accordingly (FIXME: this should be automatic)

* If you have restored an older snapshot and everything went okay, move the temporary folder as permanent:

        sudo rsync -aP --delete $restore_folder/boot.backup/ /boot/
        sudo mv $root_mnt/rootfs $root_mnt/rootfs-$(date +'%Y%m%dT%H%M')
        sudo mv $restore_folder $root_mnt/rootfs