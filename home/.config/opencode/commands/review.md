---
description: Review code with configurable scope and focus areas.
---

Review code for bugs, security issues, performance problems, or architectural concerns.

## Usage

```
/review --scope <scope> --focus <focus>
```

## Scope (what to review)

- `--scope diff` — review current branch diff vs main/master (default)
- `--scope repo` — review entire repository
- `--scope branch <name>` — review specific branch
- `--scope files <pattern>` — review files matching pattern
- `--scope staged` — review staged changes only

## Focus (what to look for)

- `--focus bugs` — find logical bugs, regressions, edge cases (default)
- `--focus security` — find vulnerabilities, injection, path traversal, secrets
- `--focus frontend` — React/Next.js best practices, performance, accessibility
- `--focus performance` — performance issues, waterfalls, bundle size
- `--focus architecture` — coupling, invariants, structural issues
- `--focus over-engineering` — find unnecessary complexity, YAGNI violations

## Shortcuts

For convenience, these shortcuts are supported:

```
/review diff              → --scope diff --focus bugs
/review repo              → --scope repo --focus bugs
/review security          → --scope diff --focus security
/review frontend          → --scope diff --focus frontend
/review --security        → --scope diff --focus security
/review --frontend        → --scope diff --focus frontend
```

## Budget

- `--budget micro` — quick scan, top issues only (5 files max)
- `--budget medium` — comprehensive review (default, 20 files max)
- `--budget full` — deep analysis, all files

## Options

- `--verbose` — show detailed findings with context
- `--dry-run` — explain what would be reviewed without executing

## Examples

```
/review --scope diff --focus security     # Security review of diff
/review --scope repo --focus over-engineering  # Find over-engineering in repo
/review --scope files "src/api/**" --focus performance  # API performance
/review --scope staged --focus bugs       # Bugs in staged changes

# Shortcuts
/review diff                              # Quick bug review of diff
/review repo                              # Full repo bug review
/review security                          # Security review of diff
/review frontend                          # Frontend review of diff

# With budget
/review --scope repo --focus architecture --budget full
/review --scope diff --budget micro
```

## Behavior

1. Determine scope (what code to analyze)
2. Load appropriate skill based on focus
3. Analyze code for issues
4. Report findings with file:line, severity, description, and fix

## Output Format

```
## Review Results

Scope: <scope>
Focus: <focus>
Budget: <budget>

### Findings (N issues)

1. 🔴 CRITICAL — src/auth.ts:45
   Problem: SQL injection vulnerability
   Fix: Use parameterized queries

2. 🟡 WARNING — src/api/users.ts:78
   Problem: Missing input validation
   Fix: Add zod schema validation

3. 🟢 NIT — src/utils.ts:12
   Problem: Unused import
   Fix: Remove import

### Summary
- Critical: 1
- Warning: 1
- Nit: 1
- Files reviewed: 15
```
