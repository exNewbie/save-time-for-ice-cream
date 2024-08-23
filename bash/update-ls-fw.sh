#!/bin/bash

MY_IP=$( curl -s ifconfig.io )
OFFICE_IP="x.x.x.x/32"

PORT_INFOS='[{ "protocol": "TCP", "fromPort": 32, "toPort": 32 }, { "protocol": "TCP", "fromPort": 33, "toPort": 33 }, { "protocol": "UDP", "fromPort": 1194, "toPort": 1194 }, { "protocol": "TCP", "fromPort": 53, "toPort": 53, "cidrs": [ "OFFICE_IP", "TEMPLATE_IP" ] }, { "protocol": "UDP", "fromPort": 53, "toPort": 53, "cidrs": [ "OFFICE_IP", "TEMPLATE_IP" ] }, { "protocol": "TCP", "fromPort": 1081, "toPort": 1081, "cidrs": [ "OFFICE_IP", "TEMPLATE_IP" ] }, { "protocol": "TCP", "fromPort": 82, "toPort": 82, "cidrs": [ "OFFICE_IP", "TEMPLATE_IP" ] }]'
PORT_INFOS="${PORT_INFOS//TEMPLATE_IP/$MY_IP\/32}"
PORT_INFOS="${PORT_INFOS//OFFICE_IP/$OFFICE_IP}"

echo "Current IP: ${MY_IP}"

print_usage() {
   echo "[USAGE] $0 -p [AWS Profile] -i [Lightsail Instance Name]";
   echo "[Example: ] $0 -p lab -i lightsail-linux";
   exit 1;
}

if [ $# -eq 0 ]; then echo "No arguments supplied"; print_usage; fi

while getopts "p:i:h" option
do
   case $option in
        p) PROFILE=${OPTARG};;
        i) INSTANCE_NAME=${OPTARG};;
        h) print_usage ;;
        \?) echo "Invalid option: -$OPTARG"
            print_usage ;;
        :) echo "Option -$OPTARG requires an argument"
           print_usage ;;
   esac
done

if [ "$INSTANCE_NAME" == '' ]; then
        echo "Instance name not found";
        exit 1;
fi

/usr/local/bin/aws --profile ${PROFILE} lightsail put-instance-public-ports \
  --instance-name ${INSTANCE_NAME} \
  --port-infos "${PORT_INFOS}"
