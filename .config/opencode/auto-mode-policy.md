# Auto-Mode Safety Policy

## Overview

This policy defines what actions are allowed, denied, or require escalation
in the opencode Auto-Mode system.

## Allow List (Low Risk)

These actions are auto-approved without review:

```yaml
allow:
  # Git operations (read-only)
  - "git status"
  - "git diff"
  - "git log"
  - "git show"
  - "git branch"
  - "git stash list"
  
  # File operations (read-only)
  - "cat *"
  - "ls *"
  - "find *"
  - "grep *"
  - "head *"
  - "tail *"
  - "wc *"
  
  # Code execution (safe)
  - "npm test"
  - "npm run lint"
  - "npm run build"
  - "cargo test"
  - "cargo clippy"
  - "go test"
  - "pytest"
  - "bun test"
  
  # Formatting
  - "prettier --write"
  - "black"
  - "gofmt"
  - "rustfmt"
```

## Deny List (Critical Risk)

These actions are always denied:

```yaml
deny:
  # Data exfiltration
  - "curl * | *"
  - "wget * | *"
  - "nc *"
  - "ssh *"
  - "scp *"
  - "rsync *"
  
  # Credential harvesting
  - "grep -r password"
  - "grep -r secret"
  - "grep -r token"
  - "grep -r api_key"
  - "cat ~/.ssh/*"
  - "cat ~/.aws/*"
  - "cat ~/.config/*"
  
  # Destructive operations
  - "rm -rf /"
  - "rm -rf ~"
  - "rm -rf /*"
  - "dd if=*"
  - "mkfs *"
  - "format *"
  
  # System modification
  - "chmod 777"
  - "chown *"
  - "systemctl *"
  - "service *"
  - "crontab -e"
  
  # Policy bypass
  - "sudo *"
  - "su -"
  - "env *"
  - "export *"
```

## Escalate List (High Risk)

These actions require human approval:

```yaml
escalate:
  # Network operations
  - "curl *"
  - "wget *"
  - "http *"
  - "fetch *"
  
  # Package management
  - "npm install *"
  - "pip install *"
  - "cargo add *"
  - "go get *"
  - "brew install *"
  
  # Git operations (write)
  - "git push *"
  - "git commit *"
  - "git merge *"
  - "git rebase *"
  - "git reset *"
  - "git checkout *"
  
  # File operations (write)
  - "echo * >"
  - "cat * >"
  - "tee *"
  - "mv *"
  - "cp *"
  
  # Docker/container
  - "docker run *"
  - "docker exec *"
  - "docker-compose *"
  
  # Environment
  - "export *"
  - "set *"
  - "source *"
```

## Custom Rules

Add project-specific rules here:

```yaml
custom:
  # Example: Only allow deploys from main branch
  - pattern: "npm run deploy"
    condition: "git branch == main"
    action: escalate
  
  # Example: Block specific packages
  - pattern: "npm install *"
    deny_packages: ["left-pad", "event-stream"]
    action: deny
  
  # Example: Require tests before commit
  - pattern: "git commit *"
    require: "npm test pass"
    action: escalate
```

## Configuration

Override defaults in `opencode.json`:

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
    "escalation_timeout": 300,
    "log_file": "~/.opencode/auto-mode.log"
  }
}
```

## Logging

All decisions are logged to `~/.opencode/auto-mode.log`:

```json
{
  "timestamp": "2026-09-17T10:30:00Z",
  "action": "curl https://api.example.com",
  "risk_level": "high",
  "decision": "ESCALATE",
  "rationale": "External network request",
  "agent": "yolo",
  "session": "abc123"
}
```

## Override Logging

When user overrides a denial:

```json
{
  "timestamp": "2026-09-17T10:35:00Z",
  "action": "curl https://api.example.com",
  "original_decision": "DENY",
  "override_by": "user",
  "override_reason": "Known safe API",
  "retry_allowed": true
}
```