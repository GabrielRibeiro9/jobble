import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_tcc/core/network/api_exception.dart';
import 'package:flutter_tcc/features/contracts/data/models/contract_model.dart';
import 'package:flutter_tcc/features/contracts/domain/contract_repository.dart';
import 'package:flutter_tcc/features/contracts/presentation/bloc/contract_detail_cubit.dart';

import 'contract_fixtures.dart';

/// Repositório em memória: guarda o que foi pedido e devolve o que o teste
/// mandou. Um erro em `failNext` é lançado uma vez só.
class _FakeRepository implements ContractRepository {
  _FakeRepository(this.current);

  ContractModel current;
  ApiException? failNext;
  final calls = <String>[];
  String? signedHash;

  Future<ContractModel> _answer(String call, [ContractModel? next]) async {
    calls.add(call);
    final error = failNext;
    if (error != null) {
      failNext = null;
      throw error;
    }
    if (next != null) current = next;
    return current;
  }

  @override
  Future<ContractModel> get(String id) => _answer('get');

  @override
  Future<List<ContractSummary>> list() async => [];

  @override
  Future<ContractModel> updateTerms(String id, ContractTerms terms) =>
      _answer('updateTerms');

  @override
  Future<ContractModel> submit(String id) => _answer(
    'submit',
    ContractModel.fromJson(
      contractJson(
        status: 'PENDING_SIGNATURES',
        contentHash: 'b' * 64,
        actions: ['EDIT_TERMS', 'SIGN', 'CANCEL', 'DOWNLOAD'],
      ),
    ),
  );

  @override
  Future<ContractModel> sign(String id, {required String contentHash}) {
    signedHash = contentHash;
    return _answer('sign');
  }

  @override
  Future<ContractModel> markCompleted(String id) => _answer('markCompleted');

  @override
  Future<ContractModel> cancel(String id, {required String reason}) =>
      _answer('cancel');

  @override
  Future<ContractModel> terminate(String id, {required String reason}) =>
      _answer('terminate');

  @override
  Future<String> sendCopy(String id) async {
    calls.add('sendCopy');
    return 'Enviamos uma cópia para maria@example.com';
  }
}

void main() {
  late _FakeRepository repository;
  late ContractDetailCubit cubit;

  setUp(() {
    repository = _FakeRepository(ContractModel.fromJson(contractJson()));
    cubit = ContractDetailCubit(repository: repository, contractId: 'contract-1');
  });

  tearDown(() => cubit.close());

  test('carrega o contrato', () async {
    await cubit.load();

    expect(cubit.state.loading, isFalse);
    expect(cubit.state.contract?.code, 'JB-2026-ABCDEF12');
  });

  test('erro ao carregar vira mensagem, não exceção', () async {
    repository.failNext = const ApiException('Contrato não encontrado');
    await cubit.load();

    expect(cubit.state.contract, isNull);
    expect(cubit.state.error, 'Contrato não encontrado');
  });

  test('enviar troca o contrato pelo que o servidor devolveu', () async {
    await cubit.load();
    final ok = await cubit.submit();

    expect(ok, isTrue);
    expect(cubit.state.contract?.status, ContractStatus.pendingSignatures);
    expect(cubit.state.contract?.can(ContractAction.sign), isTrue);
    expect(cubit.state.message, contains('enviado'));
  });

  test('não assina rascunho: sem hash não há o que assinar', () async {
    await cubit.load();
    final ok = await cubit.sign();

    expect(ok, isFalse);
    expect(repository.calls, isNot(contains('sign')));
    expect(cubit.state.error, isNotNull);
  });

  test('assina com o hash da versão que está na tela', () async {
    await cubit.load();
    await cubit.submit();
    await cubit.sign();

    expect(repository.signedHash, 'b' * 64);
  });

  test('contrato mudou (409): recarrega para mostrar a versão atual', () async {
    await cubit.load();
    await cubit.submit();

    repository.failNext = const ApiException(
      'O contrato mudou desde que você abriu.',
      statusCode: 409,
    );
    final ok = await cubit.sign();

    expect(ok, isFalse);
    expect(repository.calls.where((c) => c == 'get'), hasLength(2));
    expect(cubit.state.error, contains('mudou'));
  });

  test('salvar termos devolve falso quando o servidor recusa', () async {
    await cubit.load();
    repository.failNext = const ApiException('Complete os termos: Preço');

    final ok = await cubit.saveTerms(
      const ContractTerms(scope: 'Trocar toda a fiação do apartamento'),
    );

    expect(ok, isFalse);
    expect(cubit.state.acting, isFalse);
    expect(cubit.state.error, 'Complete os termos: Preço');
  });

  test('pedir cópia mostra a confirmação do servidor', () async {
    await cubit.load();
    await cubit.sendCopy();

    expect(cubit.state.message, contains('maria@example.com'));
  });

  test('ações não se sobrepõem', () async {
    await cubit.load();
    final first = cubit.markCompleted();
    final second = await cubit.cancel('mudança de planos');

    await first;
    expect(second, isFalse);
    expect(repository.calls.where((c) => c == 'cancel'), isEmpty);
  });
}
