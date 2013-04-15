#!/bin/sh

#set -x

#ACTIONS are: add prepare clean?
# example: $0 <action> <virtual_if> <actual_if> <IPv4/16> <IPv6/64>


ACTION=$1
LOGICAL_INTERFACE=$2
REAL_INTERFACE=$3
IPV4=$4
IPV6=$5

clean () {
  uci revert olsrd
  rm /etc/config/olsrd
  touch /etc/config/olsrd
}

prepare () {
  touch /etc/config/olsrd
  touch /etc/config/network

  uci set olsrd.@olsrd[0]=olsrd
  uci set olsrd.@olsrd[0].DebugLevel=0
  uci set olsrd.@olsrd[0].ClearScreen=no
  uci set olsrd.@olsrd[0].AllowNoInt=yes
  uci set olsrd.@olsrd[0].IpVersion=4
  uci set olsrd.@olsrd[0].FIBMetric=flat
  uci set olsrd.@olsrd[0].Willingness=7
  uci set olsrd.@olsrd[0].TcRedundancy=2
  uci set olsrd.@olsrd[0].LinkQualityFishEye=1
  uci set olsrd.@olsrd[0].LinkQualityAlgorithm=etx_ffeth
  uci set olsrd.@olsrd[0].MprCoverage=7

  uci set olsrd.@LoadPlugin[0]=LoadPlugin
  uci set olsrd.@LoadPlugin[0].library=olsrd_arprefresh.so.0.1
  uci set olsrd.@LoadPlugin[1]=LoadPlugin

  uci set olsrd.@LoadPlugin[1].library=olsrd_txtinfo.so.0.1
  uci set olsrd.@LoadPlugin[1].accept=0.0.0.0
  uci set olsrd.@LoadPlugin[1].port=2006

  uci commit olsrd
}

add () {
  uci set network.${LOGICAL_INTERFACE}=interface
  uci set network.${LOGICAL_INTERFACE}.ifname=${REAL_INTERFACE}
  uci set network.${LOGICAL_INTERFACE}.proto=static
  uci set network.${LOGICAL_INTERFACE}.ip6addr="${IPV6}"
  uci commit network

  uci set olsrd.@Interface[0]=Interface
  uci set olsrd.@Interface[0].interface=${LOGICAL_INTERFACE}
  uci set olsrd.@Interface[0].Ip4Broadcast=255.255.255.255
  uci set olsrd.@Interface[0].speed=4

  interface_is_wifi()
  {
    local iface="$( echo "$1" | cut -d'.' -f1 )"
    grep "$1:" /proc/net/wireless
  }

  interface_is_wifi "${REAL_INTERFACE}" && {
    uci set olsrd.@Interface[0].Mode=ether
  }

  uci commit olsrd
}

stop () {
  /etc/init.d/olsrd stop
}

start () {
  stop
  /etc/init.d/olsrd start
}

$ACTION
