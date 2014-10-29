#!/bin/sh

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install --force-yes -y linux-image-2.6.32-5-amd64
apt-get install --force-yes -y grub2
apt-get install --force-yes -y openssh-server
apt-get install --force-yes -y firmware-bnx2
apt-get install --force-yes -y quagga

