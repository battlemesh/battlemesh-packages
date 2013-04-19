#!/bin/sh

if [ -z $1 ]; then
	echo "usage: $0 <destination>"
	exit 1
fi

dest="$1"

while true; do 
	mtr -nt -6 -r -c 1 $dest
	date +%s.%N
	sleep 2
done
