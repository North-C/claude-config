#!/bin/zsh

# Claude Code API 快速切换工具
# 用于在不同的 API 端点之间快速切换

# ========================
#       常量定义
# ========================
CONFIG_DIR="$HOME/.claude"
SETTINGS_FILE="$CONFIG_DIR/settings.json"

# API 配置
ZHIPU_BASE_URL="https://open.bigmodel.cn/api/anthropic"
OFFICIAL_BASE_URL="https://api.anthropic.com/v1"
API_TIMEOUT_MS=3000000

# ========================
#       工具函数
# ========================

# 检查 Claude Code 配置目录
_check_claude_config() {
    if [ ! -d "$CONFIG_DIR" ]; then
        echo "❌ Claude Code 配置目录不存在: $CONFIG_DIR"
        echo "   请先安装 Claude Code"
        return 1
    fi

    if [ ! -f "$SETTINGS_FILE" ]; then
        echo "❌ Claude Code 配置文件不存在: $SETTINGS_FILE"
        echo "   请先运行 Claude Code 进行初始化"
        return 1
    fi
    return 0
}

# 更新 Claude Code 配置
_update_claude_config() {
    local base_url="$1"
    local api_key="$2"

    node --eval "
        const fs = require('fs');
        const path = require('path');

        const filePath = '$SETTINGS_FILE';
        const content = fs.existsSync(filePath)
            ? JSON.parse(fs.readFileSync(filePath, 'utf-8'))
            : {};

        content.env = content.env || {};
        content.env.ANTHROPIC_BASE_URL = '$base_url';
        content.env.API_TIMEOUT_MS = '$API_TIMEOUT_MS';
        content.env.CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = 1;

        if ('$api_key') {
            content.env.ANTHROPIC_AUTH_TOKEN = '$api_key';
        }

        fs.writeFileSync(filePath, JSON.stringify(content, null, 2), 'utf-8');
    " 2>/dev/null

    if [ $? -eq 0 ]; then
        return 0
    else
        echo "❌ 配置更新失败"
        return 1
    fi
}

# 获取当前配置
_get_current_config() {
    if [ ! -f "$SETTINGS_FILE" ]; then
        echo "未配置"
        return
    fi

    node --eval "
        const fs = require('fs');
        const filePath = '$SETTINGS_FILE';

        if (!fs.existsSync(filePath)) {
            console.log('未配置');
            process.exit(0);
        }

        const content = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
        const baseUrl = content?.env?.ANTHROPIC_BASE_URL || '未设置';
        const hasKey = content?.env?.ANTHROPIC_AUTH_TOKEN ? '已配置' : '未配置';

        console.log('Base URL: ' + baseUrl);
        console.log('API Key: ' + hasKey);
    " 2>/dev/null
}

# ========================
#       切换命令
# ========================

