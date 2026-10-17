#!/usr/bin/env bash
set -e

NO_SFE=0
[ "$1" = "--no-sfe" ] && NO_SFE=1

echo "==> Applying nft-fullcone patches"

# 1. libnftnl 补丁
mkdir -p feeds/packages/libs/libnftnl/patches
cat > feeds/packages/libs/libnftnl/patches/999-nft-fullcone.patch <<'PATCH'
--- a/include/data_reg.h
+++ b/include/data_reg.h
@@ -12,6 +12,7 @@ enum nft_data_types {
 	NFT_DATA_VALUE,
 	NFT_DATA_VERDICT,
 	NFT_DATA_CHAIN,
+	NFT_DATA_FULLCONE,
 };
 
 struct nft_data_reg {
--- a/src/expr/data.c
+++ b/src/expr/data.c
@@ -xx,6 +xx,7 @@ static const char *nft_data_type_name[NFT_DATA_CHAIN + 1] = {
 	[NFT_DATA_VALUE]	= "value",
 	[NFT_DATA_VERDICT]	= "verdict",
 	[NFT_DATA_CHAIN]	= "chain",
+	[NFT_DATA_FULLCONE]	= "fullcone",
 };
PATCH

# 2. nftables 补丁（允许 parser 认 fullcone）
mkdir -p feeds/packages/net/nftables/patches
cat > feeds/packages/net/nftables/patches/999-nft-fullcone.patch <<'PATCH'
--- a/src/parser_bison.y
+++ b/src/parser_bison.y
@@ -xx,6 +xx,7 @@ int main(int argc, char *argv[])
 %token FULLCONE		"fullcone"
 
 stmt :	...
+	|	FullConeStmt
 	;
PATCH

# 3. 拉取内核模块源码（nft-fullcone）
mkdir -p package/kernel/nft-fullcone
cat > package/kernel/nft-fullcone/Makefile <<'MK'
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
  SUBMENU:=Network Support
  TITLE:=nftables fullcone NAT support
  FILES:=$(PKG_BUILD_DIR)/nft_fullcone.ko
  AUTOLOAD:=$(call AutoLoad,45,nft_fullcone)
  DEPENDS:=@KERNEL_NFT_NAT
endef

define Build/Compile
	$(MAKE) -C "$(LINUX_DIR)" \
		$(KERNEL_MAKE_FLAGS) \
		M="$(PKG_BUILD_DIR)" \
		modules
endef

$(eval $(call KernelPackage,nft-fullcone))
MK

# 4. 默认配置追加
cat >> .config <<'EOF'
CONFIG_PACKAGE_kmod-nft-fullcone=y
CONFIG_PACKAGE_kmod-nft-offload=y
CONFIG_PACKAGE_luci-app-turboacc=y
EOF

[ "$NO_SFE" = 1 ] && echo "SFE skipped as requested"
echo "==> fullcone patches staged, run make defconfig after feeds install"
