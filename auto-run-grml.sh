#!/bin/bash

#lsblk
mkdir -p /mnt/vda2
mount /dev/vda2 /mnt/vda2
echo -n > /mnt/vda2/etc/overlayroot.conf
#echo 'overlayroot_cfgdisk="disabled"' > /mnt/vda2/etc/overlayroot.conf
echo 'overlayroot="tmpfs"' > /mnt/vda2/etc/overlayroot.conf
sudo sed -i 's|^GRUB_DEFAULT=.*|GRUB_DEFAULT=0|' /mnt/vda2/etc/default/grub
mount --bind /dev /mnt/vda2/dev
mount --bind /proc /mnt/vda2/proc
mount --bind /sys /mnt/vda2/sys
chroot /mnt/vda2
update-grub
exit
reboot
