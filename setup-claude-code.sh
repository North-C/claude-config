#!/bin/bash

# Claude Code 安装与配置脚本
# 用途: 一键安装 Claude Code 并配置插件，或仅安装插件
# 使用:
#   bash scripts/setup-claude-code.sh          # 完整安装
#   bash scripts/setup-claude-code.sh --plugins # 仅安装插件

set -euo pipefail

# ========================
#       常量定义
# ========================
SCRIPT_NAME=$(basename "$0")
NODE_MIN_VERSION=18
NODE_INSTALL_VERSION=22
NVM_VERSION="v0.40.3"
CONFIG_DIR="$HOME/.claude"
CONFIG_FILE="$CONFIG_DIR/settings.json"
API_BASE_URL="https://open.bigmodel.cn/api/anthropic"
API_KEY_URL="https://open.bigmodel.cn/usercenter/proj-mgmt/apikeys"
API_TIMEOUT_MS=3000000

# Marketplace 配置
MARKETPLACE_REPO="VoltAgent/awesome-claude-code-subagents"

# 要安装的插件列表
PLUGINS_TO_INSTALL=(
    "context7"
    "code-review"
    "feature-dev"
    "typescript-lsp"
)

# 运行模式: full 或 plugins-only
MODE="full"

# 是否安装 hooks
INSTALL_HOOKS=false

# ========================
#       工具函数
# ========================

log_info() {
    echo "🔹 $*"
}

log_success() {
    echo "✅ $*"
}

log_error() {
    echo "❌ $*" >&2
}

ensure_dir_exists() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir" || {
            log_error "Failed to create directory: $dir"
            exit 1
        }
    fi
}

show_usage() {
    cat << EOF
🚀 Claude Code Setup Script

Usage:
  $SCRIPT_NAME              完整安装 (Node.js + Claude Code + API + Marketplace + Plugins)
  $SCRIPT_NAME --plugins    仅安装插件和 Marketplace (假设 Claude Code 已安装)
  $SCRIPT_NAME --hooks      同时安装 Hooks (智能停止决策、命令日志记录、子智能体循环)
  $SCRIPT_NAME -h, --help   显示此帮助信息

Examples:
  $SCRIPT_NAME                      # 完整安装
  $SCRIPT_NAME --plugins            # 仅安装插件
  $SCRIPT_NAME --hooks              # 完整安装 + Hooks
  $SCRIPT_NAME --plugins --hooks    # 仅安装插件 + Hooks

EOF
}

# ========================
#     Node.js 安装函数
# ========================

install_nodejs() {
    local platform=$(uname -s)

    case "$platform" in
        Linux|Darwin)
            log_info "Installing Node.js on $platform..."

            # 安装 nvm
            log_info "Installing nvm ($NVM_VERSION)..."
            curl -s https://raw.githubusercontent.com/nvm-sh/nvm/"$NVM_VERSION"/install.sh | bash

            # 加载 nvm
            log_info "Loading nvm environment..."
            \. "$HOME/.nvm/nvm.sh"

            # 安装 Node.js
            log_info "Installing Node.js $NODE_INSTALL_VERSION..."
            nvm install "$NODE_INSTALL_VERSION"

            # 验证安装
            node -v &>/dev/null || {
                log_error "Node.js installation failed"
                exit 1
            }
            log_success "Node.js installed: $(node -v)"
            log_success "npm version: $(npm -v)"
            ;;
        *)
            log_error "Unsupported platform: $platform"
            exit 1
            ;;
    esac
}

# ========================
#     Node.js 检查函数
# ========================

check_nodejs() {
    if command -v node &>/dev/null; then
        current_version=$(node -v | sed 's/v//')
        major_version=$(echo "$current_version" | cut -d. -f1)

        if [ "$major_version" -ge "$NODE_MIN_VERSION" ]; then
            log_success "Node.js is already installed: v$current_version"
            return 0
        else
            log_info "Node.js v$current_version is installed but version < $NODE_MIN_VERSION. Upgrading..."
            install_nodejs
        fi
    else
        log_info "Node.js not found. Installing..."
        install_nodejs
    fi
}

# ========================
#     Claude Code 安装
# ========================

install_claude_code() {
    if command -v claude &>/dev/null; then
        log_success "Claude Code is already installed: $(claude --version)"
    else
        log_info "Installing Claude Code via official installer..."
        curl -fsSL https://claude.ai/install.sh | bash || {
            log_error "Failed to install claude-code"
            exit 1
        }
        log_success "Claude Code installed successfully"
    fi
}

configure_claude_json(){
  node --eval '
      const os = require("os");
      const fs = require("fs");
      const path = require("path");

      const homeDir = os.homedir();
      const filePath = path.join(homeDir, ".claude.json");
      if (fs.existsSync(filePath)) {
          const content = JSON.parse(fs.readFileSync(filePath, "utf-8"));
          fs.writeFileSync(filePath, JSON.stringify({ ...content, hasCompletedOnboarding: true }, null, 2), "utf-8");
      } else {
          fs.writeFileSync(filePath, JSON.stringify({ hasCompletedOnboarding: true }, null, 2), "utf-8");
      }'
}

