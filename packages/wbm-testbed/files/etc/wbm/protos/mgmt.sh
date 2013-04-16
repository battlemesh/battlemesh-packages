#!/bin/sh

ACTION=$1
LOGICAL_INTERFACE=$2
REAL_INTERFACE=$3
IPV4=$4
IPV6=$5

clean () {
  true  
}

prepare () {
  uci set batman-adv.bat1=mesh
  uci set batman-adv.bat1.bridge_loop_avoidance=1
  uci commit batman-adv

  uci set network.bat1=interface
  uci set network.bat1.ifname=bat1
  uci set network.bat1.proto=dhcp

  uci set network.bat1_v6=interface
  uci set network.bat1_v6.ifname="@bat1"
  uci set network.bat1_v6.proto=dhcpv6
  uci commit network
}

add () {
  uci set network.${LOGICAL_INTERFACE}=interface
  uci set network.${LOGICAL_INTERFACE}.proto=batadv
  uci set network.${LOGICAL_INTERFACE}.mesh=bat1
  uci set network.${LOGICAL_INTERFACE}.mtu=1528
  uci commit network
}

$ACTION
