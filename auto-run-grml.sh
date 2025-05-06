#!/bin/bash

#lsblk
mkdir -p /mnt/vda2
mount /dev/vda2 /mnt/vda2
echo -n > /mnt/vda2/etc/overlayroot.conf
#echo 'overlayroot_cfgdisk="disabled"' > /mnt/vda2/etc/overlayroot.conf
echo 'overlayroot="tmpfs"' > /mnt/vda2/etc/overlayroot.conf
grub-reboot 'Ubuntu'
#reboot
