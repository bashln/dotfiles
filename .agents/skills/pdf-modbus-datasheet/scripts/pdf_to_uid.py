#!/usr/bin/env python3
"""Converte PDF de datasheet INV (tabela Modbus) -> JSON datasheet n-smart.

Design: docs/superpowers/specs/2026-09-30-pdf-modbus-datasheet-design.md

Princípios:
  * Nunca inventa registro: linha ambígua bloqueia (DatasheetParseError).
  * Colunas detectadas por CONTEÚDO, não por posição (suporta 5 e 7 colunas).
  * Linha ancorada na célula de endereço `0x....`; células multi-linha são
    reanexadas à âncora mais próxima em Y.
  * Verificação obrigatória: cobertura reversa PDF<->JSON, integridade
    estrutural, relatório de rastreabilidade.

Uso:
    python pdf_to_uid.py <pdf> [--out ARQ] [--version N] [--merge JSON]
                               [--uid U] [--name N] [--firmware F] [--baud B]
                               [--dry-run]
"""

from __future__ import annotations

import argparse
import json
import re
import statistics
import sys
from dataclasses import dataclass, field
from pathlib import Path

import fitz  # PyMuPDF

# --------------------------------------------------------------------------
# Constantes
# --------------------------------------------------------------------------

HEX_RE = re.compile(r"0x[0-9A-Fa-f]{4}")
DATATYPE_RE = re.compile(r"^[us]\d{1,2}$")
INT_RE = re.compile(r"^\d+$")
CODE_RE = re.compile(r"^eMB_", re.IGNORECASE)
QUOTE = "['\u2018\u2019\"]?"
RANGE_RE = re.compile(
    r"(?<![\w.])"                       # não cortar no meio de um número
    + QUOTE
    + r"(-?\d+(?:[.,]\d+)?)"            # min
    + QUOTE
    + r"\s*(?:°?\s*[CF]\b)?\s*"
    r"(?:a|ou|to)\s*"
    + QUOTE
    + r"(-?\d+(?:[.,]\d+)?)",           # max
    re.IGNORECASE,
)

X_CLUSTER_TOL = 6.0        # pt: diferença máxima de x0 dentro de uma coluna
ROW_MIN_GAP = 30.0         # pt: margem máxima acima da 1a âncora para o header
HEADER_WINDOW = 55.0       # pt: altura máxima do bloco de header acima da 1a âncora

UNITY_MAP = (
    ("°c", "degrees"),
    ("°f", "degrees"),
    ("seg", "seconds"),
    ("second", "seconds"),
    ("hh", "hh"),
    ("mm", "mm"),
    ("volt", "Volts"),
    ("dia", "days"),
    ("day", "days"),
    ("%", "percent"),
)

TYPE_ROLE_ALIASES = {
    "holdingregister": "holding-register",
    "inputregister": "input-register",
}


class DatasheetParseError(Exception):
    """Linha/tabela ambígua: não é seguro emitir o JSON."""


@dataclass
class Meta:
    uid: str = ""
    name: str = ""
    firmware: str = ""
    baud: str = "9600"

    def missing(self) -> list[str]:
        out = []
        if not self.uid:
            out.append("UID")
        if not self.name:
            out.append("name")
        return out


@dataclass
class ParsedRow:
    addr: str
    page: int
    cells: dict[str, str]
    raw: str
    warnings: list[str] = field(default_factory=list)


@dataclass
class ConvertResult:
    datasheet: dict
    rows: list[ParsedRow]
    warnings: list[str] = field(default_factory=list)
    suspects: list[str] = field(default_factory=list)
    report: str = ""
    meta: Meta = field(default_factory=Meta)


# --------------------------------------------------------------------------
# 1. Extração
# --------------------------------------------------------------------------


def _norm(text: str) -> str:
    return re.sub(r"\s+", " ", text).strip()


def _cell_text(words: list[tuple[float, float, str]]) -> str:
    """Concatena palavras de uma célula em ordem de leitura (linha, depois coluna).

    Dentro de uma célula o x0 varia (texto justificado), então ordenar por x0
    embaralha as linhas: a ordenação primária tem de ser y.
    """
    ordered = sorted(words, key=lambda w: (round(w[1], 1), w[0]))
    return _norm(" ".join(w[2] for w in ordered))


FORMAT_HINT_RE = re.compile(r"Fmt\.\s*\d+|^\s*$", re.IGNORECASE)


def _fmt_like(cell: str) -> bool:
    """Célula com cara de 'formato de dados' (faixa, 'Fmt. N' ou vazia)."""
    if FORMAT_HINT_RE.search(cell or ""):
        return True
    return bool(RANGE_RE.search(cell or ""))


