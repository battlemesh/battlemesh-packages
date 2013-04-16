#!/bin/sh

ACTION=$1
LOGICAL_INTERFACE=$2
REAL_INTERFACE=$3
IPV4=$4
IPV6=$5

ipv4_addr () {
  echo ${IPV4%%/*}
}

ipv4_netmask () {
  echo ${IPV4##*/}
}

clean () {
  true  
}

prepare () {
  uci set batman-adv.bat0=mesh
  uci set batman-adv.bat0.bridge_loop_avoidance=1
  uci commit batman-adv

  uci set network.bat0=interface
  uci set network.bat0.ifname=bat0
  uci set network.bat0.proto=static
  uci set network.bat0.ip6addr=""
  uci set network.bat0.ipaddr=""
  uci set network.bat0.netmask=""
  uci set network.bat0.mtu=1500
  uci commit network
}

add () {
  if [ "$(uci -q get network.bat0.macaddr)" == "" ] ; then
    id="$(uci get system.@system[0].hostname | sed -e 's/wbm-\(..\)\(..\)/\1:\2/')"
    uci set network.bat0.macaddr="02:ba:$id:00:01"
  fi
  if [ "$(uci -q get network.bat0.ip6addr)" == "" ] ; then
    uci set network.bat0.ip6addr="$IPV6"
  fi
  if [ "$(uci -q get network.bat0.ipaddr)" == "" ] ; then
    uci set network.bat0.ipaddr="$(ipv4_addr)"
    uci set network.bat0.netmask="$(ipv4_netmask)"
  fi
  uci set network.${LOGICAL_INTERFACE}=interface
  uci set network.${LOGICAL_INTERFACE}.proto=batadv
  uci set network.${LOGICAL_INTERFACE}.mesh=bat0
  uci set network.${LOGICAL_INTERFACE}.mtu=1528
  uci commit network
}

$ACTION
