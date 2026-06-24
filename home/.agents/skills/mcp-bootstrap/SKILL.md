---
name: mcp-bootstrap
description: Configura MCP servers (Codex, Gemini, OpenCode) no repositório atual.
---

## Objetivo

Criar e gerenciar MCP server config no repositório atual. Suporta `.agents/<tool>/mcp.toml` (Codex/Gemini) e `opencode.json` (opencode).

## Quando usar

- Repositório novo precisa de MCP servers
- Repositório existente precisa de servidores adicionais
- opencode não reconhece servidores configurados

## Regras CRÍTICAS

- **MCPs são POR PROJETO — NUNCA globais.** Codex/Gemini em `.agents/<tool>/mcp.toml`, opencode em `opencode.json`.
- **NUNCA** crie em `~/.agents/` (global = proibido). Skills/agentes ficam em `~/.agents/<tool>/`.
- Use apenas caminhos relativos. `.` como raiz do projeto.
- Adicione `.agents/` ao `.gitignore`. Não commite `opencode.json` com secrets.
- Para servidores locais, `command` deve ser array de strings.
- Defina `enabled: true`.

## Workflow

### Codex / Gemini
1. Verifique se `.agents/` existe. VALIDE: `pwd` não é `$HOME`.
2. Crie `.agents/<tool>/mcp.toml` com os servidores.
3. Crie `.agents/openai.yaml` com dependências npm.
4. Adicione `.agents/` ao `.gitignore`.

### opencode
1. Verifique/crie `opencode.json` com schema `https://opencode.ai/config.json`.
2. Adicione seção `"mcp"` com servidores.
3. Mantenha seções existentes (`agent`, `tools` etc.).
4. Adicione ao `.gitignore` só se contiver dados sensíveis.

## Validação

- Codex/Gemini: confirme `.agents/<tool>/mcp.toml` existe, `~/.agents/<tool>/` NÃO foi criado, `.agents/` está no `.gitignore`.
- opencode: confirme `opencode.json` existe com seção `"mcp"`, execute `opencode mcp list`.
