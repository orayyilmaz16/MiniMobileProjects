import 'package:get/get.dart';

class SayacController extends GetxController {
  int sayac = 0;
  void arttir() {
    sayac++;
    update();
  }
}
