#!/bin/bash

IP_FORWARD=$( cat /proc/sys/net/ipv4/ip_forward )
CMD_IPTABLES=$(which iptables)

if(( $IP_FORWARD == 0 )); then
  echo "ip_forward was disabled. Enabling ip_forward...";
  echo 1 > /proc/sys/net/ipv4/ip_forward
fi

echo "Flushing all iptables rules...";
$CMD_IPTABLES -P INPUT ACCEPT
$CMD_IPTABLES -P FORWARD ACCEPT
$CMD_IPTABLES -P OUTPUT ACCEPT
$CMD_IPTABLES -t nat -F
$CMD_IPTABLES -t mangle -F
$CMD_IPTABLES -F
$CMD_IPTABLES -X

if [[ -z $1 ]]; then
  echo "Missing argument. Exit!!!";
  exit 1;
else
  HOST_IP=$( host -t A $1 | awk '{print $4;}' | egrep [0-9.] )
fi

echo "Configuring port forwarding...";
$CMD_IPTABLES -t nat -A PREROUTING -i eth0 -p tcp --dport 3306 -j DNAT --to $HOST_IP:3306
$CMD_IPTABLES -A FORWARD -i eth0 -p tcp --dport 3306 -d $HOST_IP -j ACCEPT
$CMD_IPTABLES -t nat -A POSTROUTING -o eth0 -j MASQUERADE 
