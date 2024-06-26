#!/bin/bash

#Check disk
FILE1="/dev/disk/by-label/_containers"
DISK1="/dev/disk/by-label/_containers /_containers auto nosuid,nodev,nofail,x-gvfs-show 0 0"
FILE2="/dev/disk/by-label/_data"
DISK2="/dev/disk/by-label/_data /_data auto nosuid,nodev,nofail,x-gvfs-show 0 0"

if [ ! -L "$FILE1" ]
then
    echo "Disk labeled as $FILE1 not found"
    read -p "Continue? " -n 1 -r
    if [[ $REPLY =~ ^[Nn]$ ]]
    then
        exit 1
    fi
else
    echo "Disk labeled as $FILE1 found"
fi
if [ ! -L "$FILE2" ]
then
    echo "Disk labeled as $FILE2 not found"
    read -p "Continue? " -n 1 -r
    if [[ $REPLY =~ ^[Nn]$ ]]
    then
        exit 1
    fi
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
    echo "Addind $FILE2 to fstab"
    printf "$DISK2\n" >> /etc/fstab
fi
mount -a

#Change PODMAN config, path to containers storage
sed -i 's/graphroot = "\/var\/lib\/containers\/storage"/graphroot = "\/_containers"/g' /etc/containers/storage.conf

#Add POSTGRES GROUP and USER same as in container
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

#Add FIREWALLD rule for POSTGRESQL
firewall-cmd --permanent --zone=public --add-service=postgresql
firewall-cmd --reload

#Start POSTGRESPRO container
HOSTNAME=`hostname`
podman run --name pgpro  --hostname $HOSTNAME -dt -p 5432:5432 -v /_data:/_data docker.io/kostikpl/ol9:pgsql_1c_14
podman generate systemd --new --name pgpro > /etc/systemd/system/pgpro.service
systemctl enable --now pgpro
PG_PASSWD = 'RheujvDhfub72'
podman exec -ti pgpro -c "ALTER USER postgres WITH PASSWORD $PG_PASSWD;"

#Clean
dnf clean all
