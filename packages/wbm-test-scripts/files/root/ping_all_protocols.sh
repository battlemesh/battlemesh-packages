#!/bin/sh

if [ -z $3 ]; then
        echo "usage: " $0 " <router id> <count> <size>"
        exit 1;
fi

routerid="$1"
count="$2"
size="$3"

pingypongy () {
        ping6 -c $count -s $size $1 -W 5 
}

echo "======================="
date
echo "======================="


pingypongy fdbb::${routerid}
pingypongy fdba:11:${routerid}::1
pingypongy fdba:12:${routerid}::1
pingypongy fdba:14:${routerid}::1