def _classify_columns(
    cells_by_row: dict[int, dict[int, str]],
) -> dict[int, str]:
    """Define o papel de cada coluna pelo CONTEÚDO (não pela posição).

    O layout varia entre datasheets (5 a 7 colunas), então nada é inferido por
    posição fixa. A coluna `dec` só é aceita se for vizinha de `addr` E os
    valores corresponderem ao endereço decimal da linha — senão é texto.
    """
    cols = sorted({c for row in cells_by_row.values() for c in row})
    per_col: dict[int, list[str]] = {
        c: [cells_by_row.get(r, {}).get(c, "") for r in cells_by_row] for c in cols
    }
    roles: dict[int, str] = {}

    def frac(col: int, pred) -> float:  # noqa: ANN001
        vals = [c for c in per_col[col] if c]
        return sum(1 for c in vals if pred(c)) / len(vals) if vals else 0.0

    for c in cols:
        if frac(c, lambda v: bool(HEX_RE.fullmatch(v))) >= 0.6:
            roles[c] = "addr"
        elif frac(c, lambda v: bool(DATATYPE_RE.fullmatch(v))) >= 0.5:
            roles[c] = "dataType"
        elif frac(c, lambda v: v.replace(" ", "").lower() in TYPE_ROLE_ALIASES) >= 0.5:
            roles[c] = "type"
        elif frac(c, lambda v: bool(CODE_RE.match(v))) >= 0.5:
            roles[c] = "code"
        elif frac(c, lambda v: bool(INT_RE.fullmatch(v))) >= 0.9:
            roles[c] = "dec?"
        else:
            roles[c] = "other"

    addr_cols = [c for c, r in roles.items() if r == "addr"]
    addr_col = addr_cols[0] if addr_cols else None

    for c, role in list(roles.items()):
        if role != "dec?":
            continue
        if addr_col is None or c != addr_col + 1:
            roles[c] = "other"
            continue
        ok = 0
        total = 0
        for row, cells in cells_by_row.items():
            dec, addr = cells.get(c, ""), cells.get(addr_col, "")
            if not (dec and HEX_RE.fullmatch(addr)):
                continue
            total += 1
            if int(dec) == int(addr, 16):
                ok += 1
        roles[c] = "dec" if total and ok / total >= 0.8 else "other"

    others = [c for c in cols if roles.get(c) == "other"]
    if others:
        scores = {c: frac(c, _fmt_like) for c in others}
        best = max(scores, key=lambda c: scores[c])
        if scores[best] >= 0.5:
            roles[best] = "format"
        for c in others:
            if roles[c] in {"other", "dec?"}:
                roles[c] = "description"
    return roles


@dataclass
class Column:
    left: float
    right: float
    index: int

    @property
    def center(self) -> float:
        return (self.left + self.right) / 2


def _page_lines(
    words: list[tuple], tol: float = 2.0
) -> list[list[tuple]]:
    """Agrupa palavras em linhas de texto (por y0)."""
    lines: list[list[tuple]] = []
    for w in sorted(words, key=lambda w: (w[1], w[0])):
        if lines and abs(w[1] - lines[-1][0][1]) <= tol:
            lines[-1].append(w)
        else:
            lines.append([w])
    return lines


HEADER_TOKENS = (
    "endereço",
    "endereco",
    "hex",
    "dec",
    "nome",
    "registro",
    "tipo",
    "dados",
    "função",
    "funcao",
    "formato",
    "variável",
    "variavel",
    "leitura/escrita",
    "modbus",
)


def _header_block(
    words: list[tuple], first_anchor_y: float, gap: float
) -> tuple[float, float, list[tuple]] | None:
    """Localiza o bloco de header da tabela acima da primeira âncora.

    Detecta por VOCABULÁRIO de header (linhas com termos como 'Endereço',
    'Nome', 'Formato'), não por margem fixa: uma célula alta pode começar acima
    da âncora e uma margem fixa a engoliria — perda silenciosa de dado.

    Retorna (topo, base, palavras_do_header) ou None.
    """
    lines = _page_lines(words)
    cands = []
    for line in lines:
        y0 = line[0][1]
        if y0 >= first_anchor_y or first_anchor_y - y0 > 150:
            continue
        text = _norm(" ".join(w[4] for w in line))
        if HEX_RE.search(text):
            continue
        low = text.lower()
        if any(tok in low for tok in HEADER_TOKENS):
            cands.append(line)
    if not cands:
        return None

    cands.sort(key=lambda ln: ln[0][1])
    runs: list[list[list[tuple]]] = []
    for line in cands:
        if runs and line[0][1] - runs[-1][-1][0][1] <= 20.0:
            runs[-1].append(line)
        else:
            runs.append([line])

    # o run mais próximo da primeira âncora é o header da tabela
    best = max(runs, key=lambda run: run[-1][0][1])
    if len(best) < 2:
        return None

    top = min(w[1] for line in best for w in line)
    bottom = max(w[3] for line in best for w in line)
    if bottom >= first_anchor_y:
        return None
    return top, bottom, [w for line in best for w in line]


