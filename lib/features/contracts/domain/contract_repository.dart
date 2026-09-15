import 'package:flutter_tcc/features/contracts/data/models/contract_model.dart';

/// Os casos de uso do contrato na visão do profissional.
///
/// Existe como contrato abstrato para que os cubits possam ser testados com
/// um repositório falso, sem rede — é aqui que mora a regra "o que o
/// profissional pode fazer com um contrato".
abstract class ContractRepository {
  Future<List<ContractSummary>> list();

  Future<ContractModel> get(String id);

  /// Salva o rascunho. Não precisa estar completo.
  Future<ContractModel> updateTerms(String id, ContractTerms terms);

  /// Congela o documento e manda para o cliente assinar.
  Future<ContractModel> submit(String id);

  /// Assina a versão cujo hash o profissional viu.
  Future<ContractModel> sign(String id, {required String contentHash});

  Future<ContractModel> markCompleted(String id);

  Future<ContractModel> cancel(String id, {required String reason});

  Future<ContractModel> terminate(String id, {required String reason});

  /// Manda o PDF para o e-mail do usuário; devolve a mensagem do servidor.
  Future<String> sendCopy(String id);
}
