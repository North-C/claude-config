# Rule Admission Policy

Read this reference only when evaluating whether a governance finding should become a durable `claude-config` asset.

## Required evidence

A candidate record must establish:

- **source scope**: logical repository name plus verified branch/HEAD; do not persist a personal absolute path.
- **trigger**: the natural-language task or observable condition that should activate the rule.
- **observations**: at least two independent tasks/repositories, or one severe and fully verified failure. Configuration interest and repeated copies of the same session do not satisfy this gate.
- **current evidence**: tracked source/config/docs/tests supporting the current fact. Historical evidence must be labelled and revalidated where it can drift.
- **generalized rule**: the smallest instruction that survives implementation replacement.
- **action delta**: the concrete read, check, stop, routing decision or verification the Agent changes after loading it.
- **validation**: an observable way to show that the rule, template or skill is structurally present and behaviorally useful.
- **owner and expiry**: one canonical destination plus the condition that should trigger review, replacement or deletion.

## Destination test

- Put a rule in `prompts/specs/` only if it is a cross-project behavior invariant appropriate for every globally mounted session.
- Put a workflow in `prompts/templates/` when it is selected for a concrete task and should not load globally.
- Put a capability in `prompts/skills/` when precise discovery plus conditional references or deterministic helpers materially improve repeated work.
- Keep a project-specific finding out of `claude-config` when it has no reusable task route. Recommend a project-local owner only; this workflow does not create it.

## Reject or stop

Reject a candidate when any of these applies:

- it is inferred only from a missing `AGENTS.md`, a README claim, untracked evidence, or one unverified session;
- it restates generic competence such as “write clear documentation” without changing an action;
- the proposed text embeds source code details, current machine state, credentials, internal paths or unpublished evidence;
- an existing spec/template/skill already owns the same semantic responsibility;
- accepting it would require modifying the source repository, HOME configuration, remote service, automation or another target not authorized by the current task;
- validation is unavailable, or the evidence has drifted since collection.

Do not keep a rejected-candidate ledger in Git. Report it for the current run, then rely on future independent evidence to raise it again.