def _columns_from_header(header_words: list[tuple[float, float, float, float, str]]) -> list[Column]:
    """Colunas a partir do bloco de header (x0 do header é estável por coluna)."""
    if not header_words:
        return []
    groups: list[list[tuple[float, float, float, float, str]]] = []
    for w in sorted(header_words, key=lambda w: w[0]):
        if groups and w[0] - groups[-1][0][0] <= X_CLUSTER_TOL:
            groups[-1].append(w)
        else:
            groups.append([w])
    cols = []
    for i, g in enumerate(groups):
        left = min(w[0] for w in g)
        right = max(w[2] for w in g)
        if right - left < 1.0:
            right = left + 1.0
        cols.append(Column(left=left, right=right, index=i))
    return cols


def _column_for(x0: float, x1: float, cols: list[Column]) -> int:
    """Maior sobreposição horizontal; empate/nenhuma -> centro mais próximo."""
    best, best_ov = None, 0.0
    for col in cols:
        ov = min(x1, col.right) - max(x0, col.left)
        if ov > best_ov:
            best, best_ov = col.index, ov
    if best is not None:
        return best
    center = (x0 + x1) / 2
    return min(cols, key=lambda c: abs(c.center - center)).index


def parse_pdf(pdf_path: Path) -> tuple[list[ParsedRow], Meta, list[str]]:
    """Retorna (rows, meta, suspects). Levanta DatasheetParseError se irrecuperável."""
    doc = fitz.open(str(pdf_path))
    rows: list[ParsedRow] = []
    suspects: list[str] = []
    last_cols: list[Column] = []

    for page_index, page in enumerate(doc, start=1):
        words = page.get_text("words")
        anchors = [w for w in words if HEX_RE.fullmatch(w[4])]
        if not anchors:
            continue  # tabela sem endereços (menu de firmware, legendas, texto)

        anchors.sort(key=lambda w: (w[1], w[0]))
        ys = [a[1] for a in anchors]
        gaps = [b - a for a, b in zip(ys, ys[1:]) if b - a > 1]
        gap = statistics.median(gaps) if gaps else 120.0
        band = max(ROW_MIN_GAP, gap * 0.6)

        block = _header_block(words, ys[0], gap)
        if block:
            _top, cutoff, header_words = block
        else:
            cutoff = ys[0] - min(ROW_MIN_GAP, gap / 2)
            header_words = [w for w in words if cutoff - HEADER_WINDOW <= w[1] < cutoff]
        cols = _columns_from_header(header_words) or last_cols
        if len(cols) < 3:
            suspects.append(f"p.{page_index}: header da tabela não reconhecido")
            continue
        last_cols = cols

        table_end = ys[-1] + band
        body: list[tuple] = []
        prelude: list[tuple] = []
        for w in words:
            if w[1] < cutoff:
                continue
            # palavras interiores são sempre atribuídas à âncora mais próxima;
            # a faixa só limita o que vem DEPOIS da última linha (legenda/rodapé)
            if w[1] > ys[-1] and w[1] > table_end:
                continue
            if w[1] < ys[0]:
                # acima da 1ª âncora: perto o bastante = célula da 1ª linha;
                # muito acima = cauda de célula da página anterior
                if ys[0] - w[1] <= band:
                    body.append(w)
                else:
                    prelude.append(w)
            else:
                body.append(w)
        if len(body) < 3:
            suspects.append(f"p.{page_index}: tabela com conteúdo insuficiente")
            continue

        cells: dict[tuple[int, int], list[tuple[float, float, str]]] = {}
        for x0, y0, x1, _y1, text, *_ in body:
            r = ys.index(min(ys, key=lambda y: abs(y - y0)))
            c = _column_for(x0, x1, cols)
            cells.setdefault((r, c), []).append((x0, y0, text))

        cells_by_row: dict[int, dict[int, str]] = {}
        for (r, c), ws in cells.items():
            cells_by_row.setdefault(r, {})[c] = _cell_text(ws)

        roles = _classify_columns(cells_by_row)
        if "addr" not in roles.values():
            suspects.append(f"p.{page_index}: coluna de endereço não identificada")
            continue

        if prelude and rows:
            tail: dict[int, list[tuple[float, float, str]]] = {}
            for x0, y0, x1, _y1, text, *_ in prelude:
                tail.setdefault(_column_for(x0, x1, cols), []).append((x0, y0, text))
            added = []
            for c, ws in tail.items():
                text = _cell_text(ws)
                role = roles.get(c, "other")
                if not text:
                    continue
                if role == "description" and "description" in rows[-1].cells:
                    rows[-1].cells["description"] += f" {text}"
                else:
                    rows[-1].cells[role] = (
                        f"{rows[-1].cells[role]} {text}" if role in rows[-1].cells else text
                    )
                added.append(text)
            if added:
                joined = " ".join(added)
                rows[-1].raw = _norm(f"{rows[-1].raw} (continua) {joined}")
                rows[-1].warnings.append(
                    f"{rows[-1].addr}: célula continua da página anterior "
                    f"(quebra de página): '{joined}'"
                )

        for r in sorted(cells_by_row):
            named: dict[str, str] = {}
            for c in sorted(cells_by_row[r]):
                value = cells_by_row[r][c]
                if not value:
                    continue
                role = roles.get(c, "other")
                if role == "description" and "description" in named:
                    named["description"] = f"{named['description']} {value}"
                else:
                    named[role] = value
            addr = named.pop("addr", "")
            if not HEX_RE.fullmatch(addr or ""):
                suspects.append(f"p.{page_index}: linha sem endereço válido: {named}")
                continue
            raw = " | ".join(
                named.get(k, "")
                for k in ("addr", "dec", "code", "type", "dataType", "description", "format")
            )
            rows.append(
                ParsedRow(
                    addr=addr.lower(),
                    page=page_index,
                    cells={**named, "addr": addr},
                    raw=_norm(f"{addr} | {raw}"),
                )
            )

    if not rows:
        raise DatasheetParseError(
            f"{pdf_path.name}: nenhuma tabela Modbus (coluna de endereço 0x....) encontrada"
        )

    meta = _extract_meta(doc)
    doc.close()

    unknown = sorted({r.cells.get("unknown", "") for r in rows} - {""})
    if unknown:
        suspects.append(f"colunas não classificadas: {unknown[:5]}")

    return rows, meta, suspects


