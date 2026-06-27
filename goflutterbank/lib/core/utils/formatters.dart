import 'package:flutter/services.dart';

/// Remove tudo que não for dígito de [s].
String onlyDigits(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

/// Retorna apenas os 11 dígitos brutos de um CPF mascarado (000.000.000-00).
String stripCpf(String masked) {
  final digits = onlyDigits(masked);
  return digits.length > 11 ? digits.substring(0, 11) : digits;
}

/// Converte o texto de um campo BRL ("1.234,56") para double (1234.56).
double brlTextToDouble(String text) {
  final digits = onlyDigits(text);
  if (digits.isEmpty) return 0;
  return int.parse(digits) / 100;
}

/// Máscara de CPF: formata os dígitos como 000.000.000-00 (máx. 11 dígitos).
class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = onlyDigits(newValue.text);
    if (digits.length > 11) digits = digits.substring(0, 11);

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 3 || i == 6) buffer.write('.');
      if (i == 9) buffer.write('-');
      buffer.write(digits[i]);
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Máscara de valor em reais: trata os dígitos digitados como centavos e
/// exibe "1.234,56" (sem o prefixo R$, que o campo mostra separadamente).
class BrlInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = onlyDigits(newValue.text);
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final value = int.parse(digits);
    final cents = (value % 100).toString().padLeft(2, '0');
    final reais = (value ~/ 100).toString();

    // Agrupa os reais em milhares com pontos.
    final grouped = StringBuffer();
    for (var i = 0; i < reais.length; i++) {
      if (i > 0 && (reais.length - i) % 3 == 0) grouped.write('.');
      grouped.write(reais[i]);
    }

    final text = '$grouped,$cents';
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
