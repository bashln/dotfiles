---
description: Run continuous improvement loop using skills — find bugs, fix, QA, repeat. Has edit permission.
agent: build
subtask: false
---

Execute melhoria contínua no código com permissão de edição, usando skills especializadas.

ESCOPO:
- Carregar skills para cada fase: debug, audit-and-fix, implement,
  code-simplifier, tdd, test, quality-checks
- Encontrar bugs, problemas de qualidade, falta de testes
- Implementar correções com a menor mudança possível
- Validar cada correção (testes, lint, typecheck)
- Fazer commits atômicos por correção
- Repetir até não haver mais melhorias

PERMISSÕES:
- Pode editar arquivos
- Pode rodar bash
- Pode criar/modificar testes
- Pode fazer commits
- Pode carregar skills

REGRAS:
- Prioridade: bugs > qualidade > estilo > arquitetura
- Máximo 5 arquivos por mudança
- Não alterar config do OpenCode
- Não remover testes existentes
- Validar cada mudança antes de passar para a próxima
- Sempre carregar a skill antes de executar a etapa

SAÍDA:
- Ciclos completados com skill usada e status
- Resumo da sessão
