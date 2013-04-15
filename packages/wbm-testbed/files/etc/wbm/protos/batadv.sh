#!/bin/sh

ACTION=$1
INTERFACE=$2
IPV6=$3

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
  uci set network.bat0.mtu=1500
  uci commit network
}

add () {
  if [ "$(uci -q get network.bat0.ip6addr)" == "" ] ; then
    uci set network.bat0.ip6addr="$IPV6"
  fi
  uci set network.${INTERFACE}=interface
  uci set network.${INTERFACE}.proto=batadv
  uci set network.${INTERFACE}.mesh=bat0
  uci set network.${INTERFACE}.mtu=1528
  uci commit network
}

$ACTION
