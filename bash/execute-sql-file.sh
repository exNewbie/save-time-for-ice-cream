#!/bin/bash

## Usage: execute-sql-file.sh /etc/MYSQL_CLIENT_CONF sample_db queries.sql no-sql no-col-names
set -e

MYSQL_CONF=$1;
DATABASE=$2;
SQL_FILE=$3;
NO_SQL=$4;
NO_COL_NAMES=$5;

while IFS='' read -r line || [[ -n "$line" ]]; do
  if [ "$NO_SQL" != 'no-sql' ]; then
    echo $line;
  fi

  if [ "$NO_COL_NAMES" != 'no-col-names' ]; then
    NO_COL_NAMES="-N"
  else
    NO_COL_NAMES=""
  fi

  mysql --defaults-extra-file=${MYSQL_CONF} ${DATABASE} ${NO_COL_NAMES} -e "$line";
  echo "=================================================================================================================================================";
done < "${SQL_FILE}"
