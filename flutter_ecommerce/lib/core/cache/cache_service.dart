import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger.dart';

class CacheService {
  final SharedPreferences _prefs;

  CacheService(this._prefs);

  // Token İşlemleri
  Future<void> saveToken(String token) async {
    await _prefs.setString('auth_token', token);
    logger.i("🔑 Token cihaza kaydedildi.");
  }

  String? getToken() {
    return _prefs.getString('auth_token');
  }

  Future<void> clearCache() async {
    await _prefs.clear();
    logger.w("🗑️ Tüm önbellek temizlendi.");
  }
}

// Uygulama başlarken override edilecek Provider
final cacheServiceProvider = Provider<CacheService>((ref) {
  throw UnimplementedError('SharedPreferences henüz başlatılmadı');
});
