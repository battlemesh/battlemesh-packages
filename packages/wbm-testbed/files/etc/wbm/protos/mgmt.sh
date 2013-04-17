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
  uci set batman-adv.bat1.orig_interval=600
  uci set batman-adv.bat1.bridge_loop_avoidance=1
  uci commit batman-adv

  uci set dhcp.@dnsmasq[0].domainneeded=0
  uci set dhcp.@dnsmasq[0].boguspriv=0
  uci set dhcp.@dnsmasq[0].rebind_protection=0
  uci set dhcp.mgmt=dhcp
  uci set dhcp.mgmt.interface=mgmt
  uci set dhcp.mgmt.ignore=1
  uci commit dhcp

  uci set network.mgmt=interface
  uci set network.mgmt.ifname=bat1
  uci set network.mgmt.proto=dhcp

  uci set network.mgmt_v6=interface
  uci set network.mgmt_v6.ifname="@mgmt"
  uci set network.mgmt_v6.proto=dhcpv6
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
