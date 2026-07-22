import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gelir_gider_app/modules/dashboard/widgets/summary_card.dart';
import 'package:gelir_gider_app/themes/app_colors.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import 'dashboard_controller.dart';
import 'widgets/transaction_list.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => controller.isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Obx(
                      () => ListView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        children: [
                          SummaryCard(
                            title: "Aylık Gelir",
                            amount: controller.aylikGelir.value,
                            icon: Icons.arrow_upward,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.darkIncome
                                    : AppColors.income,
                            gradientColors:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.darkIncomeGradient
                                    : AppColors.incomeGradient,
                          ),
                          SummaryCard(
                            title: "Aylık Gider",
                            amount: controller.aylikGider.value,
                            icon: Icons.arrow_downward,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.darkExpense
                                    : AppColors.expense,
                            gradientColors:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.darkExpenseGradient
                                    : AppColors.expenseGradient,
                          ),
                          SummaryCard(
                            isaretGosterilsinMi: true,
                            title: "Aylık Bakiye",
                            amount: (controller.aylikGelir.value -
                                controller.aylikGider.value),
                            icon: Icons.account_balance_wallet,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.darkBalance
                                    : AppColors.balance,
                            gradientColors:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.darkBalanceGradient
                                    : AppColors.balanceGradient,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TransactionList(),
                    flex: 9,
                  ),
                ],
              ),
      ),
    );
  }
}
