---
description: Prepara a MR da branch atual com deslop no diff contra a branch alvo, unslop no texto e checagem de testes. Não commita e não escreve no repositório.
---

Preparar a MR da branch atual para revisão.

## Passos

1. Descobrir a branch alvo da MR. Rodar `git log --oneline -3 --decorate` e `git status -sb`. Se não estiver óbvio, usar a branch de release mais recente. Neste projeto, hoje, é `origin/v2.4.9`.
2. Calcular a base com `git merge-base HEAD origin/<alvo>`.
3. Rodar o skill deslop no diff da base até o HEAD. Alvos: comentário fora do padrão do repo, check defensivo, cast para `any`, aninhamento desnecessário, código inconsistente com o entorno.
4. Rodar o skill unslop na mensagem de commit e no texto que vai na descrição da MR.
5. Checar dois pontos do projeto: comentário e JSDoc novos em inglês, e chave de locale presente em pt, en e es.
6. Rodar `npx jest` e reportar o resultado.
7. Listar o que mudaria, separado por arquivo.

## Limites

- Não commitar, não dar push, não abrir MR.
- Não escrever arquivo no repositório. Só propor.
- Não usar `npm test`.
