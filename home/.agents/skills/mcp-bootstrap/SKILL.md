---
name: mcp-bootstrap
description: Configura MCP servers (Codex, Gemini, OpenCode) no repositório atual.
---

## Objetivo

Criar e gerenciar a configuração de MCP servers no repositório atual.
Suporta dois formatos:

1. **`.agents/<tool>/mcp.toml`** — para Codex e Gemini CLI
2. **`opencode.json`** (seção `mcp`) — para opencode

## Quando usar

- Um repositório novo precisa de MCP servers (Codex, Gemini CLI e/ou opencode)
- Um repositório existente precisa de MCP servers adicionais
- opencode não reconhece servidores MCP configurados (`opencode mcp list` vazio)

## Regras CRÍTICAS

### MCPs são POR PROJETO — NUNCA globais

- **Codex/Gemini**: MCP servers em `<project-root>/.agents/<tool>/mcp.toml`
- **Opencode**: MCP servers em `<project-root>/opencode.json`, seção `"mcp"`
- **NUNCA** crie MCP configs em `~/.agents/` (isso é GLOBAL = PROIBIDO)
- **NUNCA** use `$HOME` como raiz de projeto para o filesystem server
- **Skills e agentes** ficam em `~/.agents/<tool>/` (esses sim são globais)
- **MCPs** pertencem ao projeto, skills/agentes pertencem ao usuário

### Outras regras

- Use apenas caminhos relativos; nunca absolutos
- Use `.` como raiz do projeto quando um MCP server precisar de um path root
- Não modifique código de aplicação
- Adicione `.agents/` ao `.gitignore` do repositório
- Não commite `opencode.json` se ele contiver secrets ou tokens
- Para servidores locais, `command` deve ser um array de strings (ex: `["npx", "-y", "..."]`)
- Defina `enabled: true` para ativar o servidor na inicialização

## Workflow

### Codex / Gemini CLI

1. Verifique se `.agents/` já existe no repositório
2. **VALIDE**: certifique-se de que `pwd` NÃO é `$HOME` — abortar se for
3. Crie `.agents/<tool>/mcp.toml` com os MCP servers necessários
4. Crie `.agents/openai.yaml` com as dependências npm necessárias
5. Adicione `.agents/` ao `.gitignore` se ainda não estiver lá

### opencode

1. Verifique se `opencode.json` já existe no repositório
   - Se não existir, crie com o schema `"$schema": "https://opencode.ai/config.json"`
2. Adicione a seção `"mcp"` com os servidores desejados
   - Formato: `"nome-do-servidor": { "type": "local", "command": [...], "enabled": true }`
3. Se o arquivo já tinha outras seções (`agent`, `tools` etc.), mantenha-as
4. Adicione `opencode.json` ao `.gitignore` apenas se conter dados sensíveis

## Exemplos

### Codex / Gemini (`.agents/<tool>/mcp.toml`)

```toml
# .agents/codex/mcp.toml
[mcp.servers.filesystem]
type = "stdio"
command = ["npx", "-y", "@modelcontextprotocol/server-filesystem", "."]
enabled = true

[mcp.servers.git]
type = "stdio"
command = ["npx", "-y", "@cyanheads/git-mcp-server"]
enabled = true
```

### opencode (`opencode.json`)

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "filesystem": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-filesystem", "."],
      "enabled": true
    },
    "git": {
      "type": "local",
      "command": ["npx", "-y", "@cyanheads/git-mcp-server"],
      "enabled": true
    }
  }
}
```

Também é possível adicionar variáveis de ambiente por servidor:

```json
"meu-servidor": {
  "type": "local",
  "command": ["npx", "-y", "meu-pacote-mcp"],
  "enabled": true,
  "environment": {
    "MINHA_CHAVE": "{env:MINHA_CHAVE}"
  }
}
```

## Output

- Codex/Gemini: arquivos criados/modificados em `.agents/`
- opencode: `opencode.json` criado/atualizado no raiz do projeto
- Comando(s) de validação
- Gaps restantes (se houver)

## Validação

### Codex / Gemini

- ✅ Confirme que `.agents/<tool>/mcp.toml` existe no repositório
- ✅ Confirme que `~/.agents/<tool>/` NÃO foi criado
- ✅ Confirme que `.agents/` está no `.gitignore`
- ✅ Confirme que `pwd != $HOME`

### opencode

- ✅ Confirme que `opencode.json` existe no repositório
- ✅ Confirme que `opencode.json` contém a seção `"mcp"` com os servidores esperados
- ✅ Execute `opencode mcp list` e confirme que os servidores aparecem como configurados
- ✅ Se `opencode.json` for novo, confirme que tem `$schema` apontando para `https://opencode.ai/config.json`
