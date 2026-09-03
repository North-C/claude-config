---
name: project-instruction-governance
description: Audit explicitly authorized repositories for missing, stale, duplicated, or inert Agent instructions, then distill at most one evidence-backed rule, task template, or skill into claude-config. Use for repository instruction inventories, AGENTS.md governance, or promoting repeated project experience; do not modify source repositories or promote raw session content.
---

# Project Instruction Governance

Keep project instructions small, routed, evidence-backed, and capable of changing the next Agent action. The source repository is always read-only; `claude-config` is the only write target.

## Workflow

1. Verify the current `claude-config` branch, HEAD, upstream and clean tracked/untracked boundary. Stop on unexpected changes or remote divergence; never reset, clean, stash, or overwrite them.
2. Read only repositories explicitly named in the current task. Record source branch/HEAD and tracked-dirty status before interpreting files. Use `git ls-files` to select tracked instruction, documentation, build, test and validation entries; untracked files are user assets, not governance evidence.
3. Inventory existing Agent entry points, routed skills, canonical documentation, validation commands and conflicting or missing ownership. Do not treat a missing file alone as proof that a new rule is needed.
4. Before admitting a candidate, read [references/admission-policy.md](references/admission-policy.md). For the `cloud-native` pilot, also read [references/cloud-native-pilot.md](references/cloud-native-pilot.md).
5. Choose exactly one destination owned by `claude-config`: cross-project invariant → `prompts/specs/`; reusable task procedure → `prompts/templates/`; reusable capability with conditional detail or deterministic tooling → `prompts/skills/<name>/`. Reuse or amend the existing owner instead of creating a parallel rule.
6. Promote at most one independent asset per run. If evidence is insufficient, duplicated, stale, sensitive, project-specific without a valid route, or would not alter a future action, leave the repository unchanged and report the stop reason.
7. Validate the exact claim: run `prompts/build.sh` after any spec change, validate changed skills with the available skill validator, run applicable structural checks and `git diff --check`, and inspect the exact staged paths. Structural green is not semantic or behavioral proof.
8. Commit and push only when the current task explicitly authorizes both. Never run `prompts/install.sh`, push `main`, create a PR, or modify the source repository. A no-value run creates no commit and no push.

## Boundaries

- Never read shell history, credentials, raw terminal content, browser cookies, private keys, or unapproved session archives.
- Never copy raw source text, project paths, IP addresses, tokens, logs or environment identities into global rules.
- User statements are desired direction, not proof of current implementation. Historical lessons are candidates until current tracked evidence and reuse scope are verified.
- A repository-level `AGENTS.md` is an entry/router, not a transcript or encyclopedia. Do not generate one in a source repository from this workflow.
- Generated `prompts/base-rules.md` is rebuilt from specs; do not edit it directly.
