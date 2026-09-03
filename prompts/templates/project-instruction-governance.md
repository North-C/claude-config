<!-- 收录: 2026-09-03 · 状态: 试点 · 适用: codex -->

# Project Instruction Governance

在 `{{TARGET_REPO}}` 的专用干净 worktree 中执行一次项目规则治理，唯一只读试点源为 `{{SOURCE_REPO}}`，远端结果分支为 `{{RESULT_BRANCH}}`。

先完整读取 `prompts/skills/project-instruction-governance/SKILL.md` 及其按任务要求的 references。核验目标 worktree 分支、HEAD、upstream 和 tracked/untracked 状态；任一意外改动或远端分歧都停止，不 reset、clean、stash 或覆盖。源仓库只读：记录 branch/HEAD，分别检查 tracked、staged、untracked 边界，只使用 `git ls-files` 选择 tracked Agent 入口、项目 skill、文档、构建和验证文件；不得打开或引用 untracked 文件。

本轮只处理一个治理问题。configured interest 不能冒充观测证据；历史经验需要当前 tracked 事实复核。候选必须满足 admission policy，能够说明未来任务的触发条件、具体 action delta、唯一 owner、验证方法与过期条件。现有 owner 能覆盖时直接合并语义，不建立并行规则。

按责任选择唯一目的地：全局跨项目约束进入 `prompts/specs/`，按需任务流程进入 `prompts/templates/`，可发现复用能力进入 `prompts/skills/`。每轮最多沉淀一个独立资产。不得修改源仓库、HOME、服务、Orca automation 或其他仓库；不得读取 shell history、凭据、原始 terminal 或未授权 session；不得运行 `prompts/install.sh`。

若修改 spec，运行 `prompts/build.sh` 并包含对应生成文件；若修改 skill，运行可用的 skill validator。始终运行适用检查和 `git diff --check`，检查敏感内容和精确 staged paths。只有产生经过验证的新价值时才提交，并仅推送 `HEAD:{{RESULT_BRANCH}}`；禁止推送 `main`、创建 PR 或发布。没有合格候选时保持目标仓库零改动、零提交、零 push，并给出停止原因。

最终报告源/目标身份、事实/历史/推断边界、候选去重、交付资产或停止原因、验证结果、提交与远端 ref；不得输出私人路径、IP、token 或原始证据。
