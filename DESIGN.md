# Diseño — cuban-cards

Bibliotecas multiplataforma (Dart, Python, TypeScript, Kotlin, Java) para
identificar tarjetas bancarias cubanas: qué banco, qué moneda y qué producto
hay detrás de un número, y si el número es válido.

## Fuente de los datos

El catálogo **no** se mantiene aquí. Vive en el proyecto comunitario
[qvapay/cuban_cards_prefixes](https://github.com/qvapay/cuban_cards_prefixes)
(MIT), que documenta la anatomía de la tarjeta RED:

| Dígitos | Significado |
| --- | --- |
| 1–2 | Red (`92` = RED) |
| 3–4 | Producto y moneda |
| 5–8 | Banco (`0699` BANDEC, `1299` BPA, `9598` Metropolitano, `04··` BICSA) |
| 9–15 | Cuenta |
| 16 | Dígito de control (Luhn) |

La Clásica (`9760`, FINCIMEX) y las AIS (`9550`/`9560`) no siguen la
estructura RED. La variante de 6 dígitos `976004` es la Clásica Empresarial.

Aquí los datos se **vendorizan fijando versión** (`data/`, hoy v0.5.1) para
que ninguna app dependa de la red en tiempo de ejecución. El script
`scripts/sync_data.py` actualiza la copia desde una versión concreta del
upstream y regenera lo que cada lenguaje necesite.

## Contrato de API (idéntico en todos los lenguajes)

Semántica tomada de las implementaciones de referencia del propio upstream
(JavaScript/Python/PHP en su README). Cada puerto debe cumplirla tal cual:

- `normalize(raw) -> string`
  Quita espacios, guiones y puntos (`normalize.strip_pattern` de los datos).
  Entrada no textual o `null` → cadena vacía.
- `luhn(digits) -> bool`
  Dígito de control ISO/IEC 7812.
- `isValid(raw, kind = 'any') -> bool`
  `normalize` + coincidencia con el patrón `kind` de `validators.json` +
  Luhn. `kind` ∈ `any | red | cup | usd | usd_mlc | clasica |
  clasica_empresarial | ais_cup | ais_usd`. Un `kind` desconocido es un
  **error** (excepción/argumento inválido) que lista los valores admitidos,
  nunca un `false` silencioso.
- `describe(raw) -> CardInfo | null`
  `null` si no es una tarjeta cubana válida. Si lo es:
  `{ prefix, currency, mlcBacked, product, bank }` donde:
  - `prefix`, `currency`, `mlcBacked`, `product` salen de la entrada del
    catálogo para los 4 primeros dígitos; una variante de 6 dígitos
    (p. ej. `976004`) pisa el `product`.
  - `bank` se resuelve primero por los patrones de emisor (dígitos 5–8);
    si ninguno coincide, se usa el primer emisor confirmado del prefijo.
  - `product` puede ser `null` (prefijo aún sin identificar en el catálogo).
- `bankOf(raw) -> string | null`
  Solo el banco, y solo para tarjetas RED válidas (`null` en otro caso).

Los nombres de métodos se adaptan a cada lenguaje (`isValid` →
`is_valid` en Python, etc.); la semántica y los valores no cambian.

## Conformidad

`test-vectors/vectors.json` es la fuente de verdad del comportamiento:
casos con el número (con y sin formato), el resultado de `isValid` por
`kind`, el `describe` esperado y el dígito Luhn. Incluye los 6 casos
reales aportados por titulares (BANMET/BPA/BANDEC en CUP y USD) y ejemplos
del upstream. **Un puerto no está terminado hasta pasar el 100 % de los
vectores.**

## Lo que NO es este proyecto

- No es una fuente oficial de ningún banco: es un catálogo comunitario.
- No hace red en tiempo de ejecución: los datos viajan dentro de cada
  paquete, fijados a una versión del upstream.
- No valida saldos ni cuentas: solo la estructura del número.
