import 'package:get/get.dart';
import 'package:state_management/home_page/sayac_controller.dart';
import 'package:state_management/home_page/sayi_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SayiController());
    Get.put(SayacController());
  }
}