def _extract_meta(doc: fitz.Document) -> Meta:
    head = doc[0].get_text() if len(doc) else ""
    full = "\n".join(p.get_text() for p in doc)

    meta = Meta()
    for pattern, attr in (
        (r"Modelo:\s*([^\n]+)", "name"),
        (r"Firmware:\s*([^\n]+)", "firmware"),
        (r"COMbaud|Baud\s*Rate:\s*(\d+)", "baud"),
    ):
        m = re.search(pattern, head) or re.search(pattern, full)
        if m:
            setattr(meta, attr, _norm(m.group(1)))

    m = re.search(r"Endere[çc]o(?:\s+default)?\s+do\s+escravo:\s*(\d+)", full, re.IGNORECASE)
    if m:
        meta.uid = f"{int(m.group(1)):04d}"
    return meta


# --------------------------------------------------------------------------
# 2. Inferências
# --------------------------------------------------------------------------


def _parse_range(text: str) -> tuple[str, str] | None:
    m = RANGE_RE.search(text or "")
    if not m:
        return None
    lo = m.group(1).replace(",", ".")
    hi = m.group(2).replace(",", ".")
    return lo, hi


def _infer_data_type(declared: str, minmax: tuple[str, str] | None) -> str:
    declared = (declared or "").strip().lower()
    if minmax:
        try:
            lo = float(minmax[0])
        except ValueError:
            lo = 0.0
        if lo < 0:
            return "s16"
    if declared in {"u8", "u16", "s16", "u32", "s32"}:
        return declared
    if minmax:
        try:
            hi = float(minmax[1])
        except ValueError:
            return "u16"
        return "u8" if hi <= 255 else "u16"
    return "u16"


def _normalize_addr(text: str) -> str:
    return "0x" + text[2:].upper()


def _readable_name(code: str, fallback: str) -> str:
    base = re.sub(r"^eMB_REG_", "", code or "", flags=re.IGNORECASE)
    base = re.sub(r"([A-Za-z])(\d)", r"\1 \2", base)
    base = base.replace("_", " ").strip()
    if not base:
        base = (fallback or "").strip()
    if not base:
        return ""
    name = base.title()
    for acronym in ("Ntc", "Lcd", "Adc", "Ldc", "Pid", "Pwm", "Led", "Tc", "Rtc"):
        name = re.sub(rf"\b{acronym}\b", acronym.upper(), name)
    return name


