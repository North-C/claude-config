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
OFFICIAL_BASE_URL="https://api.anthropic.com"
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
    local provider="$3"
    local force_login_method="${4:-}"

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
        } else {
            // 如果没有提供 API Key，则删除之前的 token（用于切换到账户登录方式）
            delete content.env.ANTHROPIC_AUTH_TOKEN;
        }

        // 如果指定了登录方式，则设置
        if ('$force_login_method') {
            content.forceLoginMethod = '$force_login_method';
        } else {
            // 否则删除之前的登录方式限制
            delete content.forceLoginMethod;
        }

        // 保存提供商信息和 API Key
        content.claudeSwitcher = content.claudeSwitcher || {};
        content.claudeSwitcher.currentProvider = '$provider';
        content.claudeSwitcher.apiKeys = content.claudeSwitcher.apiKeys || {};
        if ('$api_key') {
            content.claudeSwitcher.apiKeys['$provider'] = '$api_key';
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
        const currentProvider = content?.claudeSwitcher?.currentProvider || '未设置';
        const loginMethod = content?.forceLoginMethod || '未限制';

        console.log('当前提供商: ' + currentProvider);
        console.log('Base URL: ' + baseUrl);
        console.log('登录方式: ' + loginMethod);
        console.log('API Key: ' + hasKey);

        // 显示已保存的 API Keys
        const apiKeys = content?.claudeSwitcher?.apiKeys || {};
        const savedProviders = Object.keys(apiKeys);
        if (savedProviders.length > 0) {
            console.log('');
            console.log('已保存的 API Keys:');
            savedProviders.forEach(provider => {
                const key = apiKeys[provider];
                const maskedKey = key.substring(0, 8) + '...' + key.substring(key.length - 4);
                const isCurrent = provider === currentProvider ? ' (当前)' : '';
                console.log('  ' + provider + ': ' + maskedKey + isCurrent);
            });
        }
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

    local provider="zhipu"
    local api_key=""

    if [ -n "$1" ]; then
        # 使用命令行参数提供的 API Key
        api_key="$1"
    else
        # 尝试从已保存的 API Keys 中读取
        api_key=$(node --eval "
            const fs = require('fs');
            const filePath = '$SETTINGS_FILE';
            if (fs.existsSync(filePath)) {
                const content = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
                console.log(content?.claudeSwitcher?.apiKeys?.['$provider'] || '');
            }
        " 2>/dev/null)

        if [ -z "$api_key" ]; then
            echo ""
            echo "📌 获取 API Key: https://open.bigmodel.cn/usercenter/proj-mgmt/apikeys"
            read "api_key?🔑 请输入智谱 API Key (留空跳过): "
        else
            echo "📋 找到已保存的 API Key"
        fi
    fi

    if _update_claude_config "$ZHIPU_BASE_URL" "$api_key" "$provider"; then
        echo "✅ 已切换到智谱 API"
        echo "   Base URL: $ZHIPU_BASE_URL"
        [ -n "$api_key" ] && echo "   API Key: 已保存并更新"
        echo ""
        echo "⚠️  请重启 Claude Code 以使配置生效"
    fi
}

# 切换到官方 API（使用 API Key）
claude-use-official() {
    echo "🔄 切换到 Anthropic 官方 API（Console API Key 方式）..."

    if ! _check_claude_config; then
        return 1
    fi

    local provider="official"
    local api_key=""

    if [ -n "$1" ]; then
        # 使用命令行参数提供的 API Key
        api_key="$1"
    else
        # 尝试从已保存的 API Keys 中读取
        api_key=$(node --eval "
            const fs = require('fs');
            const filePath = '$SETTINGS_FILE';
            if (fs.existsSync(filePath)) {
                const content = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
                console.log(content?.claudeSwitcher?.apiKeys?.['$provider'] || '');
            }
        " 2>/dev/null)

        if [ -z "$api_key" ]; then
            echo ""
            echo "📌 获取 API Key: https://console.anthropic.com/settings/keys"
            read "api_key?🔑 请输入 Anthropic API Key (留空跳过): "
        else
            echo "📋 找到已保存的 API Key"
        fi
    fi

    # 使用 console 方式登录
    if _update_claude_config "$OFFICIAL_BASE_URL" "$api_key" "$provider" "console"; then
        echo "✅ 已切换到官方 API（Console API Key 方式）"
        echo "   Base URL: $OFFICIAL_BASE_URL"
        [ -n "$api_key" ] && echo "   API Key: 已保存并更新"
        echo ""
        echo "⚠️  请重启 Claude Code 以使配置生效"
    fi
}

# 切换到官方 API（使用账户登录）
claude-use-official-account() {
    echo "🔄 切换到 Anthropic 官方 API（账户登录方式）..."

    if ! _check_claude_config; then
        return 1
    fi

    local provider="official-account"

    # 不设置 API Key，设置 forceLoginMethod 为 claudeai
    if _update_claude_config "$OFFICIAL_BASE_URL" "" "$provider" "claudeai"; then
        echo "✅ 已切换到官方 API（账户登录方式）"
        echo "   Base URL: $OFFICIAL_BASE_URL"
        echo "   认证方式: Claude.ai 账户登录"
        echo ""
        echo "📌 请在 Claude Code 中运行 /login 命令进行浏览器登录"
        echo "   或访问: https://claude.ai"
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

    # 使用 URL 作为 provider 标识（去除特殊字符）
    local provider=$(echo "$base_url" | sed 's/[^a-zA-Z0-9]/_/g')

    if [ -z "$api_key" ]; then
        # 尝试从已保存的 API Keys 中读取
        api_key=$(node --eval "
            const fs = require('fs');
            const filePath = '$SETTINGS_FILE';
            if (fs.existsSync(filePath)) {
                const content = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
                console.log(content?.claudeSwitcher?.apiKeys?.['$provider'] || '');
            }
        " 2>/dev/null)

        if [ -z "$api_key" ]; then
            read "api_key?🔑 请输入 API Key (留空跳过): "
        else
            echo "📋 找到已保存的 API Key"
        fi
    fi

    if _update_claude_config "$base_url" "$api_key" "$provider"; then
        echo "✅ 已切换到自定义 API"
        echo "   Base URL: $base_url"
        [ -n "$api_key" ] && echo "   API Key: 已保存并更新"
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

2. Anthropic 官方 API (Console API Key)
   命令: claude-use-official [API_KEY]
   Base URL: https://api.anthropic.com
   获取 Key: https://console.anthropic.com/settings/keys
   特点: 官方服务，按使用量计费，适合 API 开发

3. Anthropic 官方 API (账户登录)
   命令: claude-use-official-account
   Base URL: https://api.anthropic.com
   登录方式: 浏览器 OAuth 登录 (/login 命令)
   特点: 适合 Pro/Max 订阅用户，使用订阅额度

4. 自定义 API
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

  claude-use-zhipu [API_KEY]            切换到智谱 API
  claude-use-official [API_KEY]         切换到 Anthropic 官方 API (Console API Key)
  claude-use-official-account           切换到 Anthropic 官方 API (账户登录)
  claude-use-custom <URL> [KEY]         切换到自定义 API

  claude-api-status                     查看当前 API 配置
  claude-api-list                       列出可用的 API 提供商
  claude-switcher-help                  显示此帮助信息

示例:

  # 切换到智谱 API（首次使用或更新 Key）
  claude-use-zhipu "your-zhipu-api-key"

  # 切换到智谱 API（使用已保存的 Key）
  claude-use-zhipu

  # 切换到官方 API（Console API Key 方式）
  claude-use-official "your-official-api-key"

  # 切换到官方 API（账户登录方式，适合 Pro/Max 订阅用户）
  claude-use-official-account

  # 切换到自定义 API
  claude-use-custom "https://api.example.com/v1" "your-api-key"

  # 查看当前配置
  claude-api-status

认证方式说明:

  1. Console API Key 方式 (claude-use-official)
     - 使用 API Key 进行认证
     - 按使用量计费
     - 适合 API 开发和测试
     - 获取 Key: https://console.anthropic.com/settings/keys

  2. 账户登录方式 (claude-use-official-account)
     - 使用浏览器 OAuth 登录
     - 适合 Claude Pro/Max 订阅用户
     - 使用订阅额度
     - 运行 /login 命令进行登录

特性:
  • 为每个 API 提供商分别保存 API Key
  • 切换时自动使用对应的 API Key
  • 首次使用时需要输入 API Key，之后自动复用
  • 可随时提供新的 API Key 来更新
  • 支持官方 API 的两种认证方式

注意:
  • 切换 API 后需要重启 Claude Code
  • 配置文件位置: ~/.claude/settings.json
  • API Keys 安全存储在配置文件中
  • 账户登录方式需要在 Claude Code 中运行 /login 命令

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
