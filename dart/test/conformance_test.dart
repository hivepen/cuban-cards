// Pruebas de conformidad: ejecuta los vectores compartidos del repositorio.
//
// Fuente de verdad del comportamiento: ../../test-vectors/vectors.json
// Todos los puertos (Dart, Python, TypeScript, Kotlin, Java) deben pasarlos.
// Estas pruebas leen el archivo de vectores, así que corren en el checkout
// del monorepo: `dart test`.
import 'dart:convert';
import 'dart:io';

import 'package:cuban_cards/cuban_cards.dart';
import 'package:test/test.dart';

void main() {
  final vectorsFile = File('../test-vectors/vectors.json');
  final doc = jsonDecode(vectorsFile.readAsStringSync()) as Map<String, dynamic>;
  final vectors = doc['vectors'] as List<dynamic>;

  test('la versión del catálogo coincide con la de los vectores', () {
    expect(cubanCards.catalogVersion, doc['catalog_version']);
  });

  for (final v in vectors.cast<Map<String, dynamic>>()) {
    test('vector: ${v['input']} — ${v['note']}', () {
      final valid = v['valid'] as Map<String, dynamic>;
      for (final e in valid.entries) {
        expect(
          cubanCards.isValid(v['input'] as String?, kind: CardKind.fromKey(e.key)),
          e.value,
          reason: 'isValid(${v['input']}, ${e.key})',
        );
      }
      final expected = v['describe'] as Map<String, dynamic>?;
      final info = cubanCards.describe(v['input'] as String?);
      if (expected == null) {
        expect(info, isNull);
      } else {
        expect(info, isNotNull);
        expect(info!.prefix, expected['prefix']);
        expect(info.currency, expected['currency']);
        expect(info.mlcBacked, expected['mlc_backed']);
        expect(info.product, expected['product']);
        expect(info.bank, expected['bank']);
      }
      expect(cubanCards.bankOf(v['input'] as String?), v['bank_of']);
    });
  }

  test('normalize acepta null', () {
    expect(cubanCards.normalize(null), '');
    expect(cubanCards.describe(null), isNull);
  });

  test('CardKind.fromKey rechaza claves desconocidas', () {
    expect(() => CardKind.fromKey('nope'), throwsArgumentError);
  });
}
