#!/bin/bash

#Disable selinux
sed -i 's/enforcing/disabled/g' /etc/selinux/config

#Disable IP6
#grub2-editenv - set "$(grub2-editenv - list | grep kernelopts) ipv6.disable=1"

#Setup system
dnf upgrade -y

dnfinstall -y krb5-workstation
dnfinstall -y pcp-system-tools
dnf install -y mc
#systemctl enable pmcd
#systemctl enable cockpit.socket

#Reboot
reboot