def _infer_unity(*texts: str) -> str | None:
    blob = " ".join(t for t in texts if t).lower()
    for needle, unity in UNITY_MAP:
        if needle in blob:
            return unity
    return None


def _group_for(addr: str, reg_type: str, code: str) -> tuple[str, str]:
    """(group_id, group_name)"""
    value = int(addr, 16) & 0xF000
    code_u = (code or "").upper()
    if value == 0x2000:
        return "Saidas", "Saídas"
    if value == 0x3000:
        if reg_type == "input-register":
            return "Entradas", "Entradas"
        return "Falhas", "Falhas"
    if value == 0x4000:
        if reg_type == "input-register":
            return "Falhas", "Falhas"
        return "Teste", "Teste de fábrica"
    if value == 0x5000:
        if "DATE" in code_u:
            return "Relogio", "Programação do relógio"
        return "Teclas", "Teclas"
    if value == 0x6000:
        return "Enderecamento", "Endereçamento"
    if value == 0x7000:
        if reg_type == "input-register":
            return "Entradas", "Entradas"
        return "Processo", "Registros do processo"
    return "Outros", "Outros"


SERIAL_START, SERIAL_END = 0x6001, 0x600D

GROUP_NAMES = {
    "Saidas": "Saídas",
    "Entradas": "Entradas",
    "Falhas": "Falhas",
    "Teste": "Teste de fábrica",
    "Teclas": "Teclas",
    "Relogio": "Programação do relógio",
    "Processo": "Registros do processo",
    "Enderecamento": "Endereçamento",
    "Serial number": "Serial number",
    "Outros": "Outros",
}


def build_datasheet(rows: list[ParsedRow], meta: Meta, version: str = "1") -> tuple[dict, list[str]]:
    warnings: list[str] = []
    registers: dict[str, list[dict]] = {}

    for row in rows:
        cells = row.cells
        code = cells.get("code", "")
        declared_type = TYPE_ROLE_ALIASES.get(
            cells.get("type", "").replace(" ", "").lower(), ""
        )
        if not declared_type:
            raise DatasheetParseError(
                f"{row.addr}: tipo de registro não reconhecido em '{cells.get('type', '')}'"
            )

        desc_text = cells.get("description", "")
        format_text = cells.get("format", "")
        if "description+format" in cells:
            desc_text = RANGE_RE.sub("", cells["description+format"]).strip(" ,;-")
            format_text = cells["description+format"]

        minmax = _parse_range(format_text) or _parse_range(cells.get("description+format", ""))
        data_type = _infer_data_type(cells.get("dataType", ""), minmax)

        if not cells.get("dataType"):
            row.warnings.append(
                f"{row.addr}: dataType não declarado no PDF; inferido como "
                f"{data_type} a partir do formato"
            )
        if not minmax and not re.search(r"ou|a\b", format_text, re.IGNORECASE):
            shown = format_text or "-"
            row.warnings.append(
                f"{row.addr}: sem faixa numérica no PDF (formato '{shown}')"
            )

        human = _norm(desc_text)
        if code and human and human.lower() not in code.lower():
            description = f"{code} — {human}"
        else:
            description = code or human

        register = {
            "addr": _normalize_addr(row.addr),
            "type": declared_type,
            "public": True,
            "appPublic": True,
            "appProtected": False,
            "webPublic": True,
            "webProtected": False,
            "homeScreen": False,
            "name": _readable_name(code, desc_text),
            "description": description,
            "dataType": data_type,
        }
        if minmax:
            register["min"] = minmax[0]
            register["max"] = minmax[1]
        unity = _infer_unity(format_text, desc_text, cells.get("unity", ""))
        if unity:
            register["unity"] = unity

        addr_int = int(row.addr, 16)
        if SERIAL_START <= addr_int <= SERIAL_END:
            group_id = "Serial number"
        else:
            group_id, _ = _group_for(row.addr, declared_type, code)
        registers.setdefault(group_id, []).append(register)

    # duplicatas
    seen: dict[str, int] = {}
    for group_id, regs in registers.items():
        for reg in regs:
            seen[reg["addr"]] = seen.get(reg["addr"], 0) + 1
    for addr, count in sorted(seen.items()):
        if count > 1:
            warnings.append(
                f"endereço duplicado no PDF: {addr} aparece {count}x "
                f"(todos preservados; conferir na origem)"
            )

    groups = []
    order = sorted(registers, key=lambda gid: min(int(r["addr"], 16) for r in registers[gid]))
    for group_id in order:
        groups.append(
            {
                "group": group_id,
                "public": True,
                "appPublic": True,
                "appProtected": False,
                "webPublic": True,
                "webProtected": False,
                "name": GROUP_NAMES[group_id],
                "description": f"Importado do PDF ({len(registers[group_id])} registradores)",
                "modbusRegisters": registers[group_id],
            }
        )

    datasheet = {
        "UID": meta.uid,
        "name": meta.name,
        "technicalsInfo": [
            {
                "version": version,
                "firmware": meta.firmware or "desconhecido",
                "COMbaud": meta.baud or "9600",
                "modbusRegistersGroup": groups,
                "viewRegistersGroup": {
                    "globals": {},
                    "exposedfunctions": [],
                    "appComponents": {
                        "deviceCard": {},
                        "remoteControl": {},
                        "functionsList": [],
                    },
                    "webComponents": {"functionsList": []},
                },
            }
        ],
    }
    return datasheet, warnings


