---
name: find-skills
description: Discover/install relevant agent skills for "how do I", "find a skill", or capability requests.
---

## When to Use

User asks "how do I do X", "find a skill for X", "is there a skill for X", "can you do X" where X is specialized, or wishes for help in a domain.

## How to Help

### 1. Understand the need
Identify the domain (React, testing, design) and specific task.

### 2. Check the leaderboard
Check https://skills.sh/ for well-known skills first.

### 3. Search for skills
```bash
npx skills find [query]
```
Use specific keywords: "react testing" is better than "testing".

### 4. Verify quality
Check install count (1K+ preferred), source reputation (official sources trusted), GitHub stars (<100 stars = skeptical).

### 5. Present options
Show skill name, what it does, install count, install command, and skills.sh link.

### 6. Offer to install
```bash
npx skills add <owner/repo@skill> -g -y
```

### When no skills found
Acknowledge, offer help directly, suggest `npx skills init` to create one.

## Common Categories

Web Dev, Testing, DevOps, Documentation, Code Quality, Design, Productivity.
