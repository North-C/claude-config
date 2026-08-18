#!/usr/bin/env bash
# 把 base-rules.md 挂载到 Claude Code 与 Codex。幂等，可重复运行。
#
#   Claude Code → ~/.claude/CLAUDE.md 追加一行 @-import（引用本仓库文件，改完即生效）
#   Codex      → ~/.codex/AGENTS.md 写入标记块内联内容（Codex 不支持 import，必须内联）
set -euo pipefail
cd "$(dirname "$0")"
REPO_ABS="$(pwd)"
RULES="$REPO_ABS/base-rules.md"
START="<!-- BASE_RULES_START (managed by claude-config/prompts/install.sh) -->"
END="<!-- BASE_RULES_END -->"

[ -f "$RULES" ] || { echo "✗ 未找到 $RULES，先运行 ./build.sh"; exit 1; }

# --- Claude Code ------------------------------------------------------------
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
mkdir -p "$HOME/.claude"
touch "$CLAUDE_MD"
if grep -Fqx "@$RULES" "$CLAUDE_MD"; then
  echo "• Claude Code: @-import 已存在，跳过（$CLAUDE_MD）"
else
  # 先清掉可能存在的旧标记块（含早期内联版本），再追加 import 行
  awk -v s="$START" -v e="$END" '
    index($0, s) { skip=1 }
    !skip { print }
    index($0, e) { skip=0 }
  ' "$CLAUDE_MD" > "$CLAUDE_MD.tmp" && mv "$CLAUDE_MD.tmp" "$CLAUDE_MD"
  printf '\n%s\n@%s\n%s\n' "$START" "$RULES" "$END" >> "$CLAUDE_MD"
  echo "✓ Claude Code: 已添加 @-import → $CLAUDE_MD"
fi

# --- Codex -------------------------------------------------------------------
AGENTS_MD="$HOME/.codex/AGENTS.md"
mkdir -p "$HOME/.codex"
touch "$AGENTS_MD"
awk -v s="$START" -v e="$END" '
  index($0, s) { skip=1 }
    !skip { print }
  index($0, e) { skip=0 }
' "$AGENTS_MD" > "$AGENTS_MD.tmp" && mv "$AGENTS_MD.tmp" "$AGENTS_MD"
{
  echo
  echo "$START"
  cat "$RULES"
  echo "$END"
} >> "$AGENTS_MD"
echo "✓ Codex: 已内联更新标记块 → $AGENTS_MD"

echo
echo "完成。新增会话生效；修改 specs/ 后运行: ./build.sh && ./install.sh"