# --------------------------------------------------------------------------
# 3. Verificação
# --------------------------------------------------------------------------


def pdf_hex_addresses(pdf_path: Path) -> set[str]:
    doc = fitz.open(str(pdf_path))
    text = "\n".join(page.get_text() for page in doc)
    doc.close()
    return {m.group(0).lower() for m in HEX_RE.finditer(text)}


def datasheet_addresses(datasheet: dict) -> list[str]:
    return [
        reg["addr"]
        for tech in datasheet["technicalsInfo"]
        for group in tech["modbusRegistersGroup"]
        for reg in group["modbusRegisters"]
    ]


def verify(pdf_path: Path, datasheet: dict, rows: list[ParsedRow]) -> tuple[list[str], list[str]]:
    """Retorna (problemas_bloqueantes, warnings)."""
    blocking: list[str] = []
    warnings: list[str] = []

    do_pdf = pdf_hex_addresses(pdf_path)
    do_json = {a.lower() for a in datasheet_addresses(datasheet)}

    faltantes = sorted(do_pdf - do_json)
    extras = sorted(do_json - do_pdf)
    if faltantes:
        blocking.append(f"endereços presentes no PDF e AUSENTES no JSON: {faltantes}")
    if extras:
        blocking.append(f"endereços no JSON que NÃO existem no PDF: {extras}")

    if len(rows) != len(datasheet_addresses(datasheet)):
        blocking.append(
            f"linhas parseadas ({len(rows)}) != registradores emitidos "
            f"({len(datasheet_addresses(datasheet))})"
        )

    for reg in (r for tech in datasheet["technicalsInfo"]
                for g in tech["modbusRegistersGroup"] for r in g["modbusRegisters"]):
        if not HEX_RE.fullmatch(reg["addr"]):
            blocking.append(f"addr inválido: {reg['addr']}")
        if "min" in reg and "max" in reg:
            try:
                if float(reg["min"]) > float(reg["max"]):
                    blocking.append(
                        f"{reg['addr']}: min ({reg['min']}) > max ({reg['max']})"
                    )
            except ValueError:
                blocking.append(f"{reg['addr']}: min/max não numéricos")
        if not reg["name"]:
            blocking.append(f"{reg['addr']}: nome vazio")

    # série do serial contínua
    serial = sorted(
        int(a, 16) for a in do_json if SERIAL_START <= int(a, 16) <= SERIAL_END
    )
    if serial:
        expected = list(range(SERIAL_START, serial[-1] + 1))
        if serial != expected:
            faltando = [hex(a) for a in set(expected) - set(serial)]
            warnings.append(f"série de serial com buracos: {faltando}")

    for row in rows:
        warnings.extend(row.warnings)

    # Avisos por registrador são redundantes com o relatório (que mostra
    # dataType/min/max linha a linha): agregamos os dois casos mais verbosos.
    def _summarize(needle: str, label: str) -> None:
        matched = [w for w in warnings if needle in w]
        if not matched:
            return
        for w in matched:
            warnings.remove(w)
        addrs = sorted(w.split(":")[0] for w in matched)
        shown = ", ".join(addrs[:8]) + (" ..." if len(addrs) > 8 else "")
        warnings.append(f"{len(addrs)} registrador(es) {label}: {shown}")

    _summarize("dataType não declarado", "sem dataType declarado no PDF (inferido do formato)")
    _summarize("sem faixa numérica", "sem faixa numérica no PDF (sem min/max)")

    # leitura/escrita suspeita: endereço de diagnóstico declarado como holding
    read_only_hint = re.compile(
        r"\b(retorna|retorno|leitura|ler|l[eê]|estado|status|monitorar)\b", re.IGNORECASE
    )
    for reg in (r for tech in datasheet["technicalsInfo"]
                for g in tech["modbusRegistersGroup"] for r in g["modbusRegisters"]):
        if reg["type"] == "holding-register" and read_only_hint.search(
            f"{reg['description']} {reg['name']}"
        ):
            warnings.append(
                f"{reg['addr']}: PDF declara holding-register mas o texto sugere "
                f"somente leitura — conferir"
            )
        if reg["name"].startswith("Serial Number") and reg["dataType"] != "u8":
            blocking.append(f"{reg['addr']}: serial number deve ser u8")

    warnings.append(
        "visibilidade assumida (public/appPublic/webPublic=true, homeScreen=false): "
        "o PDF não informa; ajustar manualmente se necessário"
    )
    return blocking, warnings