# ========================
#     API Key 配置
# ========================

configure_claude() {
    log_info "Configuring Claude Code..."
    echo "   You can get your API key from: $API_KEY_URL"
    read -s -p "🔑 Please enter your ZHIPU API key: " api_key
    echo

    if [ -z "$api_key" ]; then
        log_error "API key cannot be empty. Please run the script again."
        exit 1
    fi

    ensure_dir_exists "$CONFIG_DIR"

    # 写入配置文件
    node --eval '
        const os = require("os");
        const fs = require("fs");
        const path = require("path");

        const homeDir = os.homedir();
        const filePath = path.join(homeDir, ".claude", "settings.json");
        const apiKey = "'"$api_key"'";

        const content = fs.existsSync(filePath)
            ? JSON.parse(fs.readFileSync(filePath, "utf-8"))
            : {};

        fs.writeFileSync(filePath, JSON.stringify({
            ...content,
            env: {
                ANTHROPIC_AUTH_TOKEN: apiKey,
                ANTHROPIC_BASE_URL: "'"$API_BASE_URL"'",
                API_TIMEOUT_MS: "'"$API_TIMEOUT_MS"'",
                CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC: 1
            }
        }, null, 2), "utf-8");
    ' || {
        log_error "Failed to write settings.json"
        exit 1
    }

    log_success "Claude Code configured successfully"
}

# ========================
#     检查 Claude Code
# ========================

check_claude() {
    if ! command -v claude &>/dev/null; then
        log_error "Claude Code is not installed. Please run: $SCRIPT_NAME"
        exit 1
    fi
    log_success "Claude Code found: $(claude --version)"
}

# ========================
#     Marketplace 配置
# ========================

add_marketplace() {
    log_info "Adding VoltAgent marketplace..."
    if claude /plugin marketplace add "$MARKETPLACE_REPO"; then
        log_success "Marketplace added: $MARKETPLACE_REPO"
    else
        log_error "Failed to add marketplace: $MARKETPLACE_REPO"
    fi
    echo ""
}

# ========================
#     插件安装
# ========================

install_plugins() {
    log_info "Installing Claude Code plugins..."
    echo ""

    for plugin in "${PLUGINS_TO_INSTALL[@]}"; do
        log_info "Installing plugin: $plugin..."
        if claude /plugin "$plugin"; then
            log_success "Plugin installed: $plugin"
        else
            log_error "Failed to install plugin: $plugin"
        fi
        echo ""
    done

    log_success "Plugin installation completed"
}

# ========================
#     Hooks 安装
# ========================

install_hooks() {
    log_info "Installing Claude Code Hooks..."
    echo ""

    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local hooks_script="$script_dir/setup-hooks.sh"

    if [ ! -f "$hooks_script" ]; then
        log_error "Hooks script not found: $hooks_script"
        return 1
    fi

    if bash "$hooks_script"; then
        log_success "Hooks installed successfully"
        echo ""
        echo "📋 Installed Hooks:"
        echo "   - Stop Hook (智能停止决策)"
        echo "   - Logging Hook (命令日志记录)"
        echo "   - SubagentStop Hook (子智能体循环)"
        echo ""
        echo "📖 查看详细文档: cat $script_dir/HOOKS.md"
    else
        log_error "Failed to install hooks"
    fi
}

# ========================
#        主流程
# ========================

main() {
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --plugins)
                MODE="plugins-only"
                shift
                ;;
            --hooks)
                INSTALL_HOOKS=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    echo "🚀 $SCRIPT_NAME (mode: $MODE)"
    echo ""

    if [ "$MODE" = "plugins-only" ]; then
        # 仅安装插件模式
        check_claude
        add_marketplace
        install_plugins

        echo ""
        echo "📦 Installed plugins:"
        for plugin in "${PLUGINS_TO_INSTALL[@]}"; do
            echo "   - $plugin"
        done
        echo ""
        echo "🛒 Marketplace: $MARKETPLACE_REPO"
        echo ""

        # 安装 Hooks（如果指定）
        if [ "$INSTALL_HOOKS" = true ]; then
            install_hooks
        fi

        echo "⚠️  Please restart Claude Code to load the new plugins."
    else
        # 完整安装模式
        check_nodejs
        install_claude_code
        configure_claude_json
        configure_claude
        add_marketplace
        install_plugins

        # 安装 Hooks（如果指定）
        if [ "$INSTALL_HOOKS" = true ]; then
            install_hooks
        fi

        echo ""
        log_success "🎉 Installation completed successfully!"
        echo ""
        echo "🚀 You can now start using Claude Code with:"
        echo "   claude"
        echo ""
        echo "📦 Installed plugins:"
        for plugin in "${PLUGINS_TO_INSTALL[@]}"; do
            echo "   - $plugin"
        done
        echo ""
        echo "🛒 Marketplace: $MARKETPLACE_REPO"

        if [ "$INSTALL_HOOKS" = true ]; then
            echo ""
            echo "🪝 Hooks: Installed (智能停止决策、命令日志记录、子智能体循环)"
        fi
    fi
}

main "$@"
