import 'package:dio/dio.dart';
import 'package:flutter_tcc/core/services/token_service.dart';

class DioClient {
  late final Dio _dio;
  final TokenService tokenService;

  DioClient({required this.tokenService}) {
    const String baseUrl = 'https://jobble-api.up.railway.app';
    // const String baseUrl = 'http://[IP_ADDRESS]';

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
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
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  Dio get dio => _dio;
}
