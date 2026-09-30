# Layouts de PDF suportados e heurísticas

Os datasheets INV são exportações Markdown → PDF (`README.md` no cabeçalho,
rodapé `data / página / total`). O parser usa PyMuPDF com **palavras + bbox**
(`page.get_text("words")`), nunca o texto corrido: `get_text()` quebra células
de várias linhas e embaralha a ordem.

## Layouts conhecidos

Duas famílias já validadas (ver `scripts/tests/fixtures/`):

**7 colunas** — `318.22.pdf`
```
Endereço(hex) | Endereço(dec) | Nome do Registro | Tipo de Registro | Tipo de Dados | Função | Formato de Dados
0x3000        | 12288         | eMB_REG_...     | Holding Register | u8            | Retorna valor... | 0 a 1
```

**5 colunas** — `318.10-01.pdf`
```
Endereço modbus(hex) | Nome do registro | Tipo de registro | Variável de leitura/escrita | Formato de dados
0x2000               | eMB_REG_...      | Holding Register | Controle do relé 1          | 0 ou 1
```

O papel de cada coluna é decidido por **conteúdo**, nunca por posição fixa:

| Papel | Critério |
|---|---|
| `addr` | ≥60% das células casam `^0x[0-9A-F]{4}$` |
| `dec` | todas inteiras **E** vizinha de `addr` **E** valor == `int(addr,16)` em ≥80% das linhas |
| `dataType` | ≥50% casam `^[us]\d{1,2}$` |
| `type` | ≥50% normalizam para `holdingregister` / `inputregister` |
| `code` | ≥50% começam com `eMB_` |
| `format` | entre as restantes, a de maior densidade de células "formato" (faixa, `Fmt. N`, vazia) |
| `description` | as demais restantes, concatenadas em ordem de x |

A validação do `dec` contra o endereço é também uma checagem de correção: sem
ela, o dígito final de "Controle do relé 1" viraria uma coluna decimal falsa.

## Geometria

- **Âncora de linha** = palavra que casa `0x[0-9A-F]{4}`. Toda linha da tabela
  tem endereço, então a âncora define a linha.
- **Colunas** vêm do bloco de header (o `x0` do header é estável por coluna;
  dentro do corpo o `x0` varia por causa de texto justificado).
- **Bloco de header** é achado por vocabulário (`Endereço`, `Nome`, `Formato`,
  `Tipo`, `Dados`, `Variável`, `hex`, `dec`), pegando o agrupamento de linhas
  contíguas mais próximo da primeira âncora. Margem fixa não serve: uma célula
  alta começa acima da âncora e seria engolida.
- **Atribuição de palavra** → maior sobreposição horizontal com a coluna; sem
  sobreposição, centro mais próximo.
- **Ordem de leitura na célula**: `(y, x)`. Ordenar por `x` embaralha as linhas
  de uma célula justificada.

## Casos de borda tratados

| Caso | Tratamento |
|---|---|
| Célula alta começa acima da âncora | atribuída à âncora mais próxima |
| Célula cortada pela quebra de página | reanexada à linha da página anterior + warning |
| Legenda/rodapé depois da última linha | descartado (fora da faixa `band` após a última âncora) |
| Tabela de menu de firmware (N1..N5, TIMER), tabelas de bits `Fmt. N` | ignoradas (sem coluna `0x....`) |
| Header repetido por página | detectado por página; geometria reaproveitada da anterior se faltar |
| `'0' a '9'` (aspas) | faixa reconhecida (0–9) |
| `-10°C a 760°C` | `min=-10`, `max=760` → `dataType` vira `s16` |
| Endereço repetido | ambas as linhas preservadas + warning |
| Palavra dentro da tabela sem linha | vira **suspeita bloqueante** (jamais silencioso) |

## Como adicionar um layout novo

1. Rode `python scripts/pdf_to_uid.py <pdf> --dry-run` e leia as suspeitas.
2. Se uma coluna não for classificada, o conteúdo dela aparece em
   `colunas não classificadas` — adicione o padrão em `_classify_columns`.
3. Se o header não for reconhecido, acrescente o termo em `HEADER_TOKENS`.
4. Rode os testes; adicione o PDF novo como fixture e um teste de cobertura
   reversa — é ele que garante que nada se perdeu.
