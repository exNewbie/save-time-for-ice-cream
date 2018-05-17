#!/bin/bash

print_usage() {
  echo "[USAGE] $0 -c [Credential File] -d [Database Credential File] -a [Action]";
  echo "[Example: ] $0 -c db-credentials -d /etc/MYSQL_STAGE -a revoke";
  echo "Action value is eiher: revoke or grant";
  exit 1;
}

if [ $# -eq 0 ]; then echo "No arguments supplied"; print_usage; fi

# Getting the right options
while getopts ":c:a:d:h" option
do
   case $option in
        c) CONF_FILE=${OPTARG};;
        a) ACTION=${OPTARG};;
        d) DB_FILE=${OPTARG};;
        h) print_usage ;;
        \?) echo "Invalid option: -$OPTARG"
            print_usage ;;
        :) echo "Option -$OPTARG requires an argument"
           print_usage ;;
   esac
done

## -- Main --
if ! test -f $CONF_FILE; then
  echo "Credential file not found";
  exit 1;
fi

if ! test -f $DB_FILE; then
  echo "Database Credential file not found";
  exit 1;
fi

array_actions=( revoke grant );
if [ "$ACTION" == '' ]; then
  echo "Action not found";
  exit 1;
elif [[ ! "${array_actions[@]}" =~ "${ACTION}" ]]; then
  echo "Action not found";
  exit 1;
fi

while IFS=':' read -ra credential; do 
  if [ "$ACTION" == 'revoke' ]; then
    query="REVOKE INSERT, UPDATE, DELETE ON ${credential[2]}.* FROM '${credential[0]}'@'${credential[1]}';";
  elif [ "$ACTION" == 'grant' ]; then
    query="GRANT INSERT, UPDATE, DELETE ON ${credential[2]}.* TO '${credential[0]}'@'${credential[1]}';";
  fi
  echo $query;
  mysql --defaults-file=${DB_FILE} -e "${query}";
done <<< $(cat $CONF_FILE);

echo "FLUSH PRIVILEGES...";
mysql --defaults-file=${DB_FILE} -e "FLUSH PRIVILEGES;";