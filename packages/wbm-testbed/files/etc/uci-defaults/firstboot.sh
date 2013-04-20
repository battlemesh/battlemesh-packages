#!/bin/sh
echo "Configuring WBM testbed for first boot..."
uci add_list uhttpd.main.listen_https="[::]:443"
uci add_list uhttpd.main.listen_http="[::]:80"
uci commit uhttpd
lua /usr/bin/wbm-config
ln -s /etc /www/etc
echo "iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -j MASQUERADE" > /etc/rc.local
#echo "* * * * * sh /etc/wbm/utils/checkwifi.sh" >> /etc/crontabs/root
echo 'echo default-on > /sys/class/leds/tp-link\:blue\:qss/trigger' >> /etc/rc.local
echo "*/10 * * * *	lua /usr/bin/wbm-fwupdate" >> /etc/crontabs/root
