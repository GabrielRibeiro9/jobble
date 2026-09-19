import 'package:dio/dio.dart';
import 'package:flutter_tcc/core/config/app_config.dart';
import 'package:flutter_tcc/core/network/mock_interceptor.dart';
import 'package:flutter_tcc/core/services/token_service.dart';

class DioClient {
  late final Dio _dio;
  final TokenService tokenService;

  static const String baseUrl = AppConfig.apiBaseUrl;

  DioClient({required this.tokenService}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.connectionError) {
            await tokenService.deleteToken();
          }
          return handler.next(error);
        },
      ),
    );

    if (AppConfig.useMock) {
      // Modo desenvolvimento (`--dart-define=USE_MOCK=true`): responde os
      // GETs de leitura com dados ficticios, para o painel de 5 abas abrir
      // cheio sem depender da API nem de login real.
      _dio.interceptors.add(MockInterceptor());
    }

    if (AppConfig.enableHttpLogs) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
  }

  Dio get dio => _dio;
}
