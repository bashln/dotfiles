---
name: pdf-modbus-datasheet
description: Use when converting an INV controller datasheet PDF into an n-smart/datasheet JSON (the UID_0014 3.json format) for import into modbus-monitor.exe or the n-smart app — or when a PDF Modbus address table must become a register map. Triggers: datasheet PDF, tabela de endereços Modbus, mapa de registradores, UID json, importar registradores, converter PDF de registradores, eMB_REG.
---

# PDF Modbus datasheet → UID JSON

## Core principle

Converter é mecânico; o risco está em **perder dado em silêncio**. A garantia
não é "100% correto" (PDF não oferece isso), é:

> nada do PDF se perde, nada entra sem origem no PDF, nada ambíguo passa sem
> intervenção.

Por isso: script determinístico faz o trabalho, e **a verificação é gate, não
etapa opcional**.

## Fluxo automático

```bash
python scripts/pdf_to_uid.py <arquivo.pdf>
```

Sem flags ele já descobre produto, UID (endereço do escravo), firmware, versão e
o nome do arquivo de saída. Gera três artefatos:

| Arquivo | Para que serve |
|---|---|
| `UID_<uid> <version>.json` | o datasheet importável |
| `<out>.relatorio.md` | conferência lado a lado: cada linha do PDF ↔ registro emitido |
| `<out>.warnings.txt` | avisos não bloqueantes |

Depois de rodar, **sempre**:

1. Leia `<out>.relatorio.md` e confira as linhas contra o PDF.
2. Leia os `warnings`.
3. `suspeitas` vazias? Declare pronto e mostre o resumo.
4. `suspeitas` não vazias? O script **não escreveu nada** (exit 1) e gravou
   `<pdf>.suspeitas.txt`. Resolva antes de declarar qualquer coisa.

## O que o script decide sozinho (e por quê)

Regras auditáveis, todas documentadas:

- `type`: `Holding Register` → `holding-register`; `Input Register` → `input-register`.
- `dataType`: respeita o PDF; vira `s16` quando o `min` é negativo; quando o PDF
  não declara, é inferido da faixa (≤255 → `u8`, senão `u16`) **e avisado**.
- `unity`: `°C`/`°F` → `degrees`, `seg` → `seconds`, `%` → `percent`, etc.
- Grupos por bloco de endereço (`0x2000` saídas, `0x3000`/`0x4000` entradas ou
  falhas, `0x5000` teclas/relógio, `0x6000` endereçamento + serial, `0x7000` processo).
- `name`: legível, derivado do código (`eMB_REG_FALHA_TEMPERATURA_TETO` →
  "Falha Temperatura Teto"). O código original é preservado em `description`,
  junto do texto humano do PDF — nada é descartado.
- `0x6001`–`0x600D`: grupo `Serial number`, 13 dígitos `u8` (0–9).

## Julgamentos que continuam humanos

O PDF não informa isto; o script assume e **avisa**:

- `public`/`appPublic`/`webPublic` = `true`, `homeScreen` = `false`.
- `viewRegistersGroup` sai como stub vazio (o tipo do app exige a chave).
- Faixas ausentes (`Fmt. 1`, "retorna valor do erro…") ficam sem `min`/`max`.

Ajuste à mão quando importar para a UI do app — mas nunca apagando a origem.

## Proibições

- **Não invente registrador, faixa, tipo ou nome.** Se não está no PDF, não entra.
- **Não "conserte"** endereço duplicado, tipo estranho ou faixa suspeita por conta
  própria: o PDF é a fonte da verdade. Reporte; quem decide é o humano.
- **Não escreva o JSON em cima de arquivo existente sem `--merge`** (senão você
  apaga a versão de firmware anterior).
- **Não grave artefato no diretório do usuário** por padrão: use `--out`.
- **Não declare pronto** sem ler o relatório. "Conferi estruturalmente" não é
  verificação: a verificação que vale é a cobertura reversa + a leitura do relatório.

## Armadilhas já conhecidas nos PDFs

| Sintoma | O script faz |
|---|---|
| Célula alta começa acima da âncora | associa à âncora mais próxima; a 1ª linha **não** se perde |
| Célula cortada pela quebra de página | reanexa à linha da página anterior e avisa |
| Tabela de menu de firmware (N1..N5, TIMER) | ignora — não tem coluna de endereço |
| Endereço repetido no PDF (ex. `0x2005` CORTE/BEEP) | preserva os dois e avisa |
| Diagnóstico declarado como Holding (só leitura) | avisa, não altera |

## CLI

```
python scripts/pdf_to_uid.py <pdf>
  --out ARQUIVO              # destino explícito
  --version N                # entrada em technicalsInfo (default 1)
  --merge UID_existente.json # nova versão de firmware, preservando as antigas
  --uid / --name / --firmware / --baud   # override do que não veio no PDF
  --dry-run                  # imprime e não escreve nada
  --no-bom / --lf            # convenções de bytes (padrão espelha o alvo)
```

Exit codes: `0` ok, `1` suspeita bloqueante, `2` erro de uso.

## Convenções de bytes

O datasheet de referência do ecossistema (`UID_0014 3.json`) é UTF-8 **com BOM**
e **CRLF**. O script espelha isso por padrão para não introduzir diferença de
bytes no que a ferramenta já consome.

## Referências

- `references/uid-schema.md` — schema do JSON de saída e origem de cada chave.
- `references/pdf-layouts.md` — layouts de tabela suportados e heurísticas de parsing.

## Testes

```bash
python scripts/tests/test_pdf_to_uid.py
```

Fixtures reais em `scripts/tests/fixtures/` (2 datasheets + o JSON de referência).
Cobrem cobertura reversa, contagens, campos verificados, duplicata, continuidade
serial, convenções de bytes, `--merge` e o caso de PDF sem tabela.
