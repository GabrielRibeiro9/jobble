import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_tcc/core/network/api_exception.dart';
import 'package:flutter_tcc/features/contracts/data/models/contract_model.dart';
import 'package:flutter_tcc/features/contracts/domain/contract_repository.dart';

class ContractDetailState extends Equatable {
  const ContractDetailState({
    this.contract,
    this.loading = true,
    this.acting = false,
    this.error,
    this.message,
  });

  final ContractModel? contract;
  final bool loading;

  /// Uma ação (salvar, enviar, assinar…) está em curso.
  final bool acting;

  final String? error;

  /// Confirmação de uma ação bem-sucedida, para o snackbar.
  final String? message;

  ContractDetailState copyWith({
    ContractModel? contract,
    bool? loading,
    bool? acting,
    String? error,
    String? message,
    bool clearError = false,
    bool clearMessage = false,
  }) {
    return ContractDetailState(
      contract: contract ?? this.contract,
      loading: loading ?? this.loading,
      acting: acting ?? this.acting,
      error: clearError ? null : (error ?? this.error),
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [contract, loading, acting, error, message];
}

/// Um contrato aberto na tela do profissional.
///
/// Cada ação devolve o contrato atualizado pelo servidor, que substitui o
/// estado inteiro — inclusive `allowedActions`. A tela nunca decide sozinha o
/// que vem depois de uma ação: ela redesenha a partir do que o servidor disse.
class ContractDetailCubit extends Cubit<ContractDetailState> {
  ContractDetailCubit({
    required ContractRepository repository,
    required this.contractId,
  }) : _repository = repository,
       super(const ContractDetailState());

  final ContractRepository _repository;
  final String contractId;

  Future<void> load({bool silent = false}) async {
    if (!silent) emit(state.copyWith(loading: true, clearError: true));

    try {
      final contract = await _repository.get(contractId);
      if (isClosed) return;
      // Recarga silenciosa não apaga o erro: é ela que roda depois de um
      // "o contrato mudou", e a mensagem é o que explica a troca do texto.
      emit(
        state.copyWith(contract: contract, loading: false, clearError: !silent),
      );
    } on ApiException catch (error) {
      if (isClosed) return;
      emit(state.copyWith(loading: false, error: error.message));
    }
  }

  /// Salva os termos. Devolve `true` se salvou — a tela de edição fecha só
  /// nesse caso.
  Future<bool> saveTerms(ContractTerms terms) =>
      _act(() => _repository.updateTerms(contractId, terms), 'Termos salvos');

  Future<bool> submit() => _act(
    () => _repository.submit(contractId),
    'Contrato enviado para o cliente assinar',
  );

  /// Assina a versão que está na tela. Sem hash não há o que assinar: o
  /// contrato ainda é rascunho.
  Future<bool> sign() async {
    final hash = state.contract?.contentHash;
    if (hash == null) {
      emit(state.copyWith(error: 'Este contrato ainda não foi enviado'));
      return false;
    }
    return _act(
      () => _repository.sign(contractId, contentHash: hash),
      'Contrato assinado',
    );
  }

  Future<bool> markCompleted() => _act(
    () => _repository.markCompleted(contractId),
    'Conclusão registrada. O cliente vai confirmar',
  );

  Future<bool> cancel(String reason) => _act(
    () => _repository.cancel(contractId, reason: reason),
    'Contrato cancelado',
  );

  Future<bool> terminate(String reason) => _act(
    () => _repository.terminate(contractId, reason: reason),
    'Contrato rescindido',
  );

  Future<void> sendCopy() async {
    if (state.acting) return;
    emit(state.copyWith(acting: true, clearError: true));
    try {
      final message = await _repository.sendCopy(contractId);
      if (isClosed) return;
      emit(state.copyWith(acting: false, message: message));
    } on ApiException catch (error) {
      if (isClosed) return;
      emit(state.copyWith(acting: false, error: error.message));
    }
  }

  void clearMessages() => emit(state.copyWith(clearError: true, clearMessage: true));

  Future<bool> _act(
    Future<ContractModel> Function() action,
    String successMessage,
  ) async {
    if (state.acting) return false;

    emit(state.copyWith(acting: true, clearError: true, clearMessage: true));

    try {
      final contract = await action();
      if (isClosed) return true;
      emit(
        state.copyWith(
          contract: contract,
          acting: false,
          message: successMessage,
        ),
      );
      return true;
    } on ApiException catch (error) {
      if (isClosed) return false;
      emit(state.copyWith(acting: false, error: error.message));

      // "O contrato mudou desde que você abriu": recarregar mostra a versão
      // atual, que é o que o usuário precisa revisar.
      if (error.isConflict) await load(silent: true);
      return false;
    }
  }
}
