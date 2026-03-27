# Claude Code Hooks 使用指南

本文档介绍如何使用本项目提供的 hooks 配置脚本，为 Claude Code 添加智能停止决策、命令日志记录和子智能体循环功能。

## 📋 目录

- [什么是 Hooks](#什么是-hooks)
- [快速开始](#快速开始)
- [功能说明](#功能说明)
- [使用方法](#使用方法)
- [配置细节](#配置细节)
- [常见问题](#常见问题)

## 什么是 Hooks

Hooks 是 Claude Code 生命周期中特定事件触发时自动执行的自定义 shell 命令或 LLM prompt。它们提供确定性控制，确保特定操作总是执行。

### 本项目提供的 Hooks

| Hook 类型 | 事件 | 功能 | 用途 |
|---------|------|------|------|
| **智能停止决策** | Stop | 使用 LLM 判断任务是否完成 | 确保 Claude 不会过早停止工作，所有任务真正完成 |
| **命令日志记录** | PreToolUse | 记录所有 Bash 命令 | 追踪和审计所有执行的命令，便于问题排查 |
| **子智能体循环** | SubagentStop | 判断子智能体是否应继续 | 让子智能体持续工作直到任务完全完成 |

## 快速开始

### 前置要求

1. 已安装 Claude Code（可使用本项目的 `setup-claude-code.sh` 安装）
2. 已安装 `jq` 命令行工具
   ```bash
   # Ubuntu/Debian
   sudo apt-get install jq

   # macOS
   brew install jq
   ```

### 一键安装所有 Hooks

```bash
bash setup-hooks.sh
```

安装完成后，**重启 Claude Code** 以使配置生效。

### 选择性安装

如果只想安装特定的 hook：

```bash
# 仅安装智能停止决策
bash setup-hooks.sh --stop

# 仅安装命令日志记录
bash setup-hooks.sh --logging

# 仅安装子智能体循环
bash setup-hooks.sh --subagent
```

## 功能说明

### 1. 智能停止决策 (Stop Hook)

**作用：** 在 Claude 完成响应准备停止时，使用 LLM 智能判断是否真的应该停止，还是需要继续工作。

**适用场景：**
- 确保测试全部通过后才停止
- 确保构建没有错误
- 确保所有用户要求的任务都已完成
- 防止遗漏错误处理或边缘情况

**工作原理：**
```
Claude 完成任务 → Stop Hook 触发 → LLM 分析对话历史
                                    ↓
                                评估任务完成度
                                    ↓
                    ┌───────────────┴───────────────┐
                    ↓                               ↓
            返回 {"ok": true}                返回 {"ok": false, "reason": "..."}
                    ↓                               ↓
              允许 Claude 停止                 强制 Claude 继续工作
```

**示例输出：**
```json
// 允许停止 - 所有任务完成
{"ok": true}

// 强制继续 - 测试失败
{"ok": false, "reason": "Tests are still failing and need to be fixed"}

// 强制继续 - 构建错误
{"ok": false, "reason": "Build has errors that must be resolved"}
```

### 2. 命令日志记录 (Logging Hook)

**作用：** 自动记录所有 Claude 执行的 Bash 命令到日志文件，包含时间戳和命令描述。

**日志位置：** `~/.claude/logs/bash-commands.log`

**日志格式：**
```
[2025-01-27 14:30:15] npm test | 运行项目测试
[2025-01-27 14:30:45] git status | 查看工作区状态
[2025-01-27 14:31:02] npm run build | 构建项目
```

**查看日志：**
```bash
# 查看所有日志
cat ~/.claude/logs/bash-commands.log

# 实时查看新日志
tail -f ~/.claude/logs/bash-commands.log

# 查看最近 20 条
tail -n 20 ~/.claude/logs/bash-commands.log

# 搜索特定命令
grep "git" ~/.claude/logs/bash-commands.log
```

**适用场景：**
- 审计 Claude 执行的所有命令
- 问题排查和调试
- 了解 Claude 的工作流程
- 安全审查

### 3. 子智能体循环 (SubagentStop Hook)

**作用：** 当使用子智能体（subagent）执行任务时，在子智能体准备停止时进行智能判断，确保任务完全完成。

**与 Stop Hook 的区别：**
- Stop Hook：作用于主 Claude 会话
- SubagentStop Hook：作用于子智能体（通过 Task 工具调用）

**工作原理：**
```
子智能体完成任务 → SubagentStop Hook 触发 → LLM 分析子智能体工作
                                              ↓
                                        评估任务完成度
                                              ↓
                              ┌───────────────┴───────────────┐
                              ↓                               ↓
                      返回 {"ok": true}                返回 {"ok": false, "reason": "..."}
                              ↓                               ↓
                    允许子智能体停止                   强制子智能体继续工作
```

**适用场景：**
- 确保子智能体完成了分配的所有任务
- 检查是否遗漏了错误处理
- 验证是否需要编写测试
- 确保边缘情况都被考虑

## 使用方法

### 完整安装流程

1. **克隆或下载本项目**
   ```bash
   git clone <your-repo-url>
   cd claude-config
   ```

2. **运行 hooks 配置脚本**
   ```bash
   bash setup-hooks.sh
   ```

3. **查看配置**
   ```bash
   cat ~/.claude/settings.json | jq '.hooks'
   ```

4. **重启 Claude Code**
   ```bash
   # 退出当前 Claude Code 会话，然后重新启动
   claude
   ```

### 验证 Hooks 是否生效

#### 验证 Stop Hook

启动 Claude Code 并给它一个简单任务：

```
用户: 创建一个 hello.txt 文件，写入 "Hello World"
```

Claude 完成后，Stop Hook 会自动判断任务是否完成。你会看到 Claude 更加谨慎，确保任务真正完成才停止。

#### 验证 Logging Hook

执行一些 bash 命令后，查看日志：

```bash
tail ~/.claude/logs/bash-commands.log
```

你应该能看到所有执行的命令及其时间戳。

#### 验证 SubagentStop Hook

使用 Task 工具调用子智能体：

```
用户: 使用 explore agent 查找项目中的配置文件
```

SubagentStop Hook 会确保子智能体完整完成探索任务。

## 配置细节

### 配置文件位置

Hooks 配置保存在 `~/.claude/settings.json` 中。你可以直接编辑此文件进行自定义。

### Stop Hook 配置

```json
{
  "hooks": {
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
    ]
  }
}
```

**可自定义参数：**
- `timeout`: 评估超时时间（秒），默认 30 秒
- `prompt`: LLM 评估 prompt，可根据需要修改判断逻辑

### Logging Hook 配置

```json
{
  "hooks": {
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
    ]
  }
}
```

**可自定义参数：**
- 日志文件路径：修改脚本中的 `LOG_FILE` 变量
- 日志格式：修改 `jq` 命令的输出格式

### SubagentStop Hook 配置

```json
{
  "hooks": {
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
}
```

**可自定义参数：**
- `timeout`: 评估超时时间（秒）
- `prompt`: 子智能体评估逻辑

## 常见问题

### Q1: 安装后没有生效怎么办？

**A:** 确保：
1. 已重启 Claude Code
2. 配置文件正确写入：`cat ~/.claude/settings.json | jq '.hooks'`
3. jq 工具已正确安装：`jq --version`
4. 使用 `claude --debug` 模式查看详细日志

### Q2: 如何禁用某个 Hook？

**A:** 编辑 `~/.claude/settings.json`，删除对应的 hook 配置，或者将整个 hooks 对象改为：

```json
{
  "hooks": {}
}
```

### Q3: Stop Hook 太严格了，总是让 Claude 继续工作怎么办？

**A:** 修改 Stop Hook 的 prompt，让判断更宽松。编辑 `~/.claude/settings.json`：

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Determine if the main tasks are complete. Allow stopping if major work is done, even if minor improvements could be made. Respond with JSON: {\"ok\": true} to stop, {\"ok\": false, \"reason\": \"...\"} to continue.",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

### Q4: 日志文件太大怎么办？

**A:** 定期清理或轮转日志：

```bash
# 清空日志
> ~/.claude/logs/bash-commands.log

# 或归档旧日志
mv ~/.claude/logs/bash-commands.log ~/.claude/logs/bash-commands.$(date +%Y%m%d).log
```

### Q5: 如何恢复默认配置？

**A:** 删除 hooks 配置：

```bash
# 备份当前配置
cp ~/.claude/settings.json ~/.claude/settings.json.backup

# 删除 hooks
jq 'del(.hooks)' ~/.claude/settings.json > ~/.claude/settings.tmp.json
mv ~/.claude/settings.tmp.json ~/.claude/settings.json
```

或者使用脚本自动创建的备份文件恢复：

```bash
ls ~/.claude/settings.json.backup.*
cp ~/.claude/settings.json.backup.XXXXXXXX_XXXXXX ~/.claude/settings.json
```

### Q6: 可以自定义 Hook 的评估逻辑吗？

**A:** 可以！直接编辑 `~/.claude/settings.json` 中的 `prompt` 字段，修改 LLM 的评估逻辑。

例如，让 Stop Hook 更关注测试：

```json
{
  "type": "prompt",
  "prompt": "Check if: 1) All tests pass, 2) Code builds successfully. If tests fail or build errors exist, respond: {\"ok\": false, \"reason\": \"Tests/build failed\"}. Otherwise: {\"ok\": true}",
  "timeout": 30
}
```

### Q7: SubagentStop Hook 对哪些 subagent 生效？

**A:** 对所有通过 Task 工具调用的子智能体都生效，包括：
- Explore agent
- Plan agent
- Bash agent
- General-purpose agent
- 用户自定义的 subagent

### Q8: 如何临时禁用 Hooks 进行测试？

**A:** 重命名配置文件：

```bash
# 临时禁用
mv ~/.claude/settings.json ~/.claude/settings.json.disabled

# 恢复
mv ~/.claude/settings.json.disabled ~/.claude/settings.json
```

## 高级用法

### 组合使用多个 Hooks

你可以为同一个事件配置多个 hooks。例如，在 PreToolUse 中同时记录日志和验证命令安全性：

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r ... >> ~/.claude/logs/bash-commands.log; exit 0"
          },
          {
            "type": "command",
            "command": "jq -r '.tool_input.command' | grep -q 'rm -rf' && exit 2 || exit 0"
          }
        ]
      }
    ]
  }
}
```

### 项目级 Hooks

如果想要针对特定项目配置 hooks，在项目根目录创建 `.claude/settings.local.json`：

```bash
mkdir -p .claude
cat > .claude/settings.local.json << 'EOF'
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | { read file; if echo \"$file\" | grep -q '\\.ts$'; then npx prettier --write \"$file\"; fi; }"
          }
        ]
      }
    ]
  }
}
EOF
```

这样可以为项目添加自动格式化功能。

## 相关资源

- [Claude Code 官方文档](https://code.claude.com/docs)
- [Hooks 完整指南](https://code.claude.com/docs/en/hooks-guide.md)
- [Hooks 参考文档](https://code.claude.com/docs/en/hooks.md)
- [本项目 GitHub 仓库](https://github.com/your-repo)

## 贡献

欢迎提交 Issue 和 Pull Request 来改进本项目的 hooks 配置！

## 许可证

本项目采用 MIT 许可证。
