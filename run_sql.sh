#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: ./run_sql.sh sql/file.sql"
    exit 1
fi

docker exec -i ecommerce-postgres psql \
    -U analyst \
    -d ecommerce_analytics \
    < "$1"
