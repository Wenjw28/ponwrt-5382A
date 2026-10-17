#!/bin/bash
# PonWrt AN7581 (HG5382A) FullCone NAT1 injector (No SFE)
set -e

echo "==> Applying nft-fullcone patch (no-sfe mode)"

# 1. 确保 fw4/nftables 基础（PonWrt 默认满足，此处兜底）
sed -ri 's/.*CONFIG_PACKAGE_firewall4.*/CONFIG_PACKAGE_firewall4=y/' .config
sed -ri 's/.*CONFIG_PACKAGE_nftables.*/CONFIG_PACKAGE_nftables=y/' .config

# 2. 拉取 mufeng05 turboacc 并只打 fullcone（跳过 SFE）
if [ ! -f /tmp/add_turboacc.sh ]; then
  curl -sSL https://raw.githubusercontent.com/mufeng05/turboacc/main/add_turboacc.sh -o /tmp/add_turboacc.sh
fi
chmod +x /tmp/add_turboacc.sh
# 使用 --no-sfe 参数，避免 AN7581 编译失败
bash /tmp/add_turboacc.sh --no-sfe

# 3. 强制锁定 fullcone 内核模块与 LuCI（确保 NAT1）
cat >> .config <<'EOF'
CONFIG_PACKAGE_kmod-nft-fullcone=y
CONFIG_PACKAGE_luci-app-turboacc=y
CONFIG_PACKAGE_kmod-nft-offload=y
EOF

# 4. 刷新配置
make defconfig >/dev/null 2>&1 || true
echo "==> FullCone NAT1 patch applied (SFE disabled)."
