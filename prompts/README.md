# Prompt / Spec / Skill 资产库

日常使用中**经过验证有效**的 Prompt、行为规范（Spec）和 Skill 的沉淀库。
原则：只收验证过的，一条规则配一个来源和日期；宁可少而准，不囤积未消化的内容。

## 目录结构

```
prompts/
├── README.md          # 本文件
├── build.sh           # specs/*.md → base-rules.md（组装，源文件为准）
├── install.sh         # 挂载到 Claude Code 与 Codex（幂等）
├── base-rules.md      # 生成产物 — 全局挂载的 Agent 行为规范（勿手改）
├── specs/             # 行为规范源文件，一场景一文件
├── templates/         # 任务级 prompt 模板，按需复制使用
└── skills/            # skill 源文件，一 skill 一目录
```

## 当前收录

### specs/ — 行为规范（长期挂载，全局生效）

| 文件 | 场景 | 收录日期 |
|------|------|----------|
| `communication.md` | 沟通：中文回答、结论先行、区分事实与推断 | 2026-08-18 |
| `evidence-research.md` | 证据与检索：先搜索验证、一手来源、网页不可信 | 2026-08-18 |
| `local-work.md` | 本地操作：先查真实状态、最小修改、先诊断后修复 | 2026-08-18 |
| `safety.md` | 安全：凭据不外泄、高风险操作先确认 | 2026-08-18 |
| `tools-and-skills.md` | 工具选择：rg 优先、不重复调用 | 2026-08-18 |
| `subagents.md` | 子代理：独立子任务才拆、并行只读、主代理兜底 | 2026-08-18 |

### templates/ 与 skills/

见各自目录下的 README（收录约定与安装路径）。

## 快速开始

```bash
# 修改 specs/ 后重新组装并同步挂载
cd prompts && ./build.sh && ./install.sh
```

### 挂载机制

| 工具 | 方式 | 位置 |
|------|------|------|
| Claude Code | `~/.claude/CLAUDE.md` 中 `@绝对路径` import `base-rules.md`（改完即生效，无需重装） | 全局所有会话 |
| Codex | `install.sh` 将 `base-rules.md` 内容**内联**进 `~/.codex/AGENTS.md` 的标记块（Codex 无 import 机制，所以每次 build 后要重跑 install） | 全局所有会话 |

两个挂载点都用 `<!-- BASE_RULES_START/END -->` 标记块管理，重复运行 `install.sh` 只更新块内内容，不会重复追加。

## 沉淀流程

1. 在日常使用中发现某条 prompt / 规则确实有效（至少在不同任务上验证过两次）
2. 判断类型：
   - **长期行为约束** → 提炼成条目放进 `specs/` 对应文件（新增场景则建新文件，并在 `build.sh` 的 `order` 里登记）
   - **具体任务模板** → `templates/<场景>.md`，文件头注明来源和适用工具
   - **可复用能力** → `skills/<name>/SKILL.md`
3. 文件头注释统一记录：`收录日期 · 状态 · 适用工具`
4. `./build.sh && ./install.sh`，开新会话验证行为符合预期
5. 提交到本仓库

## 维护原则

- 规则失效或被证伪 → 直接删除，不留"仅供参考"的死规则
- spec 只写行为约束，不写任务步骤（那是 templates 的事）
- 每条规则应该能通过观察会话行为验证是否被遵守；验证不了的是空话，删
