#!/bin/sh

parted /dev/sda print | grep ^' '[1-9] | awk '{print $1}' > parteno
while read line
do
	parted /dev/sda rm $line
done < parteno

parted /dev/sda mkpart primary 0% 8G
parted /dev/sda set 1 boot on

parted /dev/sda print

mkfs.ext3 /dev/sda1

mount -t ext3 /dev/sda1 /mnt
df -h
fmnt=`df | grep mnt`

if [ -z "$fmnt" ]; then
	exit
fi

debootstrap squeeze /mnt http://ftp.jaist.ac.jp/debian/
cp -f /etc/shadow /mnt/etc
cp -f /etc/passwd /mnt/etc

mount --bind /dev /mnt/dev
mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys

cp /root/install-pkg.sh /mnt/root/
cp /etc/apt/sources.list /mnt/etc/apt/
chroot /mnt sh /root/install-pkg.sh
cp /root/interfaces /mnt/etc/network/
mkdir -p /mnt/root/.ssh
cp /root/.ssh/authorized_keys /mnt/root/.ssh/
#rm /mnt/etc/udev/rules.d/70-persistent-net.rules

addr=`ifconfig | grep 172.16 | awk '{print $2}' | awk -F: '{print $2}'`

if [ "`echo $addr | awk -F. '{print $3}'`" -eq "21" ];then
        hostname="i`echo $addr | awk -F. '{print $4}'`"
elif [ "`echo $addr | awk  -F. '{print $3}'`" -eq "22" ];then
        hostname="j`echo $addr | awk -F. '{print $4}'`"
elif [ "`echo $addr | awk -F. '{print $3}'`" -eq "23" ];then
        hostname="k`echo $addr | awk -F. '{print $4}'`"
elif [ "`echo $addr | awk -F. '{print $3}'`" -eq "24" ];then
        hostname="l`echo $addr | awk -F. '{print $4}'`"
elif [ "`echo $addr | awk -F. '{print $3}'`" -eq "26" ];then
        hostname="n`echo $addr | awk -F. '{print $4}'`"
fi

if [ "$hostname" != "" ]; then
	echo $hostname > /mnt/etc/hostname
fi

grub-install --force --root-directory=/mnt /dev/sda
chroot /mnt update-grub2

umount /mnt/sys
umount /mnt/proc
umount /mnt/dev
umount /mnt

date
echo "Finish"
