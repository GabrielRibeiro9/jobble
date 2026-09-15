import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_tcc/core/network/api_exception.dart';
import 'package:flutter_tcc/features/contracts/data/models/contract_model.dart';
import 'package:flutter_tcc/features/contracts/domain/contract_repository.dart';

class ContractsListState extends Equatable {
  const ContractsListState({
    this.items = const [],
    this.loading = true,
    this.error,
  });

  final List<ContractSummary> items;
  final bool loading;
  final String? error;

  /// Contratos esperando uma ação de quem está olhando vêm primeiro.
  List<ContractSummary> get needingAttention =>
      items.where((item) => item.needsAttention).toList();

  List<ContractSummary> get others =>
      items.where((item) => !item.needsAttention).toList();

  @override
  List<Object?> get props => [items, loading, error];
}

class ContractsListCubit extends Cubit<ContractsListState> {
  ContractsListCubit({required ContractRepository repository})
    : _repository = repository,
      super(const ContractsListState());

  final ContractRepository _repository;

  Future<void> load() async {
    emit(ContractsListState(items: state.items, loading: true));
    try {
      final items = await _repository.list();
      if (isClosed) return;
      emit(ContractsListState(items: items, loading: false));
    } on ApiException catch (error) {
      if (isClosed) return;
      emit(
        ContractsListState(
          items: state.items,
          loading: false,
          error: error.message,
        ),
      );
    }
  }
}
