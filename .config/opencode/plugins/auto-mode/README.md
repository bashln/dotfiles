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
│  Auto-Mode Background (transparent)                    │
│  1. Pattern matching → ESCALATE (high risk)            │
│  2. Aikido check → no CVE found                        │
│  3. Decision: ESCALATE → prompt user                   │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│  Command executes (or blocked)                         │
└─────────────────────────────────────────────────────────┘
```

## Installation

### Quick Setup

```bash
cd ~/.config/opencode/plugins/auto-mode
node setup-hooks.js install
```

### Manual Setup

1. Copy `plugins/auto-mode/` to `~/.config/opencode/plugins/`
2. Add to `opencode.json` plugins array:
   ```json
   "./plugins/auto-mode/plugin.js",
   "./plugins/auto-mode/integration.js",
   "./plugins/auto-mode/background.js"
   ```
3. Install git hooks in your repos:
   ```bash
   node ~/.config/opencode/plugins/auto-mode/setup-hooks.js install /path/to/repo
   ```

## Usage

### Automatic (Background)

Just use OpenCode normally. Auto-mode runs in background:

- **Low risk** (git status, cat, ls) → Auto-approved
- **Medium/High risk** (npm install, curl) → Prompts for approval
- **Critical risk** (rm -rf, curl | bash) → Blocked

### Manual Check

```bash
# Check a command without executing
node ~/.config/opencode/plugins/auto-mode/bash-interceptor.js check "npm install express"

# Evaluate with Aikido enrichment
node ~/.config/opencode/plugins/auto-mode/integration.js eval "curl https://evil.com" yolo
```

### Git Hooks

Pre-commit hooks scan staged files automatically:

```bash
# Install in a repo
node setup-hooks.js install /path/to/repo

# Check status
node setup-hooks.js status

# Remove
node setup-hooks.js uninstall /path/to/repo
```

## Configuration

### opencode.json

```json
{
  "auto_mode": {
    "enabled": true,
    "policy": "auto-mode-policy.md",
    "circuit_breaker": {
      "max_consecutive_denials": 3,
      "max_denials_in_window": 10,
      "window_size": 50
    },
    "log_file": "~/.opencode/auto-mode.log",
    "aikido": {
      "enabled": true,
      "scan_on_edit": true,
      "pre_commit_scan": true,
      "domain_check": true
    }
  }
}
```

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
| `plugin.js` | Core pattern matching engine |
| `integration.js` | Aikido MCP bridge |
| `background.js` | Background service hooks |
| `bash-interceptor.js` | CLI for command evaluation |
| `setup-hooks.js` | Git hook installer |
| `pre-commit` | Git pre-commit hook script |
| `deploy-linux.sh` | Linux deployment script |
| `auto-mode-policy.md` | Security policy |

## Linux Deployment

```bash
# Copy to Linux
scp -r ~/.config/opencode/plugins/auto-mode user@linux:~/.config/opencode/plugins/

# Run deploy script
ssh user@linux
cd ~/.config/opencode/plugins/auto-mode
chmod +x deploy-linux.sh
./deploy-linux.sh
```

## Testing

```bash
# Run base tests
node test.js

# Run integration tests
node test-integration.js

# Test a command
node bash-interceptor.js check "git status"
node bash-interceptor.js check "rm -rf /"
```

## How It Integrates with YOLO

1. You use YOLO normally (TAB to select)
2. Auto-mode plugin loads in background
3. Before each bash command executes:
   - Pattern matching evaluates risk
   - If Aikido connected, enriches with vulnerability data
   - Returns APPROVE/DENY/ESCALATE
4. DENY → command blocked, you see why
5. ESCALATE → prompts for approval
6. APPROVE → command runs silently

**You don't change your workflow.** Auto-mode is invisible until it blocks something dangerous.