# Claude Code Setup Scripts

用于安装和配置 Claude Code 及其插件的脚本。

## 脚本说明

### setup-claude-code.sh
统一的 Claude Code 安装脚本，支持两种运行模式。

**完整安装模式** (推荐新用户使用):
```bash
bash scripts/setup-claude-code.sh
```

包括:
- 检查/安装 Node.js (通过 nvm)
- 安装 Claude Code
- 配置 API (使用智谱 API)
- 添加 VoltAgent Subagents Marketplace
- 安装插件

**仅安装插件模式** (假设 Claude Code 已安装):
```bash
bash scripts/setup-claude-code.sh --plugins
```

**显示帮助信息**:
```bash
bash scripts/setup-claude-code.sh --help
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
