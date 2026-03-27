import 'package:dio/dio.dart';
import '../utils/logger.dart';

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.senineticaretprojen.com/v1', // Kendi API URL'in
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // İstek arasına girip Token ekleme ve Loglama (Interceptor)
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Not: Burada Hive veya SharedPreferences'tan kaydedilmiş token'ı almalısın
          const String? token = "mock_jwt_token_here";

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          logger.i("🌐 API İsteği: [${options.method}] ${options.uri}");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          logger.i("✅ API Başarılı: ${response.statusCode}");
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          logger.e("❌ API Hatası: ${e.response?.statusCode} - ${e.message}");
          return handler.next(e);
        },
      ),
    );
  }
}
