"""Testes da conversão PDF (datasheet INV) -> JSON datasheet n-smart.

Rodar:  python scripts/tests/test_pdf_to_uid.py
Stdlib apenas (unittest), sem pytest.

Fixtures vendorizadas em scripts/tests/fixtures/ para a skill ser auto-contida.
"""

import json
import pathlib
import re
import sys
import unittest

HERE = pathlib.Path(__file__).resolve().parent
SCRIPTS = HERE.parent
FIXTURES = HERE / "fixtures"
sys.path.insert(0, str(SCRIPTS))

import pdf_to_uid  # noqa: E402

PDF_318_22 = FIXTURES / "318.22.pdf"
PDF_318_10_01 = FIXTURES / "318.10-01.pdf"

HEX_RE = re.compile(r"0x[0-9A-Fa-f]{4}")

REQUIRED_REGISTER_KEYS = {
    "addr",
    "type",
    "dataType",
    "name",
    "description",
    "public",
    "homeScreen",
    "appPublic",
    "appProtected",
    "webPublic",
    "webProtected",
}


def all_registers(datasheet):
    for tech in datasheet["technicalsInfo"]:
        for group in tech["modbusRegistersGroup"]:
            for reg in group["modbusRegisters"]:
                yield group, reg


def pdf_hex_addresses(pdf_path):
    import fitz

    doc = fitz.open(pdf_path)
    text = "\n".join(page.get_text() for page in doc)
    return {m.group(0).lower() for m in HEX_RE.finditer(text)}


def registers_by_addr(datasheet):
    out = {}
    for _group, reg in all_registers(datasheet):
        out.setdefault(reg["addr"].lower(), []).append(reg)
    return out


class CoverageTest(unittest.TestCase):
    """Gate 6.1: cobertura reversa nos dois sentidos."""

    def _check(self, pdf_path):
        result = pdf_to_uid.convert_pdf(pdf_path)
        do_pdf = pdf_hex_addresses(pdf_path)
        do_json = {reg["addr"].lower() for _g, reg in all_registers(result.datasheet)}
        self.assertEqual(set(), do_pdf - do_json, "endereços do PDF ausentes no JSON")
        self.assertEqual(set(), do_json - do_pdf, "endereços do JSON ausentes no PDF")

    def test_coverage_318_22(self):
        self._check(PDF_318_22)

    def test_coverage_318_10_01(self):
        self._check(PDF_318_10_01)


class CountTest(unittest.TestCase):
    def test_count_318_22(self):
        result = pdf_to_uid.convert_pdf(PDF_318_22)
        self.assertEqual(50, len(list(all_registers(result.datasheet))))

    def test_count_318_10_01(self):
        result = pdf_to_uid.convert_pdf(PDF_318_10_01)
        self.assertEqual(41, len(list(all_registers(result.datasheet))))

    def test_serial_group_has_13_digits(self):
        result = pdf_to_uid.convert_pdf(PDF_318_22)
        serial = registers_by_addr(result.datasheet)
        digits = [a for a in serial if 0x6001 <= int(a, 16) <= 0x600D]
        self.assertEqual(13, len(digits))
        for a in digits:
            self.assertEqual("u8", serial[a][0]["dataType"])
            self.assertEqual("0", serial[a][0]["min"])
            self.assertEqual("9", serial[a][0]["max"])


class FieldTest(unittest.TestCase):
    def setUp(self):
        self.result = pdf_to_uid.convert_pdf(PDF_318_22)
        self.regs = registers_by_addr(self.result.datasheet)

    def test_0x3001_fault_register(self):
        reg = self.regs["0x3001"][0]
        self.assertEqual("holding-register", reg["type"])
        self.assertEqual("u8", reg["dataType"])
        self.assertEqual("0", reg["min"])
        self.assertEqual("1", reg["max"])
        self.assertIn("LASTRO", reg["name"].upper())
        self.assertIn("eMB_REG_FALHA_TEMPERATURA_LASTRO", reg["description"])

    def test_0x7005_thermocouple_is_signed(self):
        reg = self.regs["0x7005"][0]
        self.assertEqual("input-register", reg["type"])
        self.assertEqual("s16", reg["dataType"], "min negativo implica s16")
        self.assertEqual("-10", reg["min"])
        self.assertEqual("760", reg["max"])
        self.assertEqual("degrees", reg["unity"])

    def test_0x6000_address_register_bounds(self):
        reg = self.regs["0x6000"][0]
        self.assertEqual("1", reg["min"])
        self.assertEqual("248", reg["max"])

    def test_0x5001_hour_register(self):
        reg = self.regs["0x5001"][0]
        self.assertEqual("0", reg["min"])
        self.assertEqual("24", reg["max"])

    def test_all_names_readable_not_raw_codes(self):
        for _group, reg in all_registers(self.result.datasheet):
            self.assertNotIn("eMB_REG", reg["name"], "name deve ser legível")
            self.assertTrue(reg["name"].strip(), "name não pode ser vazio")

    def test_raw_code_preserved_in_description(self):
        reg = self.regs["0x4000"][0]
        self.assertIn("eMB_REG_LEDS_DISP", reg["description"])


