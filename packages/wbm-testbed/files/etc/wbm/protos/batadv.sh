#!/bin/sh

ACTION=$1
INTERFACE=$2
IPV6=$3

clean () {
  # stub
}

prepare () {
  uci set batman-adv.bat0=mesh
  uci set batman-adv.bat0.bridge_loop_avoidance=1
  uci commit batman-adv

  uci set network.bat0=interface
  uci set network.bat0.ifname=bat0
  uci set network.bat0.proto=static
  uci set network.bat0.ip6addr="$IPV6"
  uci set network.bat0.mtu=1500
  uci commit network
}

add () {
  uci set network.${INTERFACE}_batadv=interface
  uci set network.${INTERFACE}_batadv.proto=batadv
  uci set network.${INTERFACE}_batadv.mesh=bat0
  uci set network.${INTERFACE}_batadv.mtu=1528
  uci commit network
}

$ACTION
