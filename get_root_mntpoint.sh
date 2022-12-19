#!/bin/bash

# returns the mountpoint where the root subvolume mounted which holds the actual rootfs.
mount | grep $(cat /etc/fstab | awk '$2 == "/" {print $1}') | grep "\bsubvolid=5\b" | awk '{print $3}'