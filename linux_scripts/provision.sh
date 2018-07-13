#!/usr/bin/env bash

#set consistent int names
mount /dev/fd0 /media/
cp /media/rhel_grub /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

yum -y upgrade

#if redhat then unconfig subscription
if [[ $(which subscription-manager) == *"/sbin/subscription-manager"* ]]; then
	subscription-manager unregister
	subscription-manager remove --all
	subscription-manager clean
fi

rm /etc/sysconfig/network-scripts/ifcfg-ens192 
cp /media/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0

#generalize
echo "" > /etc/machine-id
rm -f /root/*.cfg
rm -f /root/*.log
rm -rf /etc/ssh/ssh_host_*