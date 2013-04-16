#!/bin/sh

#set -x

#ACTIONS are: add prepare clean?
#example: bmx6.sh <action> <virtual_if> <actual_if> <IPv4/16> <IPv6/64>

ACTION=$1
LOGICAL_INTERFACE=$2
REAL_INTERFACE=$3
IPV4=$4
IPV6=$5

clean () {
  uci revert bmx6
  rm /etc/config/bmx6
  touch /etc/config/bmx6
}

prepare () {
  rm -f /etc/config/bmx6
  touch /etc/config/bmx6

  uci set bmx6.general=bmx6
# uci set bmx6.general.ipAutoPrefix="::/0"
# uci set bmx6.general.globalPrefix="fd11::/48"

  uci set bmx6.config=plugin
  uci set bmx6.config.plugin=bmx6_config.so

  uci set bmx6.json=plugin
  uci set bmx6.json.plugin=bmx6_json.so

  # Search for any announcement of 10/8 in the mesh cloud
  uci set bmx6.mesh=tunOut
  uci set bmx6.mesh.tunOut=mesh
  uci set bmx6.mesh.network=10.0.0.0/8
  uci set bmx6.mesh.minPrefixLen=24
  uci set bmx6.mesh.maxPrefixLen=32

  # Search for internet in the mesh cloud
  uci set bmx6.inet=tunOut
  uci set bmx6.inet.tunOut=inet
  uci set bmx6.inet.network=0.0.0.0/0
  uci set bmx6.inet.minPrefixLen=0
  uci set bmx6.inet.maxPrefixLen=0

  # Search for any IPv6 announcement in the mesh cloud
  uci set bmx6.ipv6=tunOut
  uci set bmx6.ipv6.tunOut=ipv6
  uci set bmx6.ipv6.network=::/0

  uci commit bmx6
}

add () {
  uci set bmx6.${LOGICAL_INTERFACE}=dev
  uci set bmx6.${LOGICAL_INTERFACE}.dev=${REAL_INTERFACE}
  uci set bmx6.${LOGICAL_INTERFACE}.globalPrefix="$( echo ${IPV6} echo | sed s/"\/.*"/"\/128"/ )"

  if uci -q get bmx6.general.tun4Address > /dev/null ; then
    uci set bmx6.tun_${LOGICAL_INTERFACE}=tunInNet
    uci set bmx6.tun_${LOGICAL_INTERFACE}.tunInNet="$( echo ${IPV4} echo | sed s/"\/.*"/"\/32"/ )"
    uci set bmx6.tun_${LOGICAL_INTERFACE}.bandwidth="128000000000"
  else
    uci set bmx6.general.tun4Address="$( echo ${IPV4} echo | sed s/"\/.*"/"\/32"/ )"
  fi
  uci commit bmx6
}

stop () {
  killall bmx6
  sleep 2
  killall -9 bmx6
}

start () {
  stop
  bmx6
}

$ACTION
