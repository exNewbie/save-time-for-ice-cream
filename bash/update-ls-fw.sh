#!/bin/bash

MY_IP=$( curl -s ifconfig.io )

ALLOW_ALL='[
  {"protocol": "TCP", "fromPort": 32, "toPort": 32},
  {"protocol": "TCP", "fromPort": 33, "toPort": 33},
  {"protocol": "UDP", "fromPort": 1194, "toPort": 1194}
]'

echo "Current IP: ${MY_IP}"

print_usage() {
   echo "[USAGE] $0 -p [AWS Profile] -i [Lightsail Instance Name] -c [Config File]";
   echo "[Example: ] $0 -p lab -i lightsail-linux -c firewall-config.json";
   exit 1;
}

if [ $# -eq 0 ]; then echo "No arguments supplied"; print_usage; fi

while getopts "p:i:c:h" option
do
   case $option in
        p) PROFILE=${OPTARG};;
        i) INSTANCE_NAME=${OPTARG};;
        c) CONFIG_FILE=${OPTARG};;
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

if [ "$CONFIG_FILE" == '' ]; then
        echo "Config file not specified";
        exit 1;
fi

if [ ! -f "$CONFIG_FILE" ]; then
        echo "Config file not found: $CONFIG_FILE";
        exit 1;
fi

INSTANCE_PUB_IP=$( aws --profile ${PROFILE} lightsail get-instance --instance-name ${INSTANCE_NAME} --query 'instance.publicIpAddress' --output text )

/usr/local/bin/aws --profile ${PROFILE} lightsail put-instance-public-ports \
  --instance-name ${INSTANCE_NAME} \
  --port-infos "${PORT_INFOS}"

