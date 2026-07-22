import 'package:gelir_gider_app/modules/transaction/controllers/transaction_controller.dart';
import 'package:get/get.dart';

class TransactionBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionController>(() => TransactionController());
  }
}
