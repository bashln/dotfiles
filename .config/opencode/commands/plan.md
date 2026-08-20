---
description: Plan implementation, analyze architecture, decompose features.
agent: planner
---

Plan implementation, analyze architecture, or decompose features into actionable steps.

## Usage

```
/plan [description]
/plan --quick <question>
/plan --feature <description>
/plan --architecture
/plan --refactor <description>
```

## Modes

### Default (no flags)
Comprehensive planning. Analyze repository, identify implementation shape, report risks and dependencies.

```
/plan implement user authentication
```

### --quick
Quick planning. 1-2 paragraph response, up to 5 files max.

```
/plan --quick how to add caching to API?
```

### --feature
Feature-specific planning. Decompose feature into tasks and implementation steps.

```
/plan --feature notification system
```

### --architecture
Deep architectural analysis. Analyze entire project structure, coupling, invariants.

```
/plan --architecture
```

### --refactor
Refactoring plan. Identify refactoring opportunities and safe migration path.

```
/plan -- refactor auth module to use new pattern
```

## Scope

- `--scope repo` — analyze entire repository (default for --architecture)
- `--scope dir <path>` — analyze specific directory
- `--scope files <pattern>` — analyze files matching pattern

## Budget

- `--budget micro` — quick analysis, 5 files max (default for --quick)
- `--budget medium` — focused analysis, 20 files max (default)
- `--budget full` — comprehensive analysis, entire project (default for --architecture)

## Options

- `--verbose` — show detailed analysis with file paths and dependencies
- `--dry-run` — explain what would be analyzed without executing

## Examples

```
/plan                                    # Comprehensive planning
/plan --quick how to add caching?        # Quick answer
/plan --feature notification system      # Feature decomposition
/plan --architecture                     # Deep architecture analysis
/plan --refactor auth module             # Refactoring plan

/plan --scope dir src/api --budget full  # Deep analysis of src/api
/plan --budget micro fix login bug       # Quick analysis
```

## Behavior

1. Parse description and flags
2. Determine scope and budget
3. Analyze repository structure and code
4. Identify implementation shape, risks, dependencies
5. Report concrete next-step plan

## Output Format

```
## Plan

Mode: <default|quick|feature|architecture|refactor>
Scope: <scope>
Budget: <budget>

### Analysis
- Repository structure: ...
- Key dependencies: ...
- Implementation approach: ...

### Risks
- Risk 1: ...
- Risk 2: ...

### Next Steps
1. Step 1
2. Step 2
3. Step 3

### Dependencies
- Dependency 1
- Dependency 2
```
