#!/bin/bash

HOSTS=( appserver )
WEBBOOKS_DB_NAME=db_webbooks
PGUSER=postgres
export PGPASSWORD='password'

if [[ ${HOSTS[*]} =~ $HOSTNAME ]]; then

    # isntall PG12
    apt update && apt install -y vim bash-completion wget
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
    echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee  /etc/apt/sources.list.d/pgdg.list
    apt update && apt install -y postgresql-12 postgresql-client-12

    # configure PG12
    echo "set postgres password..."
    echo "ALTER USER $PGUSER WITH PASSWORD '$PGPASSWORD'\gexec" | sudo -u $PGUSER psql
    echo "creating database..."
    echo "SELECT 'CREATE DATABASE $WEBBOOKS_DB_NAME' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$WEBBOOKS_DB_NAME')\gexec" | sudo -u $PGUSER psql
    sudo -u $PGUSER psql $WEBBOOKS_DB_NAME < /vagrant/webbooks_data/data.sql

    # configure PG12
    sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/12/main/postgresql.conf
    echo "host    all             all             0.0.0.0/0               md5" >> /etc/postgresql/12/main/pg_hba.conf
    sudo systemctl restart postgresql.service

    # restore webbooks data
    psql -h 'localhost' -U $PGUSER $WEBBOOKS_DB_NAME < /vagrant/webbooks_data/data.sql
fi