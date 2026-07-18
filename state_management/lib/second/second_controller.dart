import 'package:get/get.dart';

class SecondController extends GetxController {
  var name = "oray".obs;
  @override
  void onInit() {
    super.onInit();
    print("SecondController initialized");
  }

  void degistir() {
    name.value = "oray2";
  }
}
