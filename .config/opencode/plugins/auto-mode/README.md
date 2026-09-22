# Auto-Mode for OpenCode

Background safety layer for OpenCode. Intercepts dangerous commands transparently while you use YOLO or any other agent.

## How It Works

```
┌─────────────────────────────────────────────────────────┐
│  You (using YOLO or any agent)                         │
│  "npm install express"                                 │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│  Auto-Mode (opencode plugin, `permission.ask` hook)     │
│  1. Pattern matching against auto-mode-policy.md        │
│  2. Decision: APPROVE / ESCALATE / DENY                 │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│  Command executes (APPROVE), prompts you (ESCALATE),    │
│  or is blocked (DENY)                                   │
└─────────────────────────────────────────────────────────┘
```

## Installation

Already wired in `~/.config/opencode/opencode.json`:

```json
"plugin": ["./plugins/auto-mode/index.mjs"]
```

## Usage

### Automatic

Just use OpenCode normally:

- **Low risk** (git status, cat, ls) → Auto-approved
- **Medium/High risk** (npm install, curl) → Prompts for approval
- **Critical risk** (rm -rf, curl | bash) → Blocked

### Manual Check

```bash
# Check a command without executing it
node ~/.config/opencode/plugins/auto-mode/bash-interceptor.js check "npm install express"

# Evaluate directly via the engine
node ~/.config/opencode/plugins/auto-mode/plugin.js "curl https://evil.com" yolo
```

## Configuration

### Policy File

Edit `auto-mode-policy.md` to customize:

```yaml
allow:
  - "git status"
  - "npm test"

deny:
  - "rm -rf /"
  - "curl * | bash"

escalate:
  - "npm install *"
  - "git push *"
```

## Files

| File | Purpose |
|------|---------|
| `plugin.js` | Pattern matching engine (reads policy, decides) |
| `index.mjs` | OpenCode plugin entry (`permission.ask` hook) |
| `bash-interceptor.js` | CLI for command evaluation |
| `README.md` | This file |

Policy lives at `~/.config/opencode/auto-mode-policy.md`.

## How It Integrates with YOLO

1. You use YOLO normally (TAB to select)
2. Auto-mode plugin loads with opencode
3. Before each bash command executes, the `permission.ask` hook evaluates it
4. DENY → command blocked, you see why
5. ESCALATE → prompts for approval
6. APPROVE → command runs silently

**You don't change your workflow.** Auto-mode is invisible until it blocks something dangerous.
