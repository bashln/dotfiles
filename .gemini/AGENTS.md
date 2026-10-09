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
