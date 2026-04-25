# Claude Code Skills 使用手册

> **最后更新**: 2026-04-26
> **已安装 Skills/Plugins 总数**: 9

---

## 目录

1. [概述](#概述)
2. [Plugins (Marketplace 安装)](#plugins-marketplace-安装)
   - [deep-research](#1-deep-research)
   - [ppt-creator](#2-ppt-creator)
   - [skill-creator](#3-skill-creator)
3. [Skills (手动安装)](#skills-手动安装)
   - [grok-search](#4-grok-search)
   - [github-skill-forge](#5-github-skill-forge)
   - [find-skills](#6-find-skills)
4. [Global Skills (npx 安装)](#global-skills-npx-安装)
   - [vercel-react-best-practices](#7-vercel-react-best-practices)
   - [using-superpowers](#8-using-superpowers)
   - [pretty-mermaid](#9-pretty-mermaid)
5. [组合使用场景](#组合使用场景)
6. [快速参考卡](#快速参考卡)

---

## 概述

### Skills vs Plugins

| 类型 | 安装方式 | 位置 | 特点 |
|------|----------|------|------|
| **Plugins** | `claude plugin install` | `~/.claude/plugins/cache/` | 官方 marketplace，自动更新 |
| **Skills** | 手动克隆/复制 | `~/.claude/skills/` | 灵活定制，适合私有工具 |
| **Global Skills** | `npx skills add -g` | `~/.agents/skills/` | 跨 Agent 共享 |

### 当前已安装汇总

```
~/.claude/
├── plugins/cache/daymade-skills/
│   ├── deep-research      # 深度研究报告
│   ├── ppt-creator        # 演示文稿创建
│   └── skill-creator      # 创建自定义技能
├── skills/
│   ├── grok-search        # ⚠️ 已弃用，请使用 MCP Server
│   ├── github-skill-forge # GitHub 仓库转技能
│   └── find-skills        # 发现/安装技能
└── ~/.agents/skills/
    ├── vercel-react-best-practices  # React 最佳实践
    ├── using-superpowers            # 技能使用指南（元技能）
    └── pretty-mermaid               # Mermaid 图表美化渲染
```

---

## Plugins (Marketplace 安装)

---

### 1. deep-research

#### 来源
- **Marketplace**: `daymade-skills`
- **仓库**: https://github.com/daymade/claude-code-skills

#### 用途与支持场景

| 场景 | 描述 |
|------|------|
| 研究报告 | 生成带引用的深度研究报告 |
| 文献综述 | 学术或技术文献分析 |
| 市场分析 | 行业趋势、竞争格局分析 |
| 技术简报 | 政策或技术文档撰写 |
| 模板报告 | 需要严格格式控制的报告 |

#### 核心特性

- **格式控制**: 严格的报告模板和章节格式
- **证据追踪**: 每个声明都有引用来源
- **多轮起草**: 并行 subagent 生成多版本，UNION 合并
- **引用验证**: 自动检查孤儿声明和冲突数据
- **Grok 集成**: 支持实时信息搜索（已集成）

#### 使用方法

**自动触发**:
```
"请帮我生成一份关于 AI 编程工具发展趋势的研究报告"
"做一个竞品分析报告"
```

**工作流程**:
```
Step 1: 确定报告规格（受众、目的、格式）
Step 2: 制定研究计划和查询集
Step 3: 收集证据（deepresearch + grok-search）
Step 4: 源筛选和证据表
Step 5: 大纲和章节映射
Step 6: 多轮完整起草（并行 subagents）
Step 7: UNION 合并和格式合规
Step 8: 证据和引用验证
Step 9: 人工审核和迭代
```

#### 实例

```bash
# 已测试：生成 2025-2026 AI 编程工具报告
# 输出文件：/home/test/lyq/ai-coding-tools-report-2025-2026.md
```

**使用 grok-search MCP 获取实时数据**（已通过 MCP 集成，自动触发）:
```bash
# grok-search 已作为 MCP Server 集成，Claude 会自动调用 web_search 等工具
```

#### 参考文件

| 文件 | 用途 |
|------|------|
| `references/research_report_template.md` | 报告模板 |
| `references/formatting_rules.md` | 格式规则 |
| `references/source_quality_rubric.md` | 源质量评分 |
| `references/completeness_review_checklist.md` | 完整性检查 |

---

### 2. ppt-creator

#### 来源
- **Marketplace**: `daymade-skills`
- **仓库**: https://github.com/daymade/claude-code-skills

#### 用途与支持场景

| 场景 | 描述 |
|------|------|
| 商务演示 | 产品发布、业务汇报 |
| 投融资路演 | 投资者推介、融资计划 |
| 技术分享 | 技术方案、架构设计 |
| 培训课件 | 教学内容、培训材料 |
| 数据报告 | 带图表的数据分析报告 |

#### 核心特性

- **Pyramid Principle**: 结论先行，证据支撑
- **Assertion-Evidence**: 断言式标题 + 证据内容
- **自动图表**: matplotlib/pandas 生成数据可视化
- **双路径 PPTX**: Marp + python-pptx 两种输出
- **演讲者备注**: 每页 45-60 秒的演讲提示
- **质量评分**: 自动评分，< 75 分自动迭代优化

#### 使用方法

**自动触发**:
```
"帮我创建一个关于产品发布的演示文稿"
"做一个技术方案 PPT"
"生成一个融资路演 deck"
```

**Orchestration 模式** (端到端自动化):
```
激活短语: "完整 PPTX"、"最终交付物"、"演示就绪"
输出: presentation_marp_with_charts.pptx + presentation_pptx_with_charts.pptx
```

#### 9 阶段工作流程

```
Stage 0: 归档输入
Stage 1: 结构化目标
Stage 2: 故事线 (Pyramid Principle)
Stage 3: 大纲和标题
Stage 4: 证据和图表
Stage 5: 布局和无障碍
Stage 6: 演讲者备注
Stage 7: 自检和评分
Stage 8: 打包交付物
Stage 9: 复用指南
```

#### 依赖

```bash
# 图表生成
pip install pandas matplotlib

# Marp PPTX 导出（可选）
npm install -g @marp-team/marp-cli

# python-pptx（可选）
pip install python-pptx
```

#### 实例

```bash
# 创建演示文稿
"创建一个 15 页的产品发布演示文稿，包含市场分析、产品特性、竞争优势"

# 输出结构
/output/
├── slides.md           # Markdown 幻灯片
├── assets/*.png        # 图表
├── notes.md            # 演讲者备注
├── refs.md             # 引用来源
└── presentation.pptx   # PPTX 文件
```

#### 参考文件

| 文件 | 用途 |
|------|------|
| `references/INTAKE.md` | 10 项最小问卷 |
| `references/WORKFLOW.md` | 详细工作流程 |
| `references/TEMPLATES.md` | 幻灯片模板库 |
| `references/VIS-GUIDE.md` | 图表选择字典 |
| `references/STYLE-GUIDE.md` | 样式指南 |
| `references/RUBRIC.md` | 质量评分表 |

---

### 3. skill-creator

#### 来源
- **Marketplace**: `daymade-skills`
- **仓库**: https://github.com/daymade/claude-code-skills

#### 用途与支持场景

| 场景 | 描述 |
|------|------|
| 创建新技能 | 从零开始构建自定义技能 |
| 改进现有技能 | 优化、迭代现有技能 |
| 性能评估 | 运行 evals 测试技能效果 |
| 基准测试 | 对比不同版本性能 |
| 描述优化 | 优化技能触发准确性 |

#### 核心特性

- **交互式创建**: 通过问答引导创建技能
- **模板生成**: 自动生成 SKILL.md 骨架
- **验证工具**: 检查技能结构合规性
- **打包发布**: 准备技能发布
- **安全扫描**: 检测潜在安全问题
- **描述优化**: 提高技能自动触发准确率

#### 可用脚本

| 脚本 | 功能 | 使用示例 |
|------|------|----------|
| `init_skill.py` | 初始化新技能 | `python init_skill.py my-skill --path ./skills` |
| `quick_validate.py` | 快速验证 | `python quick_validate.py /path/to/skill` |
| `package_skill.py` | 打包发布 | `python package_skill.py /path/to/skill` |
| `improve_description.py` | 优化描述 | `python improve_description.py /path/to/skill` |
| `run_eval.py` | 运行评估 | `python run_eval.py /path/to/skill` |
| `security_scan.py` | 安全扫描 | `python security_scan.py /path/to/skill` |

#### 使用方法

**自动触发**:
```
"创建一个新技能"
"我想做一个 XXX 技能"
"把这个工作流变成技能"
```

**手动调用**:
```bash
# 初始化新技能
python ~/.claude/plugins/marketplaces/daymade-skills/skill-creator/scripts/init_skill.py my-new-skill --path ~/my-skills

# 验证技能
python ~/.claude/plugins/marketplaces/daymade-skills/skill-creator/scripts/quick_validate.py ~/my-skills/my-new-skill
```

#### 创建流程

```
1. 捕获意图
   - 技能应该做什么？
   - 何时触发？
   - 输出格式是什么？

2. 先验研究
   - 检查已安装的 plugins/MCPs
   - 搜索 skills.sh
   - 查看官方 API 文档

3. 起草技能
   - 生成 SKILL.md
   - 创建 scripts/、references/、assets/

4. 测试验证
   - 设置测试用例
   - 运行评估

5. 迭代优化
   - 根据反馈改进
   - 优化触发描述
```

#### 实例

```bash
# 测试创建新技能
python ~/.claude/plugins/marketplaces/daymade-skills/skill-creator/scripts/init_skill.py test-hello-skill --path /tmp/test-skills

# 输出结构
/tmp/test-skills/test-hello-skill/
├── SKILL.md              # 技能定义
├── scripts/example.py    # 示例脚本
├── references/api_reference.md  # 参考文档
└── assets/example_asset.txt     # 资源文件
```

---

## Skills (手动安装)

---

### 4. grok-search

> **⚠️ 已弃用 (Deprecated)**
> grok-search **Skill** 已不再推荐使用。请改用 **grok-search MCP Server**，它提供了更好的集成体验（自动触发、无需手动调用脚本）。
> 详见下方 [grok-search MCP 配置](#grok-search-mcp-配置推荐)。

#### 来源
- **仓库**: https://github.com/Frankieli123/grok-skill
- **安装方式**: 手动克隆

#### grok-search MCP 配置（推荐）

grok-search 已作为 MCP Server 集成到 Claude Code 中，无需手动调用脚本。

**安装命令**:

```bash
claude mcp add grok-search \
  -s user \
  -e GROK_API_URL=<your_grok_api_url> \
  -e GROK_API_KEY=<your_grok_api_key> \
  -e GROK_MODEL=grok-4.20-reasoning \
  -e TAVILY_API_KEY=<your_tavily_api_key> \
  -e TAVILY_API_URL=<your_tavily_api_url> \
  -- uvx --from "git+https://github.com/GuDaStudio/GrokSearch@grok-with-tavily" grok-search
```

**参数说明**:

| 参数 | 说明 |
|------|------|
| `-s user` | 作用域为用户级（所有项目可用） |
| `GROK_API_URL` | Grok API 端点地址 |
| `GROK_API_KEY` | Grok API 密钥 |
| `GROK_MODEL` | 默认使用的模型 |
| `TAVILY_API_KEY` | Tavily 搜索 API 密钥（用于额外搜索源） |
| `TAVILY_API_URL` | Tavily API 端点地址 |

**验证安装**:

```bash
# 查看 MCP 状态
claude mcp list

# 查看详细配置
claude mcp get grok-search
```

**MCP 提供的工具**:

| 工具 | 功能 |
|------|------|
| `web_search` | 深度网络搜索 |
| `web_fetch` | 获取网页完整内容 |
| `web_map` | 网站结构映射 |
| `get_config_info` | 查看配置和连接状态 |
| `switch_model` | 切换默认模型 |
| `toggle_builtin_tools` | 切换内置搜索工具 |

**搜索规划工具**（6 阶段流水线）:

| 阶段 | 工具 | 说明 |
|------|------|------|
| 1 | `plan_intent` | 分析搜索意图 |
| 2 | `plan_complexity` | 评估复杂度（1-3 级） |
| 3 | `plan_sub_query` | 拆分子查询 |
| 4 | `plan_search_term` | 定义搜索词 |
| 5 | `plan_tool_mapping` | 映射工具到子查询 |
| 6 | `plan_execution` | 定义执行顺序 |

#### 与 deep-research 集成

grok-search MCP 已集成到 deep-research 的 Step 3（证据收集）阶段，用于获取实时信息：

```
deep-research Step 3:
├── deepresearch 工具（常规搜索）
└── grok-search MCP（实时搜索）← 已集成
```

---

### 5. github-skill-forge

#### 来源
- **仓库**: https://github.com/YuJunZhiXue/github-skill-forge
- **安装方式**: 手动克隆

#### 用途与支持场景

| 场景 | 描述 |
|------|------|
| 工具集成 | 将 GitHub 开源工具转为技能 |
| 团队规范 | 标准化团队工具使用方式 |
| 工作流封装 | 封装常用工具的调用流程 |
| 文档聚合 | 自动聚合项目文档和上下文 |

#### 核心特性

- **一键克隆**: 自动克隆 GitHub 仓库
- **脚手架生成**: 创建标准技能目录结构
- **Lite-RAG**: 上下文聚合，提取文件树、README、依赖
- **金标验证**: 检查 Stars、Forks、许可证
- **在线扫描**: Zero-Clone 模式，无需完整克隆
- **代理支持**: 自动处理网络代理

#### 使用方法

```bash
# 基本用法
python ~/.claude/skills/github-skill-forge/scripts/forge.py <GITHUB_URL>

# 指定技能名称
python ~/.claude/skills/github-skill-forge/scripts/forge.py <GITHUB_URL> <SKILL_NAME>

# 指定输出目录
python ~/.claude/skills/github-skill-forge/scripts/forge.py <GITHUB_URL> --output /path/to/output

# 强制覆盖
python ~/.claude/skills/github-skill-forge/scripts/forge.py <GITHUB_URL> --force

# 试运行
python ~/.claude/skills/github-skill-forge/scripts/forge.py <GITHUB_URL> --dry-run

# 设置金标阈值
python ~/.claude/skills/github-skill-forge/scripts/forge.py <GITHUB_URL> --min-stars 100
```

#### 参数说明

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `url` | GitHub 仓库 URL | 必填 |
| `skill_name` | 技能名称 | 仓库名 |
| `--output, -o` | 输出目录 | `.trae/skills` |
| `--force, -f` | 强制覆盖 | 否 |
| `--dry-run, -n` | 试运行 | 否 |
| `--depth` | Git 克隆深度 | 1 |
| `--min-stars` | 金标阈值 | 20 |
| `--verbose, -v` | 详细输出 | 否 |

#### 输出结构

```
<output>/<skill-name>/
├── SKILL.md              # 自动生成的技能定义
├── context_bundle.md     # 上下文聚合文件
├── scripts/              # 脚本目录
├── src/                  # 源码目录
└── .gitignore           # Git 忽略文件
```

#### 实例

```bash
# 将 gum 工具转为技能
python ~/.claude/skills/github-skill-forge/scripts/forge.py https://github.com/charmbracelet/gum --output /tmp/test-skills

# 输出
✅ 金标验证成功: Stars: 23,165; Forks: 476; 许可证: MIT
✅ 已生成在线上下文包: /tmp/test-skills/gum-skill/context_bundle.md
✅ 已创建 SKILL.md
✅ 技能锻造完成!
```

---

### 6. find-skills

#### 来源
- **仓库**: https://github.com/vercel-labs/skills
- **安装方式**: 手动克隆

#### 用途与支持场景

| 场景 | 描述 |
|------|------|
| 技能发现 | 搜索社区已有的技能 |
| 能力扩展 | 找到新功能对应的技能 |
| 工具查找 | 查找特定任务的工具 |
| 最佳实践 | 获取官方/社区最佳实践 |

#### 核心特性

- **技能搜索**: 按关键词搜索社区技能
- **排行榜**: 查看最热门的技能
- **一键安装**: 直接安装到本地
- **跨 Agent**: 安装后支持多个 AI Agent

#### 使用方法

```bash
# 搜索技能
npx skills find <query>

# 安装技能（项目级）
npx skills add <owner/repo@skill>

# 安装技能（全局）
npx skills add <owner/repo@skill> --global

# 列出已安装技能
npx skills list

# 检查更新
npx skills check

# 更新所有技能
npx skills update

# 初始化新技能
npx skills init <skill-name>
```

#### 参数说明

| 参数 | 说明 |
|------|------|
| `--global, -g` | 全局安装（用户级） |
| `--agent <agents>` | 指定安装到哪些 Agent |
| `--skill <skills>` | 指定安装哪些技能 |
| `--yes, -y` | 跳过确认提示 |
| `--all` | 安装所有技能到所有 Agent |

#### 常用技能分类

| 类别 | 搜索关键词 |
|------|-----------|
| Web 开发 | react, nextjs, typescript, css, tailwind |
| 测试 | testing, jest, playwright, e2e |
| DevOps | deploy, docker, kubernetes, ci-cd |
| 文档 | docs, readme, changelog, api-docs |
| 代码质量 | review, lint, refactor, best-practices |
| 设计 | ui, ux, design-system, accessibility |

#### 实例

```bash
# 搜索 React 相关技能
npx skills find react

# 输出示例
vercel-labs/agent-skills@vercel-react-best-practices  244.7K installs
vercel-labs/agent-skills@vercel-react-native-skills    70.1K installs
resend/react-email@react-email                        3.5K installs

# 安装 React 最佳实践
npx skills add vercel-labs/agent-skills@vercel-react-best-practices --global -y
```

---

## Global Skills (npx 安装)

---

### 7. vercel-react-best-practices

#### 来源
- **仓库**: https://github.com/vercel-labs/agent-skills
- **安装方式**: `npx skills add --global`

#### 用途与支持场景

| 场景 | 描述 |
|------|------|
| React 开发 | React 最佳实践和优化 |
| Next.js 项目 | Next.js 应用开发指南 |
| 性能优化 | React/Next.js 性能调优 |
| 代码审查 | React 代码质量检查 |

#### 核心特性

- **Vercel 官方**: 来自 Vercel 工程团队的最佳实践
- **244K+ 安装**: 社区广泛使用
- **跨 Agent**: 支持 Claude Code, Cursor, GitHub Copilot 等

#### 安装位置

```
~/.agents/skills/vercel-react-best-practices
```

#### 支持的 Agent

- Claude Code
- Cursor
- GitHub Copilot
- Gemini CLI
- Windsurf
- Qoder
- Continue
- Trae
- 等等...

#### 使用方法

安装后会自动在相关场景触发，例如：
```
"帮我优化这个 React 组件的性能"
"审查这个 Next.js 代码"
"这个 React 代码有什么问题？"
```

---

### 8. using-superpowers

#### 来源
- **仓库**: https://github.com/obra/superpowers
- **安装方式**: `npx skills add --global`
- **安装量**: 35K+

#### 用途与支持场景

| 场景 | 描述 |
|------|------|
| 技能发现 | 确定是否有相关技能适用于当前任务 |
| 技能优先级 | 决定多个技能的使用顺序 |
| 工作流引导 | 指导如何正确使用技能 |
| 避免遗漏 | 防止跳过应该使用的技能 |

#### 核心特性

- **元技能**: 教 AI 如何正确使用其他技能
- **强制检查**: 即使只有 1% 可能性也要检查技能
- **优先级规则**: 流程技能 → 实现技能
- **用户优先**: 用户指令优先于技能建议
- **跨 Agent**: 支持 Claude Code, Cursor, Gemini CLI 等 43+ Agent

#### 技能优先级

```
1. 用户显式指令 (CLAUDE.md, GEMINI.md, AGENTS.md) — 最高优先级
2. Superpowers 技能 — 覆盖默认系统行为
3. 默认系统提示 — 最低优先级
```

#### 技能类型

| 类型 | 说明 | 示例 |
|------|------|------|
| **刚性 (Rigid)** | 必须严格遵循 | TDD, debugging |
| **灵活 (Flexible)** | 可根据上下文调整 | patterns |

#### 红旗警告

以下想法意味着你在合理化跳过技能检查：

| 想法 | 现实 |
|------|------|
| "这只是个简单问题" | 问题也是任务，检查技能 |
| "我需要更多上下文" | 技能检查在澄清问题之前 |
| "让我先探索代码库" | 技能告诉你如何探索 |
| "我记得这个技能" | 技能会演进，读取当前版本 |
| "这个技能太复杂了" | 简单的事情会变复杂，使用它 |

#### 安装位置

```
~/.agents/skills/using-superpowers/
├── SKILL.md              # 主技能定义
└── references/
    ├── codex-tools.md    # Codex 工具映射
    └── gemini-tools.md   # Gemini 工具映射
```

#### 使用方法

此技能是**元技能**，会自动在任何对话开始时被检查：

```
用户: "帮我创建一个新功能"
AI: [自动检查是否有相关技能] → 发现 brainstorming 技能 → 调用技能
```

**核心规则**:
- 在任何响应或操作之前调用相关技能
- 即使只有 1% 可能性也要检查
- 技能本身会告诉你它是刚性的还是灵活的

---

### 9. pretty-mermaid

#### 来源
- **仓库**: https://github.com/imxv/Pretty-mermaid-skills
- **安装方式**: `npx skills add --global`

#### 用途与支持场景

| 场景 | 描述 |
|------|------|
| 图表渲染 | 将 Mermaid 代码渲染为 SVG 或 ASCII |
| 流程图 | 创建流程图、决策树、工作流 |
| 时序图 | API 调用、交互流程、消息流 |
| 状态图 | 应用状态、生命周期、状态机 |
| 类图 | 对象模型、架构、关系图 |
| ER 图 | 数据库架构、数据模型 |

#### 核心特性

- **15+ 主题**: tokyo-night, dracula, github-dark, nord 等
- **5 种图表**: flowchart, sequence, state, class, ER
- **双输出格式**: SVG (Web/文档) 和 ASCII (终端)
- **批量处理**: 并行渲染多个图表
- **自定义颜色**: 支持自定义背景、前景、强调色
- **透明背景**: 支持透明背景输出

#### 支持的主题

| 主题 | 适用场景 |
|------|----------|
| `tokyo-night` | 暗色文档（推荐） |
| `github-dark` | GitHub 风格 |
| `github-light` | 亮色文档 |
| `dracula` | 高对比度 |
| `nord` | 冷色调简约 |
| `catppuccin-mocha` | 温暖色调 |
| `solarized-dark` | Solarized 暗色 |
| `zinc-light` | 高对比可打印 |

#### 安装位置

```
~/.agents/skills/pretty-mermaid/
├── SKILL.md              # 主技能定义
├── scripts/
│   ├── render.mjs        # 渲染脚本
│   ├── batch.mjs         # 批量处理
│   └── themes.mjs        # 主题列表
├── references/
│   ├── THEMES.md         # 主题详细文档
│   └── DIAGRAM_TYPES.md  # 图表类型语法
└── assets/
    └── example_diagrams/ # 示例模板
```

#### 使用方法

**渲染单个图表**:
```bash
node ~/.agents/skills/pretty-mermaid/scripts/render.mjs \
  --input diagram.mmd \
  --output diagram.svg \
  --format svg \
  --theme tokyo-night
```

**ASCII 输出 (终端友好)**:
```bash
node ~/.agents/skills/pretty-mermaid/scripts/render.mjs \
  --input diagram.mmd \
  --format ascii
```

**批量渲染**:
```bash
node ~/.agents/skills/pretty-mermaid/scripts/batch.mjs \
  --input-dir ./diagrams \
  --output-dir ./output \
  --format svg \
  --theme dracula \
  --workers 4
```

**自定义颜色**:
```bash
node ~/.agents/skills/pretty-mermaid/scripts/render.mjs \
  --input diagram.mmd \
  --bg "#1a1b26" \
  --fg "#a9b1d6" \
  --accent "#7aa2f7" \
  --output custom.svg
```

**透明背景**:
```bash
node ~/.agents/skills/pretty-mermaid/scripts/render.mjs \
  --input diagram.mmd \
  --transparent \
  --output transparent.svg
```

#### 图表类型参考

| 类型 | 语法 | 用途 |
|------|------|------|
| Flowchart | `flowchart LR/TD` | 流程、工作流、决策树 |
| Sequence | `sequenceDiagram` | API 调用、消息流 |
| State | `stateDiagram-v2` | 状态机、生命周期 |
| Class | `classDiagram` | 对象模型、架构 |
| ER | `erDiagram` | 数据库架构 |

#### 触发场景

```
"渲染一个 Mermaid 图表"
"创建一个流程图"
"美化这个图表"
"生成时序图"
"把架构画成图"
```

---

## 组合使用场景

### 场景 1: 深度研究 + 实时搜索

```
需求: 生成一份关于 AI 编程工具的研究报告

工作流:
1. deep-research 制定研究计划
2. grok-search 获取实时数据（版本、功能更新）
3. deep-research 整合证据、生成报告
4. 输出带引用的研究报告
```

### 场景 2: 技能发现 + 创建

```
需求: 想要一个新功能但不确定是否已有技能

工作流:
1. find-skills 搜索相关技能
2. 如果找到 → 直接安装
3. 如果没找到 → skill-creator 创建新技能
4. github-skill-forge 可将 GitHub 工具转为技能
```

### 场景 3: 研究报告 → 演示文稿

```
需求: 将研究成果转化为演示

工作流:
1. deep-research 生成研究报告
2. ppt-creator 将报告转为演示文稿
3. 自动生成图表和演讲者备注
4. 输出 PPTX 文件
```

### 场景 4: GitHub 工具集成

```
需求: 想要使用 GitHub 上的开源工具

工作流:
1. github-skill-forge 将仓库转为技能
2. 自动生成 SKILL.md 和上下文
3. skill-creator 验证和优化
4. 开始使用新技能
```

---

## 快速参考卡

### 命令速查

```bash
# === Grok 搜索 (MCP) ===
# 已通过 MCP Server 集成，无需手动调用
claude mcp get grok-search  # 查看配置
claude mcp list              # 查看 MCP 状态

# === GitHub 技能锻造 ===
python ~/.claude/skills/github-skill-forge/scripts/forge.py <URL> --output <DIR>

# === 技能发现 ===
npx skills find <keyword>
npx skills add <owner/repo@skill> --global -y
npx skills list
npx skills update

# === 技能创建 ===
python ~/.claude/plugins/marketplaces/daymade-skills/skill-creator/scripts/init_skill.py <name>

# === 插件管理 ===
claude plugin marketplace add <URL>
claude plugin install <name>@<marketplace>
```

### 文件位置

```bash
# Plugins
~/.claude/plugins/cache/daymade-skills/
├── deep-research/
├── ppt-creator/
└── skill-creator/

# Skills (手动)
~/.claude/skills/
├── grok-search/          # ⚠️ 已弃用，使用 MCP
├── github-skill-forge/
└── find-skills/

# Skills (全局)
~/.agents/skills/
├── vercel-react-best-practices/
├── using-superpowers/
└── pretty-mermaid/
```

### 触发词

| Skill | 触发词示例 |
|-------|-----------|
| deep-research | "研究报告"、"竞品分析"、"文献综述" |
| ppt-creator | "演示文稿"、"PPT"、"slide deck"、"路演" |
| skill-creator | "创建技能"、"新技能"、"把...变成技能" |
| grok-search | 实时信息、版本号、最新状态（⚠️ Skill 已弃用，使用 MCP） |
| github-skill-forge | "把这个 GitHub 项目转成技能" |
| find-skills | "有没有...的技能"、"帮我找...技能" |
| using-superpowers | 元技能（自动触发，指导技能使用） |
| pretty-mermaid | "渲染图表"、"流程图"、"时序图"、"Mermaid" |

---

## 附录: 依赖安装

```bash
# Python 依赖
pip install pandas matplotlib python-pptx

# npm 全局依赖
npm install -g @marp-team/marp-cli

# 系统依赖
# macOS: brew install ffmpeg git
# Ubuntu: apt install ffmpeg git
```

---

*本手册由 Claude Code 生成*
*最后更新: 2026-04-26*
