#!/bin/bash

LOG_FILE="${0}.log";
AWS_CMD="/usr/bin/aws";
JQ_CMD="/usr/bin/jq";
MAX_ITEMS=10000;

print_usage() {
   echo "[USAGE] $0 -d [Source DB Identifier]";
   echo "[Example: ] $0 -d LogEntries_plantminernzlive";
   exit 1;
}

write_log() {
        now=$( /bin/date +"%Y-%m-%d %H:%M:%S");
        echo "${now} INFO $1" >> $LOG_FILE;
}

export_data() {
	token=$1;
	if [ -z $token ]; then
		$AWS_CMD dynamodb scan --table-name $SOURCE_DB --max-items $MAX_ITEMS > tmp_data;
	else
		$AWS_CMD dynamodb scan --table-name $SOURCE_DB --max-items $MAX_ITEMS --starting-token $token > tmp_data;
	fi

	# write data to file
	cat tmp_data | jq -r -c .Items[] >> $EXPORT_FILE;

	# carry on if next_token exists
	next_token=$( cat tmp_data | jq -r .NextToken );

	if [ $next_token == "null" ]; then
		rm tmp_data;
		return 0;
	else
		sleep 60;
		export_data $next_token;
	fi
}

if [ $# -eq 0 ]; then echo "No arguments supplied"; print_usage; fi

# Getting the right options
while getopts ":d:h" option
do
   case $option in
        d) SOURCE_DB=${OPTARG};;
        h) print_usage ;;
        \?) echo "Invalid option: -$OPTARG"
            print_usage ;;
        :) echo "Option -$OPTARG requires an argument"
           print_usage ;;
   esac
done

if [ "$SOURCE_DB" == '' ]; then
        echo "Source DB not found";
        exit 1;
fi

write_log "$0 -s $SOURCE_DB starting...";

EXPORT_FILE="${SOURCE_DB}.json"
export_data;