FROM oraclelinux:8-slim

# Update from repository
RUN dnf update -y

# Add locales
RUN dnf install -y glibc-langpack-ru
# Set locales
ENV LANG=ru_RU.UTF-8

# Set POSTGRES variables
ENV PGDATA=/_data/pg_data

# Explicitly set user/group IDs and data dir
RUN groupadd -r postgres --gid=9999 ; \
    useradd -r -g postgres --uid=9999 postgres ; \
    mkdir -p $PGDATA ; \
    chown -R postgres:postgres $PGDATA ; \
    chmod 700 $PGDATA

# Disable the built-in PostgreSQL module
RUN dnf -qy module disable postgresql
# Install the repository RPM
RUN dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
# Install PostgreSQL 15
RUN dnf install -y postgresql15-server postgresql15-contrib

# Change settings
RUN sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /usr/pgsql-15/share/postgresql.conf.sample ; \
    sed -ri "s!^#?(logging_collector)\s*=\s*\S+.*!\1 = on!" /usr/pgsql-15/share/postgresql.conf.sample ; \
    sed -ri "s!^#?(log_directory)\s*=\s*\S+.*!\1 = 'log'!" /usr/pgsql-15/share/postgresql.conf.sample ; \
    sed -ri "s!^#?(lc_messages)\s*=\s*\S+.*!\1 = 'C.UTF-8'!" /usr/pgsql-15/share/postgresql.conf.sample

RUN dnf clean all

# Setup for start
ENV PATH $PATH:/usr/pgsql-15/bin
COPY pgpro-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/pgpro-entrypoint.sh

# change user
USER postgres

EXPOSE 5432

ENTRYPOINT ["pgpro-entrypoint.sh"]

CMD ["postgres"]
