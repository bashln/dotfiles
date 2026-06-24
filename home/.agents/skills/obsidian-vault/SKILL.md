---
name: obsidian-vault
description: Busca, cria e organiza notas no cofre do Obsidian.
---

# Obsidian Vault

## Vault location

Configurable via environment variable `OBSIDIAN_VAULT_PATH`, or create a `.env` file in this skill directory:
```
OBSIDIAN_VAULT_PATH=/mnt/d/Obsidian Vault/AI Research/
```

Default: `/mnt/d/Obsidian Vault/AI Research/`

## Naming conventions

- **Index notes**: aggregate related topics (e.g., `Ralph Wiggum Index.md`)
- **Title case** for all note names
- No folders — use links and index notes instead

## Linking

- Use `[[wikilinks]]` syntax
- Notes link to dependencies at bottom
- Index notes are lists of `[[wikilinks]]`

## Workflows

### Search for notes
```bash
find "$VAULT_PATH" -name "*.md" | grep -i "keyword"
grep -rl "keyword" "$VAULT_PATH" --include="*.md"
```

### Create a new note
1. Title Case filename
2. Write content as a unit of learning
3. Add `[[wikilinks]]` to related notes at bottom

### Find related notes
```bash
grep -rl "\[\[Note Title\]\]" "$VAULT_PATH"
```

### Find index notes
```bash
find "$VAULT_PATH" -name "*Index*"
```
