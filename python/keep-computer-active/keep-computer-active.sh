#!/bin/bash
ALLOWED_LOCATIONS=("192.168.24.222")

# Loop through ALLOWED_LOCATIONS and check if the current IP is in the list
# Ping each location and check if the ping is successful
for location in "${ALLOWED_LOCATIONS[@]}"; do
    if ! ping -c 5 $location &> /dev/null; then
        echo "Ping to $location failed. Exiting."
        exit 1
    fi
done

# Check if minutes argument is provided
if [ $# -eq 1 ] && [[ $1 =~ ^[0-9]+$ ]]; then
    minutes=$1
    echo "Running for $minutes minutes..."
    end_time=$(($(date +%s) + minutes * 60))
    
    while [ $(date +%s) -lt $end_time ]; do
        echo -n "."
        ./keep-computer-active
        sleep 60
    done
    
    echo ""
    echo "Time limit of $minutes minutes reached. Exiting."
    exit 0
else
    # Original infinite loop behavior
    while [ true ]; do
        echo -n "."
        ./keep-computer-active
        sleep 60
    done
fi
