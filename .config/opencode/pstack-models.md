# pstack model configuration (OpenCode)
# Per-role model overrides. Values are `provider/model` slugs the OpenCode subagent tool accepts.
# Delete a line to fall back to the skill default. `inherit-parent` or `auto` runs the role on the parent session model.
# Panels span model families (deepseek / mimo / claude / gpt-luna) so an independent verdict comes from a different family.

feature, refactoring: opencode-go/mimo-v2.6-pro
bug-fix: opencode-go/deepseek-v4-pro
perf-issue: opencode-go/deepseek-v4-pro
hillclimb: opencode-go/deepseek-v4-pro
judgment and prose: opencode-go/mimo-v2.6-pro
strongest judgment: opencode-go/deepseek-v4-pro
how explorer: opencode-go/mimo-v2.6-flash
how explainer: opencode-go/mimo-v2.6-pro
why investigators: opencode-go/mimo-v2.6-flash
why synthesizer: opencode-go/mimo-v2.6-pro
reflect tooling: opencode-go/mimo-v2.6-flash
reflect judgment, divergent, synthesizer: opencode-go/mimo-v2.6-pro
arena runners: opencode-go/claude-haiku-5-5, opencode-go/gpt-6-luna, opencode-go/mimo-v2.6-pro
arena cross-judge pool: opencode-go/gpt-6-luna, opencode-go/claude-haiku-5-5, opencode-go/mimo-v2.6-pro
swarm workers: opencode-go/mimo-v2.6-flash
architect runners: opencode-go/claude-haiku-5-5, opencode-go/gpt-6-luna, opencode-go/mimo-v2.6-pro
interrogate reviewers: opencode-go/gpt-6-luna, opencode-go/claude-haiku-5-5, opencode-go/mimo-v2.6-pro

default effort: session
session hook: off
