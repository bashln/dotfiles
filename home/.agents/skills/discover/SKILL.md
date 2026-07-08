---
name: discover
description: >
  Map the repository before implementing changes.
  Locates relevant files, identifies dependencies, and reports structure.
  Read-only. Does not edit files or propose implementation code.
---

## Objective

Map the relevant area of the codebase before making changes.
Locates files and reports structure without implementing anything.

## Workflow

1. Parse the task to identify what to find.
2. If changes exist, run `git diff` for context.
3. Search for candidates:
   - `rg` for symbols, patterns, imports
   - `glob` for filenames
   - `git log -S` for history (when relevant)
4. Read only the top candidates found by search.
   If more context is needed, explain why before expanding.
5. Report:
   - Files and their roles
   - Dependencies between them
   - Potential risks

## Output format

```
Path:line — symbol — role (≤8 words)
Path:line — symbol — role (≤8 words)
```

Group by directory. One group header per directory.

## Rules

- Do not edit files.
- Do not propose implementation code.
- Do not run write commands.
- Read only candidates found by search, not entire directories.
- If nothing relevant is found, report "No relevant code found."
