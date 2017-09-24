include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-koolproxy
PKG_VERSION:=1.0.3
PKG_RELEASE:=3

PKG_MAINTAINER:=panda-mute <wxuzju@gmail.com>
PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-koolproxy
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=LuCI support for koolproxy
	DEPENDS:=+koolproxy +openssl-util +ipset +dnsmasq-full +@BUSYBOX_CONFIG_DIFF +iptables-mod-nat-extra +wget
	MAINTAINER:=panda-mute
endef

define Package/luci-app-koolproxy/description
	This package contains LuCI configuration pages for koolproxy.
endef

define Build/Prepare
	$(foreach po,$(wildcard ${CURDIR}/files/i18n/*.po), \
		po2lmo $(po) $(PKG_BUILD_DIR)/$(patsubst %.po,%.lmo,$(notdir $(po)));)
endef

define Build/Compile
endef

define Package/luci-app-koolproxy/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	( . /etc/uci-defaults/luci-koolproxy ) && rm -f /etc/uci-defaults/luci-koolproxy
	rm -f /tmp/luci-indexcache
fi
exit 0
endef

define Package/luci-app-koolproxy/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/koolproxy
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/koolproxy

	$(INSTALL_BIN) ./files/etc/uci-defaults/luci-koolproxy $(1)/etc/uci-defaults/luci-koolproxy
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/model/cbi/koolproxy/global.lua $(1)/usr/lib/lua/luci/model/cbi/koolproxy/global.lua
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/controller/koolproxy.lua $(1)/usr/lib/lua/luci/controller/koolproxy.lua
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/view/koolproxy/* $(1)/usr/lib/lua/luci/view/koolproxy/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/koolproxy.zh-cn.lmo $(1)/usr/lib/lua/luci/i18n/koolproxy.zh-cn.lmo

endef

$(eval $(call BuildPackage,luci-app-koolproxy))
