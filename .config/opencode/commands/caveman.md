---
description: Context compression and terse output modes.
---

Activate caveman compression mode or run caveman utilities.

## Usage

```
/caveman [mode]
/caveman commit
/caveman compress <file>
/caveman review
/caveman stats
/caveman help
```

## Modes

Activate compression mode with different intensity levels:

```
/caveman                    # Activate at default level (full)
/caveman lite               # Light compression (~30% tokens dropped)
/caveman full               # Full compression (default)
/caveman ultra              # Maximum compression
/caveman wenyan             # Classical Chinese compression
/caveman wenyan-lite        # Wenyan light
/caveman wenyan-ultra       # Wenyan maximum
/caveman off                # Deactivate
```

Behavior persists until session ends or you say "stop caveman" / "normal mode".

## Subcommands

### /caveman commit
Generate a terse Conventional Commit message for staged changes.

Format: Subject line ≤50 chars, imperative, lowercase after type. No period on subject. Body only when "why" isn't obvious from subject.

```
/caveman commit
```

### /caveman compress <file>
Compress a markdown/text file into caveman format.

Rewrites prose into terse caveman style — drops articles, filler, hedging — while preserving code blocks, inline code, URLs, file paths, commands, and markdown structure exactly.

Only compresses natural-language files (.md, .txt, .typ, .tex, extensionless). Refuses source/config files.

```
/caveman compress README.md
```

### /caveman review
Caveman-style code review — one-line findings with severity.

One line per finding. Format: `L<line>: <severity> <problem>. <fix>.`
Severity emoji: 🔴 critical · 🟡 warn · 🟢 nit. Skip non-issues.
Group by file. End with one-line verdict.

```
/caveman review
/caveman review src/auth.ts
```

### /caveman stats
Show caveman lifetime token-savings stats.

Total tokens saved, sessions, average compression ratio. One short table.

```
/caveman stats
```

### /caveman help
Show quick reference card for caveman modes, subcommands, and triggers.

```
/caveman help
```

## Natural Language

You can also activate/deactivate with natural language:

- "turn on caveman"
- "activate caveman mode"
- "stop caveman"
- "normal mode"

## Behavior

When caveman mode is active:
- Drop articles (a/an/the), filler (just/really/basically), pleasantries, hedging
- Fragments OK. Short synonyms. Technical terms exact.
- Pattern: [thing] [action] [reason]. [next step].
- Code, commits, security warnings: write normal English.

## Examples

```
/caveman                          # Activate full mode
/caveman lite                     # Activate lite mode
/caveman commit                   # Generate terse commit message
/caveman compress docs/notes.md   # Compress markdown file
/caveman review src/api/          # One-line review
/caveman stats                    # Show token savings
/caveman off                      # Deactivate
```
