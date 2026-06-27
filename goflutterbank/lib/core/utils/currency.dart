/// Formata um valor em Reais no padrão brasileiro: `R$ 1.250,00`.
/// (Formatação manual para não depender de pacote externo; trocar por `intl` se preferir.)
String formatBRL(double value, {bool signed = false}) {
  final negative = value < 0;
  final totalCents = (value.abs() * 100).round();
  final reais = totalCents ~/ 100;
  final cents = totalCents % 100;

  final digits = reais.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }

  final sign = negative ? '- ' : (signed ? '+ ' : '');
  return '$sign'
      'R\$ $buffer,${cents.toString().padLeft(2, '0')}';
}
