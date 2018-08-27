#!/usr/bin/env bash
set -e
yum -y install perl
yum -y upgrade
sed -i -e 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
sed -i -e 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

#if redhat then unconfig subscription
if [[ -e "/sbin/subscription-manager" ]]; then
	subscription-manager unregister
	subscription-manager remove --all
	subscription-manager clean
fi

#generalize
echo "" > /etc/machine-id
rm -f /root/*.cfg
rm -f /root/*.log
rm -rf /etc/ssh/ssh_host_*