#!/bin/bash
#Bitscout project
#Copyright Kaspersky Lab

. ./scripts/functions

statusprint "Setting up locale filter (localepurge).." &&
if [ -f "./build.$GLOBAL_BASEARCH/chroot/etc/locale.gen" ]
then 
  sudo sed -i 's,^# '$LANG' UTF-8$,'$LANG' UTF-8,' ./build.$GLOBAL_BASEARCH/chroot/etc/locale.gen
else
  echo "$LANG UTF-8" | sudo tee ./build.$GLOBAL_BASEARCH/chroot/etc/locale.gen >/dev/null
fi &&
statusprint "Generating locale.." &&
chroot_exec build.$GLOBAL_BASEARCH/chroot 'locale-gen "'$LANG'"' || exit 1 &&

statusprint "Updating system and installing essential packages.." &&

COMMON_PACKAGES="binutils netcat socat casper lupin-casper discover laptop-detect os-prober lxd lxd-client bindfs dialog tmux gawk grub-pc ntpdate ifupdown wicd-curses curl"

if [ $GLOBAL_RELEASESIZE -eq 1 ]
then
  chroot_exec build.$GLOBAL_BASEARCH/chroot "export DEBIAN_FRONTEND=noninteractive &&
apt-fast -y -o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\" install $COMMON_PACKAGES  && exit 0 || exit 1" || exit 1
else
  chroot_exec build.$GLOBAL_BASEARCH/chroot "export DEBIAN_FRONTEND=noninteractive
apt-fast -y -o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\" install $COMMON_PACKAGES file hdparm iptables lshw usbutils parted lsof psmisc strace ltrace time systemd-sysv man-db dosfstools cron busybox-static rsync dmidecode bash-completion command-not-found ntfs-3g uuid-runtime vim nano less pv ifupdown nbd-server grub-pc qemu-kvm fuse libfuse2 python-fusepy samba && exit 0 || exit 1" || exit 1
fi &&
statusprint "Finished installing packages." &&

statusprint "Upgrading kbd package." && #kbd is updated separately, because of related GDM issue/bug.
chroot_exec build.$GLOBAL_BASEARCH/chroot 'export DEBIAN_FRONTEND=noninteractive &&
apt-mark unhold kbd &&
cp /bin/kbd_mode.dist /bin/kbd_mode &&
apt-get -y -o DPkg::options::="--force-confdef" -o DPkg::options::="--force-confold" upgrade' || exit 1 &&


exit 0;
