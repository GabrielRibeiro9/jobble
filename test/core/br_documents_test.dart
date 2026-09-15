import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_tcc/core/utils/br_documents.dart';
import 'package:flutter_tcc/core/utils/money_input_formatter.dart';

void main() {
  group('CPF', () {
    test('aceita válido com e sem máscara', () {
      expect(isValidCpf('529.982.247-25'), isTrue);
      expect(isValidCpf('52998224725'), isTrue);
    });

    test('recusa dígito errado, repetido e incompleto', () {
      expect(isValidCpf('529.982.247-24'), isFalse);
      expect(isValidCpf('111.111.111-11'), isFalse);
      expect(isValidCpf('5299822472'), isFalse);
      expect(isValidCpf(null), isFalse);
    });

    test('formata', () {
      expect(formatCpf('52998224725'), '529.982.247-25');
    });
  });

  group('CNPJ', () {
    test('aceita válido e recusa inválido', () {
      expect(isValidCnpj('11.222.333/0001-81'), isTrue);
      expect(isValidCnpj('11.222.333/0001-80'), isFalse);
      expect(isValidCnpj('00000000000000'), isFalse);
    });

    test('formata', () {
      expect(formatCnpj('11222333000181'), '11.222.333/0001-81');
    });
  });

  group('datas', () {
    test('lê dd/mm/aaaa', () {
      expect(parseBrDate('10/05/1990'), DateTime(1990, 5, 10));
    });

    test('recusa datas que não existem', () {
      expect(parseBrDate('31/02/2000'), isNull);
      expect(parseBrDate('00/13/2000'), isNull);
      expect(parseBrDate('1/1/2000'), isNull);
    });

    test('maioridade vira no dia do aniversário', () {
      final now = DateTime(2026, 9, 13);
      expect(isAdult(DateTime(2008, 9, 13), now: now), isTrue);
      expect(isAdult(DateTime(2008, 9, 14), now: now), isFalse);
    });

    test('validador de nascimento explica o motivo', () {
      expect(BrValidators.adultBirthDate('31/02/2000'), 'Data inválida');
      expect(BrValidators.adultBirthDate('01/01/2020'), contains('18 anos'));
      expect(BrValidators.adultBirthDate('01/01/1990'), isNull);
    });
  });

  group('validadores', () {
    test('nome completo exige sobrenome', () {
      expect(BrValidators.fullName('Maria'), isNotNull);
      expect(BrValidators.fullName('  Maria   da Silva '), isNull);
    });

    test('telefone com DDD', () {
      expect(BrValidators.phone('(11) 98765-4321'), isNull);
      expect(BrValidators.phone('98765-4321'), isNotNull);
    });
  });

  group('dinheiro', () {
    test('centavos para texto e de volta', () {
      expect(formatCentsInput(150000), '1.500,00');
      expect(parseCents('1.500,00'), 150000);
      expect(parseCents(''), 0);
    });

    test('formata com símbolo', () {
      final text = formatCents(150000);
      expect(text, startsWith(r'R$'));
      expect(text, endsWith('1.500,00'));
    });

    test('o campo cresce da direita', () {
      final formatter = CentsInputFormatter();
      final value = formatter.formatEditUpdate(
        const TextEditingValue(text: '1,50'),
        const TextEditingValue(text: '1,505'),
      );
      expect(value.text, '15,05');
    });
  });
}
