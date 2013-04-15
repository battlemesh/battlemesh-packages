#    Copyright (C) Guifi.net private foundation
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc.,
#    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
#    The full GNU General Public License is included in this distribution in
#    the file called "COPYING".
#
# Contributors:
#	Pau Escrich <p4u@dabax.net>, Jo-Philipp <jow@openwrt.org>, Guido Ibarren <guido@codigosur.org>
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=wbm-testbed
PKG_RELEASE:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/wbm-testbed
  SECTION:=net
  CATEGORY:=WBM
  TITLE:=Addons for Wireless Battle of the Mesh testbed
  URL:=http://battlemesh.org
  DEPENDS:= \
	+iwinfo +lua +libiwinfo-lua +lupi \
	+iputils-arping +iputils-clockdiff +iputils-ping +iputils-tracepath \
	+radvd \
	+hostapd-mini +wpa-supplicant-mini \
	+wireless-tools +iw +netperf \
	+wide-dhcpv6-client +wide-dhcpv6-control +wide-dhcpv6-server \
	+ip \
	+ndisc6 +rdisc6 +rdnssd \
	+6in4 +6to4 \
	+ip6tables +ip6tables-utils
endef

define Package/wbm-testbed/description
 Required addons for Wireless Battle of the Mesh testbed
endef

define Package/wbm-testbed/conffiles
	/etc/config/wbm
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/wbm-testbed/install
	$(CP) ./files/* $(1)/
	date +%Y%m%d > $(1)/etc/wbm.version
endef

$(eval $(call BuildPackage,wbm-testbed))

