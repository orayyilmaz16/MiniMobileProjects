import 'package:flutter/material.dart';
import 'package:gelir_gider_app/core/base_controller.dart';
import 'package:gelir_gider_app/models/app_category.dart';
import 'package:gelir_gider_app/models/transaction_params.dart';
import 'package:gelir_gider_app/modules/dashboard/dashboard_controller.dart';
import 'package:gelir_gider_app/repositories/category_repository.dart';
import 'package:gelir_gider_app/repositories/transaction_repository.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:get/state_manager.dart';

class TransactionController extends BaseController {
  final CategoryRepository _categoryRepository = Get.find<CategoryRepository>();
  final TransactionRepository _transactionRepository =
      Get.find<TransactionRepository>();

  final categories = <AppCategory>[].obs;
  final selectedCategoryId = "".obs;
  final transactionType = 'expense'.obs;
  final formKey = GlobalKey<FormState>();
  final amount = 0.0.obs;
  final description = "".obs;
  final date = DateTime.now().obs;

  @override
  void onInit() async {
    super.onInit();
    loadCategories();

    ever(transactionType, (callback) {
      getFirstCategory();
    });
  }

  Future createTransaction() async {
    try {
      setLoading(true);
      if (!formKey.currentState!.validate()) return null;
      final transaction = Transaction(
        id: '',
        amount: amount.value,
        description: description.value,
        type: transactionType.value,
        date: date.value,
        categoryId: selectedCategoryId.value,
        userId: '',
      );
      var result = await _transactionRepository.createTransaction(transaction);
      print(result.id);
      if (result.id != null) {
        await Get.find<DashboardController>().refreshDashboard();
        Get.back();

        showSuccessSnackbar(message: 'Transaction eklendi');
      }
    } catch (e) {
      showErrorSnackbar(message: 'Transaction eklenirken hata çıktı');
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadCategories() async {
    setLoading(true);
    try {
      final result = await _categoryRepository.getCategories();

      categories.value = result;

      getFirstCategory();
    } catch (e) {
      showErrorSnackbar(message: e.toString());
    } finally {
      setLoading(false);
    }
  }

  void getFirstCategory() {
    final filteredCategories = categories
        .where((category) => category.type == transactionType.value)
        .toList();
    if (filteredCategories.isNotEmpty) {
      selectedCategoryId.value = filteredCategories.first.id!;
    } else {
      selectedCategoryId.value = '';
    }
  }

  void clearForm() {
    amount.value = 0.0;
    description.value = '';
    date.value = DateTime.now();
    transactionType.value = 'expense';
    selectedCategoryId.value = '';
  }
}
