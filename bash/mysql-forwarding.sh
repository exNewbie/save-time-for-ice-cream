#!/bin/bash

IP_FORWARD=$( cat /proc/sys/net/ipv4/ip_forward )
CMD_IPTABLES=$(which iptables)
FLUSH_RULES=""

print_usage() {
   echo "[USAGE] $0 -db [Database host name] -lport [Listen port] [-f [Flush iptables rules]]";
   echo "[Example: ] $0 -db db.example.com -lport 3306";
   exit 1;
}

flush_rules() {
  echo "Flushing all iptables rules...";
  $CMD_IPTABLES -P INPUT ACCEPT
  $CMD_IPTABLES -P FORWARD ACCEPT
  $CMD_IPTABLES -P OUTPUT ACCEPT
  $CMD_IPTABLES -t nat -F
  $CMD_IPTABLES -t mangle -F
  $CMD_IPTABLES -F
  $CMD_IPTABLES -X
}

if [ $# -eq 0 ]; then echo "No arguments supplied"; print_usage; fi

# Getting the right options
while getopts "d:l:hf" option
do
   case $option in
        d) DB_HOSTNAME=${OPTARG};;
        l) LISTEN_PORT=${OPTARG};;
        f) FLUSH_RULES=true;;
        h) print_usage ;;
        \?) echo "Invalid option: -$OPTARG"
            print_usage ;;
        :) echo "Option -$OPTARG requires an argument"
           print_usage ;;
   esac
done

if [ "$IP_FORWARD" == "0" ]; then
  echo "ip_forward was disabled. Enabling ip_forward...";
  echo 1 > /proc/sys/net/ipv4/ip_forward
fi

if [ "$DB_HOSTNAME" == "" ]; then
  echo "Database hostname not supplied";
  exit 1;
else
  HOST_IP=$( host -t A $DB_HOSTNAME | awk '{print $4;}' | egrep [0-9.] )
fi

if [ "$LISTEN_PORT" == "" ]; then
  echo "Listen port not supplied";
  exit 1;
fi

if [ "$FLUSH_RULES" == true ]; then
  flush_rules;
fi

echo "Configuring port forwarding...";
$CMD_IPTABLES -t nat -A PREROUTING -i eth0 -p tcp --dport $LISTEN_PORT -j DNAT --to $HOST_IP:3306
$CMD_IPTABLES -A FORWARD -i eth0 -p tcp --dport 3306 -d $HOST_IP -j ACCEPT
$CMD_IPTABLES -t nat -A POSTROUTING -o eth0 -j MASQUERADE 
