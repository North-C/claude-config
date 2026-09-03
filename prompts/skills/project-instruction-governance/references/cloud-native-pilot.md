# cloud-native Pilot

This is the first authorized source scope for `project-instruction-governance`. The source root is supplied by the runtime task; never commit its absolute path.

## Read-only inventory

1. Verify current branch/HEAD and run tracked, staged and untracked status checks separately.
2. If tracked or staged changes exist, stop rather than interpreting a mixed checkout. Untracked paths remain user assets: do not open, copy, hash, clean, stage or cite them.
3. Use `git ls-files` to find existing `AGENTS.md`, `CLAUDE.md`, `CODEX.md`, project skills, README/docs, Makefiles, Dockerfiles and validation scripts.
4. Read the smallest tracked set needed to answer one governance question. The configured first interest is user-guide authoring: source-of-truth, build-versus-deploy boundary, architecture verification, documentation validation and exact completion evidence.

The absence of an Agent entry is an inventory fact, not authorization to add one to `cloud-native`. Any project-local recommendation remains a proposal for separate user approval.

## Candidate boundary

The first run may promote one reusable `claude-config` asset only when current tracked evidence plus independent historical evidence satisfies the admission policy. Examples of candidate action deltas include:

- inspect the current branch/HEAD and real build manifests before documenting build steps;
- keep build-only documentation separate from deployment/runtime validation;
- verify a built binary's architecture independently of an image's platform flag;
- use image metadata or export inspection when a minimal image has no shell;
- require Markdown, link, sensitive-content and exact-diff checks before declaring a guide complete.

These are candidate shapes, not pre-approved conclusions. Revalidate them against the current pilot checkout and existing `claude-config` owners before writing.

## Completion

Success is either one verified, non-duplicated asset in `claude-config`, or a clean no-change result naming the missing evidence. Never modify, stage, commit or push from the pilot repository.
