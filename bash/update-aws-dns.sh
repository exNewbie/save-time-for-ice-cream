#!/bin/bash

## Quick and dirty script to update a record set on Route53 by the public IP of the instance

TTL=10
PUB_IP=$( curl -s http://169.254.169.254/latest/meta-data/public-ipv4 )
HOSTED_ZONE=$1
RECORD_NAME=$2
TMP_JSON=/tmp/rs.json

echo "{ \"Changes\": [ { \"Action\": \"UPSERT\", \"ResourceRecordSet\": { \"Name\": \"${RECORD_NAME}\", \"Type\": \"A\", \"TTL\": $TTL, \"ResourceRecords\": [ { \"Value\": \"${PUB_IP}\" } ] } } ] }" > $TMP_JSON

aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE --change-batch file://$TMP_JSON

rm $TMP_JSON

