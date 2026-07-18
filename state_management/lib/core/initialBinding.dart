import 'package:get/get.dart';
import 'package:state_management/services/sharedPreferences_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() async {
    await Get.putAsync(() async {
      print("SharedPreferencesService initialized");
      var service = SharedPreferencesService();
      await service.init();
      print("SharedPreferencesService is ready");
      return service;
    });

    print("InitialBinding dependencies completed");
    print("Waiting for 3 seconds before proceeding...");
    await Future.delayed(Duration(seconds: 3));
    print("Proceeding after 3 seconds delay");
    Get.offAllNamed("/home");
  }
}
