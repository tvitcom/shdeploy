#!/bin/sh

REGULAR_USER="a"

# virtual box additional
apt-get upgrade
apt-get -y install build-essential module-assistant dkms

is_vboxmounted() {
  blkid | grep VBOXADDITIONS #> /dev/null 2>&1
}

mountvbox() {
  mount -t iso9660 /dev/sr0 /media/cdrom0 #> /dev/null 2>&1
}

vboxaddition_installer_ready() {
  	ls /media/sdrom0 | grep VBoxLinuxAdditions.run #> /dev/null 2>&1
}

vboxaddition_installed() {
	cat /etc/group | grep vboxsf
}

if [ is_vboxmounted ] && [ mountvbox ] && [ vboxaddition_installer_ready ];then
	sh /media/cdrom0/VBox*.run
	echo "VBoxLinuxAdditions.run succesfully start: OK!"
fi
if [ vboxaddition_installed ];then
	adduser $REGULAR_USER vboxsf
	echo "Group vboxsf added for user: OK!"
fi