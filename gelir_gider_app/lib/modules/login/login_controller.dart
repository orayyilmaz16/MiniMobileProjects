import 'package:gelir_gider_app/core/base_controller.dart';
import 'package:gelir_gider_app/routes/app_pages.dart';
import 'package:gelir_gider_app/services/auth_service.dart';
import 'package:get/get.dart';

class LoginController extends BaseController {
  late final AuthService _authService;

  @override
  void onInit() {
    super.onInit();
    _authService = Get.find<AuthService>();
  }

  googleIleGirisYap() async {
    final user = await _authService.signInWithGoogle();
    if (user != null) {
      Get.offAllNamed(AppRoutes.HOME);
    } else {
      Get.snackbar('Hata', 'Giriş yapılamadı. Lütfen tekrar deneyin.');
    }
  }
}
