#!/bin/bash 

#aws rds copy-db-snapshot \
#    --source-db-snapshot-identifier mysql-instance1-snapshot-20130805 \
#    --target-db-snapshot-identifier mydbsnapshotcopy \
#    --copy-tags

LOG_FILE="/var/log/rds-snapshot.log";
AWS_CMD="/usr/local/bin/aws";
JQ_CMD="/usr/bin/jq";
BK_RENTION=7;

retion_date=$( date +"%Y-%m-%d" -d "$BK_RENTION day ago" );

print_usage() {
   echo "[USAGE] $0 -s [Source DB Identifier]";
   echo "[Example: ] $0 -s spotfirerds";
   exit 1;
}

write_log() {
        now=$( /bin/date +"%Y-%m-%d %H:%M:%S");
        echo "${now} INFO $1" >> $LOG_FILE;
}

if [ $# -eq 0 ]; then echo "No arguments supplied"; print_usage; fi

# Getting the right options
while getopts ":s:h" option
do
   case $option in
        s) SOURCE_DB=${OPTARG};;
        h) print_usage ;;
        \?) echo "Invalid option: -$OPTARG"
            print_usage ;;
        :) echo "Option -$OPTARG requires an argument"
           print_usage ;;
   esac
done

if [ "$SOURCE_DB" == '' ]; then
        echo "Source DB Identifier not found";
        exit 1;
fi

write_log "$0 -s $SOURCE_DB starting...";

#ORG_SNAPSHOT=`${AWS_COMMAND} rds describe-db-snapshots --output text --snapshot-type automated --max-items 1 --db-instance-identifier ${SOURCE_DB} --query 'DBSnapshots[0].DBSnapshotIdentifier' | grep -v None`
ORG_SNAPSHOT=$( ${AWS_CMD} rds describe-db-snapshots --snapshot-type automated --db-instance-identifier ${SOURCE_DB} --query 'DBSnapshots[*].{SnapshotCreateTime:SnapshotCreateTime,DBSnapshotIdentifier:DBSnapshotIdentifier}' | ${JQ_CMD} 'sort_by(.SnapshotCreateTime)' | ${JQ_CMD} -r ".[] | select(.SnapshotCreateTime | test(\"${retion_date}\")) | .DBSnapshotIdentifier" );
NEW_SNAPSHOT="manual-${ORG_SNAPSHOT/\:/\-}";

write_log "Original automated backup: $ORG_SNAPSHOT";
write_log "Manual backup: $NEW_SNAPSHOT";
${AWS_CMD} rds copy-db-snapshot --source-db-snapshot-identifier ${ORG_SNAPSHOT} --target-db-snapshot-identifier "${NEW_SNAPSHOT}" --copy-tags >> ${LOG_FILE};
write_log "Work finished";
