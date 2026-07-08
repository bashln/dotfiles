---
description: Find files, dependencies, flows, integration points. Read-only.
---

Find files, dependencies, code flows, integration points, or patterns in the codebase.

## Permissions

✅ READ-ONLY — never modify anything
- ✅ Read files
- ✅ Grep/rg/find
- ✅ aft_inspect, aft_outline, aft_zoom
- ✅ Git log/diff/show
- ❌ Edit/write files
- ❌ Bash that modifies
- ❌ Commit/push

## Usage

```
/discover <pattern>              # Find files by name/content
/discover --deps <package>       # Find dependencies of a package
/discover --flow <concept>       # Trace data/logic flow
/discover --integration <system> # Find integration points
/discover --dead-code            # Find unused code
/discover --duplicates           # Find duplicate code
```

## Flags

### Scope
- `--scope repo` — search entire repository (default)
- `--scope dir <path>` — search specific directory
- `--scope recent` — search recent changes (last 7 days)

### Focus
- `--focus files` — find files by name or content pattern
- `--focus deps` — find package dependencies
- `--focus flow` — trace data/logic flow for a concept
- `--focus integration` — find integration points with external systems
- `--focus dead-code` — find unused code, exports, imports
- `--focus duplicates` — find duplicate code patterns

### Options
- `--verbose` — show detailed output with file paths and line numbers
- `--dry-run` — explain what would be searched without executing
- `--budget micro|medium|full` — control search depth (default: medium)
  - `micro`: quick grep, top 5 results
  - `medium`: comprehensive search, top 20 results
  - `full`: deep analysis with call graphs and dependencies

## Examples

```
/discover auth                              # Find files related to auth
/discover --deps react                      # Who uses react?
/discover --flow checkout                   # Trace checkout flow
/discover --integration stripe              # Where do we integrate with stripe?
/discover --dead-code                       # Find unused code
/discover --duplicates                      # Find duplicate patterns

/discover --scope dir src/api --focus flow  # Trace flows in src/api
/discover --focus deps --budget full        # Deep dependency analysis
```

## Behavior

1. Parse the pattern or flags to understand what to find
2. Use appropriate tools (grep, rg, find, aft_inspect, etc.)
3. Return structured results: file paths, line numbers, context
4. Never modify anything — this is pure discovery

## Output Format

```
## Discovery Results

Found N matches for "<pattern>":

### Files
- src/auth.ts:12 — authentication logic
- src/oauth.ts:45 — OAuth integration
- ...

### Dependencies
Package "react" is used by:
- src/components/*.tsx (12 files)
- src/pages/*.tsx (8 files)

### Flow
Checkout flow:
1. src/cart.ts → src/checkout.ts → src/payment.ts
2. ...

### Integration Points
Stripe integration:
- src/payment.ts:78 — stripe.charges.create()
- src/webhooks.ts:23 — stripe webhook handler
```
