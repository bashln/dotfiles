# Schema do datasheet (n-smart / UID JSON)

Fonte da verdade:

1. Arquivo real consumido pela ferramenta: `UID_0014 3.json` (fixture em
   `scripts/tests/fixtures/`).
2. Tipos do app: `09-n-smart-v2-playground/src/model/data/techInfo/techInfo.types.ts`.

O teste `ReferenceShapeTest.test_no_invented_keys` garante que nenhuma chave
inventada seja emitida.

## Estrutura

```jsonc
{
  "UID": "0170",              // endereço do escravo, 4 dígitos (PDF: "Endereço do escravo")
  "name": "INV-318.22",       // PDF: linha "Modelo:"
  "technicalsInfo": [
    {
      "version": "1",         // versão do datasheet (--version); nova firmware = nova entrada
      "firmware": "318v15",   // PDF: linha "Firmware:"
      "COMbaud": "9600",      // PDF raramente informa; default 9600
      "modbusRegistersGroup": [ /* ... */ ],
      "viewRegistersGroup": { /* stub vazio: o PDF não traz esta informação */ }
    }
  ]
}
```

### Grupo

```jsonc
{
  "group": "Falhas",
  "public": true,
  "appPublic": true, "appProtected": false,
  "webPublic": true, "webProtected": false,
  "name": "Falhas",
  "description": "Importado do PDF (4 registradores)",
  "modbusRegisters": [ /* ... */ ]
}
```

Grupos são inferidos por bloco de endereço, ordenados pelo menor `addr`.
Em `318.22` o bloco `0x3000` é diagnóstico (holding → grupo `Falhas`); em
`318.10-01` o mesmo bloco é `input-register` → grupo `Entradas`.

### Registrador

```jsonc
{
  "addr": "0x3001",                    // hex maiúsculo, como no PDF
  "type": "holding-register",          // | "input-register"
  "public": true,
  "appPublic": true, "appProtected": false,
  "webPublic": true, "webProtected": false,
  "homeScreen": false,
  "name": "Falha Temperatura Lastro",  // derivado, legível
  "description": "eMB_REG_FALHA_TEMPERATURA_LASTRO — Retorna valor do erro do sensor de lastro",
  "dataType": "u8",                    // u8 | u16 | s16 (s16 quando min < 0)
  "min": "0",                          // só quando o PDF informa faixa
  "max": "1",
  "unity": "degrees"                  // só quando aplicável
}
```

### Chaves fora do schema de referência

A única chave que emitimos além das existentes em `UID_0014 3.json` é
`description` **no registrador**. Motivo: preservar o código original de firmware
(`eMB_REG_...`) e o texto humano do PDF, para rastreio. Os grupos já possuíam
`description` no arquivo de referência.

Se a ferramenta rejeitar a chave extra, remova-a do JSON emitido — mas prefira
reportar, porque é a única trilha da origem do nome.

### Unidades

| PDF | `unity` |
|---|---|
| `°C`, `°F` | `degrees` |
| `seg`, `segs`, `s`, `seconds` | `seconds` |
| `%` | `percent` |
| `hh` | `hh` |
| `mm` | `mm` |
| `Volts` | `Volts` |
| `dias`, `days` | `days` |

## Convenções de bytes

`UID_0014 3.json`: UTF-8 **com BOM** (`EF BB BF`) + **CRLF**, indent 2.
O script espelha por padrão; `--no-bom` e `--lf` desligam.

`UID_0014 3.json` também não tem `viewRegistersGroup` obrigatório preenchido em
todas as versões — mas o tipo TS exige a chave, então emitimos stub.
