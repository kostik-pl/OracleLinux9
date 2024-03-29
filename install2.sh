#!/bin/bash

#Check disk
FILE1="/dev/disk/by-label/_containers"
DISK1="/dev/disk/by-label/_containers /_containers auto nosuid,nodev,nofail,x-gvfs-show 0 0"
FILE2="/dev/disk/by-label/_data"
DISK2="/dev/disk/by-label/_data /_data auto nosuid,nodev,nofail,x-gvfs-show 0 0"

if [ ! -L "$FILE1" ]
then
    echo "Disk labeled as $FILE1 not found"
    exit 1
else
    echo "Disk labeled as $FILE1 found"
fi
if [ ! -L "$FILE2" ]
then
    echo "Disk labeled as $FILE2 not found"
    exit 1
else
    echo "Disk labeled as $FILE2 found"
fi

#Setup disk
if ! grep -q '/_containers' /etc/fstab
then
    echo "Addind $FILE1 to fstab"
    printf "$DISK1\n" >> /etc/fstab
fi
if ! grep -q '/_data' /etc/fstab
then
    echo "Addind $FILE1 to fstab"
    printf "$DISK2\n" >> /etc/fstab
fi

#Setup PODMAN
#dnf -y module install container-tools
#dnf -y install podman-docker
sed -i 's/graphroot = "\/var\/lib\/containers\/storage"/graphroot = "\/_containers"/g' /etc/containers/storage.conf

#Add GROUP and USER same as in container
groupadd -r postgres --gid=99
useradd -r -M -g postgres --uid=99 postgres
#groupadd -r grp1cv8 --gid=98
#useradd -r -m -g grp1cv8 --uid=98 usr1cv8

#Change access rights
#if [ ! -d "/_data/httpd" ] ; then
#    mkdir /_data/httpd
#fi
#if [ ! -d "/_data/httpd" ] ; then
#    mkdir /_data/httpd
#fi
#if [ ! -f "/_data/httpd/conf/extra/httpd-1C-pub.conf" ] ; then
#    mkdir /_data/httpd/conf
#    mkdir /_data/httpd/conf/extra
#    curl -LJO https://raw.githubusercontent.com/kostik-pl/rhel8-public/main/HTTPD/httpd-1C-pub.conf
#    cp httpd-1C-pub.conf /_data/httpd/conf/extra
#fi
#if [ ! -f "/_data/httpd/pub_1c/default.vrd" ] ; then
#    mkdir /_data/httpd/pub_1c
#    curl -LJO https://raw.githubusercontent.com/kostik-pl/rhel8-public/main/HTTPD/default.vrd
#    cp default.vrd /_data/httpd/pub_1c
#fi
if [ ! -d "/_data/pg_backup" ] ; then
    mkdir /_data/pg_backup
fi
if [ ! -d "/_data/pg_data" ] ; then
    mkdir /_data/pg_data
fi
#if [ ! -d "/_data/srv1c_inf_log" ] ; then
#    mkdir /_data/srv1c_inf_log
#fi
chown -R root:root /_data
chmod -R 777 /_data
chown -R root:root /_containers
chmod -R 700 /_containers
#chown -R root:root /_data/httpd
#chmod -R 700 /_data/httpd
chown -R postgres:postgres /_data/pg_backup
chmod -R 777 /_data/pg_backup
chown -R postgres:postgres /_data/pg_data
chmod -R 700 /_data/pg_data
#chown -R usr1cv8:grp1cv8 /_data/srv1c_inf_log
#chmod -R 700 /_data/srv1c_inf_log

#Clean old 1c work directory
#shopt -s extglob
#rm -rf /_data/srv1c_inf_log/reg_1541/!(*.lst)
#shopt -u extglob

#Change firewall rules
curl -LJO https://raw.githubusercontent.com/kostik-pl/OracleLinux9/main/firewalld_public.xml
cp firewalld_public.xml /etc/firewalld/zones/public.xml
firewall-cmd --reload

HOSTNAME=`hostname`

sleep 1m

#Start PGSQL15 container and restore database
podman run --name pgsql15 --ip 10.88.0.2 --hostname $HOSTNAME -dt -p 5432:5432 -v /_data:/_data docker.io/kostikpl/ol9:pgsql15
podman generate systemd --new --name pgsql15 > /etc/systemd/system/pgsql15.service
systemctl enable --now pgsql15
sleep 1m
podman exec -ti pgsql15 psql -c "ALTER USER postgres WITH PASSWORD 'RheujvDhfub72';"

# install httpd
#dnf -y install httpd
#systemctl enable --now httpd

#Install HASP
#curl -LJO https://raw.githubusercontent.com/kostik-pl/rhel8-public/main/hasp.sh
#bash hasp.sh

#Start SRV1C container
#podman run --name srv1c --ip 10.88.0.3 --hostname $HOSTNAME --add-host=pgpro.local:10.88.0.2 -dt -p 80:80 -p 1540-1541:1540-1541 -p 1545:1545 -p 1560-1591:1560-1591 -v /_data:/_data -v /dev/bus/usb:/dev/bus/usb docker.io/kostikpl/rhel8:srv1c-8.3.1_rhel-ubi-init-8.4
#podman generate systemd --new --name srv1c > /etc/systemd/system/srv1c.service
#systemctl enable --now srv1c

#Install 1C Enterprise server on host
#curl -LJO https://raw.githubusercontent.com/kostik-pl/rhel8-public/main/1c.sh
#bash 1c.sh
#printf "\nInclude /_data/httpd/conf/extra/httpd-1C-pub.conf\n" >> /etc/httpd/conf/httpd.conf
#systemctl restat httpd

#Clean
dnf clean all