def build_report(pdf_path: Path, rows: list[ParsedRow], datasheet: dict) -> str:
    # Cada linha do PDF é pareada com O SEU registro (em ordem), não com todos os
    # registros do mesmo endereço: endereço repetido no PDF (ex. 0x2005) deve
    # gerar uma linha de relatório por ocorrência, não um produto cartesiano.
    pending: dict[str, list[dict]] = {}
    for tech in datasheet["technicalsInfo"]:
        for group in tech["modbusRegistersGroup"]:
            for reg in group["modbusRegisters"]:
                pending.setdefault(reg["addr"].lower(), []).append(reg)

    lines = [
        f"# Relatório de conversão: {pdf_path.name}",
        "",
        f"Produto: `{datasheet['name']}`  ",
        f"UID: `{datasheet['UID']}`  ",
        f"Firmware: `{datasheet['technicalsInfo'][0]['firmware']}`  ",
        f"Registradores: {sum(len(g['modbusRegisters']) for g in datasheet['technicalsInfo'][0]['modbusRegistersGroup'])}",
        "",
        "Conferência lado a lado: cada linha do PDF com o registro emitido.",
        "",
        "| pág | linha crua do PDF | addr | name | type | dataType | min | max | unity |",
        "|---|---|---|---|---|---|---|---|---|",
    ]
    for row in rows:
        queue = pending.get(row.addr.lower()) or []
        emitted = [queue.pop(0)] if queue else []
        if not emitted:
            lines.append(f"| {row.page} | `{row.raw}` | **AUSENTE** | | | | | | |")
            continue
        reg = emitted[0]
        lines.append(
            "| {p} | `{raw}` | `{addr}` | {name} | {type} | {dt} | {mn} | {mx} | {u} |".format(
                p=row.page,
                raw=row.raw.replace("|", "\\|"),
                addr=reg["addr"],
                name=reg["name"],
                type=reg["type"],
                dt=reg["dataType"],
                mn=reg.get("min", ""),
                mx=reg.get("max", ""),
                u=reg.get("unity", ""),
            )
        )

    for addr, leftover in pending.items():
        for reg in leftover:
            lines.append(
                f"| - | (sem linha no PDF) | `{reg['addr']}` | {reg['name']} | "
                f"{reg['type']} | {reg['dataType']} | | | | **ÓRFÃO** |"
            )
    return "\n".join(lines) + "\n"


# --------------------------------------------------------------------------
# 4. Orquestração
# --------------------------------------------------------------------------


def convert_pdf(pdf_path: Path | str, version: str = "1",
                overrides: dict | None = None) -> ConvertResult:
    pdf_path = Path(pdf_path)
    rows, meta, suspects = parse_pdf(pdf_path)

    for key, value in (overrides or {}).items():
        if value:
            setattr(meta, key, value)

    missing = meta.missing()
    if missing:
        suspects.append(
            f"metadados não extraídos do PDF: {', '.join(missing)} "
            f"(informe manualmente via --uid/--name)"
        )

    datasheet, warnings = build_datasheet(rows, meta, version)
    blocking, verify_warnings = verify(pdf_path, datasheet, rows)
    suspects.extend(blocking)
    warnings.extend(verify_warnings)

    return ConvertResult(
        datasheet=datasheet,
        rows=rows,
        warnings=sorted(set(warnings)),
        suspects=sorted(set(suspects)),
        report=build_report(pdf_path, rows, datasheet),
        meta=meta,
    )


