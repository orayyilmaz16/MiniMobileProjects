import 'package:gelir_gider_app/repositories/category_repository.dart';
import 'package:gelir_gider_app/repositories/transaction_repository.dart';
import 'package:gelir_gider_app/services/api_service.dart';
import 'package:gelir_gider_app/services/auth_service.dart';
import 'package:gelir_gider_app/services/storage_service.dart';
import 'package:gelir_gider_app/services/theme_service.dart';
import 'package:get/get.dart';

class AppBindings extends Bindings {
  @override
  Future<void> dependencies() async {
    await Get.putAsync(() async {
      final service = StorageService();
      await service.init();
      return service;
    });

    Get.put(ThemeService());

    await Get.putAsync<ApiService>(() async {
      final service = ApiService();
      await service.init();
      return service;
    });

    await Get.putAsync(() async {
      final service = AuthService();
      await service.init();
      return service;
    });

    Get.put(CategoryRepository());
    Get.put(TransactionRepository());
  }
}
