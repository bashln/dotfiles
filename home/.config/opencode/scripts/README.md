# AI Loop System — OpenCode Agent Loops

Sistema de melhoria contínua de código usando agentes OpenCode especializados com validação real, skills reutilizáveis e agendamento.

## Pré-requisito

```bash
chmod +x ~/.config/opencode/scripts/ai-loop.sh
```

## Estrutura

```
.config/opencode/
├── scripts/
│   ├── ai-loop.sh        # Orquestrador principal
│   └── README.md         # Este arquivo
├── prompts/
│   ├── build.txt                     # Agente padrão
│   ├── tutor.txt                     # Tutor read-only
│   ├── loop-linear-bug-finding.txt   # Caça de bugs (read-only)
│   ├── loop-security-review.txt      # Segurança (read-only)
│   ├── loop-dependency-audit.txt     # Dependências (read-only)
│   ├── loop-qa-review.txt            # Qualidade (read-only)
│   └── loop-interactive-improve.txt  # Melhoria contínua COM edição
└── commands/
    ├── linear-bug-finding.md
    ├── security-review.md
    ├── dependency-audit.md
    ├── qa-review.md
    ├── interactive-improve.md
    ├── ai-loop-once.md
    └── ai-loop-status.md
```

## Modos de execução

| Modo | Descrição |
|---|---|
| `once <loop>` | Executa uma iteração e para |
| `once-dry <loop>` | Mostra o que faria sem executar |
| `loop <loop> <interval>` | Loop contínuo com pausa entre iterações |
| `timed <loop> <duration>` | Loop por tempo TOTAL (sem pausa entre ciclos) |
| `improve [duration]` | Atalho: `timed interactive-improve <duration>` |
| `cron-install <loop> <interval> [max]` | Agenda no cron |
| `cron-remove <loop>` | Remove cron |
| `status` | Mostra estado do sistema |

## Loops disponíveis

### linear-bug-finding (read-only)

**Propósito:** Caça automatizada de bugs no diff da branch atual vs base.

**Agente:** `build` | **Edição:** ❌ | **Skills:** não | **Ideal para:** Pré-PR

Analisa o diff entre branch atual e main/master. Busca bugs lógicos, regressões, edge cases, null pointers, race conditions, vazamentos de recurso. Reporta cada achado com arquivo:linha, severidade (critical/major/minor), impacto e evidência.

### security-review (read-only)

**Propósito:** Revisão contínua de segurança no código.

**Agente:** `auditor` | **Edição:** ❌ | **Skills:** não | **Ideal para:** Pré-merge

Varre o repositório buscando: injeção de comando, path traversal, credenciais/segredos expostos, falta de validação de input, dependências com CVEs. Roda `npm audit`, `trivy`, `semgrep`, `grype` quando disponíveis.

### dependency-audit (read-only)

**Propósito:** Auditoria de dependências — CVEs, deprecações, licenças.

**Agente:** `auditor` | **Edição:** ❌ | **Skills:** não | **Ideal para:** Semanal

Detecta gerenciadores (package.json, Cargo.toml, go.mod, requirements.txt), roda ferramentas nativas de auditoria. Identifica CVEs, dependências desatualizadas, deprecações, licenças restritivas.

### qa-review (read-only)

**Propósito:** Revisão de qualidade e prontidão para merge.

**Agente:** `tester` | **Edição:** ❌ | **Skills:** não | **Ideal para:** Antes de commit

Avalia 5 pilares: testes (✅/❌), types (✅/❌), lint (✅/❌), formatação (✅/❌), docs (✅/❌/⚠️). Detecta o stack automaticamente. Dá recomendação final de merge.

### interactive-improve (COM edição)

**Propósito:** Melhoria contínua com permissão de edição, usando skills especializadas em cada etapa.

**Agente:** `build` | **Edição:** ✅ | **Skills:** ✅ 8 skills | **Ideal para:** Sessões de melhoria com tempo determinado

Este loop é diferente dos outros — ele **edita o código** e usa as skills do repositório para cada fase do ciclo:

| Fase | Skill | O que faz |
|---|---|---|
| Encontrar | `code-debug` / `audit-and-fix` | Isola bugs, encontra falhas com evidência |
| Implementar | `feature-implement` / `code-simplifier` | Corrige com a menor mudança possível |
| Testar | `tdd` / `test-suite` / `quality-checks` | Cria testes, roda lint, typecheck |
| Validar | `qa-review` | Revisão final de qualidade |

**Fluxo por ciclo:**
1. Carrega skill → encontra problema
2. Carrega skill → implementa correção (máx 5 arquivos)
3. Carrega skill → testa e valida
4. Faz commit descritivo
5. Repete até o tempo acabar ou não haver mais melhorias

## Como usar

