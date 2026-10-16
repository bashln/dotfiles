# Global Engineering Instructions

Invest effort in this order: architectural safeguards, automated verification, concise instructions, and risk-based human review. This order does not override mandatory approvals or security requirements.

## Core principles
- Prefer simple, robust, low-coupling solutions.
- Fix root causes, not symptoms.
- Prefer invariants, types, contracts, and architectural boundaries over natural-language rules.
- Don't add dependencies, abstractions, docs, or files without clear ownership.
- Remove obsolete code related to the task when safe; avoid leaving broken references.
- No unrelated changes. No extensive refactors without justification.
- Every user-facing surface (app, CLI, TUI, API, library, script, docs) should be obvious, useful, and polished. Prefer intuitive defaults over tutorials.

## Before coding
- Understand existing architecture and patterns first.
- Reuse existing verification tools before creating new ones.

## Verification
- Run checks proportional to change scope.
- Never claim completion without evidence.
- Never invent test results or claim commands not run.
- For bugfixes: reproduce, verify the fix resolves it, check no regression.

## Deletion policy (proportional to risk)
- Routine (temp files, caches, build artifacts): no recovery needed.
- Important (source, config, data): reversible strategy (git, backup).
- Destructive (force-push, rm -rf, drop): explicit approval required.
- Never delete persistent data without a recovery path.

## Safety
- Never access or transmit secrets/credentials without explicit authorization.
- If operating in a bare repo (e.g., ~/.dotfiles-bare) with a pre-commit guard, stage by explicit path. The guard may block commits; it does not prevent staging.

## Autonomous execution
- Execute without waiting for human input when working toward a defined goal.
- Choose the safest reversible option; record the decision.
- One verifiable unit at a time → validate → record → next.
- Persist to progress.json + errors.json only for long-running, multi-step, or resumable tasks. Prefer existing project mechanisms; avoid creating tracking files for trivial work.

### Stop conditions
- Destructive or irreversible operations without authorization.
- Changes outside approved scope.
- Security, access, or permission blockers.
- Repeated failures without a new technical hypothesis.
- Decisions requiring scope expansion or a relevant unauthorized commitment.

## Reporting
- Record briefly: what changed, what was verified, remaining risks.
