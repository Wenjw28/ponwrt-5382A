include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=nft-fullcone
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/mufeng05/nft-fullcone.git
PKG_SOURCE_DATE:=2024-01-01
PKG_SOURCE_VERSION:=master
PKG_MIRROR_HASH:=skip

include $(INCLUDE_DIR)/package.mk

define KernelPackage/nft-fullcone
  SUBMENU:=Netfilter Extensions
  TITLE:=nftables fullcone NAT support (nft_fullcone.ko)
  FILES:=$(PKG_BUILD_DIR)/nft_fullcone.ko
  AUTOLOAD:=$(call AutoLoad,45,nft_fullcone)
  DEPENDS:=+kmod-nf-nat +kmod-nft-nat
endef

define Build/Compile
	$(MAKE) -C "$(LINUX_DIR)" M="$(PKG_BUILD_DIR)" $(KERNEL_MAKE_FLAGS) modules
endef

$(eval $(call KernelPackage,nft-fullcone))
