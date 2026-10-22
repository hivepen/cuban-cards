# Procedencia de los datos

`prefixes.json` y `validators.json` de esta carpeta son una copia fiel del
catálogo comunitario **[qvapay/cuban_cards_prefixes](https://github.com/qvapay/cuban_cards_prefixes)**,
mantenido por QvaPay y la comunidad.

- **Versión fijada:** v0.5.1 (`"version": "0.5.1"` dentro de ambos ficheros)
- **Licencia:** MIT (la del upstream; este repo es también MIT)
- **Origen:**
  - https://raw.githubusercontent.com/qvapay/cuban_cards_prefixes/main/prefixes.json
  - https://raw.githubusercontent.com/qvapay/cuban_cards_prefixes/main/validators.json
- **Copia tomada:** 2026-10-21

Para actualizar a otra versión del upstream (y regenerar las copias que
viven dentro de cada paquete), usa desde la raíz del repo:

```bash
python3 scripts/sync_data.py --version vX.Y.Z
```

Nunca edites estos JSON a mano aquí: las correcciones de datos van al
upstream, que es donde la comunidad las verifica con sus fuentes.
