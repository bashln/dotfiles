# Copilot no VS Code — agente `executor-seguro` + guard de comandos

Par de customizações globais (nível de **perfil de usuário**, valem em qualquer workspace):

- **Agente** `executor-seguro`: executa comandos seguros sem pedir permissão e para nos perigosos.
- **Guard** `command-guard.js`: hook `PreToolUse` que classifica cada comando em `allow` / `ask` / `deny`.

## Mapeamento de arquivos

| No dotfiles                                                 | Destino Windows                       | Destino Linux                         |
| ----------------------------------------------------------- | ------------------------------------- | ------------------------------------- |
| `.copilot/hooks/command-guard.js`                           | `%USERPROFILE%\.copilot\hooks\`       | `~/.copilot/hooks/`                   |
| `.config/Code/User/prompts/agents/executor-seguro.agent.md` | `%APPDATA%\Code\User\prompts\agents\` | `~/.config/Code/User/prompts/agents/` |

A pasta `~/.copilot/hooks/` é livre: para **hooks de agente** o VS Code executa o comando do frontmatter
diretamente, então essa pasta não precisa estar em `chat.hookFilesLocations`.

## Instalação (Linux)

```bash
git pull
mkdir -p ~/.copilot/hooks ~/.config/Code/User/prompts/agents
cp .copilot/hooks/command-guard.js ~/.copilot/hooks/
cp .config/Code/User/prompts/agents/executor-seguro.agent.md ~/.config/Code/User/prompts/agents/
```

Alternativa com symlink (mantém sincronizado com o repo):

```bash
ln -sf "$PWD/.copilot/hooks/command-guard.js" ~/.copilot/hooks/command-guard.js
ln -sf "$PWD/.config/Code/User/prompts/agents/executor-seguro.agent.md" ~/.config/Code/User/prompts/agents/executor-seguro.agent.md
```

Variantes (VSCodium, Insiders) usam `~/.config/Code - Insiders/User/prompts/agents/`.

## Instalação (Windows)

```powershell
.\link-dotfiles.ps1   # cria os links de .copilot\ e prompts\agents
```

Ou manual:

```powershell
Copy-Item .\.copilot\hooks\command-guard.js "$env:USERPROFILE\.copilot\hooks\" -Force
Copy-Item ".\.config\Code\User\prompts\agents\executor-seguro.agent.md" "$env:APPDATA\Code\User\prompts\agents\" -Force
```

## Pré-requisitos

1. **Node.js no PATH** — `node --version` (o guard é um script Node).
2. Setting obrigatória para hooks no agente (agent-scoped hooks é preview):
   `"chat.useCustomAgentHooks": true` em `settings.json`.
3. A linha do hook no `.agent.md` já traz as duas variantes:
   `command` (`node "$HOME/.copilot/hooks/command-guard.js"`, Linux/macOS) e
   `windows` (caminho absoluto, porque `cmd`/`pwsh` não expandem `$HOME`).
   Em outra máquina Windows, ajuste o caminho do usuário nessa linha.

## Verificação rápida

1. Selecione o agente **executor-seguro** no seletor de agentes do chat.
2. Rode algo inofensivo (`git status`) → não deve pedir confirmação.
3. Rode algo destrutivo (`rm -rf src`) → deve pedir confirmação.
4. Rode algo catastrófico (`rm -rf /`) → deve ser bloqueado, sem execução.
5. Diagnóstico: canal **GitHub Copilot Chat Hooks** no Output, ou comando
   **Developer: Show Agent Debug Logs**. O log de decisões fica em
   `~/.copilot/hooks/command-guard.log` (desative com `COMMAND_GUARD_LOG=0`).

## Ajustar regras sem alterar o guard

Crie `command-guard.config.json` ao lado do script (não versionado aqui por ser específico de máquina):

```json
{
  "extraDeny": ["^docker\\s+system\\s+prune"],
  "extraAsk": ["^terraform\\s+apply", "^aws\\s+"],
  "extraAllow": ["^node\\s+scripts/"]
}
```

Exceções por projeto: prefira declarar o hook no `.github/hooks/*.json` do repositório, que
tem precedência e vale para todo o time.

## Solução de problemas

| Sintoma                       | Causa provável                                                                                                                                                                                                   |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Pede confirmação para tudo    | Hook não carregou: falta `chat.useCustomAgentHooks`, caminho do script errado ou `node` fora do PATH                                                                                                             |
| Guard nunca bloqueia          | Script quarentenado por antivírus (Windows Defender reage a arquivos com padrões destrutivos). Exclua a pasta: `Add-MpPreference -ExclusionPath "$env:USERPROFILE\.copilot\hooks"` (terminal como administrador) |
| Agente não aparece no seletor | Arquivo fora de `<perfil>/prompts/agents/`, nome sem `.agent.md` ou YAML inválido                                                                                                                                |
| Hook roda mas o comando passa | O guard só opina em ferramentas de terminal (`run_in_terminal`, `send_to_terminal`); falha do script cai no comportamento padrão (pedir aprovação)                                                               |
