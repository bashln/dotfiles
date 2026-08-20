---
description: Explain what the last command did — files used, skills loaded, tools called, model used, context consumed.
---

Debug and explain what the previous command did.

## Usage

```
/why
```

Run this after any command to understand what happened.

## What it shows

### Files Used
List of files that were read, edited, or created.

### Reason
Why this approach was chosen. What was the goal? What constraints were considered?

### Skills Loaded
Which skills were loaded during execution.

### Tools Called
Which tools were invoked (read, edit, bash, grep, aft_inspect, etc.).

### Agents Delegated
Which subagents were called (if any).

### Model Used
Which model was used for this command.

### Context Consumed
Approximate token usage and file count.

## Output Format

```
## Why This Happened

Command: /impl add user authentication

### Files Used (N)
- src/auth.ts (read, edited)
- src/config.ts (read, edited)
- src/types.ts (read)
- ...

### Reason
User requested user authentication implementation.
Approach: JWT-based auth with bcrypt password hashing.
Constraints: Must integrate with existing user model.

### Skills Loaded
- implement (primary)
- quality-checks (validation)

### Tools Called
- read: 12 calls
- edit: 3 calls
- bash: 2 calls (npm test, npm run lint)
- grep: 1 call

### Agents Delegated
- None (direct execution)

### Model
deepseek-v4-flash

### Context
- Files accessed: 12
- Tokens consumed: ~15K
- Duration: 45 seconds
```

## Use Cases

1. **Debug unexpected behavior** — understand what files were touched
2. **Optimize token usage** — see which skills/tools consumed most context
3. **Learn the system** — understand how commands map to actions
4. **Audit changes** — trace what was done and why

## Examples

```
/impl add OAuth integration
/why                    # Shows what files were modified, skills used, etc.

/review --scope repo --focus security
/why                    # Shows which files were reviewed, what was checked

/plan --architecture
/why                    # Shows analysis scope, files examined, approach taken
```

## Behavior

1. Look at the previous command and its execution
2. Trace all file operations, tool calls, skill loads
3. Report what happened, why, and how much it cost
4. Suggest optimizations if context usage was high
