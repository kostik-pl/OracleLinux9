#!/bin/bash

#Disable selinux
sed -i 's/enforcing/disabled/g' /etc/selinux/config

#Disable IP6 in GRUB or SYSTEM_CONFIG
#grub2-editenv - set "$(grub2-editenv - list | grep kernelopts) ipv6.disable=1"
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
sysctl -w net.ipv6.conf.lo.disable_ipv6=1
firewall-cmd --permanent --zone=public --remove-service=dhcpv6-client

#Setup system
dnf upgrade -y

dnf install pcp pcp-system-tools pcp-gui
systemctl enable --now pmcd pmlogger
systemctl enable cockpit.socket

dnf install -y krb5-workstation
dnf install -y mc

#Reboot
reboot
