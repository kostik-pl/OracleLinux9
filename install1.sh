#!/bin/bash

#Disable selinux
sed -i 's/enforcing/disabled/g' /etc/selinux/config

#Disable IP6 in GRUB
#grub2-editenv - set "$(grub2-editenv - list | grep kernelopts) ipv6.disable=1"

#Setup system
dnf upgrade -y

dnf install -y krb5-workstation
dnf install pcp pcp-system-tools pcp-gui
dnf install -y mc
systemctl enable --now pmcd pmlogger
systemctl enable cockpit.socket

#Reboot
reboot
