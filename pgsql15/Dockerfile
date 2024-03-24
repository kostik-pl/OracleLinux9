FROM oraclelinux:8-slim

ENV LANG=ru_RU.UTF-8
# add locales
RUN dnf install -y glibc-langpack-ru
# update from repository
RUN dnf update -y

# Set POSTGRES PRO variables
ENV PGDATA=/_data/pg_data

# Explicitly set user/group IDs and data dir
RUN groupadd -r postgres --gid=9999 ; \
    useradd -r -g postgres --uid=9999 postgres ; \
    mkdir -p $PGDATA ; \
    chown -R postgres:postgres $PGDATA ; \
    chmod 700 $PGDATA

# Disable the built-in PostgreSQL module:
RUN dnf -qy module disable postgresql
# Install the repository RPM:
RUN dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
# Install PostgreSQL:
RUN dnf install -y postgresql15-server postgresql15-client postgresql15-contrib

# Change settings
RUN sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /opt/pgpro/std-14/share/postgresql.conf.sample ; \
    sed -ri "s!^#?(logging_collector)\s*=\s*\S+.*!\1 = on!" /opt/pgpro/std-14/share/postgresql.conf.sample ; \
    sed -ri "s!^#?(log_directory)\s*=\s*\S+.*!\1 = 'log'!" /opt/pgpro/std-14/share/postgresql.conf.sample ; \
    sed -ri "s!^#?(lc_messages)\s*=\s*\S+.*!\1 = 'C.UTF-8'!" /opt/pgpro/std-14/share/postgresql.conf.sample

RUN dnf clean all

# Setup for start
#ENV PATH $PATH:/usr/lib64/pgsql/bin
#COPY pgpro-entrypoint.sh /usr/local/bin
#RUN chmod +x /usr/local/bin/pgpro-entrypoint.sh

# change user
USER postgres

EXPOSE 5432

ENTRYPOINT ["pgpro-entrypoint.sh"]

CMD ["postgres"]