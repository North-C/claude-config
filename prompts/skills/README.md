# Skill 沉淀

自研或验证有效的 skill 源文件。**一个 skill 一个目录**：`<name>/SKILL.md`（必要时附带脚本、参考文档等辅助文件）。

## 安装路径

| 工具 | 路径 | 说明 |
|------|------|------|
| Claude Code（全局） | `~/.claude/skills/<name>/SKILL.md` | 所有项目可用 |
| Claude Code（项目） | `<project>/.claude/skills/<name>/SKILL.md` | 仅该项目 |
| Codex | `~/.codex/skills/<name>/SKILL.md` | Codex 原生 skills |
| 跨工具共享 | `~/.agents/skills/<name>/SKILL.md` | npx skills 等工具的共享位置 |

建议：本目录作为源，用符号链接或复制装到上表路径，保证仓库始终是唯一事实来源。

## SKILL.md 格式（Claude Code）

```markdown
---
name: skill-name
description: 一句话说明做什么、什么时候用（触发词写进这里，模型靠它决定是否调用）
---

# Skill 标题

正文：工作流程、步骤、约束、示例。
```

要点：

- `description` 是触发入口——写清楚"什么时候用"，包含典型触发词
- 正文控制在必要长度，能引用外部参考文件就不要全塞进 SKILL.md
- 确定性操作写成脚本放同目录，SKILL.md 里写调用方式

## 收录约定

- 文件头/目录 README 注明：`来源（自研/URL）· 收录日期 · 验证情况`
- 修改过的 skill 注明与上游的差异
