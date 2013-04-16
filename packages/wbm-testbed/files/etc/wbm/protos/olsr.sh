#!/bin/sh

#set -x

#ACTIONS are: add prepare clean?
# example: $0 <action> <virtual_if> <actual_if> <IPv4/16> <IPv6/64>

# olsr.sh prepare
# olsr.sh add wlan wlan0
# olsr.sh add lan eth0.1

ACTION=$1
LOGICAL_INTERFACE=$2
REAL_INTERFACE=$3
IPV4=$4
IPV6=$5

prepare() {
  uci revert olsrd
  rm /etc/config/olsrd
  touch /etc/config/olsrd

  uci -q add olsrd olsrd
  uci set olsrd.@olsrd[-1].IpVersion=6
  uci set olsrd.@olsrd[-1].LinkQualityAlgorithm=etx_ffeth

  uci -q add olsrd LoadPlugin
  uci set olsrd.@LoadPlugin[-1]=LoadPlugin
  uci set olsrd.@LoadPlugin[-1].library=olsrd_arprefresh.so.0.1

  uci -q add olsrd LoadPlugin
  uci set olsrd.@LoadPlugin[-1]=LoadPlugin
  uci set olsrd.@LoadPlugin[-1].library=olsrd_jsoninfo.so.0.0
  uci set olsrd.@LoadPlugin[-1].accept="::1"
  uci set olsrd.@LoadPlugin[-1].port=9090

  uci -q add olsrd LoadPlugin
  uci set olsrd.@LoadPlugin[-1]=LoadPlugin
  uci set olsrd.@LoadPlugin[-1].library=olsrd_txtinfo.so.0.1
  uci set olsrd.@LoadPlugin[-1].accept="::1"
  uci set olsrd.@LoadPlugin[-1].port=2006

  uci commit olsrd
}

add() {
  uci -q add olsrd Interface
  uci set olsrd.@Interface[-1].interface=${LOGICAL_INTERFACE}
  uci set olsrd.@Interface[-1].IPv6Multicast="ff02::6D"
  uci set olsrd.@Interface[-1].speed=5

  interface_is_wifi()
  {
    case "$iface" in
      wbm*)
        return 0
      ;;
      *)
        return 1
      ;;
    esac
  }

  if interface_is_wifi "${REAL_INTERFACE}"; then
    uci set olsrd.@Interface[-1].Mode=mesh
  else
    uci set olsrd.@Interface[-1].Mode=ether
  fi

  uci commit olsrd
}

$ACTION
