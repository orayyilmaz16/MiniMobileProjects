import 'package:flutter/material.dart';
import 'package:gelir_gider_app/models/app_category.dart';
import 'package:gelir_gider_app/modules/transaction/widgets/add_category_dialog.dart';
import 'package:gelir_gider_app/modules/transaction/widgets/amount_input.dart';
import 'package:gelir_gider_app/modules/transaction/widgets/category_dropdown.dart';
import 'package:gelir_gider_app/modules/transaction/widgets/date_input.dart';
import 'package:gelir_gider_app/modules/transaction/widgets/description_input.dart';
import 'package:gelir_gider_app/modules/transaction/widgets/save_button.dart';
import 'package:gelir_gider_app/modules/transaction/widgets/transaction_type_selector.dart';
import 'package:gelir_gider_app/themes/app_colors.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import 'controllers/transaction_controller.dart';

class TransactionPage extends GetView<TransactionController> {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Islem Ekle")),
      body: Obx(
        () => controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TransactionTypeSelector(),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: CategoryDropDown()),
                          IconButton(
                            onPressed: () async {
                              final category = await Get.dialog<AppCategory>(
                                AddCategoryDialog(),
                              );
                              if (category != null) {
                                await controller.loadCategories();
                                controller.selectedCategoryId.value =
                                    category.id!;
                              }
                            },
                            icon: Icon(Icons.add_circle_outline),
                            color: AppColors.darkTiffanyBlue,
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      AmountInput(),
                      SizedBox(height: 16),
                      DescriptionInput(),
                      SizedBox(height: 16),
                      DateInput(),
                      SizedBox(height: 16),
                      SaveButton(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