class DuplicateTest(unittest.TestCase):
    """Anomalia conhecida: 318.10-01 repete 0x2005 (CORTE e BEEP)."""

    def test_duplicate_preserved_and_reported(self):
        result = pdf_to_uid.convert_pdf(PDF_318_10_01)
        regs = registers_by_addr(result.datasheet)
        self.assertEqual(2, len(regs["0x2005"]), "ambos os registradores devem existir")
        codes = " ".join(r["description"] for r in regs["0x2005"])
        self.assertIn("CORTE", codes.upper())
        self.assertIn("BEEP", codes.upper())
        warnings = " ".join(result.warnings).lower()
        self.assertIn("0x2005", warnings)
        self.assertIn("duplic", warnings)


class MetadataTest(unittest.TestCase):
    def test_318_22_metadata(self):
        result = pdf_to_uid.convert_pdf(PDF_318_22)
        ds = result.datasheet
        self.assertEqual("0170", ds["UID"])
        self.assertEqual("INV-318.22", ds["name"])
        tech = ds["technicalsInfo"][0]
        self.assertEqual("318v15", tech["firmware"])
        self.assertEqual("9600", tech["COMbaud"])
        self.assertEqual("1", tech["version"])

    def test_318_10_01_metadata(self):
        result = pdf_to_uid.convert_pdf(PDF_318_10_01)
        ds = result.datasheet
        self.assertEqual("0170", ds["UID"])
        self.assertEqual("INV-318.10-01 ESPANHOL", ds["name"])
        self.assertEqual("318v506", ds["technicalsInfo"][0]["firmware"])


class SchemaTest(unittest.TestCase):
    def test_required_keys_present(self):
        for pdf in (PDF_318_22, PDF_318_10_01):
            result = pdf_to_uid.convert_pdf(pdf)
            for tech in result.datasheet["technicalsInfo"]:
                self.assertIn("viewRegistersGroup", tech)
                for key in ("globals", "exposedfunctions", "appComponents", "webComponents"):
                    self.assertIn(key, tech["viewRegistersGroup"])
                for group, reg in all_registers(result.datasheet):
                    missing = REQUIRED_REGISTER_KEYS - set(reg)
                    self.assertEqual(set(), missing, f"faltam chaves em {reg.get('addr')}")

    def test_group_shape(self):
        result = pdf_to_uid.convert_pdf(PDF_318_22)
        for group in result.datasheet["technicalsInfo"][0]["modbusRegistersGroup"]:
            for key in ("group", "name", "description", "public", "modbusRegisters"):
                self.assertIn(key, group)


class ReferenceShapeTest(unittest.TestCase):
    """Compara o JSON gerado com o datasheet de referência do ecossistema.

    O arquivo `UID_0014 3.json` é a verdade do formato aceito pela ferramenta.
    A única chave que emitimos além dele é `description` no registrador
    (guarda o código de firmware original, para rastreio).
    """

    REFERENCE = FIXTURES / "UID_0014 3.json"
    EXTRA_KEYS = {"description"}

    def _reference_key_sets(self):
        data = json.loads(self.REFERENCE.read_text(encoding="utf-8-sig"))
        techs = data["technicalsInfo"]
        tech_keys = {k for t in techs for k in t}
        group_keys = {
            k for t in techs for g in t["modbusRegistersGroup"] for k in g
        }
        reg_keys = {
            k
            for t in techs
            for g in t["modbusRegistersGroup"]
            for r in g["modbusRegisters"]
            for k in r
        }
        return set(data.keys()), tech_keys, group_keys, reg_keys

    def test_no_invented_keys(self):
        top_ref, tech_ref, group_ref, reg_ref = self._reference_key_sets()
        result = pdf_to_uid.convert_pdf(PDF_318_22)
        ds = result.datasheet
        tech = ds["technicalsInfo"][0]

        self.assertLessEqual(set(ds.keys()), top_ref)
        self.assertLessEqual(set(tech.keys()), tech_ref)
        for group in tech["modbusRegistersGroup"]:
            self.assertLessEqual(set(group.keys()), group_ref)
            for reg in group["modbusRegisters"]:
                self.assertLessEqual(set(reg.keys()), reg_ref | self.EXTRA_KEYS)

    def test_file_matches_reference_byte_conventions(self):
        """O alvo é UTF-8 com BOM e CRLF — espelhamos para não haver surpresa."""
        import tempfile

        ref = self.REFERENCE.read_bytes()
        self.assertTrue(ref.startswith(b"\xef\xbb\xbf"), "referência tem BOM")
        self.assertIn(b"\r\n", ref, "referência usa CRLF")

        with tempfile.TemporaryDirectory() as tmp:
            out = pathlib.Path(tmp) / "out.json"
            result = pdf_to_uid.convert_pdf(PDF_318_22)
            pdf_to_uid.write_json(out, result.datasheet)
            raw = out.read_bytes()
            self.assertTrue(raw.startswith(b"\xef\xbb\xbf"))
            self.assertIn(b"\r\n", raw)
            json.loads(raw.decode("utf-8-sig"))  # continua parseável


