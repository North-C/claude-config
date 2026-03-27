#!/bin/bash

# Claude Code Hooks 配置脚本
# 用途: 配置智能停止决策、命令日志记录和子智能体循环功能
# 使用:
#   bash setup-hooks.sh              # 完整安装所有 hooks
#   bash setup-hooks.sh --stop       # 仅安装智能停止决策 hook
#   bash setup-hooks.sh --logging    # 仅安装命令日志记录 hook
#   bash setup-hooks.sh --subagent   # 仅安装子智能体循环 hook

set -euo pipefail

# ========================
#       常量定义
# ========================
SCRIPT_NAME=$(basename "$0")
CLAUDE_DIR="$HOME/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
LOG_DIR="$CLAUDE_DIR/logs"
LOG_FILE="$LOG_DIR/bash-commands.log"

# 运行模式
INSTALL_ALL=true
INSTALL_STOP=false
INSTALL_LOGGING=false
INSTALL_SUBAGENT=false

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
    cat << 'EOF'
🪝 Claude Code Hooks 配置脚本

使用方法:
  bash setup-hooks.sh              完整安装所有 hooks
  bash setup-hooks.sh --stop       仅安装智能停止决策 hook
  bash setup-hooks.sh --logging    仅安装命令日志记录 hook
  bash setup-hooks.sh --subagent   仅安装子智能体循环 hook
  bash setup-hooks.sh -h, --help   显示此帮助信息

Hooks 功能说明:
  1. 智能停止决策 (Stop Hook)
     - 在 Claude 完成响应时，使用 LLM 智能判断是否应该继续工作
     - 确保所有任务真正完成，避免过早停止

  2. 命令日志记录 (PreToolUse Hook)
     - 记录所有执行的 Bash 命令到日志文件
     - 日志位置: ~/.claude/logs/bash-commands.log

  3. 子智能体循环 (SubagentStop Hook)
     - 让子智能体持续工作直到任务完全完成
     - 自动检测是否需要继续执行

EOF
}

# ========================
#     备份现有配置
# ========================

backup_settings() {
    if [ -f "$SETTINGS_FILE" ]; then
        local backup_file="$SETTINGS_FILE.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backing up existing settings to: $backup_file"
        cp "$SETTINGS_FILE" "$backup_file"
        log_success "Backup created"
    fi
}

# ========================
#   读取现有配置
# ========================

read_existing_settings() {
    if [ -f "$SETTINGS_FILE" ]; then
        cat "$SETTINGS_FILE"
    else
        echo '{}'
    fi
}

# ========================
#   安装 Stop Hook
# ========================

install_stop_hook() {
    log_info "Installing Stop Hook (智能停止决策)..."

    local stop_hook_config=$(cat <<'EOF'
{
  "hooks": [
    {
      "type": "prompt",
      "prompt": "You are a task completion evaluator. Your job is to determine if Claude should stop working or continue.\n\nAnalyze the recent conversation and determine if:\n1. All user-requested tasks are complete\n2. There are any errors that need to be addressed\n3. Any follow-up work is necessary\n4. The code is in a working state\n\nRespond with JSON only:\n- {\"ok\": true} to allow Claude to stop (all tasks complete)\n- {\"ok\": false, \"reason\": \"具体原因\"} to force Claude to continue working\n\nExamples:\n- If tests are failing: {\"ok\": false, \"reason\": \"Tests are still failing and need to be fixed\"}\n- If code compiles with errors: {\"ok\": false, \"reason\": \"Build has errors that must be resolved\"}\n- If all tasks done: {\"ok\": true}",
      "timeout": 30
    }
  ]
}
EOF
)

    # 使用 jq 合并配置
    local current_settings=$(read_existing_settings)
    local updated_settings=$(echo "$current_settings" | jq --argjson hook "$stop_hook_config" \
        '.hooks.Stop = [{"matcher": "", "hooks": $hook.hooks}]')

    echo "$updated_settings" | jq '.' > "$SETTINGS_FILE"
    log_success "Stop Hook installed successfully"
}

# ========================
#   安装 Logging Hook
# ========================

install_logging_hook() {
    log_info "Installing Logging Hook (命令日志记录)..."

    # 确保日志目录存在
    ensure_dir_exists "$LOG_DIR"

    # 创建日志文件
    touch "$LOG_FILE"

    local logging_hook_config=$(cat <<EOF
{
  "hooks": [
    {
      "type": "command",
      "command": "jq -r '.tool_input | \"[\" + (now | strftime(\"%Y-%m-%d %H:%M:%S\")) + \"] \" + (.command // \"N/A\") + \" | \" + (.description // \"No description\")' >> $LOG_FILE; exit 0"
    }
  ]
}
EOF
)

    # 使用 jq 合并配置
    local current_settings=$(read_existing_settings)
    local updated_settings=$(echo "$current_settings" | jq --argjson hook "$logging_hook_config" \
        '.hooks.PreToolUse = (.hooks.PreToolUse // []) + [{"matcher": "Bash", "hooks": $hook.hooks}]')

    echo "$updated_settings" | jq '.' > "$SETTINGS_FILE"
    log_success "Logging Hook installed successfully"
    log_info "Logs will be saved to: $LOG_FILE"
}