# 切换到智谱 API
claude-use-zhipu() {
    echo "🔄 切换到智谱 API..."

    if ! _check_claude_config; then
        return 1
    fi

    local api_key=""
    if [ -n "$1" ]; then
        api_key="$1"
    else
        # 尝试从现有配置读取 API Key
        api_key=$(node --eval "
            const fs = require('fs');
            const filePath = '$SETTINGS_FILE';
            if (fs.existsSync(filePath)) {
                const content = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
                console.log(content?.env?.ANTHROPIC_AUTH_TOKEN || '');
            }
        " 2>/dev/null)

        if [ -z "$api_key" ]; then
            echo ""
            echo "📌 获取 API Key: https://open.bigmodel.cn/usercenter/proj-mgmt/apikeys"
            read "api_key?🔑 请输入智谱 API Key (留空跳过): "
        fi
    fi

    if _update_claude_config "$ZHIPU_BASE_URL" "$api_key"; then
        echo "✅ 已切换到智谱 API"
        echo "   Base URL: $ZHIPU_BASE_URL"
        [ -n "$api_key" ] && echo "   API Key: 已更新"
        echo ""
        echo "⚠️  请重启 Claude Code 以使配置生效"
    fi
}

# 切换到官方 API
claude-use-official() {
    echo "🔄 切换到 Anthropic 官方 API..."

    if ! _check_claude_config; then
        return 1
    fi

    local api_key=""
    if [ -n "$1" ]; then
        api_key="$1"
    else
        # 尝试从现有配置读取 API Key
        api_key=$(node --eval "
            const fs = require('fs');
            const filePath = '$SETTINGS_FILE';
            if (fs.existsSync(filePath)) {
                const content = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
                console.log(content?.env?.ANTHROPIC_AUTH_TOKEN || '');
            }
        " 2>/dev/null)

        if [ -z "$api_key" ]; then
            echo ""
            echo "📌 获取 API Key: https://console.anthropic.com/settings/keys"
            read "api_key?🔑 请输入 Anthropic API Key (留空跳过): "
        fi
    fi

    if _update_claude_config "$OFFICIAL_BASE_URL" "$api_key"; then
        echo "✅ 已切换到官方 API"
        echo "   Base URL: $OFFICIAL_BASE_URL"
        [ -n "$api_key" ] && echo "   API Key: 已更新"
        echo ""
        echo "⚠️  请重启 Claude Code 以使配置生效"
    fi
}

# 切换到自定义 API
claude-use-custom() {
    echo "🔄 切换到自定义 API..."

    if ! _check_claude_config; then
        return 1
    fi

    local base_url="$1"
    local api_key="$2"

    if [ -z "$base_url" ]; then
        echo ""
        read "base_url?🌐 请输入 API Base URL: "
    fi

    if [ -z "$base_url" ]; then
        echo "❌ Base URL 不能为空"
        return 1
    fi

    if [ -z "$api_key" ]; then
        read "api_key?🔑 请输入 API Key (留空跳过): "
    fi

    if _update_claude_config "$base_url" "$api_key"; then
        echo "✅ 已切换到自定义 API"
        echo "   Base URL: $base_url"
        [ -n "$api_key" ] && echo "   API Key: 已更新"
        echo ""
        echo "⚠️  请重启 Claude Code 以使配置生效"
    fi
}

# 查看当前 API 配置
claude-api-status() {
    echo "📊 Claude Code API 配置状态"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if ! _check_claude_config; then
        return 1
    fi

    _get_current_config
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# 列出可用的 API 提供商
claude-api-list() {
    cat << 'EOF'
📋 可用的 API 提供商

1. 智谱 API (推荐国内用户)
   命令: claude-use-zhipu [API_KEY]
   Base URL: https://open.bigmodel.cn/api/anthropic
   获取 Key: https://open.bigmodel.cn/usercenter/proj-mgmt/apikeys
   特点: 国内访问稳定，价格实惠

2. Anthropic 官方 API
   命令: claude-use-official [API_KEY]
   Base URL: https://api.anthropic.com/v1
   获取 Key: https://console.anthropic.com/settings/keys
   特点: 官方服务，功能最新

3. 自定义 API
   命令: claude-use-custom <BASE_URL> [API_KEY]
   特点: 支持第三方兼容服务

查看当前配置: claude-api-status

EOF
}

# ========================
#       帮助信息
# ========================

claude-switcher-help() {
    cat << 'EOF'
🚀 Claude Code API 快速切换工具

使用方法:

  claude-use-zhipu [API_KEY]       切换到智谱 API
  claude-use-official [API_KEY]    切换到 Anthropic 官方 API
  claude-use-custom <URL> [KEY]    切换到自定义 API

  claude-api-status                查看当前 API 配置
  claude-api-list                  列出可用的 API 提供商
  claude-switcher-help             显示此帮助信息

示例:

  # 切换到智谱 API（交互式输入 API Key）
  claude-use-zhipu

  # 切换到智谱 API（直接提供 API Key）
  claude-use-zhipu "your-api-key-here"

  # 切换到官方 API
  claude-use-official

  # 切换到自定义 API
  claude-use-custom "https://api.example.com/v1" "your-api-key"

  # 查看当前配置
  claude-api-status

注意:
  • 切换 API 后需要重启 Claude Code
  • 如果不提供 API Key，会尝试保留现有的 Key
  • 配置文件位置: ~/.claude/settings.json

EOF
}

# ========================
#       自动补全
# ========================

# 为命令添加自动补全
if [ -n "$ZSH_VERSION" ] && (( $+functions[compdef] )); then
    # zsh 补全
    compdef _gnu_generic claude-use-zhipu
    compdef _gnu_generic claude-use-official
    compdef _gnu_generic claude-use-custom
fi
