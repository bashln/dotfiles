# Instruções globais (Antigravity CLI)

## Proteção contra remoção (obrigatório)

Nunca delete arquivos. Para remover algo, crie `./trash/` no diretório atual se não existir, mova o item para lá preservando o caminho relativo e registre `data | origem | motivo` em `./trash/LOG.md`.

<!-- ux-excellence:begin -->
## Excelência de UX (global, sempre, obrigatório)

Princípio: pecar pela excelência. Todo artefato — app, CLI, TUI, API, biblioteca, script — deve ser óbvio, útil e bonito. Meta: pessoa sem conhecimento técnico usa sem tutorial.

- Proativo, sem esperar pedido: em TODA implementação, melhorar por conta própria clareza, defaults, feedback, estados vazio/erro/loading, acessibilidade, hierarquia visual e performance percebida.
- Intuitivo > tutorial: descobrível, defaults sensatos, erros acionáveis, ações reversíveis quando possível.
- Elegante: tipografia, espaçamento, contraste, consistência, movimento com propósito. Nunca "feio funcional".
- CLI/TUI: `--help` claro, flags consistentes, cores com fallback, feedback de progresso, `--dry-run`/confirmação para destrutivo, saída legível e scriptável.
- Tradeoff UX×esforço → escolher encanto do usuário: menos features, mais polidas.
- Nunca sacrificar correção, segurança, dados nem acessibilidade por estética.
- Fechar toda implementação relendo como usuário de primeira vez; corrigir o que doeu e registrar o porquê.
- Skills: `ux-excellence` (checklist acionável por superfície) + `principle-experience-first`.
<!-- ux-excellence:end -->

<!-- minimalism:begin -->
## Minimalismo e limpeza de órfãos (global)

Escreva software simples: menos código, menos arquivos, menos estado. Deletion over addition.

- Não crie o que não é usado: sem abstração, dependência, arquivo ou config sem dono.
- Órfão = não referenciado, não carregado, obsoleto, duplicado ou leftover. Inclui `.bak` redundante, cache velho, diretório de ferramenta aposentada, código morto.
- Ao achar órfão que VOCÊ criou ou que é claramente obsoleto: mova para `./trash/<caminho-relativo>/` e registre `data | origem | motivo` em `./trash/LOG.md`. Nunca delete.
- Dados do usuário, perfis de apps (browser, IDE, editor) e config ambígua: confirmar antes de mover.
- Vale para home Linux e Windows.
<!-- minimalism:end -->

<!-- autonomy:begin -->
## Execução autônoma + TDD (unattended)

Ao receber um plano/objetivo, execute até o critério de parada sem esperar o humano.

- TDD sempre: escreva o teste que falha, rode e leia a falha, implemente o mínimo, rode verde, refatore. Depois, review.
- Não pare para perguntar. Escolha a opção mais segura e reversível, siga e registre a decisão.
- Loop: 1 unidade verificável por vez → valide no artefato real → registre → próxima. Nunca batch de validação.
- Persistência externa (sobrevive a compaction/reinício), no diretório de trabalho:
  - `progress.json`: task, status, completed_steps, pending_steps, notes
  - `errors.json`: erro, tentativas, abordagens falhas, solução
  - Releia os dois ao iniciar/retomar; atualize após CADA passo.
- Mesmo erro 2x → mude de abordagem (não repita). 3 tentativas sem progresso no mesmo passo → pare, documente em `progress.json` e reporte o bloqueio.
- Pare SÓ no critério de parada atingido ou bloqueio documentado.
- Nunca delete: mova para `./trash/` + `LOG.md`.
<!-- autonomy:end -->
