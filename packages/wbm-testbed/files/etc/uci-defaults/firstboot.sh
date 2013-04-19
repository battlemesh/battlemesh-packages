#!/bin/sh
echo "Configuring WBM testbed for first boot..."
uci add_list uhttpd.main.listen_https="[::]:443"
uci add_list uhttpd.main.listen_http="[::]:80"
uci commit uhttpd
lua /usr/bin/wbm-config
ln -s /etc /www/etc
echo "*/10 * * * *	lua /usr/bin/wbm-fwupdate" >> /etc/crontabs/root
