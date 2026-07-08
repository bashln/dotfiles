---
description: Implement code changes with optional audit, safety checks, or interactive improvement.
---

Implement code changes based on description.

## Usage

```
/impl <description>
/impl --audit <description>
/impl --safe <description>
/impl --interactive <description>
```

## Modes

### Default (no flags)
Direct implementation. Execute exactly as described — no extra scope, no audit.

```
/impl add endpoint /api/users
```

### --audit
Implementation + post-implementation audit.

Phase 1: Implement the changes
Phase 2: Auditor agent verifies:
- Implementation matches original request
- No obvious bugs, regressions, or edge cases missed
- All modified files are consistent

If audit finds issues, fix them.

```
/impl --audit refactor auth module
```

### --safe
Implementation with extra validation.

After implementation:
- Run typecheck
- Run lint
- Run tests
- Only commit if all pass

```
/impl --safe migrate database schema
```

### --interactive
Interactive improvement loop with skills.

Workflow:
1. Load skill for current phase
2. Find problems (debug, audit-and-fix)
3. Implement fixes (code-simplifier, implement)
4. Test and validate (tdd, test, quality-checks)
5. Commit atomically
6. Repeat until no more improvements

```
/impl --interactive clean up legacy code
```

## Scope

- `--scope file <path>` — implement in specific file
- `--scope dir <path>` — implement in specific directory
- `--scope branch <name>` — implement on specific branch

## Budget

- `--budget micro` — minimal changes, 1-2 files max
- `--budget medium` — focused implementation, 5-10 files (default)
- `--budget full` — comprehensive implementation, no file limit

## Options

- `--verbose` — show detailed progress
- `--dry-run` — explain what would be implemented without executing

## Examples

```
/impl add user authentication              # Direct implementation
/impl --audit refactor payment module      # Implement + audit
/impl --safe update dependencies           # Implement + validate
/impl --interactive optimize queries       # Interactive improvement

/impl --scope file src/auth.ts add OAuth   # Implement in specific file
/impl --budget micro fix typo in README    # Minimal changes
```

## Behavior

1. Parse description and flags
2. Determine scope and budget
3. Implement changes
4. Apply mode-specific behavior (audit, safe, interactive)
5. Report what was done

## Output Format

```
## Implementation Complete

Mode: <default|audit|safe|interactive>
Files modified: N
Budget: <micro|medium|full>

### Changes
- src/auth.ts: Added OAuth integration
- src/config.ts: Added OAuth config
- ...

### Validation (if --safe)
✅ Typecheck passed
✅ Lint passed
✅ Tests passed (15/15)

### Audit (if --audit)
✅ Implementation matches request
✅ No regressions found
✅ All files consistent
```
