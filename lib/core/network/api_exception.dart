import 'package:dio/dio.dart';

/// Erro de API já traduzido para o profissional.
///
/// As telas mais antigas deste app mostram `$e` direto, o que vira
/// "DioException [bad response]…" na tela. As features novas (cadastro legal,
/// identidade, contrato) passam por aqui e recebem uma frase que dá para ler.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isConflict => statusCode == 409;

  @override
  String toString() => message;
}

/// Executa a chamada traduzindo qualquer falha de rede em [ApiException].
Future<T> apiCall<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (error) {
    throw translateDioError(error);
  }
}

ApiException translateDioError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const ApiException(
        'O servidor demorou para responder. Tente de novo em instantes.',
      );
    case DioExceptionType.connectionError:
      return const ApiException(
        'Não consegui falar com o servidor. Verifique sua conexão.',
      );
    default:
      break;
  }

  final status = error.response?.statusCode;
  final data = error.response?.data;

  // 404 do próprio framework ("Cannot PATCH /matches/…"): a rota não existe
  // na versão do servidor em que o app está falando — não é um "não
  // encontrado" de negócio, então a mensagem crua não serve para ninguém.
  if (status == 404 &&
      data is Map &&
      data['message'] is String &&
      (data['message'] as String).startsWith('Cannot ')) {
    return const ApiException(
      'Esta ação ainda não está disponível no servidor. Tente de novo mais '
      'tarde.',
      statusCode: 404,
    );
  }

  // Erros de negócio vêm como `{ message: string }`; os de validação do Zod,
  // às vezes, como `{ message: string[] }`.
  if (data is Map && data['message'] != null) {
    final message = data['message'];
    if (message is List && message.isNotEmpty) {
      return ApiException(message.first.toString(), statusCode: status);
    }
    if (message is String && message.isNotEmpty) {
      return ApiException(
        message == 'Validation failed'
            ? 'Confira os dados e tente de novo.'
            : message,
        statusCode: status,
      );
    }
  }

  if (status == 413) {
    return ApiException(
      'A imagem é grande demais. Tente uma foto menor.',
      statusCode: status,
    );
  }

  return ApiException('Algo deu errado. Tente novamente.', statusCode: status);
}
