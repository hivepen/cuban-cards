# cuban-cards

**Qué banco, qué moneda y qué producto hay detrás de una tarjeta cubana, en
tu lenguaje.**

Bibliotecas para Dart, Python (y pronto TypeScript, Kotlin y Java) que
identifican tarjetas bancarias cubanas a partir de su número: validan la
estructura y el dígito de control (Luhn), y resuelven el banco, la moneda y
el producto. Sin dependencias de red en tiempo de ejecución.

Los datos vienen del catálogo comunitario abierto
[qvapay/cuban_cards_prefixes](https://github.com/qvapay/cuban_cards_prefixes)
(MIT), vendorizados aquí con la versión fijada. Este repo aporta los puertos
a cada lenguaje, un contrato de API común y vectores de prueba de
conformidad que todos los puertos deben pasar.

## Anatomía de una tarjeta RED

| Dígitos | Significado |
| --- | --- |
| 1–2 | Red (`92`) |
| 3–4 | Producto y moneda |
| 5–8 | Banco (`0699` BANDEC, `1299` BPA, `9598` Metropolitano, `04··` BICSA) |
| 9–15 | Cuenta |
| 16 | Dígito de control (Luhn) |

La Clásica (`9760`) y las AIS (`9550`/`9560`) no siguen esta estructura.

## Uso

**Dart** (`dart/`)

```dart
import 'package:cuban_cards/cuban_cards.dart';

cubanCards.isValid('9205 0699 0000 0000');               // true
cubanCards.isValid('9205 0699 0000 0000', kind: CardKind.cup); // true
cubanCards.describe('9227 9598 0000 0007');
// CardInfo(prefix: 9227, currency: CUP, mlcBacked: false,
//          product: Nómina, fondos, ahorro, bank: METROPOLITANO)
cubanCards.bankOf('9205 0699 0000 0000');                // BANDEC
```

**Python** (`python/`)

```python
import cuban_cards

cuban_cards.is_valid("9205 0699 0000 0000")          # True
cuban_cards.describe("9227 9598 0000 0007")
# CardInfo(prefix='9227', currency='CUP', mlc_backed=False,
#          product='Nómina, fondos, ahorro', bank='METROPOLITANO')
```

## Estructura del repo

| Ruta | Qué es |
| --- | --- |
| `data/` | Catálogo vendorizado del upstream, con la versión fijada (`data/UPSTREAM.md`) |
| `test-vectors/` | Vectores de conformidad compartidos: la fuente de verdad del comportamiento |
| `DESIGN.md` | Contrato de API que todos los puertos cumplen |
| `dart/`, `python/` | Puertos por lenguaje |
| `scripts/sync_data.py` | Actualiza los datos desde una versión del upstream y regenera los puertos |

## Actualizar los datos

```bash
python3 scripts/sync_data.py --version v0.5.1
```

Descarga `prefixes.json` y `validators.json` de esa versión del upstream,
actualiza `data/`, la copia del paquete Python y el código generado de Dart,
y corre las pruebas de conformidad de Python.

## Aviso

No es una fuente oficial de ningún banco: es un catálogo comunitario.
Verifica los datos antes de usarlos para mover dinero. Nunca publiques un
número de tarjeta completo en un issue o pull request: bastan los 8
primeros dígitos.

## Licencia

MIT. Los datos (`data/` y sus copias dentro de los paquetes) pertenecen al
proyecto [qvapay/cuban_cards_prefixes](https://github.com/qvapay/cuban_cards_prefixes),
también MIT; ver `data/UPSTREAM.md`.

---

**English summary.** Multi-language libraries (Dart and Python today,
TypeScript/Kotlin/Java planned) that identify Cuban bank cards: Luhn +
pattern validation, and bank/currency/product resolution from the card
number. Data comes from the open community catalog
[qvapay/cuban_cards_prefixes](https://github.com/qvapay/cuban_cards_prefixes)
(MIT), vendored here at a pinned version — no network at runtime. Every port
must pass the shared conformance vectors in `test-vectors/`.