def merge_into(existing_path: Path, datasheet: dict) -> dict:
    # utf-8-sig: o arquivo alvo do ecossistema tem BOM
    existing = json.loads(Path(existing_path).read_text(encoding="utf-8-sig"))
    new_tech = datasheet["technicalsInfo"][0]
    versions = [t["version"] for t in existing.get("technicalsInfo", [])]
    if new_tech["version"] in versions:
        raise DatasheetParseError(
            f"versão {new_tech['version']} já existe em {existing_path.name}; use --version"
        )
    existing["technicalsInfo"].append(new_tech)
    for key in ("UID", "name"):
        if not existing.get(key):
            existing[key] = datasheet[key]
    return existing


def write_json(path: Path, data: dict, bom: bool = True, crlf: bool = True) -> None:
    """Grava o datasheet.

    O arquivo de referência do ecossistema (`UID_0014 3.json`) é UTF-8 **com BOM**
    e **CRLF**. Espelhamos essa convenção por padrão para não introduzir uma
    diferença de bytes entre o JSON gerado e o que a ferramenta já consome.

    `newline=""` é obrigatório: sem ele o Python converte o `\\n` que já
    escrevemos em `\\r\\n`, produzindo `\\r\\r\\n`.
    """
    text = json.dumps(data, ensure_ascii=False, indent=2) + "\n"
    if crlf:
        text = text.replace("\n", "\r\n")
    with path.open("w", encoding="utf-8-sig" if bom else "utf-8", newline="") as fh:
        fh.write(text)


def main(argv: list[str] | None = None) -> int:
    # Console do Windows é cp1252: sem isto, imprimir 'saída' derruba o script.
    for stream in (sys.stdout, sys.stderr):
        try:
            stream.reconfigure(errors="replace")
        except (AttributeError, ValueError):
            pass

    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("pdf", type=Path)
    parser.add_argument("--out", type=Path)
    parser.add_argument("--version", default="1")
    parser.add_argument("--merge", type=Path)
    parser.add_argument("--uid")
    parser.add_argument("--name")
    parser.add_argument("--firmware")
    parser.add_argument("--baud")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--no-bom", action="store_true",
                        help="grava UTF-8 sem BOM (padrão espelha o UID_0014 3.json: com BOM)")
    parser.add_argument("--lf", action="store_true",
                        help="grava com finais de linha LF (padrão espelha o alvo: CRLF)")
    args = parser.parse_args(argv)

    if not args.pdf.exists():
        print(f"erro: arquivo não encontrado: {args.pdf}", file=sys.stderr)
        return 2

    overrides = {"uid": args.uid, "name": args.name,
                 "firmware": args.firmware, "baud": args.baud}

    try:
        result = convert_pdf(args.pdf, version=args.version, overrides=overrides)
    except DatasheetParseError as exc:
        print(f"SUSPEITA (bloqueante): {exc}", file=sys.stderr)
        sus_path = args.pdf.with_suffix(args.pdf.suffix + ".suspeitas.txt")
        sus_path.write_text(str(exc) + "\n", encoding="utf-8")
        print(f"suspeitas gravadas em {sus_path}", file=sys.stderr)
        return 1

    out = args.out or Path(f"UID_{result.meta.uid} {args.version}.json")

    print(f"produto : {result.meta.name}")
    print(f"UID     : {result.meta.uid}")
    print(f"firmware: {result.meta.firmware}")
    print(f"linhas  : {len(result.rows)}")
    print(f"saída   : {out}")

    if result.warnings:
        print("\nWARNINGS:")
        for w in result.warnings:
            print(f"  - {w}")

    if result.suspects:
        print("\nSUSPEITAS (bloqueante, nada escrito):", file=sys.stderr)
        for s in result.suspects:
            print(f"  - {s}", file=sys.stderr)
        args.pdf.with_suffix(args.pdf.suffix + ".suspeitas.txt").write_text(
            "\n".join(result.suspects) + "\n", encoding="utf-8"
        )
        return 1

    if args.dry_run:
        print("\n(dry-run: nada escrito)")
        return 0

    datasheet = result.datasheet
    if args.merge:
        datasheet = merge_into(args.merge, datasheet)
    write_json(out, datasheet, bom=not args.no_bom, crlf=not args.lf)
    out.with_suffix(out.suffix + ".relatorio.md").write_text(result.report, encoding="utf-8")
    if result.warnings:
        out.with_suffix(out.suffix + ".warnings.txt").write_text(
            "\n".join(result.warnings) + "\n", encoding="utf-8"
        )
    print(f"\nok: {out} + {out.name}.relatorio.md")
    return 0


if __name__ == "__main__":
    sys.exit(main())
