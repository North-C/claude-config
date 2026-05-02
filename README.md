# Claude Code Setup Scripts

用于安装和配置 Claude Code 及其插件的脚本。

## 脚本说明

### setup-claude-code.sh
统一的 Claude Code 安装脚本，支持多种运行模式。

**完整安装模式** (推荐新用户使用):
```bash
bash setup-claude-code.sh
```

包括:
- 检查/安装 Node.js (通过 nvm)
- 安装 Claude Code
- 配置 API (使用智谱 API)
- 添加 VoltAgent Subagents Marketplace
- 安装插件

**仅安装插件模式** (假设 Claude Code 已安装):
```bash
bash setup-claude-code.sh --plugins
```

**同时安装 Hooks**:
```bash
bash setup-claude-code.sh --hooks              # 完整安装 + Hooks
bash setup-claude-code.sh --plugins --hooks    # 仅安装插件 + Hooks
```

**显示帮助信息**:
```bash
bash setup-claude-code.sh --help
```

## 已配置的插件

- `context7` - 上下文增强
- `code-review` - 代码审查
- `feature-dev` - 功能开发辅助
- `typescript-lsp` - TypeScript 语言支持

## VoltAgent Subagents Marketplace

脚本会自动添加 [VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents) marketplace。

该 marketplace 提供了大量专业 subagents，包括:
- Core Development (api-designer, backend-developer, frontend-developer, etc.)
- Language Specialists (python-pro, typescript-pro, rust-engineer, etc.)
- Infrastructure (devops-engineer, kubernetes-specialist, terraform-engineer, etc.)
- Quality & Security (code-reviewer, security-auditor, qa-expert, etc.)
- Data & AI (data-engineer, ml-engineer, llm-architect, etc.)
- And many more...

安装后可通过以下命令浏览和安装 marketplace 中的插件:
```bash
claude /plugin install voltagent-core-dev
claude /plugin install voltagent-lang
claude /plugin install voltagent-infra
```

## 智谱 API

脚本使用智谱 AI 的 API 端点: `https://open.bigmodel.cn/api/anthropic`

API Key 获取地址: https://open.bigmodel.cn/usercenter/proj-mgmt/apikeys

## Zsh 快速切换命令

为了方便在不同 API 提供商之间快速切换，我们提供了 zsh 快速切换工具。

### 安装

将以下内容添加到你的 `~/.zshrc` 文件中:

```bash
# Claude Code API 快速切换
source ~/path/to/claude-config/claude-switcher.zsh
```

> 注意: 请将 `~/path/to/claude-config` 替换为实际的项目路径

然后重新加载配置:
```bash
source ~/.zshrc
```

### 使用方法

**切换到智谱 API:**
```bash
# 交互式输入 API Key
claude-use-zhipu

# 直接提供 API Key
claude-use-zhipu "your-api-key-here"
```

**切换到 Anthropic 官方 API:**
```bash
# 交互式输入 API Key
claude-use-official

# 直接提供 API Key
claude-use-official "your-api-key-here"
```

**切换到自定义 API:**
```bash
# 指定自定义 Base URL 和 API Key
claude-use-custom "https://api.example.com/v1" "your-api-key"
```

**查看当前配置:**
```bash
claude-api-status
```

**列出可用的 API 提供商:**
```bash
claude-api-list
```

**查看帮助信息:**
```bash
claude-switcher-help
```

### 特性

- 🔄 快速切换不同 API 提供商
- 🔑 支持交互式输入或命令行参数提供 API Key
- 📊 查看当前配置状态
- 💾 自动保留现有 API Key（如果不提供新的）
- ⚡ 支持自定义 API 端点

### 注意事项

- 切换 API 后需要重启 Claude Code 才能生效
- 配置文件位置: `~/.claude/settings.json`
- 如果不提供 API Key 参数，工具会尝试保留现有的 Key

## Claude Code Hooks

本项目提供了 Hooks 配置脚本，可为 Claude Code 添加智能停止决策、命令日志记录和子智能体循环功能。

### 什么是 Hooks

Hooks 是 Claude Code 生命周期中特定事件触发时自动执行的自定义 shell 命令或 LLM prompt。它们提供确定性控制，确保特定操作总是执行。

### 快速安装

**安装所有 Hooks:**
```bash
bash setup-hooks.sh
```

**选择性安装:**
```bash
bash setup-hooks.sh --stop       # 仅安装智能停止决策
bash setup-hooks.sh --logging    # 仅安装命令日志记录
bash setup-hooks.sh --subagent   # 仅安装子智能体循环
```

**或在安装 Claude Code 时同时安装:**
```bash
bash setup-claude-code.sh --hooks
```

### Hooks 功能

| Hook 类型 | 功能 | 说明 |
|---------|------|------|
| **智能停止决策** | Stop Hook | 在 Claude 完成响应时，使用 LLM 智能判断是否应该继续工作 |
| **命令日志记录** | PreToolUse Hook | 记录所有执行的 Bash 命令到 `~/.claude/logs/bash-commands.log` |
| **子智能体循环** | SubagentStop Hook | 让子智能体持续工作直到任务完全完成 |

### 使用示例

**查看命令日志:**
```bash
tail -f ~/.claude/logs/bash-commands.log
```

**查看当前 Hooks 配置:**
```bash
cat ~/.claude/settings.json | jq '.hooks'
```

### 详细文档

查看完整的 Hooks 使用指南和配置说明:
```bash
cat HOOKS.md
```

或在线查看: [HOOKS.md](./HOOKS.md)

## Zsh 插件配置

项目中的 `zsh/.zshrc` 配置了以下插件：

| 插件 | 功能 | 快捷操作 |
|------|------|----------|
| **zoxide** | 智能目录跳转（替代 cd） | `z foo` 跳到含 foo 的最常用目录 |
| **fzf** | 模糊搜索文件/目录/历史命令 | `Ctrl+T` 搜文件，`Ctrl+R` 搜历史 |
| **broot** | 交互式目录树浏览器 | `br` 浏览目录，退出自动 cd |

### 安装

```bash
# Fedora
sudo dnf install -y zoxide fzf

# broot（预编译二进制）
curl -L https://github.com/Canop/broot/releases/latest/download/broot_1.56.2.zip -o /tmp/broot.zip
unzip -o /tmp/broot.zip -d /tmp/broot-extract
cp /tmp/broot-extract/x86_64-unknown-linux-gnu/broot ~/.local/bin/broot
chmod +x ~/.local/bin/broot
```

首次运行 `broot` 会提示安装 shell 集成，输入 `:install` 确认即可。

### broot 使用指南

#### 启动方式

| 命令 | 说明 |
|------|------|
| `br` | 打开当前目录 |
| `br /path` | 打开指定目录 |
| `br -f` | 只显示文件夹 |
| `br -g` | 显示 git 状态 |
| `br -d` | 显示文件修改日期 |
| `br --show-root-fs` | 顶部显示磁盘空间 |

#### 界面内操作

| 按键 | 功能 |
|------|------|
| 输入文字 | 模糊搜索过滤 |
| `↑` `↓` | 上下移动 |
| `Enter` | 打开文件/进入目录 |
| `Esc` | 退出（`br` 模式下会 cd 到选中目录） |
| `:q` | 退出 |
| `:cd` | cd 到选中目录 |
| `:e` | 用编辑器打开文件 |
| `:mkdir 名称` | 创建目录 |
| `:rm` | 删除文件 |
| `:cp 目标` | 复制 |

完整文档：https://dystroy.org/broot
