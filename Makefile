include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI EdgeOS Theme (EdgeOS 3+ inspired)
LUCI_DEPENDS:=+luci-base
PKGARCH:=all

include ../../luci.mk

# call BuildPackage - OpenWrt buildroot signature
