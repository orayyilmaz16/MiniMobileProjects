import 'package:gelir_gider_app/modules/dashboard/dashboard_controller.dart';
import 'package:gelir_gider_app/modules/home/home_controller.dart';
import 'package:gelir_gider_app/modules/profile/profile_controller.dart';
import 'package:get/get.dart';

class HomeBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<DashboardController>(() => DashboardController());
  }
}
