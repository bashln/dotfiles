# LOCAL-PATCHES — obsoleto

> **OBSOLETO desde 2026-10-06.** O bundle `ui-ux-pro-max` foi removido de
> `.agents/skills/` na limpeza que migrou para o pstack.
>
> Os arquivos patchados estão preservados (com os patches aplicados) em
> `skills-old-20261006.zip`, na raiz do repo dotfiles.
>
> Não reaplicar nada daqui. Se o bundle voltar um dia, o conteúdo do zip é a
> referência do estado final, patches já inclusos.

## Histórico (mantido só para contexto)

Patches locais aplicados em 2026-09-29 sobre as skills do bundle
`ui-ux-pro-max` (instaladas via `uipro`/`ui-ux-pro-max-cli`).

Motivo: o bundle referenciava skills externas que não vêm no pacote
(`ai-artist`, `ai-multimodal`, `chrome-devtools`, `frontend-design`) e 2 skills
internas inexistentes (`project-management`, `assets-organizing`). As refs foram
suavizadas para "use se instalado, senão degrade para HTML/CSS / screenshot
manual". Também foram corrigidos paths `~/.claude/skills` → `~/.agents/skills`
e namespaces `/ck:`/`/ckm:`.

Arquivos que estavam patchados: `design/SKILL.md`, `banner-design/SKILL.md`,
`design/references/social-photos-design.md`, `brand/scripts/extract-colors.cjs`,
e todos os paths de `design`, `brand`, `slides`, `banner-design`.
