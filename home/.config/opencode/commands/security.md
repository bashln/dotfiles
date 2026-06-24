---
description: Run security review — code-level vulns and dependency audit.
agent: auditor
subtask: false
---

Execute revisão de segurança no escopo atual.

ESCOPO:
- Injeção de comando, path traversal, segredos em código.
- Validação de input ausente.
- Dependências vulneráveis (npm audit, cargo audit, pip-audit, etc).
- CVEs, deprecações, licenças restritivas.

REGRAS:
- Não editar arquivos.
- Não criar arquivos.
- Não rodar comandos destrutivos.
- Não sugerir atualizações sem evidência.

SAÍDA:
- Vulnerabilidades encontradas por severidade.
- Versões afetadas e recomendações.
- Comandos de verificação executados e seus resultados.
