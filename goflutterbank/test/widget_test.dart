import 'package:flutter_test/flutter_test.dart';
import 'package:goflutterbank/core/utils/currency.dart';

void main() {
  group('formatBRL', () {
    test('formata no padrão brasileiro', () {
      expect(formatBRL(1250), r'R$ 1.250,00');
      expect(formatBRL(45.9), r'R$ 45,90');
      expect(formatBRL(0), r'R$ 0,00');
      expect(formatBRL(1234567.89), r'R$ 1.234.567,89');
    });

    test('sinal para valores negativos e entrada', () {
      expect(formatBRL(-120), r'- R$ 120,00');
      expect(formatBRL(45.9, signed: true), r'+ R$ 45,90');
    });
  });
}
