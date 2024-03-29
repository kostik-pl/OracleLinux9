FROM oraclelinux:9

# Update from repository
RUN dnf update -y

ENV PGADMIN_DEFAULT_EMAIL=k.druchevsky@kernel.ua
ENV PGADMIN_DEFAULT_PASSWORD=Kbye[jbl12

#Install PGADMIN4
dnf install -y https://ftp.postgresql.org/pub/pgadmin/pgadmin4/yum/pgadmin4-redhat-repo-2-1.noarch.rpm
dnf install -y pgadmin4-web

RUN dnf clean all
