---
description: Run an AI loop iteration once (delegates to ai-loop.sh).
agent: build
subtask: false
---

Execute uma iteração do AI Loop System.

Este comando delega para o script ai-loop.sh que orquestra:
1. Análise (prompt específico do loop)
2. Correção (quando aplicável)
3. Validação (tester)
4. Revisão de qualidade (auditor)
5. Persistência de estado (.ai/state.json)

Uso via terminal:
  bash ~/.config/opencode/scripts/ai-loop.sh once <loop-name>

Loops disponíveis: linear-bug-finding, security-review, dependency-audit, qa-review
