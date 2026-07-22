import 'package:flutter/material.dart';
import 'package:gelir_gider_app/utils/icon_helper.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:intl/intl.dart';

import '../../../themes/app_colors.dart';
import '../dashboard_controller.dart';

class TransactionList extends GetView<DashboardController> {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.myTransactions.isEmpty) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTiffanyBlue.withAlpha(128)
                        : AppColors.tiffanyBlue.withAlpha(128),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Henüz kayıtlı bir transaction yok",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return Card(
        shape: BeveledRectangleBorder(),
        child: ListView.separated(
          itemBuilder: (context, index) {
            var oankiTransaction = controller.myTransactions[index];
            var category = oankiTransaction.category;
            return Dismissible(
              key: ValueKey(oankiTransaction.id),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                controller.deleteTransactions(oankiTransaction.id!);
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              child: ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? (oankiTransaction.type == 'income')
                              ? AppColors.darkIncome.withAlpha(25)
                              : AppColors.darkExpense.withAlpha(25)
                        : (oankiTransaction.type == 'income')
                        ? AppColors.income.withAlpha(25)
                        : AppColors.expense.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    getCategoryIcon(
                      iconName: category!.icon!,
                      isSystem: true,
                      type: category.type!,
                    ),
                    color: oankiTransaction.type == 'income'
                        ? (Theme.of(context).brightness == Brightness.dark)
                              ? AppColors.darkIncome
                              : AppColors.income
                        : (Theme.of(context).brightness == Brightness.dark)
                        ? AppColors.darkExpense
                        : AppColors.expense,
                  ),
                ),
                title: Text(category.name!),
                subtitle: Text(oankiTransaction.description!),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${oankiTransaction.type == 'income' ? '+' : '-'} ${NumberFormat.currency(symbol: '₺', decimalDigits: 2).format(double.parse(oankiTransaction.amount!))}',
                      style: TextStyle(
                        color: oankiTransaction.type == 'income'
                            ? (Theme.of(context).brightness == Brightness.dark)
                                  ? AppColors.darkIncome
                                  : AppColors.income
                            : (Theme.of(context).brightness == Brightness.dark)
                            ? AppColors.darkExpense
                            : AppColors.expense,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy').format(oankiTransaction.date!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (context, index) {
            return Divider(height: 1);
          },
          itemCount: controller.myTransactions.length,
        ),
      );
    });
  }
}
