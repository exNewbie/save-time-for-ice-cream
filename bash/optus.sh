#!/bin/bash

MY_IP=$( curl -s ifconfig.io );
MOBILE_IP_PREFIX=49;
ARN=$1;
LOG_FILE="/var/log/optus.log";

echo `date` >> $LOG_FILE;

message="Current IP: ${MY_IP}";

if [[ $MY_IP == "${MOBILE_IP_PREFIX}.*" ]]; then
  message="On LTE. ${message}";
  aws sns publish --message "${message}" --topic-arn $ARN;
else
  message="On NBN. ${message}";
fi

echo $message >> $LOG_FILE;
echo '===================================================' >> $LOG_FILE;
echo $message;
