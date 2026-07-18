import 'dart:math';

import 'package:get/get.dart';

class SayiController extends GetxController {
  Rx<int> randomSayi = 0.obs;

  void uret() {
    randomSayi.value = Random().nextInt(100);
  }

  @override
  void onInit() {
    super.onInit();
    print("SayiController initialized");
  }

  @override
  void onClose() {
    print("SayiController disposed");
    super.onClose();
  }

  @override
  void onReady() {
    print("SayiController is ready");
    super.onReady();
  }
}
