#!/usr/bin/env bash
# Ghostty 桌面集成修复 - 安装脚本
# 解决 GNOME Wayland 下点击图标无法打开 Ghostty 的问题
#
# 用法: bash install.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$SCRIPT_DIR/config"
DESKTOP_SRC="$SCRIPT_DIR/overrides/com.mitchellh.ghostty.desktop"
DBUS_SRC="$SCRIPT_DIR/overrides/com.mitchellh.ghostty.service"

# 目标路径
CONFIG_DEST="$HOME/.config/ghostty/config"
DESKTOP_DEST="$HOME/.local/share/applications/com.mitchellh.ghostty.desktop"
DBUS_DEST="$HOME/.local/share/dbus-1/services/com.mitchellh.ghostty.service"

echo "=== Ghostty 桌面集成修复 ==="
echo ""

# 1. 安装配置文件
echo "[1/5] 安装 Ghostty 配置..."
mkdir -p "$(dirname "$CONFIG_DEST")"
cp "$CONFIG_SRC" "$CONFIG_DEST"
echo "  -> $CONFIG_DEST"

# 2. 安装本地 desktop 文件 (覆盖系统默认)
echo "[2/5] 安装本地 desktop 文件..."
mkdir -p "$(dirname "$DESKTOP_DEST")"
cp "$DESKTOP_SRC" "$DESKTOP_DEST"
echo "  -> $DESKTOP_DEST"

# 3. 安装本地 D-Bus 服务文件 (覆盖系统默认)
echo "[3/5] 安装本地 D-Bus 服务文件..."
mkdir -p "$(dirname "$DBUS_DEST")"
cp "$DBUS_SRC" "$DBUS_DEST"
echo "  -> $DBUS_DEST"

# 4. 禁用系统的 D-Bus 单实例服务
echo "[4/5] 禁用系统 D-Bus 单实例服务..."
systemctl --user mask app-com.mitchellh.ghostty.service 2>/dev/null || true
echo "  -> app-com.mitchellh.ghostty.service (masked)"

# 5. 停止可能残留的旧 Ghostty 进程
echo "[5/5] 停止残留的 Ghostty 进程..."
systemctl --user stop app-com.mitchellh.ghostty.service 2>/dev/null || true

# 更新桌面数据库
echo ""
echo "更新桌面数据库..."
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

echo ""
echo "=== 安装完成 ==="
echo "请通过 GNOME 应用网格中的 Ghostty 图标启动终端。"
