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

# output should look like this
# and will be used to plot some .dot-files for visualization
#
# $myhostname $neighmac_or_ip    $iface  $quali $rx/tx-packets/bytes   $minstrel_filename
# wbm-8cd9    11:22:33:44:55:66  eth0.1  4321   123 435 723876 7632465 /tmp/minstrel.$uptimestamp

store_neigh_stats()
{
	local minstrel_file line ip uptime nop
	local hostname="$( uci -q get system.@system[0].hostname )"
	local storage_path="/tmp/neigh_stats_$mymac"
	mkdir -p "$storage_path"

	wget -qO - "http://[::1]:2006/neighbours" | while read line; do {
		set -- $line

		case "$2" in
			Neighbors)
				return 0	# no further parsing needed (next section)
			;;
			*":"*)			# localIP         remoteIP         hyst  LQ     NQL    COST
				ip="$2"		# fdba:b:8cd9::1  fdba:11:2051::1  0.00  0.937  0.156  6.802
				cost="$6"

				case "$cost" in
					*.*)	# 6.821 -> 6821
						cost="${cost%%.*}${cost#*.}"
					;;
				esac

				remotemac="$( remoteip2mac "$ip" )"
				iface="$( remoteip2dev "$ip" )"

				if [ -e /sys/kernel/debug/ieee80211/phy*/netdev:${iface}/stations/${remotemac}/rc_stats ]; then
					read uptime nop </proc/uptime
					minstrel_file="rcstats_$uptime"
					cat /sys/kernel/debug/ieee80211/phy*/netdev:${iface}/stations/${remotemac}/rc_stats >"$minstrel_file"
				else
					if [ -z "$remotemac" ]; then
						minstrel_file="no_mac_no_minstrel"
					else
						minstrel_file="no_minstrel_data"
					fi
				fi

				echo "$hostname $ip ${iface:-iface?} $cost $( get_station_stats "${iface:-iface?}" "$remotemac" ) $minstrel_file"
			;;
		esac
	} done
}

remoteip2dev()
{
	local ip="$1"

	set -- $( ip -6 route list exact "$ip"/128 )

	case "$3" in
		*":"*)	# e.g.: fdba:11:81c5::1 via fdba:21:81c5::1 dev wbm2.10  metric 2
			echo "$5"
		;;
		*)	# e.g.: fdba:21:42f1::1 dev wbm2.10  metric 2
			echo "$3"
		;;
	esac
}

remoteip2mac()
{
	local ip="$1"

	set -- $( ip neigh show to "$ip" | head -n1 )

	case "$5" in
		*":"*)	# e.g. fdba:21:42f1::1 dev wbm2.10 lladdr 64:70:02:67:6a:b4 router STALE
			echo "$3"
		;;
	esac
}

get_station_stats()
{
	local iface="$1"
	local remotemac="$2"
	local line

	[ -z "$iface" -o -z "$remotemac" ] && {
		echo "0 0 0 0"
		return 0
	}

	iw dev $iface station get $remotemac | while read line; do {
		# e.g.: Station a0:f3:c1:39:7c:f0 (on wbm1) -> rx bytes: rx packets: tx bytes: tx packets:
		set -- $line
		case "$1 $2" in
			"rx bytes:"|"rx packets:"|"tx bytes:"|"tx packets:")
				echo -n "$3 "
			;;
			"tx retries:")
				return 0
			;;
		esac
	} done

	echo "0 0 0 0"		# fallback, when there is no station info
}

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
    case "$1" in
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
