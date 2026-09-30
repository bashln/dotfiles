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

## Nome do arquivo

`<Modelo> <version>.json` — o `Modelo:` inteiro, como está no PDF (inclusive
sufixos como `ESPANHOL`). O número é a versão gravada em
`technicalsInfo[].version`, espelhando o `UID_0014 3.json` do ecossistema, cujo
sufixo `3` é a versão 3.

```
318.22.pdf / --version 1     →  INV-318.22 1.json
318.10-01.pdf / --version 1  →  INV-318.10-01 ESPANHOL 1.json
```

Como o sufixo é a **versão mais nova** e o arquivo acumula as anteriores
(`UID_0014 3.json` contém as versões 1, 2 e 3), o ciclo de firmware novo é:

```
--version 2 --merge "INV-318.22 1.json"   →   INV-318.22 2.json  (v1 + v2)
```

O arquivo antigo não é apagado. `--out` sempre vence o nome padrão.

## Convenções de bytes

`UID_0014 3.json`: UTF-8 **com BOM** (`EF BB BF`) + **CRLF**, indent 2.
O script espelha por padrão; `--no-bom` e `--lf` desligam.

Cuidado com `Path.write_text` no Windows: ele converte `\n` em `\r\n` e o
resultado vira `\r\r\n`. `write_json` abre com `newline=""` e há teste travando
isso (`\r\r\n` ausente, `count(CRLF) == count(LF)`).

## Consumidor: `modbus-monitor.exe`

Evidência verificada (ambiente `INV-YB3-15 — UID 14` no Local Storage do app,
comparado com este datasheet versão 3):

| App (`schema.rows[]`) | Vem de | Verificado |
|---|---|---|
| `register` | `addr` | 100/100 endereços idênticos |
| `name` | `name` | usado (texto exibido) |
| `kind` (`holding`/`input`) | `type` | 0 divergências |
| `groupId` (`uid-group-N`) | ordem de `modbusRegistersGroup` | 0 divergências |
| `schema.groups[]` | `name` do grupo | 13/13 |
| `writeRows[]` | todo registro `holding-register` | exato (83/83 no caso real) |
| `cyclic`, `bitField`, `interval` | estado da UI | **não** vêm do datasheet |
| `nodeAddress` | escravo (PDF) | campo do ambiente |

O app guarda tudo em **Local Storage** (WebView2/LevelDB em
`%LOCALAPPDATA%\com.kroth.serial-monitor\EBWebView\Default\Local Storage\leveldb`),
ou seja: **não existe drop-in por arquivo**; o import passa pela UI. O backend
(Tauri 2.11.1, id `com.kroth.serial-monitor`) expõe apenas
`connect`/`disconnect`/`read_register`/`write_register`/`identify_device` — nada
de importar arquivo; quem faz isso é o frontend (plugin `fs`).

Consequência prática: `homeScreen`, `public`, `appPublic*`, `webPublic*`,
`viewRegistersGroup` são irrelevantes para o import. `dataType`, `min`, `max`,
`unity` também não são usados pelo app hoje — emitimos porque documentam o PDF e
porque o schema é o mesmo do n-smart.

### Verificado em campo (2026-09-30)

Import de um datasheet gerado por esta skill **funcionou** na UI do app:
`INV-318.22 1.json` (fw 318v15, 7 grupos, 50 registradores) foi importado sem
ajuste.

Isso resolve três dúvidas que estavam em aberto:

- `technicalsInfo` com **uma única entrada**, `version: "1"` — funciona. O app
  não exige o sufixo alto do `UID_0014 3.json` nem seleção de versão.
- o campo `description` extra no registrador (que não existe na referência) é
  **tolerado** — não precisa de flag para removê-lo.
- o nome do arquivo vindo do `Modelo:` do PDF não interfere no import.

Import continua **manual na UI**: não existe drop-in por arquivo (estado fica em
Local Storage), e este skill não automatiza o `.exe`.


