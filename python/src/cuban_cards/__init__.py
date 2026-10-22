"""cuban-cards: identifica tarjetas bancarias cubanas (banco, moneda, producto).

Los datos vienen del catálogo comunitario qvapay/cuban_cards_prefixes (MIT),
vendorizados en este paquete con la versión fijada. Sin red en tiempo de
ejecución. Contrato de API: ver DESIGN.md en el repositorio.
"""

from __future__ import annotations

import json
import re
from dataclasses import dataclass
from importlib import resources

__all__ = [
    "CardInfo",
    "CATALOG_VERSION",
    "KINDS",
    "normalize",
    "luhn",
    "is_valid",
    "describe",
    "bank_of",
]

_DATA = resources.files("cuban_cards.data")
_PREFIXES = json.loads(_DATA.joinpath("prefixes.json").read_text(encoding="utf-8"))
_VALIDATORS = json.loads(_DATA.joinpath("validators.json").read_text(encoding="utf-8"))

CATALOG_VERSION: str = _PREFIXES["version"]
KINDS: tuple[str, ...] = tuple(_VALIDATORS["patterns"].keys())

_STRIP = re.compile(_VALIDATORS["normalize"]["strip_pattern"])
_PATTERNS = {k: re.compile(p) for k, p in _VALIDATORS["patterns"].items()}
_ISSUERS = {k: re.compile(p) for k, p in _VALIDATORS["issuers"].items()}
_VARIANTS = _VALIDATORS.get("variants", {})
_BY_PREFIX = {p["prefix"]: p for p in _PREFIXES["prefixes"]}


@dataclass(frozen=True)
class CardInfo:
    prefix: str
    currency: str
    mlc_backed: bool | None
    product: str | None
    bank: str | None


def normalize(raw) -> str:
    """Quita espacios, guiones y puntos. Entrada no textual -> cadena vacía."""
    if raw is None:
        return ""
    return _STRIP.sub("", str(raw))


def luhn(digits: str) -> bool:
    """Dígito de control ISO/IEC 7812 sobre una cadena de dígitos."""
    total = 0
    for i, ch in enumerate(reversed(digits)):
        d = int(ch)
        if i % 2:
            d = d * 2 - 9 if d > 4 else d * 2
        total += d
    return total % 10 == 0


def is_valid(raw, kind: str = "any") -> bool:
    """True si es una tarjeta cubana válida del tipo `kind` (patrón + Luhn)."""
    if kind not in _PATTERNS:
        raise ValueError(f"kind inválido: {kind!r}. Usa: {', '.join(KINDS)}")
    n = normalize(raw)
    if not n.isdigit():
        return False
    return _PATTERNS[kind].match(n) is not None and luhn(n)


def _bank_for(n: str, entry: dict) -> str | None:
    for bank, pattern in _ISSUERS.items():
        if pattern.match(n):
            return bank
    issuers = entry.get("issuers") or []
    return issuers[0] if issuers else None


def describe(raw) -> CardInfo | None:
    """Describe la tarjeta, o None si no es una tarjeta cubana válida."""
    n = normalize(raw)
    if not n.isdigit() or not (is_valid(n) and n[:4] in _BY_PREFIX):
        return None
    entry = _BY_PREFIX[n[:4]]
    variant = _VARIANTS.get(n[:6], {})
    return CardInfo(
        prefix=entry["prefix"],
        currency=entry["currency"],
        mlc_backed=entry["mlc_backed"],
        product=variant.get("product", entry["product"]),
        bank=_bank_for(n, entry),
    )


def bank_of(raw) -> str | None:
    """El banco de una tarjeta RED válida; None en cualquier otro caso."""
    n = normalize(raw)
    if not n.isdigit() or not is_valid(n, "red"):
        return None
    for bank, pattern in _ISSUERS.items():
        if pattern.match(n):
            return bank
    return None
