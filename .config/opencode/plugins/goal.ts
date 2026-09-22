import { mkdirSync, writeFileSync, existsSync, readFileSync, renameSync } from "fs"
import { join } from "path"
import type { Plugin } from "@opencode-ai/plugin"
import { tool } from "@opencode-ai/plugin/tool"

export const GoalPlugin: Plugin = async ({ $, directory }) => {
  const goalFile = () => join(directory, ".ai", "goal.md")
  const archiveDir = () => join(directory, ".ai", "goal.d")

  function ensureDir(dir: string) {
    mkdirSync(dir, { recursive: true })
  }

  function readGoal(): string | null {
    const f = goalFile()
    if (!existsSync(f)) return null
    return readFileSync(f, "utf-8")
  }

  function writeGoal(content: string) {
    const f = goalFile()
    ensureDir(join(directory, ".ai"))
    ensureDir(archiveDir())
    writeFileSync(f, content, "utf-8")
  }

  function updateStatus(newStatus: string): string {
    const content = readGoal()
    if (!content) return "No active goal"
    const updated = content
      .replace(/^status: ".*"/m, `status: "${newStatus}"`)
      .replace(/^updated: ".*"/m, `updated: "${new Date().toISOString()}"`)
    writeGoal(updated)
    return `Goal ${newStatus}`
  }

  return {
    tool: {
      goal_set: tool({
        description: "Set a new durable goal with objective and stopping condition",
        args: {
          objective: tool.schema.string().describe("What needs to be done"),
          stopping_condition: tool.schema.string().describe("Verifiable condition that means the goal is done"),
        },
        async execute({ objective, stopping_condition }) {
          const id = new Date().toISOString().slice(0, 10) + "-" + Math.random().toString(36).slice(2, 6)
          const ts = new Date().toISOString()
          const content = [
            "---",
            `id: "${id}"`,
            `objective: "${objective}"`,
            `stopping_condition: "${stopping_condition}"`,
            `status: "active"`,
            `created: "${ts}"`,
            `updated: "${ts}"`,
            "checkpoints_total: 0",
            "checkpoints_done: 0",
            "checkpoints_blocked: 0",
            "---",
            "",
            "## Progress Log",
            "",
            "| # | Checkpoint | Status | Notes |",
            "|---|-----------|--------|-------|",
          ].join("\n")

          writeGoal(content)

          return { output: `Goal set: ${objective}`, metadata: { goal_id: id } }
        },
      }),

      goal_status: tool({
        description: "Get the current goal state and progress",
        args: {},
        async execute() {
          const content = readGoal()
          if (!content) return { output: "No active goal" }

          const lines = content.split("\n")
          const goal: Record<string, string> = { status: "unknown" }
          for (const line of lines) {
            const m = line.match(/^(\w+):\s*(.+)/)
            if (m) goal[m[1]] = m[2].replace(/^"(.*)"$/, "$1")
          }

          return {
            output: [
              `Objective: ${goal.objective || "?"}`,
              `Status: ${goal.status}`,
              `Progress: ${goal.checkpoints_done || 0}/${goal.checkpoints_total || 0}`,
              `Stopping: ${goal.stopping_condition || "?"}`,
            ].join("\n"),
            metadata: goal,
          }
        },
      }),

      goal_pause: tool({
        description: "Pause the active goal",
        args: {},
        async execute() {
          const result = updateStatus("paused")
          return { output: result }
        },
      }),

      goal_resume: tool({
        description: "Resume a paused goal",
        args: {},
        async execute() {
          const result = updateStatus("active")
          return { output: result }
        },
      }),

      goal_clear: tool({
        description: "Clear and archive the current goal",
        args: {},
        async execute() {
          const f = goalFile()
          if (!existsSync(f)) return { output: "No active goal to clear" }

          const ts = new Date().toISOString().replace(/[:.]/g, "-")
          ensureDir(archiveDir())
          renameSync(f, join(archiveDir(), `goal-${ts}.md`))
          return { output: "Goal cleared and archived" }
        },
      }),
    },

    "tool.execute.before": async (input, output) => {
      const toolName = String(input?.tool ?? "").toLowerCase()
      if (!toolName.startsWith("goal_")) return

      const content = readGoal()
      if (!content) return

      const statusMatch = content.match(/^status:\s*"(\w+)"/m)
      if (statusMatch && statusMatch[1] === "paused" && toolName !== "goal_resume" && toolName !== "goal_status") {
        const args = output?.args
        if (args && typeof args === "object") {
          ;(args as any)._blocked = "Goal is paused. Use /goal resume to continue."
        }
      }
    },
  }
}
