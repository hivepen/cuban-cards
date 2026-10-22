import 'dart:convert';

import 'data.g.dart';

/// Tipo de tarjeta a comprobar con [CubanCards.isValid].
enum CardKind {
  any,
  red,
  cup,
  usd,
  usdMlc,
  clasica,
  clasicaEmpresarial,
  aisCup,
  aisUsd;

  /// Clave del patrón en `validators.json`.
  String get patternKey => switch (this) {
        CardKind.any => 'any',
        CardKind.red => 'red',
        CardKind.cup => 'cup',
        CardKind.usd => 'usd',
        CardKind.usdMlc => 'usd_mlc',
        CardKind.clasica => 'clasica',
        CardKind.clasicaEmpresarial => 'clasica_empresarial',
        CardKind.aisCup => 'ais_cup',
        CardKind.aisUsd => 'ais_usd',
      };

  /// Resuelve una clave de `validators.json`; error si no existe.
  static CardKind fromKey(String key) {
    for (final kind in CardKind.values) {
      if (kind.patternKey == key) return kind;
    }
    throw ArgumentError(
      'kind inválido: $key. Usa: '
      '${CardKind.values.map((k) => k.patternKey).join(', ')}',
    );
  }
}

/// Resultado de [CubanCards.describe].
class CardInfo {
  const CardInfo({
    required this.prefix,
    required this.currency,
    required this.mlcBacked,
    required this.product,
    required this.bank,
  });

  final String prefix;
  final String currency;
  final bool? mlcBacked;
  final String? product;
  final String? bank;

  @override
  bool operator ==(Object other) =>
      other is CardInfo &&
      other.prefix == prefix &&
      other.currency == currency &&
      other.mlcBacked == mlcBacked &&
      other.product == product &&
      other.bank == bank;

  @override
  int get hashCode => Object.hash(prefix, currency, mlcBacked, product, bank);

  @override
  String toString() => 'CardInfo(prefix: $prefix, currency: $currency, '
      'mlcBacked: $mlcBacked, product: $product, bank: $bank)';
}

/// Identificador de tarjetas cubanas sobre un catálogo concreto.
class CubanCards {
  CubanCards.fromJson(String prefixesJson, String validatorsJson)
      : _prefixes = jsonDecode(prefixesJson) as Map<String, dynamic>,
        _validators = jsonDecode(validatorsJson) as Map<String, dynamic> {
    final normalize = _validators['normalize'] as Map<String, dynamic>;
    _strip = RegExp(normalize['strip_pattern'] as String);
    final patterns = _validators['patterns'] as Map<String, dynamic>;
    _patterns = {
      for (final e in patterns.entries) e.key: RegExp(e.value as String),
    };
    final issuers = _validators['issuers'] as Map<String, dynamic>;
    _issuerPatterns = {
      for (final e in issuers.entries) e.key: RegExp(e.value as String),
    };
    _variants =
        (_validators['variants'] as Map<String, dynamic>?) ?? const {};
    final prefixList = _prefixes['prefixes'] as List<dynamic>;
    _byPrefix = {
      for (final p in prefixList)
        (p as Map<String, dynamic>)['prefix'] as String: p,
    };
  }

  /// Instancia con los datos vendorizados del paquete (versión fijada).
  factory CubanCards.bundled() => CubanCards.fromJson(
        kPrefixesJson,
        kValidatorsJson,
      );

  final Map<String, dynamic> _prefixes;
  final Map<String, dynamic> _validators;
  late final RegExp _strip;
  late final Map<String, RegExp> _patterns;
  late final Map<String, RegExp> _issuerPatterns;
  late final Map<String, dynamic> _variants;
  late final Map<String, Map<String, dynamic>> _byPrefix;

  /// Versión del catálogo de datos en uso.
  String get catalogVersion => _prefixes['version'] as String;

  /// Quita espacios, guiones y puntos. `null` -> cadena vacía.
  String normalize(String? raw) =>
      raw == null ? '' : raw.replaceAll(_strip, '');

  /// Dígito de control ISO/IEC 7812 (Luhn) sobre una cadena de dígitos.
  static bool luhn(String digits) {
    var total = 0;
    final units = digits.codeUnits;
    for (var i = 0; i < units.length; i++) {
      var d = units[units.length - 1 - i] - 0x30;
      if (i.isOdd) {
        d = d > 4 ? d * 2 - 9 : d * 2;
      }
      total += d;
    }
    return total % 10 == 0;
  }

  static final _digitsOnly = RegExp(r'^[0-9]+$');

  /// True si es una tarjeta cubana válida del tipo [kind] (patrón + Luhn).
  bool isValid(String? raw, {CardKind kind = CardKind.any}) {
    final n = normalize(raw);
    if (!_digitsOnly.hasMatch(n)) return false;
    return _patterns[kind.patternKey]!.hasMatch(n) && luhn(n);
  }

  String? _bankFor(String n, Map<String, dynamic> entry) {
    for (final e in _issuerPatterns.entries) {
      if (e.value.hasMatch(n)) return e.key;
    }
    final issuers = entry['issuers'] as List<dynamic>?;
    return (issuers == null || issuers.isEmpty) ? null : issuers.first as String;
  }

  /// Describe la tarjeta, o `null` si no es una tarjeta cubana válida.
  CardInfo? describe(String? raw) {
    final n = normalize(raw);
    if (!_digitsOnly.hasMatch(n) || !isValid(n)) return null;
    final entry = _byPrefix[n.substring(0, 4)];
    if (entry == null) return null;
    final variant = _variants[n.substring(0, 6)] as Map<String, dynamic>?;
    return CardInfo(
      prefix: entry['prefix'] as String,
      currency: entry['currency'] as String,
      mlcBacked: entry['mlc_backed'] as bool?,
      product: (variant?['product'] ?? entry['product']) as String?,
      bank: _bankFor(n, entry),
    );
  }

  /// El banco de una tarjeta RED válida; `null` en cualquier otro caso.
  String? bankOf(String? raw) {
    final n = normalize(raw);
    if (!_digitsOnly.hasMatch(n) || !isValid(n, kind: CardKind.red)) {
      return null;
    }
    for (final e in _issuerPatterns.entries) {
      if (e.value.hasMatch(n)) return e.key;
    }
    return null;
  }
}

/// Instancia compartida con los datos vendorizados.
final CubanCards cubanCards = CubanCards.bundled();
