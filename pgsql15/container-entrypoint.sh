#!/usr/bin/env bash

set -e

if [ ! -s "$PGDATA/PG_VERSION" ]; then
    pg_ctl initdb -D $PGDATA -o "--locale=$LANG"
    psql -c "ALTER USER postgres WITH PASSWORD 'RheujvDhfub72';"
    printf "host all all all md5\n" >> $PGDATA/pg_hba.conf
fi

exec "$@"
