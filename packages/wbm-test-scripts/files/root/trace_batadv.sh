#!/bin/sh

if [ -z $1 ]; then 
	echo "usage: $0 <destination mac address>"
	exit 1
fi

dest="$1"

while true; do 
	batctl traceroute -n -T $dest
	date +%s.%N
	sleep 2 
done
