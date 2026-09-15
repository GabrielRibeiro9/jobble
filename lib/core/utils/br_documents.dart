import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

/// Documentos brasileiros: validação por dígito verificador, máscaras e
/// formatação.
///
/// É a mesma regra de `br-documents.ts` no backend. Validar aqui também
/// evita a ida ao servidor só para ouvir "CPF inválido" — mas quem decide
/// continua sendo o servidor.

String onlyDigits(String? value) => (value ?? '').replaceAll(RegExp(r'\D'), '');

bool _isRepeated(String digits) => RegExp(r'^(\d)\1+$').hasMatch(digits);

bool isValidCpf(String? value) {
  final cpf = onlyDigits(value);
  if (cpf.length != 11 || _isRepeated(cpf)) return false;

  int digit(int length) {
    var sum = 0;
    for (var i = 0; i < length; i++) {
      sum += int.parse(cpf[i]) * (length + 1 - i);
    }
    final rest = (sum * 10) % 11;
    return rest == 10 ? 0 : rest;
  }

  return digit(9) == int.parse(cpf[9]) && digit(10) == int.parse(cpf[10]);
}

bool isValidCnpj(String? value) {
  final cnpj = onlyDigits(value);
  if (cnpj.length != 14 || _isRepeated(cnpj)) return false;

  int digit(int length) {
    final weights = length == 12
        ? const [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
        : const [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    var sum = 0;
    for (var i = 0; i < weights.length; i++) {
      sum += int.parse(cnpj[i]) * weights[i];
    }
    final rest = sum % 11;
    return rest < 2 ? 0 : 11 - rest;
  }

  return digit(12) == int.parse(cnpj[12]) && digit(13) == int.parse(cnpj[13]);
}

bool isValidPhone(String? value) {
  final phone = onlyDigits(value);
  return phone.length == 10 || phone.length == 11;
}

bool isValidCep(String? value) => onlyDigits(value).length == 8;

String formatCpf(String? value) {
  final cpf = onlyDigits(value);
  if (cpf.length != 11) return cpf;
  return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.'
      '${cpf.substring(6, 9)}-${cpf.substring(9)}';
}

String formatCnpj(String? value) {
  final cnpj = onlyDigits(value);
  if (cnpj.length != 14) return cnpj;
  return '${cnpj.substring(0, 2)}.${cnpj.substring(2, 5)}.'
      '${cnpj.substring(5, 8)}/${cnpj.substring(8, 12)}-${cnpj.substring(12)}';
}

String formatPhone(String? value) {
  final phone = onlyDigits(value);
  if (phone.length == 11) {
    return '(${phone.substring(0, 2)}) ${phone.substring(2, 7)}-${phone.substring(7)}';
  }
  if (phone.length == 10) {
    return '(${phone.substring(0, 2)}) ${phone.substring(2, 6)}-${phone.substring(6)}';
  }
  return phone;
}

String formatCep(String? value) {
  final cep = onlyDigits(value);
  if (cep.length != 8) return cep;
  return '${cep.substring(0, 5)}-${cep.substring(5)}';
}

/// Idade em anos completos.
int ageAt(DateTime birthDate, {DateTime? now}) {
  final today = now ?? DateTime.now();
  var age = today.year - birthDate.year;
  final beforeBirthday = today.month < birthDate.month ||
      (today.month == birthDate.month && today.day < birthDate.day);
  if (beforeBirthday) age--;
  return age;
}

bool isAdult(DateTime birthDate, {DateTime? now}) =>
    ageAt(birthDate, now: now) >= 18;

/// "dd/mm/aaaa" → data. Devolve `null` para datas que não existem
/// (31/02, 00/13…), que o `DateTime` aceitaria rolando o mês.
DateTime? parseBrDate(String? value) {
  final digits = onlyDigits(value);
  if (digits.length != 8) return null;

  final day = int.parse(digits.substring(0, 2));
  final month = int.parse(digits.substring(2, 4));
  final year = int.parse(digits.substring(4));
  final date = DateTime(year, month, day);

  if (date.day != day || date.month != month || date.year != year) return null;
  return date;
}

String formatBrDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

/// R$ 1.500,00 a partir de centavos.
String formatCents(int cents) {
  return NumberFormat.currency(locale: 'pt_BR', symbol: r'R$', decimalDigits: 2)
      .format(cents / 100);
}

/// Máscaras de campo. Cada chamada cria um formatador novo: eles guardam
/// estado e não podem ser compartilhados entre campos.
abstract final class BrMasks {
  static MaskTextInputFormatter _mask(String pattern) => MaskTextInputFormatter(
    mask: pattern,
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  static MaskTextInputFormatter cpf() => _mask('###.###.###-##');
  static MaskTextInputFormatter cnpj() => _mask('##.###.###/####-##');
  static MaskTextInputFormatter phone() => _mask('(##) #####-####');
  static MaskTextInputFormatter cep() => _mask('#####-###');
  static MaskTextInputFormatter date() => _mask('##/##/####');
}

/// Validadores prontos para `TextFormField.validator`.
abstract final class BrValidators {
  static String? cpf(String? value) =>
      isValidCpf(value) ? null : 'CPF inválido';

  static String? cnpj(String? value) =>
      isValidCnpj(value) ? null : 'CNPJ inválido';

  static String? phone(String? value) =>
      isValidPhone(value) ? null : 'Telefone com DDD';

  static String? cep(String? value) => isValidCep(value) ? null : 'CEP inválido';

  static String? adultBirthDate(String? value) {
    final date = parseBrDate(value);
    if (date == null) return 'Data inválida';
    if (!isAdult(date)) return 'É preciso ter 18 anos ou mais';
    return null;
  }

  static String? fullName(String? value) {
    final parts = (value ?? '').trim().split(RegExp(r'\s+'))
      ..removeWhere((part) => part.isEmpty);
    return parts.length >= 2 ? null : 'Informe nome e sobrenome';
  }

  static String? required(String? value, [String message = 'Obrigatório']) =>
      (value ?? '').trim().isEmpty ? message : null;
}
