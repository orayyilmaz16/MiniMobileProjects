import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/logger.dart';

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false); // false = giriş yapılmadı

  Future<void> login(String email, String password) async {
    try {
      // Burada normalde AuthRepository üzerinden Data katmanına istek atılır.
      logger.i("Login isteği atılıyor: $email");
      await Future.delayed(const Duration(seconds: 2)); // Sahte gecikme

      // Başarılı giriş
      state = true;
      logger.i("Giriş başarılı!");
    } catch (e) {
      logger.e("Giriş hatası: $e");
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      // Burada normalde AuthRepository üzerinden Data katmanına istek atılır.
      logger.i("Kayıt isteği atılıyor: $email");
      await Future.delayed(const Duration(seconds: 2)); // Sahte gecikme

      // Başarılı kayıt
      state = true;
      logger.i("Kayıt başarılı!");
    } catch (e) {
      logger.e("Kayıt hatası: $e");
    }
  }

  Future<void> logout() async {
    state = false;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier();
});
