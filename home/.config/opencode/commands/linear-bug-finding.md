---
description: Run linear bug finding on current branch diff.
agent: auditor
subtask: false
---

Execute análise de bugs no diff atual.

ESCOPO:
- Comparar branch atual com main/master.
- Encontrar bugs lógicos, regressões, edge cases.
- Reportar cada problema com arquivo, linha, severidade, impacto.

REGRAS:
- Não editar arquivos.
- Não criar arquivos.
- Não rodar comandos destrutivos.

SAÍDA:
- Lista de problemas encontrados (ou "Nenhum problema encontrado").
- Estatísticas: total de problemas por severidade.
