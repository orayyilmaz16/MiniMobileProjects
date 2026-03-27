import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class AuthRepository {
  final DioClient _api = DioClient();

  // Login İsteği
  Future<Response?> loginUser(String email, String password) async {
    try {
      final response = await _api.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      // Başarılıysa token döner, bu token'ı cihazda (Hive/SharedPrefs) saklamalısın.
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Register (Kayıt Ol) İsteği
  Future<Response?> registerUser(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await _api.dio.post(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