# ========================
#   安装 SubagentStop Hook
# ========================

install_subagent_hook() {
    log_info "Installing SubagentStop Hook (子智能体循环)..."

    local subagent_hook_config=$(cat <<'EOF'
{
  "hooks": [
    {
      "type": "prompt",
      "prompt": "You are evaluating whether a subagent should stop or continue working.\n\nAnalyze the subagent's work and determine if:\n1. The assigned task is fully complete\n2. There are any errors or issues that need fixing\n3. Any edge cases were missed\n4. The implementation meets all requirements\n\nRespond with JSON only:\n- {\"ok\": true} to allow the subagent to stop (task complete)\n- {\"ok\": false, \"reason\": \"具体原因\"} to force the subagent to continue\n\nBe thorough - if there's ANY doubt, choose to continue working.\n\nExamples:\n- If implementation incomplete: {\"ok\": false, \"reason\": \"需要添加错误处理\"}\n- If tests missing: {\"ok\": false, \"reason\": \"需要编写单元测试\"}\n- If all done: {\"ok\": true}",
      "timeout": 30
    }
  ]
}
EOF
)

    # 使用 jq 合并配置
    local current_settings=$(read_existing_settings)
    local updated_settings=$(echo "$current_settings" | jq --argjson hook "$subagent_hook_config" \
        '.hooks.SubagentStop = [{"matcher": "", "hooks": $hook.hooks}]')

    echo "$updated_settings" | jq '.' > "$SETTINGS_FILE"
    log_success "SubagentStop Hook installed successfully"
}

# ========================
#   检查依赖
# ========================

check_dependencies() {
    # 检查 jq
    if ! command -v jq &>/dev/null; then
        log_error "jq is not installed. Please install it first:"
        echo "  Ubuntu/Debian: sudo apt-get install jq"
        echo "  macOS: brew install jq"
        exit 1
    fi

    # 检查 Claude Code
    if ! command -v claude &>/dev/null; then
        log_error "Claude Code is not installed. Please run setup-claude-code.sh first."
        exit 1
    fi
}

# ========================
#   显示配置信息
# ========================

show_config_info() {
    echo ""
    log_success "🎉 Hooks 配置完成！"
    echo ""
    echo "📋 已安装的 Hooks:"

    if [ "$INSTALL_ALL" = true ] || [ "$INSTALL_STOP" = true ]; then
        echo "  ✓ Stop Hook - 智能停止决策"
    fi

    if [ "$INSTALL_ALL" = true ] || [ "$INSTALL_LOGGING" = true ]; then
        echo "  ✓ Logging Hook - 命令日志记录"
        echo "    日志位置: $LOG_FILE"
    fi

    if [ "$INSTALL_ALL" = true ] || [ "$INSTALL_SUBAGENT" = true ]; then
        echo "  ✓ SubagentStop Hook - 子智能体循环"
    fi

    echo ""
    echo "📝 配置文件位置: $SETTINGS_FILE"
    echo ""
    echo "⚠️  请重启 Claude Code 以使配置生效"
    echo ""
    echo "🔍 查看当前配置:"
    echo "   cat $SETTINGS_FILE | jq '.hooks'"
    echo ""
    echo "📊 查看命令日志:"
    echo "   tail -f $LOG_FILE"
    echo ""
}

# ========================
#        主流程
# ========================

main() {
    # 解析命令行参数
    if [ $# -eq 0 ]; then
        INSTALL_ALL=true
    else
        INSTALL_ALL=false
        while [[ $# -gt 0 ]]; do
            case $1 in
                --stop)
                    INSTALL_STOP=true
                    shift
                    ;;
                --logging)
                    INSTALL_LOGGING=true
                    shift
                    ;;
                --subagent)
                    INSTALL_SUBAGENT=true
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
    fi

    echo "🪝 Claude Code Hooks 配置脚本"
    echo ""

    # 检查依赖
    check_dependencies

    # 确保目录存在
    ensure_dir_exists "$CLAUDE_DIR"

    # 备份现有配置
    backup_settings

    # 安装 hooks
    if [ "$INSTALL_ALL" = true ] || [ "$INSTALL_STOP" = true ]; then
        install_stop_hook
    fi

    if [ "$INSTALL_ALL" = true ] || [ "$INSTALL_LOGGING" = true ]; then
        install_logging_hook
    fi

    if [ "$INSTALL_ALL" = true ] || [ "$INSTALL_SUBAGENT" = true ]; then
        install_subagent_hook
    fi

    # 显示配置信息
    show_config_info
}

main "$@"
