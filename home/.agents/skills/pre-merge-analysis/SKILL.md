---
name: pre-merge-analysis
description: "Analisa estado git do repositório: branch, status, commits locais/remotos, divergência, comparação com branch alvo e recomendação de merge. Use antes de merge, PR, push, ou quando precisar entender estado atual da branch e próximos passos."
---

## Objective

Check git state and produce merge-readiness report. No changes made.

## Use for

- Before merge or PR creation
- After long development branch, check sync status
- When assessing branch state or divergence
- Before push to verify no unpulled commits
- When planning commit grouping for unstaged work

## Workflow

1. **Current branch** — `git branch --show-current`
2. **Status** — `git status` (staged, unstaged, untracked)
3. **Local commits not pushed** — `git log origin/<branch>..HEAD --oneline`
4. **Remote commits not pulled** — `git log HEAD..origin/<branch> --oneline`
5. **Branch divergence** — count ahead/behind with `git rev-list --count`

## If local changes without commit

- List changed files grouped by concern (feature, fix, refactor, config, etc.)
- Do NOT commit
- Suggest logical commit grouping (e.g., "commit 1: auth fix; commit 2: style tweaks")
- Wait for decision

## If branch diverges from remote

- Show local-only and remote-only commits
- Explain sync impact (rebase vs merge trade-offs)
- Flag potential conflicts: `git merge-tree` or diff with target

## Compare with target branch (main/master/develop)

- Detect target: `git remote show origin` or try main/master/develop
- Summary diff: `git diff <target>..HEAD --stat`
- Critical files: config, dependencies, migrations, schemas
- Merge conflicts: `git merge-tree $(git merge-base HEAD <target>) HEAD <target>` (consultative, no side effects)
- Risks: regressions, breaking changes, missing migrations

## Final report

- **State**: clean / dirty / diverged / ahead / behind
- **Pending**: uncommitted / unpushed / unpulled / conflict risk
- **Recommendation**:
  - `ready` — merge safe
  - `sync` — pull/push needed first
  - `review` — needs code review before merge
  - `commit` — needs commits before merge

## Constraints

- Read-only: never stage, commit, push, pull, merge, rebase, or abort
- Target branch auto-detected (main > master > develop)
