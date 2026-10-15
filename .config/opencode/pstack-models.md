# pstack model configuration (OpenCode)
# Per-role model overrides. Values are `provider/model` slugs the OpenCode subagent tool accepts.
# Cheap tier only. mimo-v2.6-flash 0.14/0.28, mimo-v2.6-pro 0.435/0.87, muse-spark-1.3-contributor 0.1/0.2, gpt-6-luna 0.1/0.5 (USD por M in/out).
# Delete a line to fall back to the skill default. `inherit-parent` or `auto` runs the role on the parent session model.

feature, refactoring: opencode-go/mimo-v2.6-pro
bug-fix: opencode-go/mimo-v2.6-pro
perf-issue: opencode-go/mimo-v2.6-pro
hillclimb: opencode-go/mimo-v2.6-pro
judgment and prose: opencode-go/mimo-v2.6-pro
strongest judgment: opencode-go/mimo-v2.6-pro
how explorer: opencode-go/mimo-v2.6-flash
how explainer: opencode-go/mimo-v2.6-pro
why investigators: opencode-go/mimo-v2.6-flash
why synthesizer: opencode-go/mimo-v2.6-pro
reflect tooling: opencode-go/mimo-v2.6-flash
reflect judgment, divergent, synthesizer: opencode-go/mimo-v2.6-pro
arena runners: opencode-go/muse-spark-1.3-contributor, opencode-go/gpt-6-luna, opencode-go/mimo-v2.6-pro
arena cross-judge pool: opencode-go/gpt-6-luna, opencode-go/muse-spark-1.3-contributor, opencode-go/mimo-v2.6-pro
swarm workers: opencode-go/mimo-v2.6-flash
architect runners: opencode-go/muse-spark-1.3-contributor, opencode-go/gpt-6-luna, opencode-go/mimo-v2.6-pro
interrogate reviewers: opencode-go/gpt-6-luna, opencode-go/muse-spark-1.3-contributor, opencode-go/mimo-v2.6-pro

default effort: session
session hook: off
