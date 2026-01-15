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
