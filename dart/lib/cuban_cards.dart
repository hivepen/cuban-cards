/// Identifica tarjetas bancarias cubanas: banco, moneda y producto detrás
/// de un número, y si es válido.
///
/// Datos del catálogo comunitario qvapay/cuban_cards_prefixes (MIT),
/// vendorizados con la versión fijada: sin red en tiempo de ejecución.
/// Contrato de API: ver DESIGN.md en el repositorio.
library;

export 'src/cuban_cards_base.dart'
    show CardInfo, CardKind, CubanCards, cubanCards;
