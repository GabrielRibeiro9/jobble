import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final _format = NumberFormat.currency(locale: 'pt_BR', symbol: '', decimalDigits: 2);

/// "1.234,56" a partir de centavos, sem o símbolo — o campo já tem o ícone.
String formatCentsInput(int cents) => _format.format(cents / 100).trim();

/// Centavos a partir do texto do campo ("1.234,56" → 123456).
int parseCents(String text) {
  final digits = text.replaceAll(RegExp(r'\D'), '');
  return digits.isEmpty ? 0 : int.parse(digits);
}

/// Campo de dinheiro que cresce da direita, como numa maquininha: cada dígito
/// entra nos centavos. Evita o usuário brigar com vírgula e ponto.
class CentsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cents = parseCents(newValue.text);
    final text = formatCentsInput(cents);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
