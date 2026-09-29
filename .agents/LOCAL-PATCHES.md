# LOCAL-PATCHES — ui-ux-pro-max bundle

Patches locais aplicados em 2026-09-29 por cima das skills instaladas do bundle
`ui-ux-pro-max` (instaladas via `uipro`/`ui-ux-pro-max-cli`).

Motivo: o bundle referencia skills externas que **não** vêm no pacote
(`ai-artist`, `ai-multimodal`, `chrome-devtools`, `frontend-design`) e 2 skills
internas inexistentes (`project-management`, `assets-organizing`). As refs foram
suavizadas para "use se instalado, senão degrade para HTML/CSS / screenshot
manual". Também foram corrigidos paths `~/.claude/skills` → `~/.agents/skills`
e namespaces `/ck:`/`/ckm:`.

⚠️ `uipro update` / reinstalação sobrescreve estes arquivos. Reaplicar após update.

## Arquivos patchados

| Arquivo | O que mudou |
|---|---|
| `design/SKILL.md` | deps opcionais suavizadas, paths `.agents`, nota de topo |
| `banner-design/SKILL.md` | bloco AI marcado opcional, paths neutros `<skill>/...` |
| `design/references/social-photos-design.md` | chrome-devtools como opcional + fallback |
| `brand/scripts/extract-colors.cjs` | comentários/mensagem (sem mudança de lógica) |
| `design`, `brand`, `slides`, `banner-design` (todos) | paths `~/.claude/skills` → `~/.agents/skills` |

## Regenerar do zero

Se reinstalar o bundle, reaplicar:
1. `sed 's|~/.claude/skills|~/.agents/skills|g; s|\.claude/skills|.agents/skills|g'`
2. Suavizar refs a `ai-artist|ai-multimodal|chrome-devtools|frontend-design|project-management|assets-organizing`.
