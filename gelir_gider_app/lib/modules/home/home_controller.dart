import 'package:gelir_gider_app/core/base_controller.dart';
import 'package:gelir_gider_app/routes/app_pages.dart';
import 'package:gelir_gider_app/services/auth_service.dart';
import 'package:get/get.dart';

class HomeController extends BaseController {
  final currentIndex = 0.obs;

  changePage(int index) {
    currentIndex.value = index;
  }

  cikisYap() async {
    await Get.find<AuthService>().signOut();
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  void goToTransaction() {
    Get.toNamed(AppRoutes.TRANSACTION);
  }
}
