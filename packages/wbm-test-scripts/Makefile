#    Copyright (C) OpenWRT.org
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
#	Pau Escrich <p4u@dabax.net>, Jo-Philipp <jow@openwrt.org>
#	Guido Ibarren <guido@codigosur.org>, Claudio Pisa <clauz@ninux.org>
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=wbm-test-scripts
PKG_RELEASE:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/wbm-test-scripts
  SECTION:=net
  CATEGORY:=WBM
  TITLE:=Test scripts for Wireless Battle of the Mesh testbeds
  URL:=http://battlemesh.org
  DEPENDS:=wbm-testbed
endef

define Package/wbm-test-scripts/description
 Test scripts for Wireless Battle of the Mesh testbeds
endef

define Package/wbm-test-scripts/conffiles
	/etc/config/wbm
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/wbm-test-scripts/install
	chmod 755 ./files/root/*.sh 
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/etc
	date -u +%Y%m%d%H%M > $(1)/etc/wbm-test-scripts.version
	git log -1 --format=%h > $(1)/etc/wbm-test-scripts.release
endef

$(eval $(call BuildPackage,wbm-test-scripts))

