# cuban-cards (Python)

Identifica tarjetas bancarias cubanas: qué banco, qué moneda y qué producto
hay detrás de un número, y si el número es válido (patrón + dígito de
control Luhn). Datos del catálogo comunitario
[qvapay/cuban_cards_prefixes](https://github.com/qvapay/cuban_cards_prefixes)
(MIT), vendorizados con la versión fijada: sin red en tiempo de ejecución.

```python
import cuban_cards

cuban_cards.is_valid("9205 0699 0000 0000")            # True
cuban_cards.is_valid("9205 0699 0000 0000", "cup")     # True
info = cuban_cards.describe("9205 0699 0000 0000")
# CardInfo(prefix='9205', currency='CUP', mlc_backed=False,
#          product='Ahorro', bank='BANDEC')
cuban_cards.bank_of("9227 9598 0000 0007")             # 'METROPOLITANO'
```

Repo y contrato de API: https://github.com/hivepen/cuban-cards
