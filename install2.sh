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
sed -i 's/graphroot = "\/var\/lib\/containers\/storage"/graphroot = "\/_containers"/g' /etc/containers/storage.conf

#Add GROUP and USER same as in container
groupadd -r postgres --gid=99
useradd -r -M -g postgres --uid=99 postgres

#Change access rights
if [ ! -d "/_data/pg_backup" ] ; then
    mkdir /_data/pg_backup
fi
if [ ! -d "/_data/pg_data" ] ; then
    mkdir /_data/pg_data
fi
chown -R root:root /_data
chmod -R 777 /_data
chown -R root:root /_containers
chmod -R 700 /_containers
chown -R postgres:postgres /_data/pg_backup
chmod -R 777 /_data/pg_backup
chown -R postgres:postgres /_data/pg_data
chmod -R 700 /_data/pg_data

#Start POSTGRESQL container and restore database
#firewall-cmd --permanent --new-service=pgsql
#firewall-cmd --permanent --service=pgsql --set-description=Allow services for POSTGRESQL server
#firewall-cmd --permanent --service=pgsql --set-short=pgsql
#firewall-cmd --permanent --service=pgsql --add-port=5432/tcp
curl -LJO https://raw.githubusercontent.com/kostik-pl/OracleLinux9/pgsql.xml -o /etc/firewalld/services/
sleep 10 #waiting for changes to be applied 
firewall-cmd --permanent --zone=public --add-service=pgsql

HOSTNAME=`hostname`
podman run --name pgsql15 --ip 10.88.0.2 --hostname $HOSTNAME -dt -p 5432:5432 -v /_data:/_data docker.io/kostikpl/ol9:pgsql15
podman generate systemd --new --name pgsql15 > /etc/systemd/system/pgsql15.service
systemctl enable --now pgsql15
sleep 1m
podman exec -ti pgsql15 psql -c "ALTER USER postgres WITH PASSWORD 'RheujvDhfub72';"

#Clean
dnf clean all
#Reload FIREWALLD config
firewall-cmd --reload
