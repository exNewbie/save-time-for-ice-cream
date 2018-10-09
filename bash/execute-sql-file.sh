#!/bin/bash

## Usage: execute-sql-file.sh /etc/MYSQL_CLIENT_CONF sample_db queries.sql
set -e

MYSQL_CONF=$1;
DATABASE=$2;
SQL_FILE=$3;

while IFS='' read -r line || [[ -n "$line" ]]; do
  echo $line;
  mysql --defaults-extra-file=${MYSQL_CONF} ${DATABASE} -e "$line";
  echo "=================================================================================================================================================";
done < "${SQL_FILE}"
