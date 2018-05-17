#!/bin/bash
set -eu +o pipefail

LOG_FILE="/tmp/mysql-kill-idle-connections.log";
TIMEOUT=1000;
MYSQL_CLIENT=/etc/MYSQL_STAGE

main() {
  echo -e "\n-------------------------------------MySQL Session Proc Kill START-------------------------------------" &>> $LOG_FILE;
  echo -e "\nSearching for long Admin sessions\n" &>> $LOG_FILE;

  date &>> $LOG_FILE;
  mysql --defaults-file=${MYSQL_CLIENT} -e 'show full processlist' | grep -v 'show full processlist' &>> $LOG_FILE;

  mysql --defaults-file=${MYSQL_CLIENT} -e "SELECT ID, USER, COMMAND, TIME FROM information_schema.processlist WHERE COMMAND = 'Sleep' AND TIME > ${TIMEOUT};" &>> $LOG_FILE;

  res=$(mysql --defaults-file=${MYSQL_CLIENT} -Nsr -e "SELECT GROUP_CONCAT(ID) FROM information_schema.processlist WHERE COMMAND = 'Sleep' AND TIME > ${TIMEOUT};")

  if [[ ! -z "${res}" && "${res}" != "NULL" ]]; then 
    for proc_id in $(echo "${res}" | sed 's/,/i /g'); do
      echo "Going to kill: ${proc_id}" &>> $LOG_FILE;
      mysql --defaults-file=${MYSQL_CLIENT} -Nsr -e "CALL mysql.rds_kill('${proc_id}');" &>> $LOG_FILE;
    done

    echo -e "\nAll lingering sessions killed!\n" &>> $LOG_FILE;
  else
    echo "No lingering sessions. Doing nothing." &>> $LOG_FILE;
  fi

  echo -e "-------------------------------------MySQL Session Proc Kill END-------------------------------------\n" &>> $LOG_FILE;
}

main "$@"