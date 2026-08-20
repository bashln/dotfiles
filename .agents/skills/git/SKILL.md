---
name: git
description: Instala guardrails para bloquear comandos git perigosos, resolve merge/rebase conflicts, analisa estado git pré-merge. Use when setting up git safety hooks, resolving merge conflicts, or checking branch merge readiness.
---

# Git

Unified skill for git operations: safety guardrails, merge conflict resolution, and pre-merge analysis. Use the mode that fits your task.

## Modes

| Mode | What it does | When to use |
|---|---|---|
| `guardrails` | Install hooks blocking dangerous git commands (push, reset --hard, clean, branch -D) | Setting up git safety for a project or user account |
| `resolve` | Resolve an in-progress git merge/rebase conflict | During a merge or rebase with conflicts |
| `analyze` | Check git state and produce merge-readiness report (read-only) | Before merge, PR creation, or push |

---

## Mode: guardrails

Set up a PreToolUse hook that intercepts and blocks dangerous git commands.

### What gets blocked

- `git push` (all variants including `--force`)
- `git reset --hard`
- `git clean -f` / `git clean -fd`
- `git branch -D`
- `git checkout .` / `git restore .`

### Steps

1. Ask scope: project only (`.claude/settings.json`) or all projects (`~/.claude/settings.json`)?
2. Copy the hook script from [scripts/block-dangerous-git.sh](scripts/block-dangerous-git.sh) to target location. Make executable.
3. Add hook to settings file. If settings exists, merge into existing `hooks.PreToolUse` array.
4. Ask about customization — add/remove patterns.
5. Verify with a quick test.

### Reference

Hook script: [scripts/block-dangerous-git.sh](scripts/block-dangerous-git.sh)

---

## Mode: resolve

1. See current state: check git history, conflicting files
2. Find primary sources for each conflict: commit messages, PRs, issues
3. Resolve each hunk: preserve both intents where possible. Never `--abort`
4. Discover automated checks and run them (typecheck → tests → format)
5. Finish merge/rebase: stage, commit, continue rebase until done

---

## Mode: analyze

### Workflow

1. Current branch: `git branch --show-current`
2. Status: `git status` (staged, unstaged, untracked)
3. Local commits not pushed: `git log origin/<branch>..HEAD --oneline`
4. Remote commits not pulled: `git log HEAD..origin/<branch> --oneline`
5. Branch divergence: ahead/behind counts

### If local changes without commit

- List changed files grouped by concern
- Suggest logical commit grouping
- Wait for decision

### If branch diverges from remote

- Show local-only and remote-only commits
- Explain sync impact (rebase vs merge trade-offs)
- Flag potential conflicts

### Compare with target branch

- Detect target: `git remote show origin` or try main/master/develop
- Summary diff: `git diff <target>..HEAD --stat`
- Critical files: config, dependencies, migrations, schemas
- Merge conflicts: consultative check with `git merge-tree`
- Risks: regressions, breaking changes, missing migrations

### Final report

- **State**: clean / dirty / diverged / ahead / behind
- **Pending**: uncommitted / unpushed / unpulled / conflict risk
- **Recommendation**: ready / sync / review / commit

### Constraints

- Read-only: never stage, commit, push, pull, merge, rebase, or abort
- Target branch auto-detected (main > master > develop)