class PreservationTest(unittest.TestCase):
    def test_addr_is_uppercase_like_pdf(self):
        result = pdf_to_uid.convert_pdf(PDF_318_10_01)
        addrs = [a for _g, r in all_registers(result.datasheet) for a in [r["addr"]]]
        self.assertIn("0x600D", addrs)
        self.assertNotIn("0x600d", addrs)

    def test_pdf_human_text_is_preserved(self):
        """Nada do PDF se perde: o texto humano vai junto do código."""
        result = pdf_to_uid.convert_pdf(PDF_318_10_01)
        reg = registers_by_addr(result.datasheet)["0x2000"][0]
        self.assertIn("Controle do rel", reg["description"])
        self.assertIn("1", reg["description"])

    def test_tall_cell_not_truncated(self):
        """Célula que começa acima da âncora não pode perder a 1ª linha."""
        result = pdf_to_uid.convert_pdf(PDF_318_22)
        reg = registers_by_addr(result.datasheet)["0x3002"][0]
        self.assertIn("Retorna", reg["description"])
        self.assertIn("caldeira", reg["description"])

    def test_cell_split_across_pages_is_rejoined(self):
        """'LCD' é cauda do 0x7002 na página seguinte, não do 0x7003."""
        result = pdf_to_uid.convert_pdf(PDF_318_10_01)
        regs = registers_by_addr(result.datasheet)
        self.assertIn("LCD", regs["0x7002"][0]["description"])
        self.assertNotIn("LCD", regs["0x7003"][0]["description"])
        self.assertTrue(
            any("página anterior" in w for w in result.warnings),
            "continuidade entre páginas deve ser reportada",
        )


class MergeTest(unittest.TestCase):
    def test_merge_adds_new_version_and_keeps_old(self):
        import tempfile

        with tempfile.TemporaryDirectory() as tmp:
            tmp_path = pathlib.Path(tmp)
            first = pdf_to_uid.convert_pdf(PDF_318_22, version="1").datasheet
            base = tmp_path / "UID_0170 1.json"
            pdf_to_uid.write_json(base, first)

            second = pdf_to_uid.convert_pdf(PDF_318_22, version="2").datasheet
            merged = pdf_to_uid.merge_into(base, second)
            self.assertEqual(["1", "2"], [t["version"] for t in merged["technicalsInfo"]])
            pdf_to_uid.write_json(base, merged)

            with self.assertRaises(pdf_to_uid.DatasheetParseError):
                pdf_to_uid.merge_into(base, second)


class ReportTest(unittest.TestCase):
    """O relatório é o artefato de verificação: não pode mentir."""

    def test_no_missing_registers_in_report(self):
        for pdf in (PDF_318_22, PDF_318_10_01):
            result = pdf_to_uid.convert_pdf(pdf)
            self.assertNotIn(
                "AUSENTE", result.report,
                f"{pdf.name}: relatório não cobre todas as linhas do PDF",
            )
            self.assertNotIn(
                "ÓRFÃO", result.report,
                f"{pdf.name}: registro sem linha correspondente no PDF",
            )

    def test_report_covers_every_register(self):
        for pdf, expected in ((PDF_318_22, 50), (PDF_318_10_01, 41)):
            result = pdf_to_uid.convert_pdf(pdf)
            body = [
                line for line in result.report.splitlines()
                if line.startswith("| ") and "`0x" in line
            ]
            self.assertEqual(expected, len(body), f"{pdf.name}: linhas no relatório")


class SuspectTest(unittest.TestCase):
    """Gate 6.4: sem tabela de endereços -> falha alta, nada escrito."""

    def _make_pdf_without_table(self, tmpdir):
        import fitz

        doc = fitz.open()
        page = doc.new_page()
        page.insert_text((72, 72), "Datasheet sem tabela modbus nenhuma.")
        path = pathlib.Path(tmpdir) / "sem-tabela.pdf"
        doc.save(path)
        doc.close()
        return path

    def test_no_table_aborts(self):
        import tempfile

        with tempfile.TemporaryDirectory() as tmp:
            pdf = self._make_pdf_without_table(tmp)
            with self.assertRaises(pdf_to_uid.DatasheetParseError):
                pdf_to_uid.convert_pdf(pdf)


if __name__ == "__main__":
    unittest.main(verbosity=2)
