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
  touch /etc/config/bmx6
  touch /etc/config/network

  uci set bmx6.general=bmx6
# uci set bmx6.general.ipAutoPrefix="::/0"
# uci set bmx6.general.globalPrefix="fd11::/48"

  uci set bmx6.plugin=plugin
  uci set bmx6.plugin.plugin=bmx6_config.so

  uci set bmx6.tun4=tunOut
  uci set bmx6.tun4.tunOut=tun4
  uci set bmx6.tun4.network=10.0.0.0/8
  uci set bmx6.tun4.minPrefixLen=24
  uci set bmx6.tun4.maxPrefixLen=32

  uci commit bmx6
}

add () {
  uci set network.${LOGICAL_INTERFACE}=interface
  uci set network.${LOGICAL_INTERFACE}.ifname=${REAL_INTERFACE}
  uci set network.${LOGICAL_INTERFACE}.proto=static
  uci set network.${LOGICAL_INTERFACE}.ip6addr="${IPV6}"
#  uci set network.${LOGICAL_INTERFACE}.ipaddr=""
#  uci set network.${LOGICAL_INTERFACE}.netmask=""
#  uci set network.${LOGICAL_INTERFACE}.mtu=1500
  uci commit network

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
