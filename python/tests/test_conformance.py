"""Pruebas de conformidad: ejecuta los vectores compartidos del repositorio.

Fuente de verdad del comportamiento: ../../test-vectors/vectors.json
Todos los puertos (Dart, Python, TypeScript, Kotlin, Java) deben pasarlos.
"""

import json
import unittest
from pathlib import Path

import cuban_cards

VECTORS = json.loads(
    (Path(__file__).resolve().parents[2] / "test-vectors" / "vectors.json").read_text(
        encoding="utf-8"
    )
)["vectors"]


class ConformanceTest(unittest.TestCase):
    def test_catalog_version(self):
        data = json.loads(
            (Path(__file__).resolve().parents[2] / "test-vectors" / "vectors.json").read_text(
                encoding="utf-8"
            )
        )
        self.assertEqual(cuban_cards.CATALOG_VERSION, data["catalog_version"])

    def test_vectors(self):
        for v in VECTORS:
            with self.subTest(input=v["input"], note=v["note"]):
                for kind, expected in v["valid"].items():
                    self.assertEqual(
                        cuban_cards.is_valid(v["input"], kind),
                        expected,
                        f"is_valid({v['input']!r}, {kind!r})",
                    )
                got = cuban_cards.describe(v["input"])
                if v["describe"] is None:
                    self.assertIsNone(got)
                else:
                    self.assertIsNotNone(got)
                    self.assertEqual(
                        {
                            "prefix": got.prefix,
                            "currency": got.currency,
                            "mlc_backed": got.mlc_backed,
                            "product": got.product,
                            "bank": got.bank,
                        },
                        v["describe"],
                    )
                self.assertEqual(cuban_cards.bank_of(v["input"]), v["bank_of"])

    def test_unknown_kind_raises(self):
        with self.assertRaises(ValueError):
            cuban_cards.is_valid("9205069900000000", "nope")

    def test_normalize_none(self):
        self.assertEqual(cuban_cards.normalize(None), "")
        self.assertIsNone(cuban_cards.describe(None))


if __name__ == "__main__":
    unittest.main()
