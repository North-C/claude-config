#!/usr/bin/env bash
# 组装 specs/*.md → base-rules.md（源文件是唯一事实来源，顺序在此处维护）
set -euo pipefail
cd "$(dirname "$0")"

out="base-rules.md"
order=(communication evidence-research local-work bug-fixing performance-tuning code-convergence safety tools-and-skills subagents)

{
  echo "# Agent 基础行为规范"
  echo
  echo "> ⚠️ 生成文件 — 不要手改。修改 specs/ 下源文件后运行 ./build.sh 重新生成，"
  echo "> 再运行 ./install.sh 同步到 Codex（Claude Code 引用本文件路径，无需同步）。"
  echo
  for name in "${order[@]}"; do
    f="specs/$name.md"
    if [ ! -f "$f" ]; then
      echo "✗ 缺少 $f（请检查 order 列表）" >&2
      exit 1
    fi
    cat "$f"
    echo
  done
} > "$out"

echo "✓ 已生成 $out（$(grep -c '^## ' "$out") 个规范模块）"
