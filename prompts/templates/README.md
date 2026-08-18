# 任务级 Prompt 模板

与 `specs/` 的区别：specs 是**长期挂载**的行为规范；这里是**按需取用**的具体任务提示词——用的时候整段复制进对话，或让 agent 按模板执行。

## 收录约定

- 一文件一场景，英文 kebab-case 命名（如 `release-checklist.md`）
- 文件头注释统一记录：`收录日期 · 状态 · 适用工具 (claude / codex / 通用)`
- 正文即 prompt 本体，保持**可直接复制使用**，不要写成"关于 XX 的说明"
- 模板中的可变部分用 `{{占位符}}` 标出

## 使用方式

- Claude Code：直接粘贴，或存为 `~/.claude/commands/<name>.md` 变成斜杠命令
- Codex：直接粘贴，或存为 `~/.codex/prompts/<name>.md` 变成自定义 `/name` 命令
