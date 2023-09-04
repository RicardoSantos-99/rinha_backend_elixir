#!/bin/sh

# DB_NAME="postgres"
# DB_USER="postgres"
# DB_HOST="db"

# if ! psql -h $DB_HOST -U $DB_USER -lqt | cut -d \| -f 1 | grep -qw $DB_NAME; then
#   echo "CREATE DATABASE"
#   # mix ecto.create
#   # mix ecto.migrate
# fi

exec mix run --no-halt

