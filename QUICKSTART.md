# Claude Code Hooks 快速开始指南

本指南帮助你快速在本机配置 Claude Code 的智能 Hooks 功能。

## 🎯 三步快速安装

### 第一步：确保依赖已安装

```bash
# 检查 jq 是否已安装
jq --version

# 如果未安装，执行以下命令：
# Ubuntu/Debian
sudo apt-get install jq

# macOS
brew install jq

# 检查 Claude Code 是否已安装
claude --version
```

### 第二步：安装 Hooks

```bash
# 进入项目目录
cd /home/test/lyq/claude-config

# 运行 hooks 安装脚本
bash setup-hooks.sh
```

你会看到类似输出：
```
🪝 Claude Code Hooks 配置脚本

🔹 Backing up existing settings to: ~/.claude/settings.json.backup.20250127_143015
✅ Backup created
🔹 Installing Stop Hook (智能停止决策)...
✅ Stop Hook installed successfully
🔹 Installing Logging Hook (命令日志记录)...
✅ Logging Hook installed successfully
🔹 Logs will be saved to: ~/.claude/logs/bash-commands.log
🔹 Installing SubagentStop Hook (子智能体循环)...
✅ SubagentStop Hook installed successfully

✅ 🎉 Hooks 配置完成！
```

### 第三步：重启 Claude Code

```bash
# 退出当前会话（如果有）
# 然后重新启动
claude
```

## ✅ 验证安装

### 验证配置文件

```bash
# 查看 hooks 配置
cat ~/.claude/settings.json | jq '.hooks'
```

你应该看到类似的输出：
```json
{
  "Stop": [
    {
      "matcher": "",
      "hooks": [
        {
          "type": "prompt",
          "prompt": "You are a task completion evaluator...",
          "timeout": 30
        }
      ]
    }
  ],
  "PreToolUse": [
    {
      "matcher": "Bash",
      "hooks": [
        {
          "type": "command",
          "command": "jq -r ... >> ~/.claude/logs/bash-commands.log; exit 0"
        }
      ]
    }
  ],
  "SubagentStop": [
    {
      "matcher": "",
      "hooks": [
        {
          "type": "prompt",
          "prompt": "You are evaluating whether a subagent should stop...",
          "timeout": 30
        }
      ]
    }
  ]
}
```

### 测试 Hooks 功能

#### 测试 Stop Hook（智能停止决策）

启动 Claude Code 并给它一个任务：

```
user: 创建一个 test.txt 文件，写入 "Hello Hooks"，然后显示文件内容
```

观察 Claude 的行为，它会更加谨慎地判断任务是否完成，不会过早停止。

#### 测试 Logging Hook（命令日志）

执行几个命令后，查看日志：

```bash
# 查看最近的命令日志
tail -n 20 ~/.claude/logs/bash-commands.log

# 实时监控日志
tail -f ~/.claude/logs/bash-commands.log
```

你应该看到类似的输出：
```
[2025-01-27 14:35:22] ls -la | 列出当前目录文件
[2025-01-27 14:35:30] cat test.txt | 显示文件内容
```

#### 测试 SubagentStop Hook（子智能体循环）

让 Claude 使用子智能体执行任务：

```
user: 使用 explore agent 查找项目中所有的 .sh 脚本文件
```

SubagentStop Hook 会确保子智能体彻底完成探索任务。

## 🛠️ 常用命令

```bash
# 查看命令日志
tail -f ~/.claude/logs/bash-commands.log

# 搜索特定命令
grep "git" ~/.claude/logs/bash-commands.log

# 查看 hooks 配置
cat ~/.claude/settings.json | jq '.hooks'

# 清空日志
> ~/.claude/logs/bash-commands.log

# 恢复默认配置（移除 hooks）
cp ~/.claude/settings.json.backup.* ~/.claude/settings.json
```

## 📚 进一步学习

- 查看完整文档: `cat HOOKS.md`
- 了解所有配置选项: `bash setup-hooks.sh --help`
- 查看主安装脚本: `bash setup-claude-code.sh --help`

## 🐛 常见问题

### Q: 安装后没有生效？
**A:** 确保已重启 Claude Code

### Q: 日志文件找不到？
**A:** 检查目录是否存在: `ls -la ~/.claude/logs/`

### Q: 想要禁用某个 hook？
**A:** 编辑 `~/.claude/settings.json`，删除对应的 hook 配置

### Q: 如何卸载 hooks？
**A:** 恢复备份文件:
```bash
ls ~/.claude/settings.json.backup.*
cp ~/.claude/settings.json.backup.XXXXXXXX_XXXXXX ~/.claude/settings.json
```

## 🔄 更新配置

如果你修改了 hooks 脚本，重新运行安装：

```bash
bash setup-hooks.sh
```

脚本会自动备份现有配置并应用新配置。

## 💡 提示

- Stop Hook 使用 LLM 判断，可能会增加少量响应时间（约 1-3 秒）
- 日志文件会随时间增长，建议定期清理
- 你可以自定义 hooks 的 prompt 来调整判断逻辑
- 所有 hooks 都是可选的，可以单独安装或移除

## 🎉 完成

现在你的 Claude Code 已经配置了智能 Hooks，享受更智能、更可控的 AI 助手体验！
