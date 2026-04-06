import 'package:dio/dio.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    const String baseUrl = 'https://jobble-api.up.railway.app';
    // const String baseUrl = 'http://[IP_ADDRESS]';

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  Dio get dio => _dio;
}
