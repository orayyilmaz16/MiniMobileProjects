import 'package:flutter/material.dart';
import 'package:gelir_gider_app/core/base_controller.dart';
import 'package:gelir_gider_app/models/app_transaction.dart';
import 'package:gelir_gider_app/repositories/transaction_repository.dart';
import 'package:get/get.dart';

class DashboardController extends BaseController {
  late final TransactionRepository _transactionRepository;
  final myTransactions = <AppTransaction>[].obs;

  final aylikGelir = 0.0.obs;
  final aylikGider = 0.0.obs;

  void aylikOzet() {
    aylikGelir.value = 0;
    aylikGider.value = 0;
    var simdikiTarih = DateTime.now();
    var oankiYil = simdikiTarih.year;
    var oankiAy = simdikiTarih.month;

    if (myTransactions.isNotEmpty) {
      var filteredTransaction = myTransactions
          .where(
            (transaction) =>
                transaction.date!.year == oankiYil &&
                transaction.date!.month == oankiAy,
          )
          .toList();

      for (var tr in filteredTransaction) {
        if (tr.type == 'income') {
          aylikGelir.value += double.parse(tr.amount!);
        } else {
          aylikGider.value += double.parse(tr.amount!);
        }
      }
    } else {
      aylikGelir.value = 0;
      aylikGider.value = 0;
    }

    debugPrint("aylik gelir $aylikGelir gider : $aylikGider");
  }

  @override
  void onInit() async {
    super.onInit();
    _transactionRepository = Get.find<TransactionRepository>();
    await getTransactions();
  }

  Future<void> refreshDashboard() async {
    await getTransactions();
  }

  Future getTransactions() async {
    try {
      setLoading(true);
      final transactions = await _transactionRepository.getTransactions();
      myTransactions.value = transactions;
      aylikOzet();
    } catch (e) {
      showErrorSnackbar(message: "Veriler getirilirken hata olustu");
    } finally {
      setLoading(false);
    }
  }

  Future<void> deleteTransactions(String id) async {
    try {
      // setLoading(true);
      final transactionResult =
          await _transactionRepository.deleteTransaction(id);
      if (transactionResult) {
        myTransactions.removeWhere(
          (element) => element.id == id,
        );
        aylikOzet();
        showSuccessSnackbar(message: "Transaction silindi");
      } else {
        showErrorSnackbar(message: "Transaction silinemedi");
      }
    } catch (e) {
      showErrorSnackbar(message: "Transaction silinemedi $e");
    } finally {
      // setLoading(false);
    }
  }
}