```bash
# ── Execução única ───────────────────────────────────────

# Caça de bugs no diff atual
bash ~/.config/opencode/scripts/ai-loop.sh once linear-bug-finding

# QA review
bash ~/.config/opencode/scripts/ai-loop.sh once qa-review

# ── Melhoria contínua COM edição (por tempo total) ───────

# Roda 30 minutos de melhoria (default)
bash ~/.config/opencode/scripts/ai-loop.sh improve

# Roda 10 minutos
bash ~/.config/opencode/scripts/ai-loop.sh improve 10m

# Roda 1 hora
bash ~/.config/opencode/scripts/ai-loop.sh improve 1h

# ── Timed (qualquer loop por tempo total) ─────────────────

bash ~/.config/opencode/scripts/ai-loop.sh timed security-review 30m

# ── Loop contínuo (com pausa) ────────────────────────────

bash ~/.config/opencode/scripts/ai-loop.sh loop linear-bug-finding 30m

# ── Cron ─────────────────────────────────────────────────

bash ~/.config/opencode/scripts/ai-loop.sh cron-install dependency-audit weekly 5
bash ~/.config/opencode/scripts/ai-loop.sh cron-remove dependency-audit

# ── Status ───────────────────────────────────────────────

bash ~/.config/opencode/scripts/ai-loop.sh status

# ── Dry-run ──────────────────────────────────────────────

DRY_RUN=true bash ~/.config/opencode/scripts/ai-loop.sh once linear-bug-finding
```

## Exemplos

```bash
# Antes do PR: caça de bugs rápida
bash ~/.config/opencode/scripts/ai-loop.sh once linear-bug-finding

# Sessão de melhoria de 20 minutos (edita código!)
bash ~/.config/opencode/scripts/ai-loop.sh improve 20m

# QA contínuo a cada 30 min
bash ~/.config/opencode/scripts/ai-loop.sh loop qa-review 30m

# Auditoria de dependências semanal automática
bash ~/.config/opencode/scripts/ai-loop.sh cron-install dependency-audit weekly 5
```

## Aliases

Após `source ~/.bashrc` ou `source ~/.config/fish/config.fish`:

```bash
ai-bug              # once linear-bug-finding
ai-sec              # once security-review
ai-deps             # once dependency-audit
ai-qa               # once qa-review
ai-improve          # improve (30m default)
ai-improve 20m      # improve com duração customizada
ai-timed <l> <d>    # timed mode para qualquer loop
ai-loop <l> <i>     # loop contínuo com intervalo
ai-status           # status do sistema
ai-dry <l>          # dry-run
ai-cron <l> <i>     # instalar cron
ai-cron-rm <l>      # remover cron
```

## Segurança

- **Bloqueio em main/master** — o script recusa executar na branch principal
- **Limite de iterações** — default 10, configurável
- **Parada automática** — após 3 execuções consecutivas sem problemas encontrados
- **Verificação de diff size** — bloqueia diffs > 10 arquivos (exceto `interactive-improve`)
- **Dry-run** — modo seguro para inspecionar antes de executar
- **Logs por execução** — `.ai/runs/{timestamp}_{loop}.log`
- **Agentes read-only** — `auditor` e `tester` não podem editar arquivos
- **Sem web** — todos os loops têm `webfetch: deny`

## Skills usadas

O loop `interactive-improve` carrega skills do diretório `.agents/skills/` em cada fase:

| Skill | Localização | Uso |
|---|---|---|
| `code-debug` | `.agents/skills/code-debug/` | Isolar bugs com evidência |
| `audit-and-fix` | `.agents/skills/audit-and-fix/` | Auditoria geral de código |
| `improve-architecture` | `.agents/skills/improve-architecture/` | Melhorias arquiteturais |
| `architecture-guard` | `.agents/skills/architecture-guard/` | Verificar invariantes |
| `feature-implement` | `.agents/skills/feature-implement/` | Implementar correções |
| `code-simplifier` | `.agents/skills/code-simplifier/` | Simplificar código |
| `tdd` | `.agents/skills/tdd/` | Test-driven development |
| `test-suite` | `.agents/skills/test-suite/` | Suíte de testes |
| `quality-checks` | `.agents/skills/quality-checks/` | Lint e typecheck |
| `qa-review` | `.agents/skills/qa-review/` | Revisão de qualidade |

## Diferença entre `loop` e `timed`

| Modo | Comportamento | Ideal para |
|---|---|---|
| `loop <interval>` | Executa → **espera o intervalo** → executa de novo | Tarefas periódicas (ex: a cada 1h) |
| `timed <duration>` | Executa → **já começa outro ciclo** → para quando o tempo total acaba | Sessões de melhoria com tempo definido |

## Integração com just

```bash
just ai-loop <name>          # Execução única
just ai-loop-loop <name>     # Loop contínuo
just ai-improve [duration]   # Melhoria contínua COM edição
just ai-timed <loop> <dur>   # Loop por tempo total
just ai-loop-dry <name>      # Dry-run
just ai-loop-cron-install    # Agendar cron
just ai-loop-cron-remove     # Remover cron
just ai-loop-status          # Status do sistema
just ai-loop-last            # Último log
just ai-loop-logs            # Listar logs
just ai-loop-reset           # Resetar contador
```

## Persistência

```
.ai/
├── state.json           # Estado atual (iteração, status, timestamp)
├── progress.md          # Narrativa cumulativa das execuções
├── runs/                # Logs por execução
│   └── {timestamp}_{loop}.log
└── findings/            # Achados persistentes
    └── {timestamp}_{loop}.md
```

## Licença

MIT
